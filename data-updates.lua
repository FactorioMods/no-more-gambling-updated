local ore_washing = require("prototypes.ore-washing")

for name, item in pairs(data.raw['item']) do
	if name:find("-ore") or name == "scrap" then
		ore_washing.generate_washing_recipe(item)
	end
end
for name, drill in pairs(data.raw['mining-drill']) do
	ore_washing.disable_mining_drill_quality(drill)
end
for name, recipe in pairs(data.raw['recipe']) do
	-- Find Recipes for the Fabricator
	local num_liquids = 0
	for _, result in ipairs(recipe.ingredients or {}) do
		if result.type == "fluid" then
			num_liquids = num_liquids + 1
		end
	end
	local main_product = recipe.main_product or (recipe.results and recipe.results[1] and recipe.results[1].name)
	local main_product_prototype = main_product and data.raw.item[main_product] or data.raw.item[name] or (data.raw.tool and data.raw.tool[name]) -- This is missing equipment... but who cares.
	local fabricator_categories = "chemistry,chemistry-or-cryogenics,smelting,crafting,crafting-with-fluid,electronics,electronics-with-fluids,advanced-crafting,organic-or-assembling"
	local subgroup = recipe.subgroup or (main_product_prototype and main_product_prototype.subgroup) or "crafting"
	log(name.." -> "..(main_product or "???").." -> "..subgroup)
	local can_craft = recipe.results and recipe.results[1] and recipe.results[1].type == "item"
	can_craft = can_craft and num_liquids < 2
	can_craft = can_craft and (recipe.allow_productivity or subgroup == "terrain")
	can_craft = can_craft and subgroup ~= "science-pack" and subgroup ~= "fluid-recipes"
	can_craft = can_craft and subgroup ~= "vulcanus-processes" and subgroup ~= "uranium-processing" and subgroup ~= "aquilo-processes"
	local category_allowed = false
	for _, category in pairs(recipe.categories or {recipe.category or "crafting"}) do
	  if string.find(fabricator_categories, category, 1, true) then category_allowed = true end
	end
	can_craft = can_craft and category_allowed
	if can_craft then
		local cpy = table.deepcopy(recipe)
		cpy.name = name .. "-fabrication"
		cpy.categories = {"fabrication"}
		cpy.category = nil
		cpy.additional_categories = nil
		if recipe.localised_name == nil then
			cpy.localised_name = {"?", {"recipe-name." .. recipe.name}, {"item-name." .. (main_product or recipe.name)}, {"entity-name." .. (main_product or recipe.name)}, {"equipment-name." .. (main_product or recipe.name)}}
		end
		cpy.allow_decomposition = false
		cpy.hide_from_player_crafting = true
		cpy.hidden_in_factoriopedia = true
		cpy.hide_from_signal_gui = true
		if subgroup == "terrain" then
			cpy.subgroup = "terrain-fabrication"
		end
		data:extend({cpy})
	end
end