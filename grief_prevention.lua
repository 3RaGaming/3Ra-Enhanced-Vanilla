--[[ list of inventories to save - constants from api reference]]--
require "locale/utils/defines"

players = {}

function get_player_inventories(player)
    local inventories = {}
    for i = 1, #player_inventories, 1 do
        local inventoryid = player_inventories[i]
        local playerinventory = player.get_inventory(inventoryid)
        table.insert(inventories,playerinventory)
    end
    return inventories
end

script.on_event(defines.events.on_preplayer_mined_item, function (event)
    local player = game.players[event.player_index]
    local author = event.entity.last_user
--    if player ~= author then
        event.entity.clear_items_inside()
        players[event.player_index] = true
--    end
end)

script.on_event(defines.events.on_player_mined_item, function(event)
    local player = game.players[event.player_index]
    local item_count = event.item_stack.count
    if players[event.player_index] then
        players[event.player_index] = nil
        for i = 1, #player_inventories, 1 do
            local inventoryid = player_inventories[i]
            local playerinventory = player.get_inventory(inventoryid)
            if playerinventory then
                item_count = item_count - playerinventory.remove({name=event.item_stack.name,count=item_count})
            end
            if item_count == 0 then
                break
            end
        end
    end
end)

