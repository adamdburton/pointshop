ITEM.Name = 'Bucket Hat'
ITEM.Price = 100
ITEM.Model = 'models/props_junk/MetalBucket01a.mdl'
ITEM.Attachment = 'eyes'

function ITEM:OnEquip(ply)
	ply:PS_AddClientsideModel(self.ID)
end

function ITEM:OnHolster(ply)
	ply:PS_RemoveClientsideModel(self.ID)
end

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
	model:SetModelScale(0.7, 0)
	pos = pos + (ang:Forward() * -5) + (ang:Up() * 5)
	ang:RotateAroundAxis(ang:Right(), 200)
	
	return model, pos, ang
end
