local Player = FindMetaTable('Player')

function Player:PS_PlayerSpawn()
	if not self:Alive() then return end
	if self.IsSpec and self:IsSpec() then return end
	
	timer.Simple(1, function()
		for item_id, item in pairs(self.PS_Items) do
			local ITEM = PS.Items[item_id]
			if item.Equipped then
				ITEM:OnEquip(self, item.Modifiers)
			end
		end
	end)
end

function Player:PS_PlayerDeath(rar)
	for item_id, item in pairs(self.PS_Items) do
		if item.Equipped then
			local ITEM = PS.Items[item_id]
			ITEM:OnHolster(self, item.Modifiers)
		end
	end
end

function Player:PS_Initialize()
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
end

function Player:PS_Save()
	self:SetPData('PS_Items', util.TableToJSON(self.PS_Items))
	self:SetPData('PS_Points', self.PS_Points)
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

	if not self:PS_HasPoints(ITEM.Price) then return false end
	
	if not self:IsAdmin() and ITEM.AdminOnly then
		self:PS_Notify('This item is Admin only!')
		return false
	end

	if ITEM.SingleShipment and ITEM.VerifySingleShipment then -- Is a single shipment and has a func to verify if it's okay to ship right now
		local verifybool, verifymsg = ITEM:VerifySingleShipment(self)
		if not verifybool then
			local msg = verifymsg or 'This item can not be bought right now!' -- If verifymsg wasn't returned we use the default one
			self:PS_Notify(msg)
			return false
		end
	end
	
	self:PS_TakePoints(ITEM.Price)
	
	self:PS_Notify('Bought ', ITEM.Name, ' for ', ITEM.Price, ' points.')
	
	ITEM:OnBuy(self)
	
	if ITEM.SingleShipment then -- It was a single shipment so we'll ship right away and forget about it
		ITEM:OnEquip(self)
		return true
	end
	return self:PS_GiveItem(item_id)
end

function Player:PS_SellItem(item_id)
	if not PS.Items[item_id] then return false end
	if not self:PS_HasItem(item_id) then return false end
	
	local ITEM = PS.Items[item_id]
	local points = PS.Config.CalculateSellPrice(ITEM.Price)
	
	self:PS_GivePoints(points)
	
	ITEM:OnHolster(self)
	ITEM:OnSell(self)
	
	self:PS_Notify('Sold ', ITEM.Name, ' for ', points, ' points.')
	
	return self:PS_TakeItem(item_id)
end

function Player:PS_HasItem(item_id)
	return self.PS_Items[item_id] or false
end

-- equip/hoster items

function Player:PS_EquipItem(item_id)
	if not PS.Items[item_id] then return false end
	if not self:PS_HasItem(item_id) then return false end
	if not self:Alive() then return false end
	
	self.PS_Items[item_id].Equipped = true
	
	local ITEM = PS.Items[item_id]
	ITEM:OnEquip(self, self.PS_Items[item_id].Modifiers)
	
	self:PS_SendItems()
end

function Player:PS_HolsterItem(item_id)
	if not PS.Items[item_id] then return false end
	if not self:PS_HasItem(item_id) then return false end
	if not self:Alive() then return false end
	
	self.PS_Items[item_id].Equipped = false
	
	local ITEM = PS.Items[item_id]
	ITEM:OnHolster(self)
	
	self:PS_SendItems()
end

-- modify items

function Player:PS_ModifyItem(item_id, modifications)
	if not PS.Items[item_id] then return false end
	if not self:PS_HasItem(item_id) then return false end
	
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
	local str = table.concat({...}, ' ')
	self:SendLua('notification.AddLegacy("' .. str .. '", NOTIFY_GENERIC, 5)')
end
