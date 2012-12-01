ITEM.Name = 'Bomb Head'
ITEM.Price = 100
ITEM.Model = 'models/Combine_Helicopter/helicopter_bomb01.mdl'
ITEM.Attachment = 'eyes'

function ITEM:OnEquip(ply, modifications)
	ply:PS_AddClientsideModel(self.ID)
end

function ITEM:OnHolster(ply)
	ply:PS_RemoveClientsideModel(self.ID)
end

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
	model:SetModelScale(0.5, 0)
	pos = pos + (ang:Forward() * -2)
	ang:RotateAroundAxis(ang:Right(), 90)
	
	return model, pos, ang
end
