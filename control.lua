--Enhanced Vanilla
--A 3Ra Gaming compilation
if not scenario then scenario = {} end
if not scenario.config then scenario.config = {} end
--config and event must be called first.
require "autodeconstruct"
require "config"
require "locale/utils/event"
require "locale/utils/admin"
require "announcements"
require "gravestone"
require "rocket"
require "locale/utils/undecorator"

--Give starting items.
function player_joined(event)
  local player = game.players[event.player_index]
  player.insert{name="iron-plate", count=8}
  player.insert{name="pistol", count=1}
  player.insert{name="firearm-magazine", count=20}
  player.insert{name="burner-mining-drill", count = 2}
  player.insert{name="stone-furnace", count = 2}
end

--Give player weapons after they die.
function player_respawned(event)
	local player = game.players[event.player_index]
	player.insert{name="pistol", count=1}
	player.insert{name="firearm-magazine", count=10}
end

--Special command for communicating through our custom web-gui
function server_message(user, message)
	print("[WEB] "..user..": "..message)
	game.print("[WEB] "..user..": "..message)
end

Event.register(defines.events.on_player_created, player_joined)
Event.register(defines.events.on_player_respawned, player_respawned)
