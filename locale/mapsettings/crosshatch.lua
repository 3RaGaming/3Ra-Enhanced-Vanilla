Event.register(defines.events.on_chunk_generated, function(event)
    local tiles = {}
    crossWidth = scenario.config.mapsettings.cross_width
    for x = event.area.left_top.x, event.area.right_bottom.x do
        for y = event.area.left_top.y, event.area.right_bottom.y do
            if (math.abs(x) > crossWidth / 2) and (math.abs(y) > crossWidth / 2) then
                table.insert(tiles, {name = "out-of-map", position = {x,y}})
            end
        end
    end
    event.surface.set_tiles(tiles)
end)
