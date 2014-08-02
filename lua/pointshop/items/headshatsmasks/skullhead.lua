ITEM.Name = 'Skull Head'
ITEM.Price = 150
ITEM.Model = 'models/Gibs/HGIBS.mdl'
ITEM.Attachment = 'eyes'

function ITEM:OnEquip(ply, modifications)
	ply:PS_AddClientsideModel(self.ID)
end

function ITEM:OnHolster(ply)
	ply:PS_RemoveClientsideModel(self.ID)
end

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
	model:SetModelScale(1.6, 0)
	pos = pos + (ang:Forward() * -2.5)
	ang:RotateAroundAxis(ang:Right(), -15)
	
	return model, pos, ang
end
