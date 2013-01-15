local Player = FindMetaTable('Player')

function Player:PS_PlayerSpawn()
	if not self:PS_CanPerformAction() then return end
	
	-- TTT ( and others ) Fix
	if ( ( TEAM_SPECTATOR != nil ) and ( self:Team() == TEAM_SPECTATOR ) ) then return end
	
	timer.Simple(1, function()
		for item_id, item in pairs(self.PS_Items) do
			local ITEM = PS.Items[item_id]
			if item.Equipped then
				ITEM:OnEquip(self, item.Modifiers)
			end
		end
	end)
end

function Player:PS_PlayerDeath()
	for item_id, item in pairs(self.PS_Items) do
		if item.Equipped then
			local ITEM = PS.Items[item_id]
			ITEM:OnHolster(self, item.Modifiers)
		end
	end
end

function Player:PS_PlayerInitialSpawn()
	self.PS_Items = {}
	self.PS_Points = 0
	
	self.PS_Items = PS:ValidateItems(util.JSONToTable(self:GetPData('PS_Items', '[]')))
	self.PS_Points = PS:ValidatePoints(tonumber(self:GetPData('PS_Points')))
	
	-- Send stuff
	timer.Simple(1, function()
		self:PS_SendItems()
		self:PS_SendPoints()
		self:PS_SendClientsideModels()
	end)
	
	if PS.Config.NotifyOnJoin then
		if PS.Config.ShopKey ~= '' then
			timer.Simple(5, function() -- Give them time to load up
				self:PS_Notify('Press ' .. PS.Config.ShopKey .. ' to open PointShop!')
			end)
		end
		
		if PS.Config.ShopCommand ~= '' then
			timer.Simple(5, function() -- Give them time to load up
				self:PS_Notify('Type ' .. PS.Config.ShopCommand .. ' in console to open PointShop!')
			end)
		end
		
		if PS.Config.ShopChatCommand ~= '' then
			timer.Simple(5, function() -- Give them time to load up
				self:PS_Notify('Type ' .. PS.Config.ShopChatCommand .. ' in chat to open PointShop!')
			end)
		end
		
		timer.Simple(10, function() -- Give them time to load up
			self:PS_Notify('You have ' .. self:PS_GetPoints() .. ' points to spend!')
		end)
	end
	
	if PS.Config.PointsOverTime then
		timer.Create('PS_PointsOverTime_' .. self:UniqueID(), PS.Config.PointsOverTimeDelay * 60, 0, function()
			self:PS_GivePoints(PS.Config.PointsOverTimeAmount)
			self:PS_Notify("You've been given ", PS.Config.PointsOverTimeAmount, " points for playing on the server!")
		end)
	end
end

function Player:PS_PlayerDisconnected()
	self:PS_Save()
	PS.ClientsideModels[self] = nil
	
	if timer.Exists('PS_PointsOverTime_' .. self:UniqueID()) then
		timer.Destroy('PS_PointsOverTime_' .. self:UniqueID())
	end
end

function Player:PS_Save()
	self:SetPData('PS_Items', util.TableToJSON(self.PS_Items))
	self:SetPData('PS_Points', self.PS_Points)
end

function Player:PS_CanPerformAction()
	local allowed = true
	
	if self.IsSpec and self:IsSpec() then allowed = false end
	if not self:Alive() then allowed = false end
	
	if not allowed then
		self:PS_Notify('You\'re not allowed to do that at the moment!')
	end
	
	return allowed
end

-- points

function Player:PS_GivePoints(points)
	self.PS_Points = self.PS_Points + points
	self:PS_SendPoints()
end

function Player:PS_TakePoints(points)
	self.PS_Points = self.PS_Points - points >= 0 and self.PS_Points - points or 0
	self:PS_SendPoints()
end

function Player:PS_SetPoints(points)
	self.PS_Points = points
	self:PS_SendPoints()
end

function Player:PS_GetPoints()
	return self.PS_Points and self.PS_Points or 0
end

function Player:PS_HasPoints(points)
	return self.PS_Points >= points
end

-- give/take items

function Player:PS_GiveItem(item_id)
	if not PS.Items[item_id] then return false end
	
	self.PS_Items[item_id] = { Modifiers = {}, Equipped = false }
	
	self:PS_SendItems()
	
	return true
end

function Player:PS_TakeItem(item_id)
	if not PS.Items[item_id] then return false end
	if not self:PS_HasItem(item_id) then return false end
	
	self.PS_Items[item_id] = nil
	
	self:PS_SendItems()
	
	return true
end

-- buy/sell items

function Player:PS_BuyItem(item_id)
	local ITEM = PS.Items[item_id]
	if not ITEM then return false end
	
	local points = PS.Config.CalculateBuyPrice(self, ITEM)
	
	if not self:PS_HasPoints(points) then return false end
	if not self:PS_CanPerformAction() then return end
	
	if ITEM.AdminOnly and not self:IsAdmin() then
		self:PS_Notify('This item is Admin only!')
		return false
	end
	
	if ITEM.AllowedUserGroups and #ITEM.AllowedUserGroups > 0 then
		local allowed = false
		
		for _, ug in pairs(ITEM.AllowedUserGroups) do
			if self:IsUserGroup(ug) then
				allowed = true
			end
		end
		
		if not allowed then
			self:PS_Notify('You\'re not in the right group to buy this item!')
			return false
		end
	end
	
	local cat_name = ITEM.Category
	local CATEGORY = PS:FindCategoryByName(cat_name)
	
	if CATEGORY.AllowedUserGroups and #CATEGORY.AllowedUserGroups > 0 then
		local allowed = false
		
		for _, ug in pairs(CATEGORY.AllowedUserGroups) do
			if self:IsUserGroup(ug) then
				allowed = true
			end
		end
		
		if not allowed then
			self:PS_Notify('You\'re not in the right group to buy this item!')
			return false
		end
	end
	
	if ITEM.CanPlayerBuy then -- should exist but we'll check anyway
		local allowed, message = ITEM:CanPlayerBuy(self)
		
		if not allowed then
			self:PS_Notify(message or 'You\'re not allowed to buy this item!')
			return false
		end
	end
	
	self:PS_TakePoints(points)
	
	self:PS_Notify('Bought ', ITEM.Name, ' for ', points, ' points.')
	
	ITEM:OnBuy(self)
	
	if ITEM.SingleUse then
		self:PS_Notify('Single use item. You\'ll have to buy this item again next time!')
		return
	end

	self:PS_GiveItem(item_id)
	self:PS_EquipItem(item_id)
end

function Player:PS_SellItem(item_id)
	if not PS.Items[item_id] then return false end
	if not self:PS_HasItem(item_id) then return false end
	
	local ITEM = PS.Items[item_id]
	local points = PS.Config.CalculateSellPrice(self, ITEM)
	
	self:PS_GivePoints(points)
	
	ITEM:OnHolster(self)
	ITEM:OnSell(self)
	
	self:PS_Notify('Sold ', ITEM.Name, ' for ', points, ' points.')
	
	return self:PS_TakeItem(item_id)
end

function Player:PS_HasItem(item_id)
	return self.PS_Items[item_id] or false
end

function Player:PS_HasItemEquipped(item_id)
	if not self:PS_HasItem(item_id) then return false end
	
	return self.PS_Items[item_id].Equipped or false
end

function Player:PS_NumItemsEquippedFromCategory(cat_name)
	local count = 0
	
	for item_id, item in pairs(self.PS_Items) do
		local ITEM = PS.Items[item_id]
		if ITEM.Category == cat_name and item.Equipped then
			count = count + 1
		end
	end
	
	return count
end

-- equip/hoster items

function Player:PS_EquipItem(item_id)
	if not PS.Items[item_id] then return false end
	if not self:PS_HasItem(item_id) then return false end
	if not self:PS_CanPerformAction() then return false end
	
	local ITEM = PS.Items[item_id]
	
	local cat_name = ITEM.Category
	local CATEGORY = PS:FindCategoryByName(cat_name)
	
	if CATEGORY and CATEGORY.AllowedEquipped > -1 then
		if self:PS_NumItemsEquippedFromCategory(cat_name) + 1 > CATEGORY.AllowedEquipped then
			self:PS_Notify('Only ' .. CATEGORY.AllowedEquipped .. ' item' .. (CATEGORY.AllowedEquipped == 1 and '' or 's') .. ' can be equipped from this category!')
			return false
		end
	end
	
	self.PS_Items[item_id].Equipped = true
	
	ITEM:OnEquip(self, self.PS_Items[item_id].Modifiers)
	
	self:PS_Notify('Equipped ', ITEM.Name, '.')
	
	self:PS_SendItems()
end

function Player:PS_HolsterItem(item_id)
	if not PS.Items[item_id] then return false end
	if not self:PS_HasItem(item_id) then return false end
	if not self:PS_CanPerformAction() then return false end
	
	self.PS_Items[item_id].Equipped = false
	
	local ITEM = PS.Items[item_id]
	ITEM:OnHolster(self)
	
	self:PS_Notify('Holstered ', ITEM.Name, '.')
	
	self:PS_SendItems()
end

-- modify items

function Player:PS_ModifyItem(item_id, modifications)
	if not PS.Items[item_id] then return false end
	if not self:PS_HasItem(item_id) then return false end
	if not type(modifications) == "table" then return false end
	if not self:PS_CanPerformAction() then return false end
	
	local ITEM = PS.Items[item_id]
	
	for key, value in pairs(modifications) do
		self.PS_Items[item_id].Modifiers[key] = value
	end
	
	ITEM:OnModify(self, self.PS_Items[item_id].Modifiers)
	
	self:PS_SendItems()
end

-- clientside Models

function Player:PS_AddClientsideModel(item_id)
	if not PS.Items[item_id] then return false end
	if not self:PS_HasItem(item_id) then return false end
	
	net.Start('PS_AddClientsideModel')
		net.WriteEntity(self)
		net.WriteString(item_id)
	net.Broadcast()
	
	if not PS.ClientsideModels[self] then PS.ClientsideModels[self] = {} end
	
	PS.ClientsideModels[self][item_id] = item_id
end

function Player:PS_RemoveClientsideModel(item_id)
	if not PS.Items[item_id] then return false end
	if not self:PS_HasItem(item_id) then return false end
	if not PS.ClientsideModels[self] or not PS.ClientsideModels[self][item_id] then return false end
	
	net.Start('PS_RemoveClientsideModel')
		net.WriteEntity(self)
		net.WriteString(item_id)
	net.Broadcast()
	
	PS.ClientsideModels[self][item_id] = nil
end

-- menu stuff

function Player:PS_ToggleMenu(show)
	net.Start('PS_ToggleMenu')
	net.Send(self)
end

-- send stuff

function Player:PS_SendPoints()
	self:PS_Save()
	
	net.Start('PS_Points')
		net.WriteEntity(self)
		net.WriteInt(self.PS_Points, 32)
	net.Broadcast()
end

function Player:PS_SendItems()
	self:PS_Save()
	
	net.Start('PS_Items')
		net.WriteEntity(self)
		net.WriteTable(self.PS_Items)
	net.Broadcast()
end

function Player:PS_SendClientsideModels()	
	net.Start('PS_SendClientsideModels')
		net.WriteTable(PS.ClientsideModels)
	net.Send(self)
end

-- notifications

function Player:PS_Notify(...)
	local str = table.concat({...}, '')
	self:SendLua('notification.AddLegacy("' .. str .. '", NOTIFY_GENERIC, 5)')
end
