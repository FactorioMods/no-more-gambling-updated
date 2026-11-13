local function get_base(name)
	local result, _ = name:gsub("%-upcrafting%-%d+", "")
	return result
end

local function generate_upcrafting_recipe(recipe, n)
	local cost_factor = 1.0 + n * settings.startup["quality-cost-increase"].value
	local energy_factor = 1.0 + n * settings.startup["quality-crafting-time-increase"].value

	local recipe_map = {}
	local solid_product_found = false
	local solid_input_found = false
	local main_product = nil
	for k, v in pairs(recipe.ingredients) do
		if v.name ~= nil then
			recipe_map[v.name] = recipe_map[v.name] or {type = v.type, input = 0.0, expected_output = 0.0, output = 0.0, output_variance = 0.0, probability = 1.0}
			local map = recipe_map[v.name]
			map.input = map.input + v.amount
		end
	end
	for k,v in pairs(recipe.results) do
		if v.name ~= nil then
			recipe_map[v.name] = recipe_map[v.name] or {type = v.type, input = 0.0, expected_output = 0.0, output = 0.0, output_variance = 0.0, probability = 1.0}
			local map = recipe_map[v.name]
			if v.amount then
				map.output = map.output + v.amount
			elseif v.amount_min and v.amount_max then
				map.output = map.output + v.amount_min
				map.output_variance = map.output_variance + (v.amount_max - v.amount_min)
			end
			if v.extra_count_fraction then
				map.output = map.output + v.extra_count_fraction
			end
			if v.probability then
				map.probability = v.probability
			end
		end
	end

	local is_recycling = false
	for _, category in pairs(recipe.categories or {recipe.category}) do
		if category == "recycling" or category == "recycling-or-hand-crafting" then
			is_recycling = true
			break
		end
	end

	for k,v in pairs(recipe_map) do
		if is_recycling then
			v.expected_output = 0.25
		else
			v.expected_output = (v.output + v.output_variance) * v.probability
		end

		if v.type == "item" and (v.output > 0.0 or v.output_variance > 0.0) and main_product == nil then
			solid_product_found = true
			main_product = v.name
		end
		if v.type == "item" and v.input > 0.0 then
			solid_input_found = true
		end
	end

	main_product = recipe.main_product or main_product
	local main_product_prototype = main_product and data.raw.item[main_product]

	local cpy = table.deepcopy(recipe)
	cpy.name = recipe.name.."-upcrafting-"..n
	if recipe.localised_name == nil then
		cpy.localised_name = {"?", {"recipe-name." .. recipe.name}, {"item-name." .. (main_product or recipe.name)}, {"entity-name." .. (main_product or recipe.name)}, {"equipment-name." .. (main_product or recipe.name)}}
	end
	cpy.categories = {}
	for _, category in pairs(recipe.categories or {recipe.category or "crafting"}) do
	  table.insert(cpy.categories, get_base(category).."-upcrafting-"..n)
	end
	cpy.category = nil
	cpy.additional_categories = nil
	cpy.allow_decomposition = false
	cpy.hide_from_player_crafting = true
	cpy.hidden_in_factoriopedia = true
	cpy.hide_from_signal_gui = true

	local disable_recipe = false
	if solid_product_found == true then
		cpy.maximum_productivity = (recipe.maximum_productivity or 3.0) * cost_factor
		if cpy.ingredients == nil or #cpy.ingredients == 0 then
			local energy = (recipe.energy_required or 0.5)
			cpy.energy_required = energy + energy * (energy_factor - 1.0) + energy * (cost_factor - 1.0)
		else
			cpy.energy_required = (recipe.energy_required or 0.5) * energy_factor
			for i, item in ipairs(cpy.ingredients) do
				local amount = recipe_map[item.name].input + math.max(recipe_map[item.name].input - recipe_map[item.name].expected_output, 0.0) * (cost_factor - 1.0)
				local integerPart, fractionalPart = math.modf(amount)
				item.amount = math.max(integerPart, item.amount)
				if item.amount > 65535 then
					disable_recipe = true
				end
			end
		end
	end

	if disable_recipe then
		cpy.ingredients = table.deepcopy(recipe.ingredients or {})
		cpy.results = table.deepcopy(recipe.results or {})
		cpy.localised_description = {"quality-crafting-impossible", tostring(n)}
		cpy.allow_quality = false
	end
  
	data:extend(
		{cpy}
	)
end

local function generate_recipe_variants(recipe)
	if string.find(recipe.name, "upcraft") then
		return
	end

	if recipe.results == nil then
		log("Skipped "..recipe.name)
		return
	end

	local max = settings.startup["quality-module-cap"].value
	for n=1,max do
		generate_upcrafting_recipe(recipe, n)
	end
end

local function contains(arr, item)
    for i = 1, #arr do
        if arr[i] == item then
            return true
        end
    end
    return false
end

local function generate_crafting_machine_variants(entity)
	if string.find(entity.name, "upcraft") then
		return
	end

	-- Make sure to scale quality so that other mods keep working (not used in vanilla)
	if entity and entity.effect_receiver and entity.effect_receiver.base_effect and entity.effect_receiver.base_effect.quality then
		entity.effect_receiver.base_effect.quality = entity.effect_receiver.base_effect.quality * (0.1 / settings.startup["quality-skip-chance"].value)
	end

	-- Mod Compatibility: Some mods use crafting machines for weird things. If it can't use modules, don't create variants.
	if entity.effect_receiver and entity.uses_module_effects ~= nil and entity.uses_module_effects == false then return end
	if entity.allowed_effects and contains(entity.allowed_effects, "quality") == false then return end
	if entity.allowed_module_categories and contains(entity.allowed_module_categories, "quality") == false then return end
	if entity.module_slots == nil or entity.module_slots == 0 then return end

	-- We need to scan all items to find out what can place the base entity
	local placeable_by = {}
	local hash_set = {}
	-- Import the Placeable By from the base entity
	-- Single Item
	if entity.placeable_by and entity.placeable_by[1] == nil then
		table.insert(placeable_by, {item = entity.placeable_by, count = 1})
		hash_set[placeable_by] = true
	-- Array
	elseif entity.placeable_by and entity.placeable_by[1] ~= nil then
		placeable_by = table.deepcopy(entity.placeable_by)
		for i=1, #placeable_by do
			hash_set[placeable_by[i].item] = true
		end
	end
	-- Finally: Scan items
	for _, item in pairs(data.raw.item) do
		if item.place_result == entity.name and hash_set[item.name] == nil then
			table.insert(placeable_by, {item = item.name, count = 1})
			hash_set[item.name] = true
		end
	end

	local base_module_count = 0

	local update_description = function(entity, n)
		local cost_increase = settings.startup['quality-cost-increase'].value * 100.0 * n
		local time_increase = settings.startup['quality-crafting-time-increase'].value * 100.0 * n
		entity.localised_description = { "", {"description.quality-cost-increase", tostring(cost_increase)} }
		if time_increase > 1.0 then
			entity.localised_description = { "", {"description.quality-cost-increase", tostring(cost_increase)}, "\n", {"description.quality-crafting-time-increase", tostring(time_increase)} }
		end
	end

	if entity.name == "fabricator" then
		base_module_count = 1
		update_description(entity, 1)
	end

	local max = settings.startup["quality-module-cap"].value
	for n=1+base_module_count,max do
		local cpy = table.deepcopy(entity)
		cpy.name = entity.name.."-upcrafting-"..n
		if entity.localised_name == nil then
			cpy.localised_name = {"entity-name." .. entity.name}
		end

		update_description(cpy, n)

		for i, category in ipairs(cpy.crafting_categories) do
			log(get_base(category))
			cpy.crafting_categories[i] = get_base(category).."-upcrafting-"..n
		end
		if cpy.fixed_recipe ~= nil then
			cpy.fixed_recipe = get_base(cpy.fixed_recipe).."-upcrafting-"..n
		end

		if #placeable_by >= 1 then
			cpy.placeable_by = placeable_by
		end
		cpy.deconstruction_alternative = entity.name
		cpy.hidden = true
		data:extend(
			{cpy}
		)
	end
end

local function generate_crafting_category_variants(category)
	if string.find(category.name, "upcraft") then
		return
	end

	local max = settings.startup["quality-module-cap"].value
	for n=1,max do
		local cpy = table.deepcopy(category)
		cpy.name = category.name.."-upcrafting-"..n
		if category.localised_name == nil then
			cpy.localised_name = {"recipe-category." .. category.name}
		end
		cpy.hidden = true
		data:extend(
			{cpy}
		)
	end
end

local function technology_add_recipes(technology)
	if technology.effects == nil then
		return
	end

	local old_effects = table.deepcopy(technology.effects)
	local max = settings.startup["quality-module-cap"].value
	technology.effects = {}
	for i, effect in ipairs(old_effects) do
		table.insert(technology.effects, effect)
		if effect.type == "unlock-recipe" then
			local base_recipe = effect.recipe
			for n=1,max do
				local name = base_recipe.."-upcrafting-"..n
				if data.raw['recipe'][name] then
					table.insert(technology.effects, {type = "unlock-recipe", recipe = name, hidden = true})
				end
				if data.raw['recipe'][base_recipe.."-fabrication-upcrafting-"..n] then
					table.insert(technology.effects, {type = "unlock-recipe", recipe = base_recipe.."-fabrication-upcrafting-"..n, hidden = true})
				end
			end
		end
		if effect.type == "change-recipe-productivity" then
			local base_recipe = effect.recipe
			for n=1,max do
				local name = base_recipe.."-upcrafting-"..n
				-- local cost_factor = 1.0 + settings.startup['quality-cost-increase'].value * n
				if data.raw['recipe'][name] then
					table.insert(technology.effects, {type = "change-recipe-productivity", recipe = name, change = effect.change, hidden = true})
				end
				if data.raw['recipe'][base_recipe.."-fabrication-upcrafting-"..n] then
					table.insert(technology.effects, {type = "change-recipe-productivity", recipe = name, change = effect.change, hidden = true})
				end
			end
		end
	end
end

local function quality_adjust_upgrade_chance(quality)
	if quality.next_probability then
		quality.next_probability = settings.startup["quality-skip-chance"].value * quality.next_probability / 0.1
	end
end

local function module_adjust_upgrade_chance(mod)
	if mod and mod.effect and mod.effect.quality then
		if mod.effect.quality < 0.0 and settings.startup["speed-module-dont-affect-quality"].value then
			mod.effect.quality = 0.0
		else
			mod.effect.quality = mod.effect.quality * (0.1 / settings.startup["quality-skip-chance"].value)
		end
	end
end

local lib = {}
lib.generate_recipe_variants = generate_recipe_variants
lib.generate_crafting_machine_variants = generate_crafting_machine_variants
lib.generate_crafting_category_variants = generate_crafting_category_variants
lib.module_adjust_upgrade_chance = module_adjust_upgrade_chance
lib.quality_adjust_upgrade_chance = quality_adjust_upgrade_chance
lib.technology_add_recipes = technology_add_recipes
return lib
