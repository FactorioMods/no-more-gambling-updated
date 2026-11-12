-- Two native machine forms: finish exactly the already paid craft, then feed
-- the new recipe while its finite original fluid buffers are restored.
local additions={}
for _,kind in ipairs{'assembling-machine','furnace'} do
  for name,prototype in pairs(data.raw[kind]) do
    if not name:find('^nmg%-') then
      for _,stage in ipairs{'finish','drain'} do
        local helper=table.deepcopy(prototype)
        helper.name='nmg-'..stage..'--'..name
        helper.hidden=true
        helper.next_upgrade=nil
        helper.placeable_by=nil
        helper.flags=helper.flags or {}
        table.insert(helper.flags,'not-blueprintable')
        if stage=='finish' then table.insert(helper.flags,'no-automated-item-insertion') end
        for _,box in pairs(helper.fluid_boxes or {}) do
          if stage=='finish' or box.production_type~='output' then box.pipe_connections={} end
        end
        additions[#additions+1]=helper
      end
    end
  end
end
data:extend(additions)
