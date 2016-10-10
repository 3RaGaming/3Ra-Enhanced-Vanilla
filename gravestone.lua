--Gravestone [based on Hazzard's Gravestone Mod]
--A 3Ra Gaming revision
--[[ list of inventories to save - constants from api reference]]--
local storeinventories = { 
	defines.inventory.player_vehicle,
	defines.inventory.player_armor,
	defines.inventory.player_tools, 
	defines.inventory.player_guns,
	defines.inventory.player_ammo,
	defines.inventory.player_quickbar, 
	defines.inventory.player_main, 
	defines.inventory.player_trash, 
}

--[[ name of inventories to print on report ]]--
local storeinventoriesstring = { 
	"Vehicle",
	"Armor",
	"Tools", 
	"Guns",
	"Ammo",
	"Quickbar",
	"Main", 
	"Trash", 
}

local save_craft_queue = true

local function spawn_chest(player, chestname)
	if player ~= nil then
		local playersurface = game.surfaces[player.surface.name]
		if playersurface ~= nil then
			local chestposition = playersurface.find_non_colliding_position("steel-chest", player.position, 100, 1)
			if chestposition ~= nil then
				local savechest = playersurface.create_entity({
					name = chestname,
					position = chestposition,
					force = game.forces.neutral
				})
				if savechest ~= nil then
					savechest.destructible = false
					return savechest
				end
			end
		end
	end

	return nil
end

local function on_player_died(event)
	local player = game.players[event.player_index]
	if player ~= nil then
		local transfered = 0	
		local chestId = 1
		local savechest = spawn_chest(player, "steel-chest")
		if savechest ~= nil then
			local chestitems = 0
			local chestinventory = savechest.get_inventory(defines.inventory.chest)

			--[[ save all predefined inventorie ]]--
			for i = 1, #storeinventories, 1 do
				local inventoryid = storeinventories[i]
				local playerinventory = player.get_inventory(inventoryid)
				if playerinventory ~= nil and chestinventory ~= nil then			
					player.print("Storing items from inventory '" .. storeinventoriesstring[i] .. "(" .. tostring(inventoryid) .. ")' to chest #" .. tostring(chestId))
					for j = 1, #playerinventory, 1 do
						if playerinventory[j].valid and playerinventory[j].valid_for_read then
							local item = playerinventory[j]
							if storeinventories[i] == defines.inventory.player_guns and item.name == "pistol" then

							else
								if storeinventories[i] == defines.inventory.player_ammo and item.name == "firearm-magazine" then
									if item.count > 10 then
										item.count = item.count - 10
									end
								end
								if chestinventory ~= nil and chestinventory.can_insert(item) then
									chestitems = chestitems + 1
									chestinventory[chestitems].set_stack(item)
									transfered = transfered + 1
								else
									savechest = spawn_chest(player, "steel-chest")
									chestinventory = nil
									if savechest ~= nil then
										chestitems = 0
										chestinventory = savechest.get_inventory(1)
										if chestinventory ~= nil then
											chestitems = 1
											chestinventory[chestitems].set_stack(item)
											transfered = transfered + 1
											chestId = chestId + 1
											player.print("Storing items from inventory '" .. storeinventoriesstring[i] .. "(" .. tostring(inventoryid) .. ")' to chest #" .. tostring(chestId))
										end
									else --[[ break if unable to spawn new chest ]]--
										break
									end
								end
							end
						end
					end	--[[ end for #playerinventory ]]--
				else --[[ break if unable to spawn new chest ]]--
					if savechest == nil then
						break
					end
				end
			end	--[[ end for #storeinventories ]]--
			if chestitems == 0 then
				if savechest ~= nil then
					savechest.destroy()
				end
			end
			
			--[[ save craft queue ]]--
			if save_craft_queue == true then
				local maininventory = player.get_inventory(defines.inventory.player_main)
				local toolbar = player.get_inventory(defines.inventory.player_quickbar)
				local queue = player.crafting_queue
				local craftchestId = 1
				local crafttransfered = 0
				if maininventory ~= nil and toolbar ~= nil and #queue > 0 then
					savechest = spawn_chest(player, "steel-chest")
					if savechest ~= nil then
						chestitems = 0
						--[[ canceled queue mats are dropped to main inventory ]]--
						maininventory.clear()
						--[[ complete products, even if they are intermediate are dropped into toolbar, if they are placeable - eg. factories for example ]]--
						toolbar.clear()
						chestinventory = savechest.get_inventory(1)
						local cnt = player.crafting_queue_size
						while cnt > 0 do
							local craftitem = queue[cnt]
							player.print("Canceling craft of " .. tostring(craftitem.count) .. " piece(s) of " .. craftitem.recipe .. " , index #" .. tostring(craftitem.index))
							local cancelparam = { index = craftitem.index, count = craftitem.count }
							player.cancel_crafting(cancelparam)
							--[[ canceling craft cancels also intermediate crafts ]]--
							cnt = player.crafting_queue_size
						end
						player.print("Storing items from queue to craft chest #" .. tostring(craftchestId))
						for j = 1, #maininventory, 1 do
							if maininventory[j].valid and maininventory[j].valid_for_read then
								local item = maininventory[j]

								if chestinventory ~= nill and chestinventory.can_insert(item) then
									chestitems = chestitems + 1
									chestinventory[chestitems].set_stack(item)
									crafttransfered = crafttransfered + 1
								else
									savechest = spawn_chest(player, "steel-chest")
									if savechest ~= nil then
										chestitems = 0
										chestinventory = savechest.get_inventory(1)
										if chestinventory ~= nil then
											chestitems = 1
											chestinventory[chestitems].set_stack(item)
											crafttransfered = crafttransfered + 1
											craftchestId = craftchestId + 1
											player.print("Storing items from queue to craft chest #" .. tostring(craftchestId))
										end
									else --[[ break if unable to spawn new chest ]]--
										break
									end
								end
							end
						end --[[ end for #maininventory ]]--
						for j = 1, #toolbar, 1 do
							if toolbar[j].valid and toolbar[j].valid_for_read then
								local item = toolbar[j]

								if chestinventory ~= nil and chestinventory.can_insert(item) then
									chestitems = chestitems + 1
									chestinventory[chestitems].set_stack(item)
									crafttransfered = crafttransfered + 1
								else
									savechest = spawn_chest(player, "steel-chest")
									if savechest ~= nil then
										chestitems = 0
										chestinventory = savechest.get_inventory(1)
										if chestinventory ~= nil then
											chestitems = 1
											chestinventory[chestitems].set_stack(item)
											crafttransfered = crafttransfered + 1
											craftchestId = craftchestId + 1
											player.print("Storing items from queue to craft chest #" .. tostring(craftchestId))
										end
									else --[[ break if unable to spawn new chest ]]--
										break
									end
								end
							end
						end --[[ end for #toolbar ]]--
					end
				end
				local message = "No  craft queue items were saved"
				if crafttransfered > 0 then
					message = "Saved " .. tostring(crafttransfered) .. " craft queue item(s) into " .. tostring(craftchestId) .. " craft box(es)"
				end
				player.print(message)
			end
		end

		local message = "No items were saved"
		if transfered > 0 then
			message = "Saved " .. tostring(transfered) .. " item(s) into " .. tostring(chestId) .. " box(es)"
		end
		player.print(message)
	end
end


Event.register(defines.events.on_player_died, on_player_died)
