local category_blacklist, machine_blacklist = unpack(require("blacklists"))
local upcrafting = require("prototypes.upcrafting")

for name, category in pairs(data.raw['recipe-category']) do
	if not category_blacklist[name] then
		upcrafting.generate_crafting_category_variants(category)
	end
end
for name, recipe in pairs(data.raw['recipe']) do
	if not category_blacklist[recipe.category] then
		upcrafting.generate_recipe_variants(recipe)
	end
end
for name, entity in pairs(data.raw['assembling-machine']) do
	if not machine_blacklist[name] then
		upcrafting.generate_crafting_machine_variants(entity)
	end
end
for name, entity in pairs(data.raw['furnace']) do
	if not machine_blacklist[name] then
		upcrafting.generate_crafting_machine_variants(entity)
	end
end
for name, tech in pairs(data.raw['technology']) do
	upcrafting.technology_add_recipes(tech)
end

-- Apply Quality Curve
for name, quality in pairs(data.raw['quality']) do
	local depth = 0.0
	if quality.next == "epic" then
		while quality.next do
			depth = depth + 1.0
			quality.next_probability = quality.next_probability * math.pow(settings.startup["quality-epic-legendary-quality-curve"].value, depth)
			quality = data.raw['quality'][quality.next]
		end
		break
	end
end

local level_increase = settings.startup["quality-level-increase"].value
local level_increase_increase = settings.startup["quality-level-increase-increase"].value
local quality = data.raw['quality']['normal']
local depth = 0.0
local level = 0
if level_increase ~= 1.0 or level_increase_increase ~= 0.0 then
	while quality do
		depth = depth + 1.0
		quality.level = level
		level = math.floor(level + level_increase)
		level_increase = level_increase + level_increase_increase
		quality = data.raw['quality'][quality.next]
	end
end

for name, quality in pairs(data.raw['quality']) do
	upcrafting.quality_adjust_upgrade_chance(quality)
end


for name, mod in pairs(data.raw['module']) do
	upcrafting.module_adjust_upgrade_chance(mod)
end
require("transition-prototypes")
