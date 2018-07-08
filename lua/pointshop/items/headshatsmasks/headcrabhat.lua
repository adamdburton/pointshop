ITEM.Name = 'Headcrab Hat'
ITEM.Price = 100
ITEM.Model = 'models/headcrabclassic.mdl'
ITEM.Attachment = 'eyes'
ITEM.AdminOnly = true

function ITEM:OnEquip(ply, modifications)
	ply:PS_AddClientsideModel(self.ID)
end

function ITEM:OnHolster(ply)
	ply:PS_RemoveClientsideModel(self.ID)
end

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
	model:SetModelScale(0.7, 0)
	pos = pos + (ang:Forward() * 2)
	ang:RotateAroundAxis(ang:Right(), 20)
	
	return model, pos, ang
end
