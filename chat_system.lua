CHAT_LIMIT = 15
global.chat_channels = global.chat_channels or {global = {history = {}, members = {}, password = "", creator = 0}}
global.player_memberships = global.player_memberships or {}
global.selected_channel = {}
local md5 = require "md5"

local COMMAND_PREFIX = "/"
local ANNOUNCEMENT_COLOR = {r=1,g=1,b=1}
local commands = {
    join = (function(player, args)
        local index = player.name:lower()
        local channel = args[2] and args[2]:lower() or " "
        local password = args[3] and encrypt(args[3], #channel) or ""
        if not global.chat_channels[channel] then
            push_message(global.selected_channel[index], ANNOUNCEMENT_COLOR, "[Error] Channel with name '"..channel.."' not found.", index)
            return {false, "Channel '"..channel.."' not found."}
        end
        if get_index(global.player_memberships[index], channel) then
            push_message(global.selected_channel[index], ANNOUNCEMENT_COLOR, "[Error] Already a member of channel '"..channel.."'.", index)
            return {false, "User "..tostring(index).." already in channel '"..channel.."'."}
        end
        if password ~= global.chat_channels[channel].password then
            push_message(global.selected_channel[index], ANNOUNCEMENT_COLOR, "[Error] Password incorrect for channel '"..channel.."'.", index)
            return {false, "User "..tostring(index).." specified incorrect password for channel '"..channel.."'."}
        end
        table.insert(global.chat_channels[channel].members, index)
        table.insert(global.player_memberships[index], channel)
        global.selected_channel[index] = channel
        update_channel_list(player)
        update_labels(player)
    end),
    leave = (function(player)
        local index = player.name:lower()
        local selected = global.selected_channel[index]
        if selected == "global" then
            push_message("global", ANNOUNCEMENT_COLOR, "[Error] Cannot leave global channel.", index)
            return {false, "User "..tostring(index).." cannot leave global server."}
        elseif index == global.chat_channels[selected].creator then
            push_message(selected, ANNOUNCEMENT_COLOR, "[Error] Cannot leave a channel that you created. Use the '/delete channelname' command if you wish to delete this channel.", index)
        else
            table.remove(global.player_memberships[index], get_index(global.player_memberships[index], selected))
            table.remove(global.chat_channels[selected].members, get_index(global.chat_channels[selected].members, index))
            global.selected_channel[index] = "global"
            update_channel_list(player)
        end
    end),
    create = (function(player, args)
        local index = player.name:lower()
        local channel =  args[2] and args[2]:lower() or nil
        local selected = global.selected_channel[index]
        if not channel then
            push_message(selected, ANNOUNCEMENT_COLOR, "[Error] Channel name not specified. Type /help for more information.")
            return
        end
    end)
}
function encrypt(str, num)
    for i = 1,num do
        str = md5.sumhexa(str)
    end
    game.print(str)
    return str
end

function create_channel(name, password)
end
function get_index(table, value)
    for i,v in pairs(table) do
        if v == value then
            return i
        end
    end
end

function set_attributes(target, attributes)
    for i,v in pairs(attributes) do
        target.style[i] = v
    end
    return target
end

function get_player_from_name(name)
    for i,v in pairs(game.players) do
        if v.name:lower() == name then
            return v
        end
    end
end

function update_channel_list(player)
    local index = player.name:lower()
    local channel_frame = player.gui.left.chat_outer.channel_list.channel_frame
    for i,v in pairs(global.player_memberships[index]) do
        local channel_label = channel_frame["channel_button_"..v] or set_attributes(channel_frame.add{name = "channel_button_"..v, type="button", caption = v, style = "slot_button_style"}, {font = "default", maximal_width = 100, maximal_height = 100, font_color = {r=0,g=0,b=0}})
    end
    for i, button_name in pairs(channel_frame.children_names) do
        local channel_button = channel_frame[button_name]
        local channel = channel_button.caption
        if not get_index(global.player_memberships[index], channel) then
            channel_button.destroy()
        elseif global.selected_channel[index] == channel then
            channel_button.style = "selected_slot_button_style"
            set_attributes(channel_button, {font = "default", maximal_width = 100, maximal_height = 100, font_color = {r=0,g=0,b=0}})
        else
            channel_button.style = "slot_button_style"
            set_attributes(channel_button, {font = "default", maximal_width = 100, maximal_height = 100, font_color = {r=0,g=0,b=0}})
        end
    end
end

function update_labels(player)
	local channel = global.selected_channel[player.name:lower()]
    local chat_scroll = player.gui.left.chat_outer.chat_frame.chat_scroll
    for i = 1, CHAT_LIMIT do
        local stored_message = global.chat_channels[channel].history[i]
        local chat_label = chat_scroll["chat_label_"..tostring(i)]
        if stored_message then
            chat_label.caption = stored_message.message
            chat_label.style.font_color = stored_message.color
        else
        	chat_label.caption = " "
        	chat_label.style.font_color = {r = math.random(), g = math.random(), b = math.random()}
        end
    end
end

function initialise_player(player)
    local index = player.name:lower()
    if not(get_index(global.chat_channels.global.members, player.name:lower())) then
    	table.insert(global.chat_channels.global.members, player.name:lower())
    end
    global.player_memberships[index] = global.player_memberships[index] or {"global"}
    global.selected_channel[index] = global.selected_channel[index] or "global"
    generate_display(player)
end

function generate_display(player)
    local chat_outer = player.gui.left.chat_outer or player.gui.left.add{name="chat_outer", type = "frame", style = "outer_frame_style", direction = "vertical"}
    local channel_list = chat_outer.channel_list or set_attributes(chat_outer.add{name = "channel_list", type = "scroll-pane"}, {maximal_width = 400})
    channel_list.vertical_scroll_policy = "never"
    local channel_frame = channel_list.channel_frame or set_attributes(channel_list.add{name = "channel_frame", type = "frame", direction = "horizontal"}, {minimal_width = 400, left_padding=25})
    update_channel_list(player)
    local chat_frame = chat_outer.chat_frame or set_attributes(chat_outer.add{name = "chat_frame", type = "frame", direction = "vertical"}, {minimal_width = 400, minimal_height = 250, maximal_width = 400, maximal_height = 250, left_padding=20})
    local chat_scroll = chat_frame.chat_scroll or set_attributes(chat_frame.add{name = "chat_scroll", type = "scroll-pane", direction = "vertical"}, {top_padding = 15, minimal_height = 200, maximal_height = 200, minimal_width = 360})
    for i = 1,CHAT_LIMIT do
    	local history = global.chat_channels[global.selected_channel[player.name:lower()]].history[i]
        local label = chat_scroll["chat_label_"..tostring(i)] or set_attributes(chat_scroll.add{name = "chat_label_"..tostring(i), type = "label", caption = history and history.message or " "}, {font = "default-listbox", font_color = history and history.color or ANNOUNCEMENT_COLOR})
    end
    local chat_textbox = chat_frame["chat_textbox"] or set_attributes(chat_frame.add{name = "chat_textbox", type = "textfield"}, { minimal_width = 300, maximal_width = 300})
    local send_chat_button = chat_frame["send_chat_button"] or set_attributes(chat_frame.add{name = "send_chat_button", type = "button", caption = "Send", style = "slot_button_style"}, {maximal_width = 100, font = "default-bold"})
end

Event.register(defines.events.on_player_joined_game, function(event)
    initialise_player(game.players[event.player_index])
end)

function push_message(channel, color, message, for_player)
    if not for_player then
        table.insert(global.chat_channels[channel].history, 1, {color = color, message = message})
        global.chat_channels[channel].history[CHAT_LIMIT+1] = nil
    end
    for _,v in pairs(for_player and {for_player} or global.chat_channels[channel].members) do
        local player = get_player_from_name(v)
        if player.connected and global.selected_channel[v] == channel then
            local chat_scroll = player.gui.left.chat_outer.chat_frame.chat_scroll
            for i = CHAT_LIMIT, 2, -1 do -- Go from the very last message to the 2nd latest and push them all down one.
                local new_label = chat_scroll["chat_label_"..tostring(i)]
                local old_label = chat_scroll["chat_label_"..tostring(i-1)]
                new_label.caption = old_label.caption or " "
                new_label.style.font_color = old_label.style.font_color
            end
            chat_scroll["chat_label_1"].caption = message
            chat_scroll["chat_label_1"].style.font_color = color
        end
    end
    return {true, "Messages delivered to requested channel "..channel}
end

function input_message(event)
    --check commands here too
    local player = game.players[event.player_index]
    local index = player.name:lower()
    local textbox = player.gui.left.chat_outer.chat_frame.chat_textbox
    if textbox.text ~= "" then
        local message = textbox.text
        if message:sub(1,#COMMAND_PREFIX) == COMMAND_PREFIX then
            message = message:sub(#COMMAND_PREFIX + 1, #message)
            local args = {}
            for i in string.gmatch(message, "%S+") do
                args[#args+1] = i
            end
            for i,v in pairs(commands) do
                if args[1]:lower() == (i) then
                    v(player, args)
                    return;
                end
            end
            push_message(global.selected_channel[index], ANNOUNCEMENT_COLOR, "[Error] Command '"..args[1].."' not found.", index)
            return;
        end
        push_message(global.selected_channel[index], player.color, "["..global.scenario.identifier.."] "..player.name..": "..message)
    end
end

function add_channel(name, password)
    password = password and encrypt(password, #name) or ""
    global.chat_channels[name] = {history = {}, members = {}, password = password, creator = 0}
end

Event.register(defines.events.on_gui_click, function(e)
    local player = game.players[e.player_index]
    if not e.element.valid then return end
    if e.element.name == "send_chat_button" then
        input_message(e)
        game.players[e.player_index].gui.left.chat_outer.chat_frame.chat_textbox.text = ""
    elseif e.element.name:sub(1,15) == "channel_button_" then
        global.selected_channel[player.name:lower()] = e.element.caption
        update_channel_list(player)
        update_labels(player)
    end
end)
