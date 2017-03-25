require "crosshatch"

Event.register(defines.events.on_chunk_generated, function(event)
    local crossWidth = global.scenario.config.mapsettings.cross_width
	local top_left = event.area.left_top
	local bottom_right = event.area.right_bottom
    local replacement
	if (top_left.x < -crossWidth / 2) then
		replacement = "iron-ore"
		if (bottom_right.x) > -crossWidth / 2 then bottom_right.x = -crossWidth / 2 end
	elseif (bottom_right.x > crossWidth / 2) then
		replacement = "copper-ore"
		if (top_left.x) > crossWidth / 2 then top_left.x = crossWidth / 2 end
	elseif (bottom_right.y > crossWidth / 2) then
		replacement = "coal"
		if (top_left.y) > crossWidth / 2 then top_left.y = crossWidth / 2 end
	elseif (top_left.y < -crossWidth / 2) then
		replacement = "stone"
		if (bottom_right.y) > -crossWidth / 2 then bottom_right.y = -crossWidth / 2 end
	end

	local names = {"iron-ore", "copper-ore", "coal", "stone"}

	if replacement then
		for _,name in pairs(names) do
			if name ~= replacement then
				for _,ore in pairs(event.surface.find_entities_filtered{name = name, area = {top_left, bottom_right}}) do
					local amount = ore.amount
					local position = ore.position
					ore.destroy()
					event.surface.create_entity{name = replacement, position = position, force = "neutral", amount = amount}
				end
			end
		end
	end
end)
