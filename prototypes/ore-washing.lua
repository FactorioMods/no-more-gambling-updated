local function generate_uprade_icons_from_item(item)
	local icons = {}
	if item.icons == nil then
		icons[#icons + 1] =
		{
			icon = item.icon,
			icon_size = item.icon_size,
		}
	else
		for i = 1, #item.icons do
			icons[#icons + 1] = item.icons[i]
		end
	end
	icons[#icons + 1] =
	{
		icon = "__no-more-gambling-updated__/graphics/icons/ore-washing.png"
	}
	return icons
end

local function generate_washing_recipe(item)
	local icons = generate_uprade_icons_from_item(item)
	local amount = 1
	data:extend({
		{
			type = "recipe",
			name = item.name .. "-washing",
			localised_name = {"", {"recipe-name.ore-washing"}, {"item-name."..item.name}},
			icon = nil,
			icons = icons,
			order = item.order,
			subgroup = "ore-washing",
			categories = {"chemistry"},
			enabled = true,
			allow_productivity = false,
			unlock_results = false,
			ingredients = {{type = "item", name = item.name, amount = 5}, {type = "fluid", name = "sulfuric-acid", amount = 2}, {type = "fluid", name = "water", amount = 2}},
			results = {{type = "item", name = item.name, amount_min = 2, amount_max = 3}, {type = "item", name = "stone", amount=0, extra_count_fraction = 0.05}, {type = "item", name = "coal", amount=0, extra_count_fraction = 0.05}},
			energy_required = 1.0,
			crafting_machine_tint =
			{
			  primary = {r = 0.633, g = 0.773, b = 1.000, a = 1.000}, -- #6ec5ffff
			  secondary = {r = 0.791, g = 0.856, b = 1.000, a = 1.000}, -- #96daffff
			  tertiary = {r = 0.581, g = 0.428, b = 0.436, a = 0.502}, -- #616d6f80
			  quaternary = {r = 0.699, g = 0.797, b = 0.793, a = 0.733}, -- #7fcbcabb
			}
		}
	})
end

local function disable_mining_drill_quality(drill)
	drill.allowed_effects = {"speed", "productivity", "consumption", "pollution"}
end

local lib = {}
lib.generate_washing_recipe = generate_washing_recipe
lib.disable_mining_drill_quality = disable_mining_drill_quality
return lib
