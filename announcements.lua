-- Periodic announcements and intro messages
-- A 3Ra Gaming creation

-- List of announcements that are printed periodically, going through the list.
local announcements = {
	{"msg-announce1"},
	{"msg-announce2"}
}

-- List of introductory messages that players are shown upon joining (in order).
local intros = {
	{"msg-intro1"},
	{"msg-intro2"},
	{"msg-intro3"}
}
-- Go through the announcements, based on the delay set in config
-- @param event on_tick event
local function show_announcement(event)
	global.last_announcement = global.last_announcement or 0
	if (game.tick / 60 - global.last_announcement > scenario.config.announcement_delay) then
		global.current_message = global.current_message or 1
		game.print(announcements[global.current_message])
		global.current_message = (global.current_message == #announcements) and 1 or global.current_message + 1
		global.last_announcement = game.tick / 60
	end
end

-- Show introduction messages to players upon joining
-- @param event
local function show_intro(event)
	local player = game.players[event.player_index]
	for i,v in ipairs(intros) do
		player.print(v)
	end
end

function player_died(event)
  player = event.player_index
  if game.players[player].name ~= nil then
    print("[PUPDATE] | "..game.players[player].name.." | died")
  end
end

function player_respawned(event)
  player = event.player_index
  if game.players[player].name ~= nil then
    print("[PUPDATE]| "..game.players[player].name.." | respawn")
  end
end

function player_joined(event)
	local player = event.player_index
	if game.players[player].name ~= nil then
		print("[PUPDATE]| "..game.players[player].name.." | join | "..game.players[player].force.name) -- Print for human readability
		print("PLAYER$join," .. player .. "," .. game.players[player].name .. "," .. game.players[player].force.name) -- Print for computer parsing
	end
end

function player_left(event)
	local player = event.player_index
	if game.players[player].name ~= nil then
		print("[PUPDATE]| "..game.players[player].name.." | leave | "..game.players[player].force.name) -- Print for human readability
		print("PLAYER$leave," .. player .. "," .. game.players[player].name .. "," .. game.players[player].force.name) -- Print for computer parsing
	end
end

-- Event handlers
Event.register(defines.events.on_player_died, player_died)
Event.register(defines.events.on_player_respawned, player_respawned)
Event.register(defines.events.on_player_joined_game, player_joined)
Event.register(defines.events.on_player_left_game, player_left)
Event.register(defines.events.on_tick, show_announcement)
Event.register(defines.events.on_player_created, show_intro)
