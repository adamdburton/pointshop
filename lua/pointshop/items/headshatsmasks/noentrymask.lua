ITEM.Name = 'No Entry Mask'
ITEM.Price = 50
ITEM.Model = 'models/props_c17/streetsign004f.mdl'
ITEM.Attachment = 'eyes'

function ITEM:OnEquip(ply, modifications)
	ply:PS_AddClientsideModel(self.ID)
end

function ITEM:OnHolster(ply)
	ply:PS_RemoveClientsideModel(self.ID)
end

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
	model:SetModelScale(0.7, 0)
	pos = pos + (ang:Forward() * 3)
	ang:RotateAroundAxis(ang:Up(), -90)
	
	return model, pos, ang
end
