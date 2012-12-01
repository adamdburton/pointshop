ITEM.Name = 'Snowman Head'
ITEM.Price = 200
ITEM.Model = 'models/props/cs_office/Snowman_face.mdl'
ITEM.Attachment = 'eyes'

function ITEM:OnEquip(ply, modifications)
	ply:PS_AddClientsideModel(self.ID)
end

function ITEM:OnHolster(ply)
	ply:PS_RemoveClientsideModel(self.ID)
end

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
	pos = pos + (ang:Forward() * -2.2)
	ang:RotateAroundAxis(ang:Up(), -90)
	
	return model, pos, ang
end
