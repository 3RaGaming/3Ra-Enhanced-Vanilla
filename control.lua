-- Enhanced Vanilla
-- A 3Ra Gaming compilation
if not scenario then scenario = {} end
if not scenario.config then scenario.config = {} end
-- config and event must be required first.
require "util"
require "config"
require "locale/utils/event"
require "locale/utils/admin"
require "locale/utils/undecorator"
require "locale/utils/utils"
require "locale/utils/gravestone"
require "autodeconstruct"
require "announcements"
require "rocket"
require "bps"
require "tag"
require "autofill"
require "showhealth"
require "locale/mapsettings/spiral"

-- Give player starting items.
-- @param event on_player_joined event
function player_joined(event)
	local player = game.players[event.player_index]
	player.insert { name = "iron-plate", count = 8 }
	player.insert { name = "pistol", count = 1 }
	player.insert { name = "firearm-magazine", count = 20 }
	player.insert { name = "burner-mining-drill", count = 2 }
	player.insert { name = "stone-furnace", count = 2 }
end

-- Give player weapons after they respawn.
-- @param event on_player_respawned event
function player_respawned(event)
	local player = game.players[event.player_index]
	player.insert { name = "pistol", count = 1 }
	player.insert { name = "firearm-magazine", count = 10 }
end

Event.register(defines.events.on_research_finished, function (event)
	local research = event.research

	research.force.recipes["logistic-chest-requester"].enabled=false
	research.force.recipes["logistic-chest-active-provider"].enabled=false
end)

-- Event handlers
Event.register(defines.events.on_player_created, player_joined)
Event.register(defines.events.on_player_respawned, player_respawned)
