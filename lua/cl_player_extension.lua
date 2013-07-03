local Player = FindMetaTable('Player')

-- items

function Player:PS_GetItems()
	return self.PS_Items or {}
end

function Player:PS_HasItem(item_id)
	if not self.PS_Items then return false end
	return self.PS_Items[item_id] and true or false
end

function Player:PS_HasItemEquipped(item_id)
	if not self:PS_HasItem(item_id) then return false end
	
	return self.PS_Items[item_id].Equipped or false
end

function Player:PS_BuyItem(item_id)
	if self:PS_HasItem(item_id) then return false end
	if not self:PS_HasPoints(PS.Config.CalculateBuyPrice(self, PS.Items[item_id])) then return false end
	
	net.Start('PS_BuyItem')
		net.WriteString(item_id)
	net.SendToServer()
end

function Player:PS_SellItem(item_id)
	if not self:PS_HasItem(item_id) then return false end
	
	net.Start('PS_SellItem')
		net.WriteString(item_id)
	net.SendToServer()
end

function Player:PS_EquipItem(item_id)
	if not self:PS_HasItem(item_id) then return false end
	
	net.Start('PS_EquipItem')
		net.WriteString(item_id)
	net.SendToServer()
end

function Player:PS_HolsterItem(item_id)
	if not self:PS_HasItem(item_id) then return false end
	
	net.Start('PS_HolsterItem')
		net.WriteString(item_id)
	net.SendToServer()
end

-- points

function Player:PS_GetPoints()
	return self.PS_Points or 0
end

function Player:PS_HasPoints(points)
	return self:PS_GetPoints() >= points
end

-- clientside models

function Player:PS_AddClientsideModel(item_id)
	if not PS.Items[item_id] then return false end
	
	local ITEM = PS.Items[item_id]
	
	local mdl = ClientsideModel(ITEM.Model, RENDERGROUP_OPAQUE)
	mdl:SetNoDraw(true)
	
	if not PS.ClientsideModels[self] then PS.ClientsideModels[self] = {} end
	PS.ClientsideModels[self][item_id] = mdl
end

function Player:PS_RemoveClientsideModel(item_id)
	if not PS.Items[item_id] then return false end
	if not PS.ClientsideModels[self] then return false end
	if not PS.ClientsideModels[self][item_id] then return false end
	
	PS.ClientsideModels[self][item_id] = nil
end
