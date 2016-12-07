function loadResourceConfig()
	config = {}


	config["iron-ore"] = {
		type="resource-ore",

		-- general spawn params
		allotment=100, -- how common resource is
		spawns_per_region={min=1, max=1}, --number of chunks
		richness=18000,        -- resource_ore has only one richness value - resource-liquid has min/max

		size={min=20, max=30}, -- rough radius of area, too high value can produce square shaped areas
		min_amount=350,

		-- resource provided at starting location
		-- probability: 1 = 100% chance to be in starting area
		--              0 = resource is not in starting area
		starting={richness=8000, size=25, probability=1},

		multi_resource_chance=0.20, -- absolute value
		multi_resource={
			["iron-ore"] = 2, -- ["resource_name"] = allotment
			['copper-ore'] = 4,
			["coal"] = 4,
			["stone"] = 4,
		}
	}

	config["copper-ore"] = {
		type="resource-ore",

		allotment=100,
		spawns_per_region={min=1, max=1},
		richness=16000,
		size={min=20, max=30},
		min_amount=350,

		starting={richness=6000, size=25, probability=1},

		multi_resource_chance=0.20,
		multi_resource={
			["iron-ore"] = 4,
			['copper-ore'] = 2,
			["coal"] = 4,
			["stone"] = 4,
		}
	}

	config["coal"] = {
		type="resource-ore",

		allotment=80,

		spawns_per_region={min=1, max=1},
		size={min=15, max=25},
		richness=13000,
		min_amount=350,

		starting={richness=6000, size=20, probability=1},

		multi_resource_chance=0.30,
		multi_resource={
			["crude-oil"] = 1,
			["iron-ore"] = 3,
			['copper-ore'] = 3,
		}
	}

	config["stone"] = {
		type="resource-ore",

		allotment=60,
		spawns_per_region={min=1, max=1},
		richness=11000,
		size={min=15, max=20},
		min_amount=250,

		starting={richness=5000, size=16, probability=1},

		multi_resource_chance=0.30,
		multi_resource={
			["coal"] = 4,
			["iron-ore"] = 3,
			['copper-ore'] = 3,
		}
	}

	config["crude-oil"] = {
		type="resource-liquid",
		minimum_amount=10000,
		allotment=70,
		spawns_per_region={min=1, max=2},
		richness={min=10000, max=30000}, -- richness per resource spawn
		size={min=2, max=5},

		starting={richness=20000, size=2, probability=1},

		multi_resource_chance=0.20,
		multi_resource={
			["coal"] = 4,
		}
	}

	config["enemy-base"] = {
		type="entity",
		force="enemy",
		clear_range = {6, 6},

		spawns_per_region={min=2,max=4},
		size={min=2,max=4},
		size_per_region_factor=0.4,
		richness=1,

		absolute_probability=absolute_enemy_chance, -- chance to spawn in region
		probability_distance_factor=1.15, -- relative increase per region
		max_probability_distance_factor=3.0, -- absolute value

		along_resource_probability=0.20, -- chance to spawn in resource chunk anyway, absolute value. Can happen once per resource.

		sub_spawn_probability=0.3,     -- chance for this entity to spawn anything from sub_spawns table, absolute value
		sub_spawn_size={min=1, max=2}, -- in same chunk
		sub_spawn_distance_factor=1.04,
		sub_spawn_max_distance_factor=3,
		sub_spawns={
			["small-worm-turret"]={
				min_distance=2,
				allotment=200,
				allotment_distance_factor=0.9,
				clear_range = {2, 2},
			},
			["medium-worm-turret"]={
				min_distance=4,
				allotment=100,
				allotment_distance_factor=1.05,
				clear_range = {2, 2},
			},
			["big-worm-turret"]={
				min_distance=6,
				allotment=100,
				allotment_distance_factor=1.15,
				clear_range = {2, 2},
			}
		}
	}
	return config
end

debug_enabled = false
debug_items_enabled = false

region_size = 7	-- alternative mean to control how further away resources would be, default - 256 tiles or 8 chunks
-- each region is region_size*region_size chunks
-- each chunk is 32*32 tiles

use_donut_shapes = false		-- setting this to false will remove donuts from possible resource layouts

starting_area_size = 1         	-- starting area in regions, safe from random nonsense

absolute_resource_chance = 0.60 -- chance to spawn an resource in a region
starting_richness_mult = 1		-- multiply starting area richness for resources
global_richness_mult = 1		-- multiply richness for all resources except starting area
global_size_mult = 1			-- multiply size for all ores, doesn't affect starting area

absolute_enemy_chance = 0.25	-- chance to spawn enemies per sector (can be more then one base if spawned)
	enemy_base_size_multiplier = 1  -- all base sizes will be multiplied by this - larger number means bigger bases

	multi_resource_active = true			-- global switch for multi resource chances
	multi_resource_richness_factor = 0.60 	-- any additional resource is multiplied by this value times resources-1
	multi_resource_size_factor = 0.90
	multi_resource_chance_diminish = 0.6	-- diminishing effect factor on multi_resource_chance

	min_amount=250 					-- default value for minimum amount of resource in single pile

	richness_distance_factor=0.7 	-- exponent for richness distance factor calculation
	size_distance_factor=0.1	   	-- exponent for size distance factor calculation

	deterministic = true           	-- set to false to use system for all decisions  math.random

	-- mode is no longer used by generation process - it autodetects endless resources
	-- endless_resource_mode = false   -- if true, the size of each resource is modified by the following modifier. Use with the endless resources mod.
	endless_resource_mode_sizeModifier = 0.80

	disableEnemyExpansion = false		-- allows for disabling of in-game biter base building
	use_RSO_biter_spawning = true    	-- enables spawning of biters controlled by RSO mod - less enemies around with more space between bases
	use_vanilla_biter_spawning = false	-- enables using of vanilla spawning

	biter_ratio_segment=1      --the ratio components determining how many biters to spitters will be spawned
	spitter_ratio_segment=1    --eg. 1 and 1 -> equal number of biters and spitters,  10 and 1 -> 10 times as many biters to spitters

	useEnemiesInPeaceMod = false -- additional override for peace mod detection - when set to true it will spawn enemies normally, needs to have enemies enabled in peace mod

	useStraightWorldMod = false -- enables Straight World mod - actual mod code copied into RSO to make it compatible

	ignoreMapGenSettings = false -- stops the default behaviour of reading map gen settings

	fluidResourcesFactor = 20 -- temporary factor for calculation of resource %-ages for fluids

	useResourceCollisionDetection = true	-- enables avoidace calculations to reduce ores overlaping of each other
	resourceCollisionDetectionRatio = 0.8	-- at least this much of ore field needs to be placable to spawn it
	resourceCollisionFieldSkip = true		-- determines if ore field should be skipped completely if placement based on ratio failed



	return config
