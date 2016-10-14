-- Enhanced Vanilla
-- A 3Ra Gaming compilation
if not scenario then scenario = {} end
if not scenario.config then scenario.config = {} end
-- config and event must be required first.
require "config"
require "locale/utils/event"
require "locale/utils/admin"
require "locale/utils/undecorator"
require "announcements"
require "gravestone"
require "rocket"
require "autodeconstruct"
require "bps"

-- Give player starting items.
-- @param event on_player_joined event
function player_joined(event)
  local player = game.players[event.player_index]
  player.insert{name="iron-plate", count=8}
  player.insert{name="pistol", count=1}
  player.insert{name="firearm-magazine", count=20}
  player.insert{name="burner-mining-drill", count = 2}
  player.insert{name="stone-furnace", count = 2}
end

-- Give player weapons after they respawn.
-- @param event on_player_respawned event
function player_respawned(event)
	local player = game.players[event.player_index]
	player.insert{name="pistol", count=1}
	player.insert{name="firearm-magazine", count=10}
    
    --console player death
	if player.name ~= nil then
		print("[PUPDATE] | "..player.name.." | respawn | "..player.force.name)
    end
end

-- Send a custom message to the server
-- @param user username to include
-- @param message message to print
function server_message(user, message)
	print("[WEB] "..user..": "..message)
	game.print("[WEB] "..user..": "..message)
end

-- Event handlers
Event.register(defines.events.on_player_created, player_joined)
Event.register(defines.events.on_player_respawned, player_respawned)
