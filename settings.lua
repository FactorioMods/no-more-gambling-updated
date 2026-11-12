data:extend({
    {
        type = "bool-setting",
        name = "no-more-gambling-limit-collector-range-to-legendary",
        setting_type = "startup",
        default_value = true,
        order = "i"
    },
    {
        type = "double-setting",
        name = "quality-cost-increase",
        setting_type = "startup",
        minimum_value = 0.25,
        default_value = 2.25,
		allowed_values = {0.25, 0.5, 1.0, 1.75, 2.25, 3.5, 4.75, 6.0, 8.0, 12.0, 16.0},
		order = "a"
    },
    {
        type = "double-setting",
        name = "quality-crafting-time-increase",
        setting_type = "startup",
        minimum_value = 0.0,
        default_value = 0.0,
		allowed_values = {0.0, 0.1, 0.25, 0.5, 1.0, 1.5, 2.0, 3.0, 4.0, 8.0},
		order = "b"
    },
	{
        type = "int-setting",
        name = "quality-module-cap",
        setting_type = "startup",
        minimum_value = 4,
        default_value = 4,
		allowed_values = {4, 6, 8, 10, 20},
		order = "c"
    },
	{
		type = "bool-setting",
		name = "speed-module-dont-affect-quality",
		setting_type = "startup",
        default_value = true,
		order = "d"
	},
	{
        type = "double-setting",
        name = "quality-skip-chance",
        setting_type = "startup",
        minimum_value = 0.0025,
        default_value = 0.01,
		allowed_values = {0.0025, 0.005, 0.01, 0.02, 0.04, 0.1},
		order = "e"
    },
	{
        type = "double-setting",
        name = "quality-epic-legendary-quality-curve",
        setting_type = "startup",
        minimum_value = 0.2,
        default_value = 0.75,
		allowed_values = {0.2, 0.4, 0.5, 0.6, 0.75, 0.8, 1.0},
		order = "f"
    },
	{
        type = "int-setting",
        name = "quality-level-increase",
        setting_type = "startup",
        minimum_value = 1,
        default_value = 1,
		allowed_values = {1, 2, 3, 4, 5},
		order = "g"
    },
	{
        type = "double-setting",
        name = "quality-level-increase-increase",
        setting_type = "startup",
        minimum_value = 0.0,
        default_value = 0.0,
		allowed_values = {0.0, 0.25, 0.35, 0.4, 0.5, 0.75, 1.0, 1.5, 2.0},
		order = "h"
    },
	{
        type = "int-setting",
        name = "no-more-gambling-scan-chunks-per-second",
        setting_type = "runtime-global",
        minimum_value = 1,
		maximum_value = 10000,
        default_value = 250,
		order = "a"
    }
})