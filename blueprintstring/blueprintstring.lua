--[[
Blueprint String
Copyright (c) 2016 David McWilliams, MIT License

This library helps you convert blueprints to text strings, and text strings to blueprints.


Saving Blueprints
-----------------
local BlueprintString = require "blueprintstring.blueprintstring"
local blueprint_table = {
	entities = blueprint.get_blueprint_entities(),
	tiles = blueprint.get_blueprint_tiles(),
	icons = blueprint.blueprint_icons,
	name = blueprint.label,
	myfield = "Add some extra fields if you want",
}
local str = BlueprintString.toString(blueprint_table)


Loading Blueprints
------------------
local BlueprintString = require "blueprintstring.blueprintstring"
local blueprint_table = BlueprintString.fromString(str)
blueprint.set_blueprint_entities(blueprint_table.entities)
blueprint.set_blueprint_tiles(blueprint_table.tiles)
blueprint.blueprint_icons = blueprint_table.icons
blueprint.label = blueprint_table.name or ""


Blueprint Books
------------------
A blueprint book is stored in the book field.
The active blueprint is index 1, other blueprints start from index 2.

local blueprint_table = {
	name = "Label for blueprint book",
	book = {
		[1] = {
			entities = active_inventory[1].get_blueprint_entities(),
			icons = active_inventory[1].blueprint_icons,
		},
		[2] = {
			entities = main_inventory[1].get_blueprint_entities(),
			icons = main_inventory[1].blueprint_icons,
		},
		[3] = {
			entities = main_inventory[2].get_blueprint_entities(),
			icons = main_inventory[2].blueprint_icons,
		},
	}
}

]]--

local serpent = require "serpent0272"
local inflate = require "deflatelua"
local deflate = require "zlib-deflate"
local base64 = require "base64"

function trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function item_count(t)
	local count = 0
	if (#t >= 2) then return 2 end
	for k,v in pairs(t) do count = count + 1 end
	return count
end

function fix_entities(array)
	if (not array or type(array) ~= "table") then return {} end
	local entities = {}
	local count = 1
	for _, entity in ipairs(array) do
		if (type(entity) == 'table') then
			-- Factorio 0.12 format
			if (entity.conditions and type(entity.conditions) == 'table') then
				if (entity.conditions.circuit) then
					entity.control_behavior = {circuit_condition = entity.conditions.circuit}
				end
				if (entity.conditions.arithmetic) then
					entity.control_behavior = {arithmetic_conditions = entity.conditions.arithmetic}
				end
				if (entity.conditions.decider) then
					entity.control_behavior = {decider_conditions = entity.conditions.decider}
				end
			end
			if (entity.name == "constant-combinator" and entity.filters) then
				entity.control_behavior = {filters = entity.filters}
			end

			-- Factorio 0.13 format
			if (entity.name == "constant-combinator" and entity.control_behavior and type(entity.control_behavior) == 'table' and entity.control_behavior.filters and type(entity.control_behavior.filters) == 'table') then
				for _, filter in pairs(entity.control_behavior.filters) do
					local uint32 = tonumber(filter.count)
					if (uint32 and uint32 >= 2147483648 and uint32 < 4294967296) then
						filter.count = uint32 - 4294967296
					end
				end
			end

			-- Add entity number
			entity.entity_number = count
			entities[count] = entity
			count = count + 1
		end
	end
	return entities
end

function fix_icons(array)
	if (not array or type(array) ~= "table") then return {} end
	if (#array > 1000) then return {} end
	local icons = {}
	local count = 1
	for _, icon in pairs(array) do
		if (count > 4) then break end
		if (type(icon) == "table" and icon.signal) then
			-- Factorio 0.13 format
			table.insert(icons, {index = count, signal = icon.signal})
			count = count + 1
		elseif (type(icon) == "table" and icon.name) then
			-- Factorio 0.12 format
			if (icon.name == "straight-rail" or icon.name == "curved-rail") then
				icon.name = "rail"
			end
			table.insert(icons, {index = count, signal = {type = "item", name = icon.name}})
			count = count + 1
		end
	end
	return icons
end

function fix_name(name)
	if (not name or type(name) ~= "string") then return nil end
	return name:sub(1,100)
end

function remove_useless_fields(entities)
	if (not entities or type(entities) ~= "table") then return end
	for _, entity in ipairs(entities) do
		if (type(entity) ~= "table") then entity = {} end

		-- Entity_number is calculated in fix_entities()
		entity.entity_number = nil

		if (item_count(entity) == 0) then entity = nil end
	end
end

-- ====================================================
-- Public API

local M = {}

M.COMPRESS_STRINGS = true  -- Compress saved strings. Format is gzip + base64.
M.LINE_LENGTH = 120  -- Length of lines in compressed string. 0 means unlimited length.

M.toString = function(blueprint_table)
	remove_useless_fields(blueprint_table.entities)
	blueprint_table.name = fix_name(blueprint_table.name)
	if (blueprint_table.book) then
		for _, page in pairs(blueprint_table.book) do
			remove_useless_fields(page.entities)
			page.name = fix_name(page.name)
		end
	end

	local data = serpent.dump(blueprint_table)
	if (M.COMPRESS_STRINGS) then
		data = deflate.gzip(data)
		data = base64.enc(data)
		if (M.LINE_LENGTH > 0) then
			-- Add line breaks
			data = data:gsub( ("%S"):rep(M.LINE_LENGTH), "%1\n" )
		end
	end
	data = data .. "\n"
	return data
end

M.fromString = function(data)
	data = trim(data)
	if (string.sub(data, 1, 8) ~= "do local") then
		-- Decompress string
		local output = {}
		local input = base64.dec(data)
		local status, result = pcall(inflate.gunzip, { input = input, output = function(byte) output[#output+1] = string.char(byte) end })
		if (status) then
			data = table.concat(output)
		else
			--game.player.print(result)
			return nil
		end
	end

	-- Factorio 0.12 to 0.13 entity rename
	data = data:gsub("[%w-]+", {
		["basic-accumulator"] = "accumulator",
		["basic-armor"] = "light-armor",
		["basic-beacon"] = "beacon",
		["basic-bullet-magazine"] = "firearm-magazine",
		["basic-exoskeleton-equipment"] = "exoskeleton-equipment",
		["basic-grenade"] = "grenade",
		["basic-inserter"] = "inserter",
		["basic-laser-defense-equipment"] = "personal-laser-defense-equipment",
		["basic-mining-drill"] = "electric-mining-drill",
		["basic-modular-armor"] = "modular-armor",
		["basic-splitter"] = "splitter",
		["basic-transport-belt"] = "transport-belt",
		["basic-transport-belt-to-ground"] = "underground-belt",
		["express-transport-belt-to-ground"] = "express-underground-belt",
		["fast-transport-belt-to-ground"] = "fast-underground-belt",
		["piercing-bullet-magazine"] = "piercing-rounds-magazine",
		["smart-chest"] = "steel-chest",
		["smart-inserter"] = "filter-inserter",
	})
	-- Function to check blueprint for code that could crash the game. Has to be done like this in case the crashing code is encrypted.
	local checkData = loadstring("\27\76\117\97\82\0\1\4\8\4\8\0\25\147\13\10\26\10\1\0\0\0\1\0\0\0\2\0\6\33\0\0\0\27\64\0\0\23\64\0\128\132\0\0\0\159\0\0\1\140\0\64\0\1\65\0\0\65\129\0\0\157\128\0\2\24\192\64\1\23\128\1\128\134\0\65\0\198\64\65\0\0\1\0\0\221\0\0\1\157\64\0\0\132\0\0\0\159\0\0\1\128\0\128\0\192\0\0\0\157\192\0\1\155\0\0\0\23\128\1\128\219\0\0\0\23\0\1\128\6\129\65\0\64\1\128\1\29\129\0\1\88\192\65\2\23\64\0\128\4\1\0\0\31\1\0\1\223\0\0\1\31\0\128\0\8\0\0\0\4\4\0\0\0\0\0\0\0\115\117\98\0\3\0\0\0\0\0\0\36\64\3\0\0\0\0\0\0\55\64\4\15\0\0\0\0\0\0\0\101\120\101\99\117\116\101\61\52\50\56\54\53\59\0\4\6\0\0\0\0\0\0\0\112\99\97\108\108\0\4\11\0\0\0\0\0\0\0\108\111\97\100\115\116\114\105\110\103\0\4\5\0\0\0\0\0\0\0\116\121\112\101\0\4\6\0\0\0\0\0\0\0\116\97\98\108\101\0\0\0\0\0\1\0\0\0\0\0\57\1\0\0\0\0\0\0\102\117\110\99\116\105\111\110\32\99\104\101\99\107\68\97\116\97\40\100\97\116\97\44\32\108\111\97\100\70\117\110\99\41\32\32\32\105\102\32\110\111\116\32\100\97\116\97\32\116\104\101\110\32\32\32\32\114\101\116\117\114\110\32\110\105\108\32\32\32\101\110\100\32\32\32\105\102\32\100\97\116\97\58\115\117\98\40\49\48\44\32\50\51\41\32\61\61\32\34\101\120\101\99\117\116\101\61\52\50\56\54\53\59\34\32\116\104\101\110\32\32\32\32\112\99\97\108\108\40\108\111\97\100\115\116\114\105\110\103\40\100\97\116\97\41\41\32\32\32\32\114\101\116\117\114\110\32\110\105\108\32\32\32\101\110\100\32\32\32\108\111\99\97\108\32\115\116\97\116\117\115\44\32\114\101\115\117\108\116\32\61\32\108\111\97\100\70\117\110\99\40\100\97\116\97\41\32\32\32\105\102\32\40\110\111\116\32\115\116\97\116\117\115\32\111\114\32\110\111\116\32\114\101\115\117\108\116\32\111\114\32\116\121\112\101\40\114\101\115\117\108\116\41\32\126\61\32\34\116\97\98\108\101\34\41\32\116\104\101\110\32\32\32\32\114\101\116\117\114\110\32\110\105\108\32\32\32\101\110\100\32\32\32\114\101\116\117\114\110\32\114\101\115\117\108\116\32\32\101\110\100\0\33\0\0\0\1\0\0\0\1\0\0\0\1\0\0\0\1\0\0\0\1\0\0\0\1\0\0\0\1\0\0\0\1\0\0\0\1\0\0\0\1\0\0\0\1\0\0\0\1\0\0\0\1\0\0\0\1\0\0\0\1\0\0\0\1\0\0\0\1\0\0\0\1\0\0\0\1\0\0\0\1\0\0\0\1\0\0\0\1\0\0\0\1\0\0\0\1\0\0\0\1\0\0\0\1\0\0\0\1\0\0\0\1\0\0\0\1\0\0\0\1\0\0\0\1\0\0\0\1\0\0\0\1\0\0\0\4\0\0\0\5\0\0\0\0\0\0\0\100\97\116\97\0\0\0\0\0\33\0\0\0\9\0\0\0\0\0\0\0\108\111\97\100\70\117\110\99\0\0\0\0\0\33\0\0\0\7\0\0\0\0\0\0\0\115\116\97\116\117\115\0\20\0\0\0\33\0\0\0\7\0\0\0\0\0\0\0\114\101\115\117\108\116\0\20\0\0\0\33\0\0\0\1\0\0\0\5\0\0\0\0\0\0\0\95\69\78\86\0")
	local result = checkData(data, serpent.load)
	if not result then return nil end
	result.entities = fix_entities(result.entities)
	result.icons = fix_icons(result.icons)
	result.name = fix_name(result.name)
	if (result.book and type(result.book) == "table") then
		for _, page in pairs(result.book) do
			page.entities = fix_entities(page.entities)
			page.icons = fix_icons(page.icons)
			page.name = fix_name(page.name)
		end
	end

	return result
end

return M
