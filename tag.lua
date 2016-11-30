-- Give players the option to set their preferred role as a tag
-- A 3Ra Gaming creation

function create_tag_gui(event)
	local player = game.players[event.player_index]
	if player.gui.top.tag == nil then
		player.gui.top.add { name = "tag", type = "button", caption = "Tag" }
	end
end

-- Tag list
local roles = {
	{ display_name = "Mining" },
	{ display_name = "Oil" },
	{ display_name = "Bus" },
	{ display_name = "Smelting" },
	{ display_name = "Pest Control" },
	{ display_name = "Automation" },
	{ display_name = "Quality Control" },
	{ display_name = "Power" },
	{ display_name = "Trains" },
	{ display_name = "Science" },
	{ display_name = "Robotics"},
	{ display_name = "Admin"},
	{ display_name = "AFK" },
	{ display_name = "Clear" }
}

function expand_tag_gui(player)
	local frame = player.gui.left["tag-panel"]
	if (frame) then
		frame.destroy()
	else
		local frame = player.gui.left.add { type = "frame", name = "tag-panel", caption = "Choose Tag" }
		for _, role in pairs(roles) do
			if role.display_name ~= "Admin" then frame.add { type = "button", caption = role.display_name, name = role.display_name }
			else if player.admin then frame.add { type = "button", caption = role.display_name, name = role.display_name } end
		end
	end
end

local function on_gui_click(event)
	if not (event and event.element and event.element.valid) then return end
	local player = game.players[event.element.player_index]
	local name = event.element.name

	if (name == "tag") then
		expand_tag_gui(player)
	end

	if (name == "Clear") then
		player.tag = ""
		expand_tag_gui(player)
		return
	end
	for _, role in pairs(roles) do
		if (name == role.display_name) then
			player.tag = "[" .. role.display_name .. "]"
			expand_tag_gui(player)
		end
	end
end


Event.register(defines.events.on_gui_click, on_gui_click)
Event.register(defines.events.on_player_joined_game, create_tag_gui)
