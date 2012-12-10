PS = {}
PS.__index = PS

PS.Items = {}
PS.Categories = {}
PS.ClientsideModels = {}

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

function PS:LoadItems()	
	local _, dirs = file.Find('items/*', 'LUA')
	
	for _, category in pairs(dirs) do
		local f, _ = file.Find('items/' .. category .. '/__category.lua', 'LUA')
		
		if #f > 0 then
			CATEGORY = {}
			
			CATEGORY.Name = ''
			CATEGORY.Icon = ''
			CATEGORY.AllowedEquiped = -1
			
			if SERVER then AddCSLuaFile('items/' .. category .. '/__category.lua') end
			include('items/' .. category .. '/__category.lua')
			
			if not PS.Categories[category] then
				PS.Categories[category] = CATEGORY
			end
			
			local files, _ = file.Find('items/' .. category .. '/*.lua', 'LUA')
			
			for _, name in pairs(files) do
				if name ~= '__category.lua' then
					if SERVER then AddCSLuaFile('items/' .. category .. '/' .. name) end
					
					ITEM = {}
					
					ITEM.__index = ITEM
					ITEM.ID = string.gsub(name, '.lua', '')
					ITEM.Category = CATEGORY.Name
					ITEM.Price = 0
					
					-- model and material are missing
					
					ITEM.AdminOnly = false
					ITEM.AllowedUserGroups = {} -- thie will fail the #ITEM.AllowedUserGroups test and continue
					ITEM.SingleUse = false
					
					ITEM.OnBuy = function() end
					ITEM.OnSell = function() end
					ITEM.OnEquip = function() end
					ITEM.OnHolster = function() end
					ITEM.CanPlayerBuy = function() return true end
					ITEM.ModifyClientsideModel = function(s, ply, model, pos, ang)
						return model, pos, ang
					end
					
					include('items/' .. category .. '/' .. name)
					
					if not ITEM.Name then
						ErrorNoHalt("Item missing name: " .. category .. '/' .. name)
					end
					
					if not ITEM.Price then
						ErrorNoHalt("Item missing price: " .. category .. '/' .. name)
					end
					
					if not ITEM.Model and not ITEM.Material then
						ErrorNoHalt("Item missing model or material: " .. category .. '/' .. name)
					end
					
					self.Items[ITEM.ID] = ITEM
					
					ITEM = nil
				end
			end
		end
	end
end