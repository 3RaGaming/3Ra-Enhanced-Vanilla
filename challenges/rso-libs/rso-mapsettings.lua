local mapset = {
	["terrain_segmentation"] = "normal",
	["water"] = "normal",
	["autoplace_controls"] = {
		["coal"] = {
			["frequency"] = "normal",
			["size"] = "normal",
			["richness"] = "normal",
		},
		["copper-ore"] = {
			["frequency"] = "very-low",
			["size"] = "very-high",
			["richness"] = "normal",
		},
		["crude-oil"] = {
			["frequency"] = "low",
			["size"] = "high",
			["richness"] = "normal",
		},
		["enemy-base"] = {
			["frequency"] = "normal",
			["size"] = "normal",
			["richness"] = "normal",
		},
		["iron-ore"] = {
			["frequency"] = "very-low",
			["size"] = "very-high",
			["richness"] = "normal",
		},
		["stone"] = {
			["frequency"] = "normal",
			["size"] = "normal",
			["richness"] = "normal",
		},
	},
	["seed"] = 663454425,
	["shift"] = {
		["x"] = 1540,
		["y"] = 1302,
	},
	["width"] = 2000000,
	["height"] = 2000000,
	["starting_area"] = "normal",
	["peaceful_mode"] = false,
}
return mapset
