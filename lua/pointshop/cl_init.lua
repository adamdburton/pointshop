--[[
	pointshop/cl_init.lua
	first file included clientside.
]]--

include "sh_init.lua"
include "cl_player_extension.lua"

include "vgui/DPointShopMenu.lua"
include "vgui/DPointShopItem.lua"
include "vgui/DPointShopPreview.lua"
include "vgui/DPointShopColorChooser.lua"
include "vgui/DPointShopGivePoints.lua"

PS.ShopMenu = nil
PS.ClientsideModels = {}

PS.HoverModel = nil
PS.HoverModelClientsideModel = nil

local invalidplayeritems = {}

-- menu stuff

function PS:ToggleMenu()
	if not PS.ShopMenu then
		PS.ShopMenu = vgui.Create('DPointShopMenu')
		PS.ShopMenu:SetVisible(false)
	end
	
	if PS.ShopMenu:IsVisible() then
		PS.ShopMenu:Hide()
		gui.EnableScreenClicker(false)
	else
		PS.ShopMenu:Show()
		gui.EnableScreenClicker(true)
	end
end

function PS:SetHoverItem(item_id)
	local ITEM = PS.Items[item_id]
	
	if ITEM.Model then
		self.HoverModel = item_id
	
		self.HoverModelClientsideModel = ClientsideModel(ITEM.Model, RENDERGROUP_OPAQUE)
		self.HoverModelClientsideModel:SetNoDraw(true)
	end
end

function PS:RemoveHoverItem()
	self.HoverModel = nil
	self.HoverModelClientsideModel = nil
end

-- modification stuff

function PS:ShowColorChooser(item, modifications)
	-- TODO: Do this
	local chooser = vgui.Create('DPointShopColorChooser')
	chooser:SetColor(modifications.color)
	
	chooser.OnChoose = function(color)
		modifications.color = color
		self:SendModifications(item.ID, modifications)
	end
end

function PS:SendModifications(item_id, modifications)
	net.Start('PS_ModifyItem')
		net.WriteString(item_id)
		net.WriteTable(modifications)
	net.SendToServer()
end

-- net hooks

net.Receive('PS_ToggleMenu', function(length)
	PS:ToggleMenu()
end)

net.Receive('PS_Items', function(length)
	local ply = net.ReadEntity()
	local items = net.ReadTable()
	ply.PS_Items = PS:ValidateItems(items)
end)

net.Receive('PS_Points', function(length)
	local ply = net.ReadEntity()
	local points = net.ReadInt(32)
	ply.PS_Points = PS:ValidatePoints(points)
end)

net.Receive('PS_AddClientsideModel', function(length)
	local ply = net.ReadEntity()
	local item_id = net.ReadString()
	
	if not IsValid(ply) then
		if not invalidplayeritems[ply] then
			invalidplayeritems[ply] = {}
		end
		
		table.insert(invalidplayeritems[ply], item_id)
		return
	end
	
	ply:PS_AddClientsideModel(item_id)
end)

net.Receive('PS_RemoveClientsideModel', function(length)
	local ply = net.ReadEntity()
	local item_id = net.ReadString()
	
	if not ply or not IsValid(ply) or not ply:IsPlayer() then return end
	
	ply:PS_RemoveClientsideModel(item_id)
end)

net.Receive('PS_SendClientsideModels', function(length)
	local itms = net.ReadTable()
	
	for ply, items in pairs(itms) do
		if not IsValid(ply) then -- skip if the player isn't valid yet and add them to the table to sort out later
			invalidplayeritems[ply] = items
			continue
		end
			
		for _, item_id in pairs(items) do
			if PS.Items[item_id] then
				ply:PS_AddClientsideModel(item_id)
			end
		end
	end
end)

net.Receive('PS_SendNotification', function(length)
	local str = net.ReadString()
	notification.AddLegacy(str, NOTIFY_GENERIC, 5)
end)

-- hooks

hook.Add('Think', 'PS_Think', function()
	for ply, items in pairs(invalidplayeritems) do
		if IsValid(ply) then
			for _, item_id in pairs(items) do
				if PS.Items[item_id] then
					ply:PS_AddClientsideModel(item_id)
				end
			end
			
			invalidplayeritems[ply] = nil
		end
	end
end)

hook.Add('PostPlayerDraw', 'PS_PostPlayerDraw', function(ply)
	if not ply:Alive() then return end
	if ply == LocalPlayer() and GetViewEntity():GetClass() == 'player' and (GetConVar('thirdperson') and GetConVar('thirdperson'):GetInt() == 0) then return end
	if not PS.ClientsideModels[ply] then return end
	
	for item_id, model in pairs(PS.ClientsideModels[ply]) do
		if not PS.Items[item_id] then PS.ClientsideModel[ply][item_id] = nil continue end
		
		local ITEM = PS.Items[item_id]
		
		if not ITEM.Attachment and not ITEM.Bone then PS.ClientsideModel[ply][item_id] = nil continue end
		
		local pos = Vector()
		local ang = Angle()
		
		if ITEM.Attachment then
			local attach_id = ply:LookupAttachment(ITEM.Attachment)
			if not attach_id then return end
			
			local attach = ply:GetAttachment(attach_id)
			
			if not attach then return end
			
			pos = attach.Pos
			ang = attach.Ang
		else
			local bone_id = ply:LookupBone(ITEM.Bone)
			if not bone_id then return end
			
			pos, ang = ply:GetBonePosition(bone_id)
		end
		
		model, pos, ang = ITEM:ModifyClientsideModel(ply, model, pos, ang)
		
		model:SetPos(pos)
		model:SetAngles(ang)

		model:SetRenderOrigin(pos)
		model:SetRenderAngles(ang)
		model:SetupBones()
		model:DrawModel()
		model:SetRenderOrigin()
		model:SetRenderAngles()
	end
end)
