ITEM.Name = 'Lampshade Hat'
ITEM.Price = 100
ITEM.Model = 'models/props_c17/lampShade001a.mdl'
ITEM.Attachment = 'eyes'

function ITEM:OnEquip(ply, modifications)
	ply:PS_AddClientsideModel(self.ID)
end

function ITEM:OnHolster(ply)
	ply:PS_RemoveClientsideModel(self.ID)
end

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
	model:SetModelScale(0.7, 0)
	pos = pos + (ang:Forward() * -3.5) + (ang:Up() * 4)
	ang:RotateAroundAxis(ang:Right(), 10)
	
	return model, pos, ang
end
