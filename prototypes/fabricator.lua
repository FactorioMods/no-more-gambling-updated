local assembler_pictures = require("__base__.prototypes.entity.assembler-pictures")
require("__base__.prototypes.entity.pipecovers")
require("circuit-connector-sprites")
local sounds = require("__base__.prototypes.entity.sounds")
local item_sounds = require("__base__.prototypes.item_sounds")

local categories = {"fabrication"}
for i, str in ipairs(categories) do
    categories[i] = str .. "-upcrafting-1"
end
log(serpent.block(categories))

data:extend
({
	{
		type = "recipe-category",
		name = "fabrication"
	},
	{
		type = "item-subgroup",
		name = "terrain-fabrication",
		group = "intermediate-products",
		order = "i"
	},
	{
		type = "technology",
		name = "component-fabricator",
		icon = "__no-more-gambling-updated__/graphics/technology/fabricator.png",
		icon_size = 256,
		effects =
		{
		  {
			type = "unlock-recipe",
			recipe = "fabricator"
		  },
		  {
			type = "unlock-quality",
			quality = "uncommon"
		  }
		},
		prerequisites = { "automation-2" },
		unit =
		{
		  count = 50,
		  ingredients =
		  {
			{ "automation-science-pack", 1 },
			{ "logistic-science-pack", 1 }
		  },
		  time = 15
		},
		upgrade = true
	},
	{
		type = "item",
		name = "fabricator",
		icon = "__no-more-gambling-updated__/graphics/icons/precision-fabricator.png",
		subgroup = "production-machine",
		order = "c[assembling-machine-9-precision-fabricator]",
		inventory_move_sound = item_sounds.mechanical_inventory_move,
		pick_sound = item_sounds.mechanical_inventory_pickup,
		drop_sound = item_sounds.mechanical_inventory_move,
		place_result = "fabricator",
		stack_size = 50,
		weight = 40 * kg,
	},
	{
		type = "recipe",
		name = "fabricator",
		ingredients =
		{
		  {type = "item", name = "electronic-circuit", amount = 30},
		  {type = "item", name = "assembling-machine-2", amount = 2}
		},
		results = {{type="item", name="fabricator", amount=1}},
		energy_required = 3,
		enabled = false
	},
	{
		type = "assembling-machine",
		name = "fabricator",
		icon = "__no-more-gambling-updated__/graphics/icons/precision-fabricator.png",
		flags = {"placeable-neutral", "placeable-player", "player-creation"},
		minable = {mining_time = 0.2, result = "fabricator"},
		max_health = 400,
		corpse = "medium-remnants",
		dying_explosion = "assembling-machine-3-explosion",
		icon_draw_specification = {shift = {0, -0.3}},
		circuit_wire_max_distance = assembling_machine_circuit_wire_max_distance,
		circuit_connector = circuit_connector_definitions["assembling-machine"],
		alert_icon_shift = util.by_pixel(0, -12),
		resistances =
		{
		  {
			type = "fire",
			percent = 70
		  }
		},
		fluid_boxes =
		{
		  {
			production_type = "input",
			pipe_picture = table.deepcopy(assembler_pictures.assembler3pipepictures),
			pipe_covers = pipecoverspictures(),
			volume = 1000,
			pipe_connections = {{ flow_direction="input", direction = defines.direction.north, position = {0, -1} }},
			secondary_draw_orders = { north = -1 }
		  },
		  {
			production_type = "output",
			pipe_picture = table.deepcopy(assembler_pictures.assembler3pipepictures),
			pipe_covers = pipecoverspictures(),
			volume = 1000,
			pipe_connections = {{ flow_direction="output", direction = defines.direction.south, position = {0, 1} }},
			secondary_draw_orders = { north = -1 }
		  }
		},
		fluid_boxes_off_when_no_fluid_recipe = true,
		open_sound = sounds.machine_open,
		close_sound = sounds.machine_close,
		impact_category = "metal",
		working_sound =
		{
		  sound = { filename = "__base__/sound/assembling-machine-t3-1.ogg", volume = 0.45 },
		  audible_distance_modifier = 0.5,
		  fade_in_ticks = 4,
		  fade_out_ticks = 20
		},
		collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
		selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
		drawing_box_vertical_extension = 0.2,
		fast_replaceable_group = "fabricator",
		graphics_set =
		{
		  animation_progress = 0.5,
		  animation =
		  {
			layers =
			{
			  {
				filename = "__no-more-gambling-updated__/graphics/entity/precision-fabricator/precision-fabricator.png",
				priority = "high",
				width = 214,
				height = 237,
				frame_count = 32,
				line_length = 8,
				shift = util.by_pixel(0, -0.75),
				scale = 0.5
			  },
			  {
				filename = "__no-more-gambling-updated__/graphics/entity/precision-fabricator/precision-fabricator-shadow.png",
				priority = "high",
				width = 260,
				height = 162,
				frame_count = 32,
				line_length = 8,
				draw_as_shadow = true,
				shift = util.by_pixel(28, 4),
				scale = 0.5
			  }
			}
		  }
		},
	
		crafting_categories = categories,
		crafting_speed = 1.25,
		effect_receiver = { base_effect = { quality = 5.0, productivity = 0.25 }},
		energy_source =
		{
		  type = "electric",
		  usage_priority = "secondary-input",
		  emissions_per_minute = { pollution = 2 }
		},
		energy_usage = "400kW",
		module_slots = 3,
		allowed_effects = {"consumption", "speed", "productivity", "pollution", "quality"},
		allowed_module_categories = {"productivity", "speed", "efficiency", "quality"}
	  }
})
