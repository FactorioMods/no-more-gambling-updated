-- Base recipe renames supplied by the engine and current maintained mods.
-- Native migrations also cover their generated variants; transaction recipe
-- names are strings inside storage and therefore need the same translation.
local names={
  ["bre-roboport-mk2"]="BRE-roboport-mk2",
  ["bre-roboport-mk2-recycling"]="BRE-roboport-mk2-recycling",
  ["bre-roboport-mk3"]="BRE-roboport-mk3",
  ["bre-roboport-mk3-recycling"]="BRE-roboport-mk3-recycling",
  ["engine-speed-equipment"]="speed-booster-equipment-1",
  ["heli-item-recycling"]="helicopter-recycling",
  ["heli-pad-item-recycling"]="helicopter-pad-recycling",
  ["heli-pad-recipe"]="helicopter-pad",
  ["heli-recipe"]="helicopter",
  ["heli-remote-equipment-recycling"]="helicopter-remote-equipment-recycling",
  ["heli-remote-recipe"]="helicopter-remote-equipment",
  ["item-bre-roboport-mk2-incineration"]="item-BRE-roboport-mk2-incineration",
  ["item-bre-roboport-mk3-incineration"]="item-BRE-roboport-mk3-incineration",
  ["item-heli-pad-item-incineration"]="item-helicopter-pad-incineration",
  ["item-heli-remote-equipment-incineration"]="item-helicopter-remote-equipment-incineration",
  ["molten-copper"]="copper-ore-melting",
  ["molten-iron"]="iron-ore-melting",
  ["wood-processing"]="tree-seed",
  ["wood-processing-fabrication"]="tree-seed-fabrication",
}

local M={}
function M.recipe(name)
  local base=name:gsub("%-upcrafting%-%d+",""):gsub("%-RS$","")
  return names[base] and names[base]..name:sub(#base+1) or name
end

function M.migrate_pending(transactions)
  for _,transaction in pairs(transactions or {}) do
    if transaction.recipe then transaction.recipe=M.recipe(transaction.recipe) end
  end
end
return M
