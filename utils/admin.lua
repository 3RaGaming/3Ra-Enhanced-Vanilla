-- @module admin
-- A 3Ra Gaming creation

global.green = { r = 0, g = 1, b = 0 }
global.red = { r = 1, g = 0, b = 0 }

-- values here are player ids from game.connected_players, which is different from game.players
global.follow_targets = global.follow_targets or {}

global.original_position = global.original_position or {}
global.original_surface = global.original_surface or {}

local function update_position(event)
	for player_index, follow_target_index in pairs(global.follow_targets) do
		if follow_target_index then
			local player = game.players[player_index]
			local follow_target = game.players[follow_target_index]
			if player and follow_target then
				player.teleport(follow_target.position, follow_target.surface)
			end
		end
	end
end

Event.register(defines.events.on_tick, update_position)
Event.register(-1, function()
	game.create_force("Admins")
	game.forces.Admins.research_all_technologies()
end)

Event.register(defines.events.on_force_created, function(event)
	event.force.set_cease_fire(game.forces.Admins, true)
	game.forces.Admins.set_cease_fire(event.force, true)
end)

function entity_mined(event)
	local entity = event.entity
	if entity.force.name == "neutral" 
	or entity.name == "entity-ghost" 
	or entity.type == "locomotive" 
	or entity.type == "cargo-wagon" 
	or entity.type == "car" 
	or entity.type:find("robot") 
	or game.players[event.player_index].force == game.forces.Admins 
	or entity.name == "tile-ghost"
	then return end
	local ghost = entity.surface.create_entity
	{name="entity-ghost",	force=game.forces.Admins, inner_name=entity.name, position=entity.position, direction = entity.direction}
	ghost.last_user = game.players[event.player_index]
end

Event.register(defines.events.on_preplayer_mined_item, entity_mined)
-- Handle various gui clicks, either spectate or character modification
-- @param event gui click event
local function gui_click(event)
	local i = event.player_index
	local p = game.players[i]
	local e = event.element.name
	if e == "character" and event.element.caption == "Disabled" then
		p.print("Character modification disabled in Spectator mode.")
		return
	end
	if e == "spectate" and event.element.caption == "Spectating" then
		p.print("Use a button in the spectate panel to stop spectating.")
		return
	end
	if e ~= nil then
		if e == "spectate" then
			--if not p.admin then
			--	p.gui.top.spectate.destroy()
			--	p.print("You are no longer an admin.")
			--	return
			--end
			force_spectators(i, nil)
		elseif e == "teleport" then
			force_spectators(i, true)
		elseif e == "return_character" then
			force_spectators(i, false)
		elseif e == "character" then
			if p.gui.left.character_panel then
				p.gui.left.admin_pane.character.caption = "Character"
				p.gui.left.character_panel.destroy()
			else
				p.gui.left.admin_pane.character.caption = "Close"
				create_character_gui(i)
			end
		elseif e == "character_pickup" then
			if global.player_character_stats[i].item_loot_pickup then
				global.player_character_stats[i].item_loot_pickup = false
				event.element.style.font_color = global.red
				p.character_item_pickup_distance_bonus = 0
				p.character_loot_pickup_distance_bonus = 0
			else
				global.player_character_stats[i].item_loot_pickup = true
				event.element.style.font_color = global.green
				p.character_item_pickup_distance_bonus = 125
				p.character_loot_pickup_distance_bonus = 125
			end
		elseif e == "character_reach" then
			if global.player_character_stats[i].build_itemdrop_reach_resourcereach_distance then
				global.player_character_stats[i].build_itemdrop_reach_resourcereach_distance = false
				event.element.style.font_color = global.red
				p.character_build_distance_bonus = 0
				p.character_item_drop_distance_bonus = 0
				p.character_reach_distance_bonus = 0
				p.character_resource_reach_distance_bonus = 0
			else
				global.player_character_stats[i].build_itemdrop_reach_resourcereach_distance = true
				event.element.style.font_color = global.green
				p.character_build_distance_bonus = 125
				p.character_item_drop_distance_bonus = 125
				p.character_reach_distance_bonus = 125
				p.character_resource_reach_distance_bonus = 125
			end
		elseif e == "character_craft" then
			if global.player_character_stats[i].crafting_speed then
				global.player_character_stats[i].crafting_speed = false
				event.element.style.font_color = global.red
				p.character_crafting_speed_modifier = 0
			else
				global.player_character_stats[i].crafting_speed = true
				event.element.style.font_color = global.green
				p.character_crafting_speed_modifier = 60
			end
		elseif e == "character_mine" then
			if global.player_character_stats[i].mining_speed then
				global.player_character_stats[i].mining_speed = false
				event.element.style.font_color = global.red
				p.character_mining_speed_modifier = 0
			else
				global.player_character_stats[i].mining_speed = true
				event.element.style.font_color = global.green
				p.character_mining_speed_modifier = 150
			end
		elseif e == "character_invincible" then
			if global.player_character_stats[i].invincible then
				global.player_character_stats[i].invincible = false
				event.element.style.font_color = global.red
				p.character.destructible = false
			else
				global.player_character_stats[i].invincible = true
				event.element.style.font_color = global.green
				p.character.destructible = true
			end
		elseif e == "character_run1" then
			local run_table = event.element.parent
			run_table.character_run1.state = true
			run_table.character_run2.state = false
			run_table.character_run3.state = false
			run_table.character_run5.state = false
			run_table.character_run10.state = false
			p.character_running_speed_modifier = 0
			global.player_character_stats[i].running_speed = 0
		elseif e == "character_run2" then
			local run_table = event.element.parent
			run_table.character_run1.state = false
			run_table.character_run2.state = true
			run_table.character_run3.state = false
			run_table.character_run5.state = false
			run_table.character_run10.state = false
			p.character_running_speed_modifier = 1
			global.player_character_stats[i].running_speed = 1
		elseif e == "character_run3" then
			local run_table = event.element.parent
			run_table.character_run1.state = false
			run_table.character_run2.state = false
			run_table.character_run3.state = true
			run_table.character_run5.state = false
			run_table.character_run10.state = false
			p.character_running_speed_modifier = 2
			global.player_character_stats[i].running_speed = 2
		elseif e == "character_run5" then
			local run_table = event.element.parent
			run_table.character_run1.state = false
			run_table.character_run2.state = false
			run_table.character_run3.state = false
			run_table.character_run5.state = true
			run_table.character_run10.state = false
			p.character_running_speed_modifier = 4
			global.player_character_stats[i].running_speed = 4
		elseif e == "character_run10" then
			local run_table = event.element.parent
			run_table.character_run1.state = false
			run_table.character_run2.state = false
			run_table.character_run3.state = false
			run_table.character_run5.state = false
			run_table.character_run10.state = true
			p.character_running_speed_modifier = 9
			global.player_character_stats[i].running_speed = 9
		elseif e == "follow" then
			toggle_follow_panel(p)
		elseif e == "unfollow" then
			global.follow_targets[i] = nil
			p.gui.left.follow_panel.follow_list.unfollow.destroy()
			p.gui.left.follow_panel.follow_list.return_button.destroy()
		elseif e == "return_button" then
			global.follow_targets[i] = nil
			p.teleport(global.original_position[i], global.original_surface[i])
			p.gui.left.follow_panel.follow_list.unfollow.destroy()
			p.gui.left.follow_panel.follow_list.return_button.destroy()
		end
		--set who to follow
		for _, player in pairs(game.connected_players) do
			if e == player.name then
				global.original_position[i] = p.position
				global.original_surface[i] = p.surface
				global.follow_targets[i] = player.index
				if not p.gui.left.follow_panel.follow_list.unfollow then p.gui.left.follow_panel.follow_list.add { name = "unfollow", type = "button", caption = "Unfollow" } end
				if not p.gui.left.follow_panel.follow_list.return_button then p.gui.left.follow_panel.follow_list.add { name = "return_button", type = "button", caption = "Return" } end
				p.gui.left.follow_panel.follow_list.unfollow.style.font = "default"
				p.gui.left.follow_panel.follow_list.return_button.style.font = "default"
			end
		end
	end
end

-- Create the full character GUI for admins to update their character settings
-- @param index index of the player to change
function create_character_gui(index)
	local player = game.players[index]
	local character_frame = player.gui.left.add { name = "character_panel", type = "frame", direction = "vertical", caption = "Character" }
	character_frame.add { name = "character_pickup", type = "button", caption = "Pickup" }
	character_frame.add { name = "character_reach", type = "button", caption = "Reach" }
	character_frame.add { name = "character_craft", type = "button", caption = "Crafting" }
	character_frame.add { name = "character_mine", type = "button", caption = "Mining" }
	character_frame.add { name = "character_invincible", type = "button", caption = "Invincible" }
	character_frame.add { name = "run_label", type = "label", caption = "Run speed control:" }
	local run_table = character_frame.add { name = "character_run", type = "table", colspan = 5, caption = "Run Speed" }
	run_table.add { name = "run1_label", type = "label", caption = "1x" }
	run_table.add { name = "run2_label", type = "label", caption = "2x" }
	run_table.add { name = "run3_label", type = "label", caption = "3x" }
	run_table.add { name = "run5_label", type = "label", caption = "5x" }
	run_table.add { name = "run10_label", type = "label", caption = "10x" }
	run_table.add { name = "character_run1", type = "radiobutton", state = false }
	run_table.add { name = "character_run2", type = "radiobutton", state = false }
	run_table.add { name = "character_run3", type = "radiobutton", state = false }
	run_table.add { name = "character_run5", type = "radiobutton", state = false }
	run_table.add { name = "character_run10", type = "radiobutton", state = false }
	update_character_settings(index)
end

-- Updates the full character GUI to show the current settings
-- @param index index of the player to change
function update_character_settings(index)
	local char_gui = game.players[index].gui.left.character_panel
	local settings = global.player_character_stats[index]

	if settings.item_loot_pickup then
		char_gui.character_pickup.style.font_color = global.green
	else
		char_gui.character_pickup.style.font_color = global.red
	end

	if settings.build_itemdrop_reach_resourcereach_distance then
		char_gui.character_reach.style.font_color = global.green
	else
		char_gui.character_reach.style.font_color = global.red
	end

	if settings.crafting_speed then
		char_gui.character_craft.style.font_color = global.green
	else
		char_gui.character_craft.style.font_color = global.red
	end

	if settings.mining_speed then
		char_gui.character_mine.style.font_color = global.green
	else
		char_gui.character_mine.style.font_color = global.red
	end

	if settings.invincible then
		char_gui.character_invincible.style.font_color = global.green
	else
		char_gui.character_invincible.style.font_color = global.red
	end

	local run_table = char_gui.character_run
	if settings.running_speed == 0 then
		run_table.character_run1.state = true
	elseif settings.running_speed == 1 then
		run_table.character_run2.state = true
	elseif settings.running_speed == 2 then
		run_table.character_run3.state = true
	elseif settings.running_speed == 4 then
		run_table.character_run5.state = true
	elseif settings.running_speed == 9 then
		run_table.character_run10.state = true
	end
end

-- Updates the new character of an admin coming out of spectate mode
-- @param index index of the player to change
function update_character(index)
	local player = game.players[index]
	local settings = global.player_character_stats[index]

	if settings.item_loot_pickup then
		player.character_item_pickup_distance_bonus = 125
		player.character_loot_pickup_distance_bonus = 125
	else
		player.character_item_pickup_distance_bonus = 0
		player.character_loot_pickup_distance_bonus = 0
	end

	if settings.build_itemdrop_reach_resourcereach_distance then
		player.character_item_drop_distance_bonus = 125
		player.character_reach_distance_bonus = 125
		player.character_resource_reach_distance_bonus = 125
	else
		player.character_item_drop_distance_bonus = 0
		player.character_reach_distance_bonus = 0
		player.character_resource_reach_distance_bonus = 0
	end

	if settings.crafting_speed then
		player.character_crafting_speed_modifier = 60
	else
		player.character_crafting_speed_modifier = 0
	end

	if settings.mining_speed then
		player.character_mining_speed_modifier = 150
	else
		player.character_mining_speed_modifier = 0
	end

	if settings.invincible then
		player.character.destructible = false
	else
		player.character.destructible = true
	end

	player.character_running_speed_modifier = settings.running_speed
end


--[[ Follow logic works as follows:
When panel is opened, for each connected player a button is created.
When button is pressed, a key-value pair is added to global.follow_targets and every few ticks the admins camera position is updated to match that of the followed player.
We also save the camera postion of the admin before they started following anyone, so that we can return to that position later.
This panel is also updated when connected players change, such as play joins or disconnects.
]]
local function update_follow_panel(player)
	local player_index = player.index

	if player.gui.left.follow_panel then
		-- destroy the panel first to make sure we are not duplicating names.
		if player.gui.left.follow_panel.follow_list then player.gui.left.follow_panel.follow_list.destroy() end

		local follow_list = player.gui.left.follow_panel.add { name = "follow_list", type = "scroll-pane" }
		follow_list.style.maximal_height = 190

		if #game.connected_players == 1 then
			follow_list.add { name = "no_player_label", type = "label", caption = "There are no players to follow" }
		else
			for _, follow_player in pairs(game.connected_players) do
				if player.index ~= follow_player.index then
					local label = follow_list.add{name = follow_player.name, type = "button", caption = follow_player.name}
					label.style.font = "default"
				end
			end
		end

		-- Readd Unfollow and Return buttons if already following a player
		if global.follow_targets[player_index] then
			local button1 = follow_list.add{name = "unfollow", type = "button", caption = "Unfollow"}
			local button2 = follow_list.add{name = "return_button", type = "button", caption = "Return"}
			button1.style.font = "default"
			button2.style.font = "default"
		end
	end
end

function toggle_follow_panel(player)
	if player.gui.left.follow_panel then
		if player.gui.left.spectate_panel then player.gui.left.spectate_panel.follow.caption = "Follow" end
		player.gui.left.follow_panel.destroy()
		global.follow_targets[player.index] = nil
	else
		player.gui.left.spectate_panel.follow.caption = "Close"
		player.gui.left.add { name = "follow_panel", type = "frame", direction = "vertical", caption = "Follow" }
		update_follow_panel(player)
	end
end

local function connected_players_changed(event)
	for player_index, follow_target_index in pairs(global.follow_targets) do
		if player_index == event.player_index or follow_target_index == event.player_index then
			global.follow_targets[player_index] = nil
			if follow_target_index == event.player_index then
				game.players[player_index].print("Follow target disconnected.")
			end
		end
	end

	for _, player in pairs(game.connected_players) do
		if player.admin then
			update_follow_panel(player)
		end
	end
end

Event.register(defines.events.on_player_joined_game, connected_players_changed)
Event.register(defines.events.on_player_left_game, connected_players_changed)

-- Announce an admin's joining and give them the admin gui
-- @param event player joined event
local function admin_joined(event)
	local index = event.player_index
	local player = game.players[index]
	if player.admin then create_admin_gui(player.name) end
end

-- The actual admin GUI creation is done in a separate function so it can be called in-game, giving new admins the GUI without restarting.
-- @param player_name string that matches player name (game.players[player_name].name)
function create_admin_gui(player_name)
	local player = game.players[player_name]
	local index = player.index
	local admin_pane = nil
	global.player_character_stats = global.player_character_stats or {}
	if not player.gui.left.admin_pane then
		admin_pane = player.gui.left.add { name = "admin_pane", type = "frame", direction = "vertical", caption = "Admin Tools" }
	else
		admin_pane = player.gui.left.admin_pane
	end
	if not player.gui.left.admin_pane.spectate then
		admin_pane.add { name = "spectate", type = "button", caption = "Spectate" }
	end
	if not player.gui.left.admin_pane.character then
		admin_pane.add { name = "character", type = "button", caption = "Character" }
	end
	if global.player_character_stats[index] == nil then
		global.player_character_stats[index] = {
			item_loot_pickup = false,
			build_itemdrop_reach_resourcereach_distance = false,
			crafting_speed = false,
			mining_speed = false,
			invincible = false,
			running_speed = 0
		}
	end

	game.print("All Hail Admin " .. player.name)
end

-- Toggle the player's spectator state
-- @param index index of the player to change
function force_spectators(index, teleport)
	local player = game.players[index]
	global.player_spectator_state = global.player_spectator_state or {}
	global.player_spectator_character = global.player_spectator_character or {}
	global.player_spectator_force = global.player_spectator_force or {}
	global.player_spectator_logistics_slots = global.player_spectator_logistics_slots or {}
	if global.player_spectator_state[index] then
		--remove spectator mode
		if player.character == nil then
			local pos = player.position
			if global.player_spectator_character[index] and global.player_spectator_character[index].valid then
				if not teleport then player.print("Returning you to your character.") end
				player.set_controller { type = defines.controllers.character, character = global.player_spectator_character[index] }
			else
				player.print("Character missing, will create new character at spawn.")
				player.set_controller { type = defines.controllers.character, character = player.surface.create_entity { name = "player", position = { 0, 0 }, force = global.player_spectator_force[index] } }
				player.insert { name = "pistol", count = 1 }
				player.insert { name = "firearm-magazine", count = 10 }
			end
			--restore character logistics slots due to bug in base game that clears them after returning from spectator mode
			for slot=1, player.character.request_slot_count do
				if global.player_spectator_logistics_slots[index][slot] then
					player.character.set_request_slot(global.player_spectator_logistics_slots[index][slot], slot)
				end
			end
			if teleport then
				player.print("Teleporting you to the location you are currently looking at.")
				player.teleport(pos)
			end
		end
		global.player_spectator_state[index] = false
		player.force = game.forces[global.player_spectator_force[index].name]
		if player.gui.left.spectate_panel then
			player.gui.left.spectate_panel.destroy()
		end
		if player.gui.left.follow_panel then
			toggle_follow_panel(player)
		end
		player.gui.left.admin_pane.spectate.caption = "Spectate"
		if player.gui.left.admin_pane.character ~= nil then
			player.gui.left.admin_pane.character.caption = "Character"
		end
		update_character(index)
	else
		--put player in spectator mode
		if player.character then
			player.character.destructible = false
			player.walking_state = { walking = false, direction = defines.direction.north }
			global.player_spectator_character[index] = player.character
			global.player_spectator_force[index] = player.force
			--store character logistics slots due to an apparent bug in the base game that discards them when returning from spectate
			global.player_spectator_logistics_slots[index] = {}
			for slot=1, player.character.request_slot_count do
				global.player_spectator_logistics_slots[index][slot] = player.character.get_request_slot(slot)
			end
			player.set_controller { type = defines.controllers.god }
			player.cheat_mode = true
		end
		player.force = game.forces["Admins"]
		global.player_spectator_state[index] = true
		player.print("You are now a spectator")

		-- Creates a Spectator Panel
		local spectate_panel = player.gui.left.add { name = "spectate_panel", type = "frame", direction = "vertical", caption = "Spectator Mode" }
		spectate_panel.add { name = "teleport", type = "button", caption = "Teleport" }
		spectate_panel.add { name = "return_character", type = "button", caption = "Return" }
		player.gui.left.admin_pane.spectate.caption = "Spectating"

		if player.gui.left.character_panel ~= nil then
			player.gui.left.character_panel.destroy()
			player.gui.left.admin_pane.character.caption = "Disabled"
		end
		if player.gui.left.admin_pane.character ~= nil then
			player.gui.left.admin_pane.character.caption = "Disabled"
		end
		-- adds an option to follow another player.
		if spectate_panel.follow_panel == nil then
			spectate_panel.add { name = "follow", type = "button", caption = "Follow" }
		end
	end
end

function admin_reveal(event)
	if (game.tick % 1800 == 0) then
		game.forces.Admins.chart_all()
	end
end

-- Event handlers
Event.register(defines.events.on_player_joined_game, admin_joined)
Event.register(defines.events.on_gui_click, gui_click)
Event.register(defines.events.on_tick, admin_reveal)
