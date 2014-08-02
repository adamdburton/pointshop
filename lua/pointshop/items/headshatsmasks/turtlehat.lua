ITEM.Name = 'Turtle Hat'
ITEM.Price = 100
ITEM.Model = 'models/props/de_tides/Vending_turtle.mdl'
ITEM.Attachment = 'eyes'

function ITEM:OnEquip(ply, modifications)
	ply:PS_AddClientsideModel(self.ID)
end

function ITEM:OnHolster(ply)
	ply:PS_RemoveClientsideModel(self.ID)
end

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
	pos = pos + (ang:Forward() * -3)
	ang:RotateAroundAxis(ang:Up(), -90)
	
	return model, pos, ang
end
