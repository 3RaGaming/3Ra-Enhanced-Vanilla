local tau=2*math.pi
local atan2=math.atan2
local sqrt = math.sqrt
local landWidth = scenario.mapsettings.config.spiral_land_width
local gap = landWidth + scenario.config.mapsettings.spiral_water_width
local function TileIsInSpiral(x,y)
	return (sqrt(x*x+y*y)+atan2(y,x)*gap/tau)%gap<landWidth
end
Event.register(defines.events.on_chunk_generated, function(event)
	local tiles = {}
	for x = event.area.left_top.x, event.area.right_bottom.x - 1 do
		for y = event.area.left_top.y, event.area.right_bottom.y - 1 do
			if not (math.abs(x) < 4 and math.abs(y) < 4) then
				if not TileIsInSpiral(x, y) then
					table.insert(tiles, {name="water", position = {x,y}})
				elseif event.surface.get_tile(x,y).name:find("water") then
					table.insert(tiles, {name="grass", position = {x,y}})
				end
			end
		end
	end
	event.surface.set_tiles(tiles)
end)
