--[[
	pointshop/sh_init.lua
	first file included on both states.
]]--

PS = {}
PS.__index = PS

PS.Items = {}
PS.Categories = {}
PS.ClientsideModels = {}

include("sh_config.lua")
include("sh_player_extension.lua")

-- validation

function PS:ValidateItems(items)
	if type(items) ~= 'table' then return {} end
	
	-- Remove any items that no longer exist
	for item_id, item in pairs(items) do
		if not self.Items[item_id] then
			items[item_id] = nil
		end
	end
	
	return items
end

function PS:ValidatePoints(points)
	if type(points) != 'number' then return 0 end
	
	return points >= 0 and points or 0
end

-- Utils

function PS:FindCategoryByName(cat_name)
	for id, cat in pairs(self.Categories) do
		if cat.Name == cat_name then
			return cat
		end
	end
	
	return false
end

-- Initialization

function PS:Initialize()
	if SERVER then self:LoadDataProvider() end
	if SERVER and self.Config.CheckVersion then self:CheckVersion() end

	self:LoadItems()
end

-- Loading

function PS:LoadItems()	
	local _, dirs = file.Find('pointshop/items/*', 'LUA')
	
	for _, category in pairs(dirs) do
		local f, _ = file.Find('pointshop/items/' .. category .. '/__category.lua', 'LUA')
		
		if #f > 0 then
			CATEGORY = {}
			
			CATEGORY.Name = ''
			CATEGORY.Icon = ''
			CATEGORY.Order = 0
			CATEGORY.AllowedEquipped = -1
			CATEGORY.AllowedUserGroups = {}
			CATEGORY.CanPlayerSee = function() return true end
			CATEGORY.ModifyTab = function(tab) return end
			
			if SERVER then AddCSLuaFile('pointshop/items/' .. category .. '/__category.lua') end
			include('pointshop/items/' .. category .. '/__category.lua')
			
			if not PS.Categories[category] then
				PS.Categories[category] = CATEGORY
			end
			
			local files, _ = file.Find('pointshop/items/' .. category .. '/*.lua', 'LUA')
			
			for _, name in pairs(files) do
				if name ~= '__category.lua' then
					if SERVER then AddCSLuaFile('pointshop/items/' .. category .. '/' .. name) end
					
					ITEM = {}
					
					ITEM.__index = ITEM
					ITEM.ID = string.gsub(string.lower(name), '.lua', '')
					ITEM.Category = CATEGORY.Name
					ITEM.Price = 0
					
					-- model and material are missing but there's no way around it, there's a check below anyway
					
					ITEM.AdminOnly = false
					ITEM.AllowedUserGroups = {} -- this will fail the #ITEM.AllowedUserGroups test and continue
					ITEM.SingleUse = false
					ITEM.NoPreview = false
					
					ITEM.CanPlayerBuy = true
					ITEM.CanPlayerSell = true
					
					ITEM.CanPlayerEquip = true
					ITEM.CanPlayerHolster = true

					ITEM.OnBuy = function() end
					ITEM.OnSell = function() end
					ITEM.OnEquip = function() end
					ITEM.OnHolster = function() end
					ITEM.OnModify = function() end
					ITEM.ModifyClientsideModel = function(ITEM, ply, model, pos, ang)
						return model, pos, ang
					end
					
					include('pointshop/items/' .. category .. '/' .. name)
					
					if not ITEM.Name then
						ErrorNoHalt("[POINTSHOP] Item missing name: " .. category .. '/' .. name .. "\n")
						continue
					elseif not ITEM.Price then
						ErrorNoHalt("[POINTSHOP] Item missing price: " .. category .. '/' .. name .. "\n")
						continue
					elseif not ITEM.Model and not ITEM.Material then
						ErrorNoHalt("[POINTSHOP] Item missing model or material: " .. category .. '/' .. name .. "\n")
						continue
					end
					
					-- precache
					
					if ITEM.Model then
						util.PrecacheModel(ITEM.Model)
					end
					
					-- item hooks
					local item = ITEM
					
					for prop, val in pairs(item) do
						if type(val) == "function" then -- although this hooks every function, it doesn't matter because the non-hook functions will never get called
							hook.Add(prop, 'PS_Item_' .. item.Name .. '_' .. prop, function(...)
								for _, ply in pairs(player.GetAll()) do
									if ply:PS_HasItemEquipped(item.ID) then -- hooks are only called if the player has the item equipped
										item[prop](item, ply, ply.PS_Items[item.ID].Modifiers, unpack({...}))
									end
								end
							end)
						end
					end
					
					self.Items[ITEM.ID] = ITEM
					
					ITEM = nil
				end
			end
			
			CATEGORY = nil
		end
	end
end
