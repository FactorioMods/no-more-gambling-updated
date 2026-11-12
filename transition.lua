local M={}
function M.original_name(name) return name:gsub('^nmg%-finish%-%-',''):gsub('^nmg%-drain%-%-','') end
function M.is_helper(entity) return entity.name:find('^nmg%-finish%-%-') or entity.name:find('^nmg%-drain%-%-') end
local function inventories(entity)
  return {entity.get_inventory(entity.type=='furnace' and defines.inventory.furnace_source or defines.inventory.crafter_input),entity.get_output_inventory(),entity.get_inventory(defines.inventory.crafter_trash)}
end
local function scalar(entity)
  return {direction=entity.direction,health=entity.health,energy=entity.energy,products_finished=entity.products_finished,
    bonus_progress=entity.bonus_progress,disabled_by_script=entity.disabled_by_script,
    operable=entity.operable,destructible=entity.destructible,minable_flag=entity.minable_flag,
    rotatable=entity.rotatable,recipe_locked=entity.recipe_locked,last_user=entity.last_user,
    custom_status=entity.custom_status}
end
local function restore(entity,state,temporary)
  for key,value in pairs(state) do
    if key~='custom_status' then entity[key]=value end
  end
  entity.custom_status=state.custom_status
  if temporary then
    entity.operable=false;entity.minable_flag=false;entity.destructible=false;entity.rotatable=false
    entity.recipe_locked=true
    entity.custom_status={diode=defines.entity_status_diode.yellow,label={'no-more-gambling.finishing-craft'}}
  end
end
local function take_fluids(entity,transaction)
  for index=1,entity.fluids_count do
    local fluid=entity.get_fluid(index)
    if fluid then
      local removed=entity.remove_fluid(index,fluid.amount)
      assert(removed and math.abs(removed.amount-fluid.amount)<0.00001,'No More Gambling: fluid extraction failed')
      transaction.fluids[#transaction.fluids+1]={index=index,name=removed.name,amount=removed.amount,temperature=removed.temperature}
    end
  end
end
local function take_items(entity,transaction)
  local bags=inventories(entity)
  for kind,inventory in pairs(bags) do
    for slot=1,#inventory do
      if inventory[slot].valid_for_read then
        local target,index=transaction.items.find_empty_stack()
        assert(target and target.transfer_stack(inventory[slot]),'No More Gambling: finite transition inventory full')
        transaction.item_kind[index]=kind
      end
    end
  end
end
local function replace(transaction,name,temporary)
  local old=transaction.entity
  local previous=scalar(old)
  -- minable_flag=false can create an overlapping empty machine instead of
  -- replacing the source. Require native invalidation of the actual source.
  old.minable_flag=true
  local new=old.surface.create_entity{name=name,position=old.position,direction=old.direction,
    quality=old.quality,force=old.force,fast_replace=true,spill=false,
    create_build_effect_smoke=false,raise_built=false}
  if not(new and new.valid) or old.valid then
    if new and new.valid and new~=old then new.destroy{raise_destroy=false} end
    if old.valid then old.minable_flag=previous.minable_flag end
    return false
  end
  transaction.entity=new
  restore(new,previous,temporary)
  return true
end
local function put_items(transaction,only_kind)
  local bags=inventories(transaction.entity)
  local remaining=false
  for slot=1,#transaction.items do
    local item=transaction.items[slot]
    if item.valid_for_read and (not only_kind or transaction.item_kind[slot]==only_kind) then
      local inventory=bags[transaction.item_kind[slot]]
      if inventory then
        for target=1,#inventory do
          if not item.valid_for_read then break end
          inventory[target].transfer_stack(item)
        end
      end
      if item.valid_for_read then remaining=true else transaction.item_kind[slot]=nil end
    end
  end
  return remaining
end
local function put_fluids(transaction)
  local entity=transaction.entity
  local remaining=false
  for _,fluid in ipairs(transaction.fluids) do
    if fluid.amount>0.000001 then
      local current=entity.get_fluid(fluid.index)
      local filter=entity.get_fluid_filter(fluid.index)
      if (not current or current.name==fluid.name) and (not filter or filter.name==fluid.name) then
        local occupied=current and current.amount or 0
        local amount=math.min(fluid.amount,math.max(0,entity.get_fluid_capacity(fluid.index)-occupied))
        if amount>0 then
          local temperature=(occupied*(current and current.temperature or 0)+amount*fluid.temperature)/(occupied+amount)
          local stored=entity.set_fluid(fluid.index,{name=fluid.name,amount=occupied+amount,temperature=temperature})
          assert(stored>=occupied-0.000001,'No More Gambling: fluid restoration reduced native contents')
          fluid.amount=fluid.amount-(stored-occupied)
        end
      end
      if fluid.amount>0.000001 then remaining=true end
    end
  end
  return remaining
end
local function dispose(transaction)
  if transaction.items and transaction.items.valid then transaction.items.destroy() end
end
function M.begin(entity,target,recipe,quality)
  storage.nmg_transitions=storage.nmg_transitions or {}
  local input,output,trash=table.unpack(inventories(entity))
  local transaction={entity=entity,state=scalar(entity),original=M.original_name(entity.name),
    target=target,recipe=recipe and recipe.name,quality=quality and quality.name or 'normal',
    fluids={},items=game.create_inventory((input and #input or 0)+2*(output and #output or 0)+(trash and #trash or 0)+8),
    item_kind={},stage='finish',surface=entity.surface,position=entity.position}
  -- Capture BEFORE replacement: disconnecting a fluid output can shrink its
  -- native buffer even when its same old recipe is retained.
  take_fluids(entity,transaction)
  take_items(entity,transaction)
  if not replace(transaction,'nmg-finish--'..entity.name,true) then
    put_items(transaction);put_fluids(transaction);dispose(transaction);return false
  end
  put_items(transaction,3)
  storage.nmg_transitions[transaction.entity.unit_number]=transaction
  return true
end
function M.tick(resolve_target,adjust_recipe)
  local transactions=storage.nmg_transitions
  if not transactions then return end
  for key,transaction in pairs(transactions) do
    local entity=transaction.entity
    if not entity.valid then
      -- External scripted destruction has the same inventory/fluid loss
      -- semantics as destroying a normal machine. Never duplicate its escrow.
      dispose(transaction);transactions[key]=nil
    elseif transaction.stage=='finish' then
      if entity.crafting_progress==0 then
        take_items(entity,transaction);take_fluids(entity,transaction)
        local target=resolve_target(entity,transaction.original)
        transaction.target=target
        if replace(transaction,'nmg-drain--'..target,true) then
          transactions[key]=nil;key=transaction.entity.unit_number;transactions[key]=transaction
          entity=transaction.entity
          if entity.type=='assembling-machine' and transaction.recipe then
            entity.set_recipe(adjust_recipe(transaction.recipe,target),transaction.quality)
            entity.direction=transaction.state.direction
          end
          transaction.stage='drain'
        end
      end
    else
      local items=put_items(transaction)
      local fluids=put_fluids(transaction)
      if not items and not fluids then
        -- Reconnect without changing the accepted new recipe or its paid work.
        take_items(entity,transaction)
        take_fluids(entity,transaction)
        if replace(transaction,transaction.target,false) then
          assert(not put_items(transaction), 'No More Gambling: final item restoration failed')
          assert(not put_fluids(transaction), 'No More Gambling: final fluid restoration failed')
          local final=transaction.entity
          local progress={energy=final.energy,bonus_progress=final.bonus_progress,products_finished=final.products_finished}
          restore(final,transaction.state,false)
          for field,value in pairs(progress) do final[field]=value end
          dispose(transaction);transactions[key]=nil
          local latest=resolve_target(final,transaction.original)
          if latest~=final.name then
            local recipe,quality=final.get_recipe()
            M.begin(final,latest,recipe,quality)
          end
        end
      end
    end
  end
end
return M
