PS.ShopMenu = nil
PS.ClientsideModels = {}

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

-- modification stuff

function PS:ShowColorChooser(item, modifications)
	-- TODO: Do this
	local chooser = vgui.Create('DPointShopColorChooser')
	chooser:SetColor(modifications.color)
	
	chooser.OnChoose = function(color)
		self:SendModifications(item.ID, {color = color})
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
	
	ply:PS_AddClientsideModel(item_id)
end)

net.Receive('PS_RemoveClientsideModel', function(length)
	local ply = net.ReadEntity()
	local item_id = net.ReadString()
	
	ply:PS_RemoveClientsideModel(item_id)
end)

net.Receive('PS_SendClientsideModels', function(length)
	for ply, items in pairs(net.ReadTable()) do
		for _, item_id in pairs(items) do
			if PS.Items[item_id] then
				ply:PS_AddClientsideModel(item_id)
			end
		end
	end
end)

-- hooks

hook.Add('PostPlayerDraw', 'PS_PostPlayerDraw', function(ply)
	if not ply:Alive() then return end
	if ply == LocalPlayer() and GetViewEntity():GetClass() == 'player' then return end
	if not PS.ClientsideModels[ply] then return end
	
	for item_id, model in pairs(PS.ClientsideModels[ply]) do
		if not PS.Items[item_id] then PS.ClientsideModel[ply][item_id] = nil continue end
		
		local ITEM = PS.Items[item_id]
		
		if not ITEM.Attachment and not ITEM.Bone then PS.ClientsideModel[ply][item_id] = nil continue end
		
		local pos = Vector()
		local ang = Angle()
		
		if ITEM.Attachment then
			local attach = ply:GetAttachment(ply:LookupAttachment(ITEM.Attachment))
			pos = attach.Pos
			ang = attach.Ang
		else
			pos, ang = ply:GetBonePosition(ply:LookupBone(ITEM.Bone))
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