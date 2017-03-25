require "crosshatch"

function replacex(surface, top, left, bottom, right)
	local crossWidth = global.scenario.config.mapsettings.cross_width
	local top_left = {x = left, y = top}
	local bottom_right = {x = right, y = bottom}
    local replacement
	if (top_left.x <= -crossWidth / 2) then
		replacement = "iron-ore"
		if (bottom_right.x) > -crossWidth / 2 then bottom_right.x = (-crossWidth / 2) - 1 end
	elseif (bottom_right.x >= crossWidth / 2) then
		replacement = "copper-ore"
		if (top_left.x) < crossWidth / 2 then top_left.x = (crossWidth / 2) + 1 end
	end

	local names = {"iron-ore", "copper-ore", "coal", "stone"}

	if replacement then
		for _,name in pairs(names) do
			if name ~= replacement then
				for _,ore in pairs(surface.find_entities_filtered{name = name, area = {top_left, bottom_right}}) do
					local amount = ore.amount
					local position = ore.position
					ore.destroy()
					surface.create_entity{name = replacement, position = position, force = "neutral", amount = amount}
				end
			end
		end
	end
end

function replacey(surface, top, left, bottom, right)
	local crossWidth = global.scenario.config.mapsettings.cross_width
	local top_left = {x = left, y = top}
	local bottom_right = {x = right, y = bottom}
    local replacement
	if (bottom_right.y >= crossWidth / 2) then
		replacement = "coal"
		if (top_left.y) < crossWidth / 2 then top_left.y = (crossWidth / 2) + 1 end
	elseif (top_left.y <= -crossWidth / 2) then
		replacement = "stone"
		if (bottom_right.y) > -crossWidth / 2 then bottom_right.y = (-crossWidth / 2) - 1 end
	end

	local names = {"iron-ore", "copper-ore", "coal", "stone"}

	if replacement then
		for _,name in pairs(names) do
			if name ~= replacement then
				for _,ore in pairs(surface.find_entities_filtered{name = name, area = {top_left, bottom_right}}) do
					local amount = ore.amount
					local position = ore.position
					ore.destroy()
					surface.create_entity{name = replacement, position = position, force = "neutral", amount = amount}
				end
			end
		end
	end
end

Event.register(defines.events.on_chunk_generated, function(event)
	local top = event.area.left_top.y
	local bottom = event.area.right_bottom.y
	local left = event.area.left_top.x
	local right = event.area.right_bottom.x
    replacex(event.surface, top, left, bottom, right)
	replacey(event.surface, top, left, bottom, right)
end)

Event.register(defines.events.on_player_created, function(event)
	local player = game.players[event.player_index]
	player.print("To the west is only iron.")
	player.print("To the east is only copper.")
	player.print("To the north is only stone.")
	player.print("To the south is only coal.")
end)