-- Enhanced Vanilla
-- A 3Ra Gaming compilation
-- config and event must be required first.
require "util"
require "locale/utils/event"
require "config"
require "locale/utils/admin"
require "locale/utils/undecorator"
require "locale/utils/utils"
require "locale/utils/gravestone"
require "locale/utils/bot"
require "autodeconstruct"
require "announcements"
require "rocket"
require "bps"
require "tag"
require "autofill"
require "showhealth"
require "rso"

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


function check_name(function_name)
	for i,v in pairs(global.scenario.custom_functions) do
		if v.name == function_name:lower() then
			return i
		end
	end
	return false
end

function add_global_event(event, func, name)
	local p = game.player and game.player.print or print
	if not event then p("Missing event parameter") return end
	if not func then p("Missing function parameter") return end
	if not name then p("Missing name parameter") return end
	if check_name(name) then p("Function name \""..name.."\" already in use.") return end
	table.insert(global.scenario.custom_functions, {event = event, name = name, func = func})
	Event.register(event, func)
end

function remove_global_event(name)
	local reg = check_name(name)
	if reg then
		Event.remove(global.scenario.custom_functions[reg].event, global.scenario.custom_functions[reg].func)
		table.remove(global.scenario.custom_functions, reg)
	else
		game.print("Function with name \""..name.."\" not found")
	end
end

Event.register(-2, function()
	for i,v in pairs(global.scenario.custom_functions) do
		Event.register(v.event, v.func)
	end
end)

Event.register(defines.events.on_research_finished, function (event)
	local research = event.research
	research.force.recipes["logistic-chest-requester"].enabled=false
	research.force.recipes["logistic-chest-active-provider"].enabled=false
end)

-- Event handlers
Event.register(defines.events.on_player_created, player_joined)
Event.register(defines.events.on_player_respawned, player_respawned)
