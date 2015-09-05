if ITEM == nil then
	ITEM = {}
end

ITEM.Name = 'Jump Pack'
ITEM.Price = 1000
ITEM.Model = 'models/xqm/jetengine.mdl'
ITEM.Bone = 'ValveBiped.Bip01_Spine2'

function ITEM:OnEquip(ply, modifications)
	ply:PS_AddClientsideModel(self.ID)
end

function ITEM:OnHolster(ply)
	ply:PS_RemoveClientsideModel(self.ID)
end

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
	model:SetModelScale(0.5, 0)
	pos = pos + (ang:Right() * 7) + (ang:Forward() * 6)
	
	return model, pos, ang
end

function ITEM:Think(ply, modifications)
	if ply:KeyDown(IN_JUMP) then
		ply:SetVelocity(ply:GetUp() * 6)
	end
end