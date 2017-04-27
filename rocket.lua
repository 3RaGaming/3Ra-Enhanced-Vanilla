-- Rocket Launch GUI [based off of the default freeplay scenario]
-- A 3Ra Gaming revision, original from Score Extended by binbinhfr
default_precision = 1;
unit_change_rocket_per_hour = 60;
--------------------------------------------------------------------------------------
local function update_averages(force_mem)
	local dt, nb

	if force_mem.count_tot then
		dt = game.tick / 60
		nb = force_mem.rockets_tot
	else
		dt = (game.tick - force_mem.rockets_count_tick) / 60
		nb = force_mem.rockets_count
	end

	force_mem.rockets_count_delay = dt

	if dt == 0 or nb == 0 then
		force_mem.rockets_per_time = 0
		force_mem.time_per_rocket = 0
	else
		force_mem.rockets_per_time = 3600 * nb / dt -- calculate average per hour
		force_mem.time_per_rocket = dt / 60 / nb -- calculate period in minutes
	end
end

--------------------------------------------------------------------------------------
local function clean_gui(gui)
	for _, guiname in pairs(gui.children_names) do
		gui[guiname].destroy()
	end
end

--------------------------------------------------------------------------------------
local function build_bar(player, rebuild_bar)
	-- debug_print("update bar player" .. player.name)

	if rebuild_bar and player.gui.top.but_score_main ~= nil then
		player.gui.top.but_score_main.destroy()
	end

	if player.gui.top.but_score_main == nil then
		player.gui.top.add({ type = "button", name = "but_score_main", caption = "Score" })
	end
end

--------------------------------------------------------------------------------------
local function update_bars(force, launching)
	for _, player in pairs(force.players) do
		if player.connected then
			if launching then
				player.gui.top.but_score_main.caption = "Score"
			else
				player.gui.top.but_score_main.caption = "Score"
			end
		end
	end
end

--------------------------------------------------------------------------------------
local function destroy_vanilla(player, force_mem)
	if player.gui.left.rocket_score == nil then return (false) end

	local previous_count = false

	if force_mem.rockets_tot == 0 then -- retrieve previous rocket total if no stat recorded yet (in case of late mod install)
	local tot = tonumber(player.gui.left.rocket_score.rocket_count.caption)
	if tot == nil then
		force_mem.rockets_tot = 0
		force_mem.rockets_count = 0
		force_mem.rockets_count_tick = 0
	else
		force_mem.rockets_tot = tot
		force_mem.rockets_count = tot
		force_mem.rockets_count_tick = 0
		update_averages(force_mem)
		previous_count = true
	end
	end

	player.gui.left.rocket_score.destroy()

	return (previous_count)
end

--------------------------------------------------------------------------------------
local function build_gui(player)
	-- debug_print("build_gui player" .. player.name)

	destroy_vanilla(player, force_mem)

	if player.gui.left.frm_score == nil then
		local gui1, gui2, gui3
		local player_mem = global.player_mem[player.index]
		gui1 = player.gui.left.add({ type = "frame", name = "frm_score", direction = "vertical" })
		gui1 = gui1.add({ type = "flow", name = "flw_score", direction = "vertical" })
		gui1.add({ type = "label", name = "lbl_score_tit", caption = { "score-gui-title" } })
		player_mem.lbl_score_tot = gui1.add({ type = "label", name = "lbl_score_tot" })
		gui2 = gui1.add({ type = "frame", name = "frm_score_count", direction = "vertical" })
		gui2 = gui2.add({ type = "flow", name = "flw_score", direction = "vertical" })
		player_mem.lbl_score_nb = gui2.add({ type = "label", name = "lbl_score_nb" })
		player_mem.lbl_score_delay = gui2.add({ type = "label", name = "lbl_score_delay", tooltip = { "score-gui-delay-tt" } })
		player_mem.lbl_score_av1 = gui2.add({ type = "label", name = "lbl_score_av1" })
		player_mem.lbl_score_av2 = gui2.add({ type = "label", name = "lbl_score_av2" })
		gui3 = gui2.add({ type = "flow", name = "flw_score", direction = "horizontal" })
		gui3.add({ type = "button", name = "but_score_count_rst", caption = {"score-gui-reset"}, tooltip = {"score-gui-reset-tt"} })
		player_mem.chk_score_count_tot = gui3.add({ type = "checkbox", name = "chk_score_count_tot", caption = { "score-gui-count-tot" }, state = false })
		gui3.add({ type = "button", name = "but_score_prec_down", caption = "<", tooltip = { "score-gui-prec-down-tt" } })
		gui3.add({ type = "button", name = "but_score_prec_up", caption = ">", tooltip = { "score-gui-prec-up-tt" } })
		--player_mem.chk_score_autolaunch = gui1.add({ type = "checkbox", name = "chk_score_autolaunch", caption = { "score-gui-autolaunch" }, state = false })
		player_mem.chk_score_autoshow = gui1.add({ type = "checkbox", name = "chk_score_autoshow", caption = { "score-gui-autoshow" }, state = false })
	end
end

--------------------------------------------------------------------------------------
local function update_gui(player, force_mem)
	-- debug_print("update_gui player" .. player.name)

	if player.gui.left.frm_score == nil then return end

	if force_mem == nil then
		force_mem = global.force_mem[player.force.name]
	end

	local player_mem = global.player_mem[player.index]

	player_mem.lbl_score_tot.caption = { "score-gui-tot", force_mem.rockets_tot }

	if force_mem.count_tot then
		player_mem.lbl_score_nb.caption = { "score-gui-nb", force_mem.rockets_tot }
	else
		player_mem.lbl_score_nb.caption = { "score-gui-nb", force_mem.rockets_count }
	end

	player_mem.lbl_score_delay.caption = { "score-gui-delay", string.format("%u", force_mem.rockets_count_delay) }

	local rpt = force_mem.rockets_per_time
	local tpr = force_mem.time_per_rocket
	local frm = "%." .. player_mem.precision .. "f"
	if rpt < unit_change_rocket_per_hour then
		player_mem.lbl_score_av1.caption = { "score-gui-av1h", string.format(frm, rpt) }
		player_mem.lbl_score_av2.caption = { "score-gui-av2m", string.format(frm, tpr) }
	else
		player_mem.lbl_score_av1.caption = { "score-gui-av1m", string.format(frm, rpt / 60) }
		player_mem.lbl_score_av2.caption = { "score-gui-av2s", string.format(frm, tpr * 60) }
	end
	player_mem.chk_score_count_tot.state = force_mem.count_tot
	player_mem.chk_score_autolaunch.state = force_mem.autolaunch
	player_mem.chk_score_autoshow.state = player_mem.autoshow
end

--------------------------------------------------------------------------------------
local function update_guis(refresh, force)
	if force then
		local force_mem = global.force_mem[force.name]
		if refresh then
			update_averages(force_mem)
		end

		for _, player in pairs(force.players) do
			if player.connected then
				update_gui(player, force_mem)
			end
		end
	else
		for _, player in pairs(game.players) do
			if player.connected then
				local force_mem = global.force_mem[player.force.name]
				if refresh then
					update_averages(force_mem)
				end
				update_gui(player, force_mem)
			end
		end
	end
end

--------------------------------------------------------------------------------------
local function find_silos()
	-- search for existing silos (if late mod install)

	for _, force in pairs(game.forces) do
		local force_mem = global.force_mem[force.name]
		force_mem.silos = {}
	end

	for _, surf in pairs(game.surfaces) do
		for _, silo in pairs(surf.find_entities_filtered({ type = "rocket-silo" })) do
			local force_mem = global.force_mem[silo.force.name]
			add_list(force_mem.silos, silo) -- to avoid duplicates (1 silo can be on 2 chunks)
		end
	end

	for _, force in pairs(game.forces) do
		local force_mem = global.force_mem[force.name]
		debug_print("force ", force.name, " silos ", #force_mem.silos)
	end

	return (nil)
end

--------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------
function init_globals()
	-- initialize or update general globals of the mod
	debug_print("init_globals ")

	global.ticks = global.ticks or 0
	global.force_mem = global.force_mem or {}
	global.player_mem = global.player_mem or {}

	if global.no_silos == nill then global.no_silos = true end
end

--------------------------------------------------------------------------------------
local function init_force(force)
	if global.force_mem == nil then return end

	-- initialize or update per force globals of the mod
	debug_print("init_force ", force.name)

	global.force_mem[force.name] = global.force_mem[force.name] or {}
	local force_mem = global.force_mem[force.name]

	force_mem.ticks_erase = force_mem.ticks_erase or 0

	force_mem.rockets_tot = force_mem.rockets_tot or 0 -- count rockets since beginning of game
	force_mem.rockets_count = force_mem.rockets_count or 0 -- count rockets since counter reset
	force_mem.rockets_count_tick = force_mem.rockets_count_tick or force_mem.rockets_count_ticks or 0 -- ref time of counter
	force_mem.rockets_count_delay = force_mem.rockets_count_delay or 0 -- delay since last counter reset in sec
	force_mem.last_rocket_tick = force_mem.last_rocket_tick or 0 -- time of last rocket launch
	force_mem.rockets_per_time = force_mem.rockets_per_time or 0 -- average
	force_mem.time_per_rocket = force_mem.time_per_rocket or 0 -- average

	update_averages(force_mem)

	force_mem.silos = force_mem.silos or {}
	force_mem.combinators = force_mem.combinators or {}
	if force_mem.count_tot == nil then force_mem.count_tot = false end
	if force_mem.autolaunch == nil then force_mem.autolaunch = global.scenario.config.autolaunch_default end
end

--------------------------------------------------------------------------------------
function init_forces()
	for _, force in pairs(game.forces) do
		init_force(force)
	end

	if global.no_silos then
		find_silos()
		global.no_silos = false
	end
end

--------------------------------------------------------------------------------------
function init_player(player, rebuild_bar)
	if global.player_mem == nil then return end

	if player.gui.left.rocket_score ~= nil then
		local force_mem = global.force_mem[player.force.name]
		destroy_vanilla(player, force_mem)
	end

	-- initialize or update per player globals of the mod, and reset the gui
	debug_print("init_player ", player.name, " connected=", player.connected)

	global.player_mem[player.index] = global.player_mem[player.index] or {}

	local player_mem = global.player_mem[player.index]

	if player_mem.gui_opened == nil then player_mem.gui_opened = false end
	if player_mem.autoshow == nil then player_mem.autoshow = true end
	player_mem.precision = player_mem.precision or default_precision

	if player.connected then
		build_bar(player, rebuild_bar)

		if player.gui.left.frm_score ~= nil then -- rebuild main widow if opened
		player.gui.left.frm_score.destroy()
		player_mem.gui_opened = true
		build_gui(player)
		update_gui(player)
		end
	end
end

--------------------------------------------------------------------------------------
function init_players()
	for _, player in pairs(game.players) do
		init_player(player, true)
	end
end

--------------------------------------------------------------------------------------
function rocket_init()
	-- called once, the first time the mod is loaded on a game (new or existing game)
	debug_print("on_init")
	init_globals()
	init_forces()
	init_players()
end

Event.register(-1, rocket_init)





--------------------------------------------------------------------------------------
local function on_force_created(event)
	local force = event.force
	debug_print("force created ", force.name)

	init_force(force)
end

Event.register(defines.events.on_force_created, on_force_created)

--------------------------------------------------------------------------------------
local function on_player_created(event)
	-- called at player creation
	local player = game.players[event.player_index]
	debug_print("player created ", player.name)

	init_player(player, true)
end

Event.register(defines.events.on_player_created, on_player_created)

--------------------------------------------------------------------------------------
local function on_player_joined_game(event)
	-- called in SP(once) and MP(every connect), eventually after on_player_created
	local player = game.players[event.player_index]
	debug_print("player joined ", player.name)

	init_player(player, false)
end

Event.register(defines.events.on_player_joined_game, on_player_joined_game)

--------------------------------------------------------------------------------------
local function on_creation(event)
	local ent = event.created_entity
	local force_mem = global.force_mem[ent.force.name]

	if ent.type == "rocket-silo" then
		debug_print("creation ", ent.name)

		table.insert(force_mem.silos, ent)
	end
end

Event.register(defines.events.on_built_entity, on_creation)
Event.register(defines.events.on_robot_built_entity, on_creation)

--------------------------------------------------------------------------------------
local function on_destruction(event)
	local ent = event.entity
	local force_mem = global.force_mem[ent.force.name]

	if ent.type == "rocket-silo" then
		debug_print("destruction ", ent.name)
		del_list(force_mem.silos, ent)
	end
end

Event.register(defines.events.on_entity_died, on_destruction)
Event.register(defines.events.on_robot_pre_mined, on_destruction)
Event.register(defines.events.on_preplayer_mined_item, on_destruction)

--------------------------------------------------------------------------------------
function rocket_on_tick(event)
	if global.ticks <= 0 then
		global.ticks = 91

	elseif global.ticks == 12 then
		-- hide score window after delay, if not opened manually before
		for _, force in pairs(game.forces) do
			local force_mem = global.force_mem[force.name]

			if force_mem.ticks_erase ~= 0 and game.tick >= force_mem.ticks_erase then
				for _, player in pairs(force.players) do
					if player.connected then
						local player_mem = global.player_mem[player.index]
						if player_mem.autoshow and (not player_mem.gui_opened) and player.gui.left.frm_score ~= nil then
							player.gui.left.frm_score.destroy()
						end
					end
				end
				update_bars(force, false)
				force_mem.ticks_erase = 0
			end
		end

	elseif global.ticks == 55 then
		-- check autolaunch

		for _, force in pairs(game.forces) do
			local force_mem = global.force_mem[force.name]

			if force_mem.autolaunch then
				for k, silo in pairs(force_mem.silos) do
					if silo.valid then
						-- if silo.get_item_count("satellite") > 0 then
						-- silo.launch_rocket()
						-- update_bars( force, true )
						-- end
						invent = silo.get_inventory(defines.inventory.rocket_silo_rocket)
						if invent ~= nil and not invent.is_empty() then
							silo.launch_rocket()
						end
					else
						table.remove(force_mem.silos, k)
					end
				end
			end
		end

	elseif global.ticks == 77 then
		-- update_guis(true,nil)
	end

	global.ticks = global.ticks - 1
end

Event.register(defines.events.on_tick, rocket_on_tick)

--------------------------------------------------------------------------------------
local function on_rocket_launched(event)
	local force = event.rocket.force

	-- debug_print( "rocket=", event.rocket.name )

	local force_mem = global.force_mem[force.name]
	local previous_count = false

	-- destroy vanilla score window and try to get rocket count if not known yet...
	for _, player in pairs(force.players) do
		if player.connected then
			if destroy_vanilla(player, force_mem) then previous_count = true end
		end
	end

	-- update stats and display window

	force_mem.ticks_erase = game.tick + global.scenario.config.score_delay * 60
	if not previous_count then
		force_mem.rockets_tot = force_mem.rockets_tot + 1
		force_mem.rockets_count = force_mem.rockets_count + 1
	end
	force_mem.last_rocket_tick = game.tick
	update_averages(force_mem)

	if global.scenario.config.score_delay >= 0 then
		for _, player in pairs(force.players) do
			if player.connected then
				local player_mem = global.player_mem[player.index]
				if player_mem.autoshow then
					build_gui(player)
					update_gui(player, force_mem)
				elseif player_mem.gui_opened then
					update_gui(player, force_mem)
				end
			end
		end
		update_bars(force, true)
	end

	-- transmit signals
end

Event.register(defines.events.on_rocket_launched, on_rocket_launched)

--------------------------------------------------------------------------------------
local function on_gui_click(event)
	if not (event and event.element and event.element.valid) then return end
	local player = game.players[event.player_index]
	local event_name = event.element.name

	-- debug_print( "player ", player.name, " click ", event_name )

	if event_name == "but_score_main" then
		local player_mem = global.player_mem[player.index]

		if player.gui.left.frm_score == nil then
			build_gui(player)
			update_gui(player)
			player_mem.gui_opened = true
		else
			player.gui.left.frm_score.destroy()
			player_mem.gui_opened = false
		end

	elseif event_name == "chk_score_count_tot" then
		local force_mem = global.force_mem[player.force.name]
		force_mem.count_tot = not force_mem.count_tot
		update_guis(true, player.force)

	elseif event_name == "chk_score_autolaunch" then
		local force_mem = global.force_mem[player.force.name]
		if player.admin then
			force_mem.autolaunch = not force_mem.autolaunch
		else
			player.print("Only admins can toggle autolaunch!")
		end
		update_guis(false, player.force)

	elseif event_name == "chk_score_autoshow" then
		local player_mem = global.player_mem[player.index]
		player_mem.autoshow = not player_mem.autoshow
		update_guis(false, player.force)

	elseif event_name == "but_score_count_rst" then
		local force_mem = global.force_mem[player.force.name]
		force_mem.rockets_count = 0
		if force_mem.last_rocket_tick == 0 then
			force_mem.rockets_count_tick = game.tick
		else
			force_mem.rockets_count_tick = force_mem.last_rocket_tick
		end
		update_guis(true, player.force)

	elseif event_name == "but_score_prec_down" then
		local player_mem = global.player_mem[player.index]
		if player_mem.precision > 0 then player_mem.precision = player_mem.precision - 1 end
		update_guis(false, player.force)

	elseif event_name == "but_score_prec_up" then
		local player_mem = global.player_mem[player.index]
		if player_mem.precision < 6 then player_mem.precision = player_mem.precision + 1 end
		update_guis(false, player.force)
	end
end

Event.register(defines.events.on_gui_click, on_gui_click)

--------------------------------------------------------------------------------------

local interface = {}

function interface.zero()
	debug_print("zero")

	for _, force in pairs(game.forces) do
		local force_mem = global.force_mem[force.name]
		force_mem.rockets_count = force_mem.rockets_tot
		force_mem.rockets_count_tick = 0
		update_guis(true, force)
	end
end

function interface.all()
	debug_print("all")

	for _, force in pairs(game.forces) do
		local force_mem = global.force_mem[force.name]
		if force_mem and force_mem.rockets_tot and force_mem.rockets_tot > 0 then
			message_all("Force " .. force.name .. " : " .. force_mem.rockets_tot .. " rockets.")
		end
	end
end

remote.add_interface("score", interface)

-- /c remote.call( "score", "zero" )
-- /c remote.call( "score", "all" )
