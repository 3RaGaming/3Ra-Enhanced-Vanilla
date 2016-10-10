--Periodic Announcements
--A 3Ra Gaming creation
--List of announcements that are printed periodically, going through the list.
local announcements = {
	{"msg-announce1"},
	{"msg-announce2"}
}

--List of introductory messages that players are shown upon joining (in order).
local intros = {
	{"msg-intro1"},
	{"msg-intro2"},
	{"msg-intro3"}
}

local function show_announcement(event)
	global.last_announcement = global.last_announcement or 0
	if (game.tick / 60 - global.last_announcement > scenario.config.announcement_delay) then
		global.current_message = global.current_message or 1
		game.print(announcements[global.current_message])
		global.current_message = (global.current_message == #announcements) and 1 or global.current_message + 1
		global.last_announcement = game.tick / 60
	end
end

local function show_intro(event)
	local player = game.players[event.player_index]
	for i,v in ipairs(intros) do
		player.print(v)
	end
end

Event.register(defines.events.on_tick, show_announcement)
Event.register(defines.events.on_player_created, show_intro)
