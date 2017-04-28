-- Periodic announcements and intro messages
-- A 3Ra Gaming creation
Event.register(-1, function()
	-- List of announcements that are printed periodically, going through the list.
	global.announcements = {
		{"announcements.msg-announce1"},
		{"announcements.msg-announce2"}
	}

	-- List of introductory messages that players are shown upon joining (in order).
	global.intros = {
		{"announcements.msg-intro1"},
		{"announcements.msg-intro2"},
		{"announcements.msg-intro3"}
	}
end)
-- Go through the announcements, based on the delay set in config
-- @param event on_tick event
local function show_announcement(event)
	global.last_announcement = global.last_announcement or 0
	if not global.scenario.config.announcements_enabled then return end
	if (game.tick / 60 - global.last_announcement > global.scenario.config.announcement_delay) then
		global.current_message = global.current_message or 1
		game.print(global.announcements[global.current_message])
		global.current_message = (global.current_message == #global.announcements) and 1 or global.current_message + 1
		global.last_announcement = game.tick / 60
	end
end

-- Show introduction messages to players upon joining
-- @param event
local function show_intro(event)
	local player = game.players[event.player_index]
	for i,v in pairs(global.intros) do
		player.print(v)
	end
end

-- Event handlers
Event.register(defines.events.on_tick, show_announcement)
Event.register(defines.events.on_player_created, show_intro)
