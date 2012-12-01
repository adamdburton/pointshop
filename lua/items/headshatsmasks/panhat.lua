ITEM.Name = 'Pan Hat'
ITEM.Price = 100
ITEM.Model = 'models/props_interiors/pot02a.mdl'
ITEM.Attachment = 'eyes'

function ITEM:OnEquip(ply, modifications)
	ply:PS_AddClientsideModel(self.ID)
end

function ITEM:OnHolster(ply)
	ply:PS_RemoveClientsideModel(self.ID)
end

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
	pos = pos + (ang:Forward() * -3) + (ang:Up() * 2) + (ang:Right() * 5.5)
	ang:RotateAroundAxis(ang:Right(), 180)
	
	return model, pos, ang
end
