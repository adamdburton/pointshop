local PANEL = {}

function PANEL:Init()
	self:SetModel(LocalPlayer():GetModel())
	
	local PrevMins, PrevMaxs = self.Entity:GetRenderBounds()
	self:SetCamPos(PrevMins:Distance(PrevMaxs) * Vector(0.30, 0.30, 0.25) + Vector(0, 0, 15))
	self:SetLookAt((PrevMaxs + PrevMins) / 2)
end

function PANEL:Paint()
	if ( !IsValid( self.Entity ) ) then return end

	local x, y = self:LocalToScreen( 0, 0 )

	self:LayoutEntity( self.Entity )

	local ang = self.aLookAngle
	if ( !ang ) then
		ang = (self.vLookatPos-self.vCamPos):Angle()
	end

	local w, h = self:GetSize()
	cam.Start3D( self.vCamPos, ang, self.fFOV, x, y, w, h, 5, 4096 )
	cam.IgnoreZ( true )

	render.SuppressEngineLighting( true )
	render.SetLightingOrigin( self.Entity:GetPos() )
	render.ResetModelLighting( self.colAmbientLight.r/255, self.colAmbientLight.g/255, self.colAmbientLight.b/255 )
	render.SetColorModulation( self.colColor.r/255, self.colColor.g/255, self.colColor.b/255 )
	render.SetBlend( self.colColor.a/255 )

	for i=0, 6 do
		local col = self.DirectionalLight[ i ]
		if ( col ) then
			render.SetModelLighting( i, col.r/255, col.g/255, col.b/255 )
		end
	end

	self.Entity:DrawModel()

	self:DrawOtherModels()
	
	render.SuppressEngineLighting( false )
	cam.IgnoreZ( false )
	cam.End3D()

	self.LastPaint = RealTime()
end

function PANEL:DrawOtherModels()
	local ply = LocalPlayer()
	
	if PS.ClientsideModels[ply] then
		for item_id, model in pairs(PS.ClientsideModels[ply]) do
			local ITEM = PS.Items[item_id]
			
			if not ITEM.Attachment and not ITEM.Bone then PS.ClientsideModel[ply][item_id] = nil continue end
			
			local pos = Vector()
			local ang = Angle()
			
			if ITEM.Attachment then
				local attach_id = self.Entity:LookupAttachment(ITEM.Attachment)
				if not attach_id then return end
				
				local attach = self.Entity:GetAttachment(attach_id)
				
				if not attach then return end
				
				pos = attach.Pos
				ang = attach.Ang
			else
				local bone_id = self.Entity:LookupBone(ITEM.Bone)
				if not bone_id then return end
				
				pos, ang = self.Entity:GetBonePosition(bone_id)
			end
			
			model, pos, ang = ITEM:ModifyClientsideModel(ply, model, pos, ang)
			
			model:SetPos(pos)
			model:SetAngles(ang)
			
			model:DrawModel()
		end
	end
	
	if PS.HoverModel then
		local ITEM = PS.Items[PS.HoverModel]
		
		if ITEM.NoPreview then return end -- don't show
		if ITEM.WeaponClass then return end -- hack for weapons
		
		if not ITEM.Attachment and not ITEM.Bone then -- must be a playermodel?
			self:SetModel(ITEM.Model)
		else
			local model = PS.HoverModelClientsideModel
			
			local pos = Vector()
			local ang = Angle()
			
			if ITEM.Attachment then
				local attach_id = self.Entity:LookupAttachment(ITEM.Attachment)
				if not attach_id then return end
				
				local attach = self.Entity:GetAttachment(attach_id)
				
				if not attach then return end
				
				pos = attach.Pos
				ang = attach.Ang
			else
				local bone_id = self.Entity:LookupBone(ITEM.Bone)
				if not bone_id then return end
				
				pos, ang = self.Entity:GetBonePosition(bone_id)
			end
			
			model, pos, ang = ITEM:ModifyClientsideModel(ply, model, pos, ang)
			
			model:SetPos(pos)
			model:SetAngles(ang)
			
			model:DrawModel()
		end
	else
		self:SetModel(LocalPlayer():GetModel())
	end
end

vgui.Register('DPointShopPreview', PANEL, 'DModelPanel')
