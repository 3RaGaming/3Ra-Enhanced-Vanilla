Event.register(defines.events.on_chunk_generated, function(event)
    crossWidth = scenario.config.mapsettings.cross_width
    local tiles = {}
    for x = event.area.left_top.x, event.area.right_bottom.x - 1 do
        for y = event.area.left_top.y, event.area.right_bottom.y - 1 do
			local water = event.surface.get_tile(x,y).name:find("water")
            local absx = math.abs(x)
            local absy = math.abs(y)
            if (absx > crossWidth / 2) and (absy > crossWidth / 2)  then
				if not water then
                	table.insert(tiles, {name = "out-of-map", position = {x,y}})
				else
					if not ((absx - (crossWidth / 2) <= 12) or (absy - (crossWidth / 2) <= 12)) then
						if (absx%32 == 0) or (absy%32 == 0) then
							table.insert(tiles, {name = "water", position = {x,y}})
						else
							table.insert(tiles, {name = "grass", position = {x,y}})
						end
					end
				end
			end
        end
    end
    event.surface.set_tiles(tiles, true)
end)
