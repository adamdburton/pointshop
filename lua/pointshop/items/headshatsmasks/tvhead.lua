ITEM.Name = 'TV Head'
ITEM.Price = 100
ITEM.Model = 'models/props_c17/tv_monitor01.mdl'
ITEM.Attachment = 'eyes'

function ITEM:OnEquip(ply, modifications)
	ply:PS_AddClientsideModel(self.ID)
end

function ITEM:OnHolster(ply)
	ply:PS_RemoveClientsideModel(self.ID)
end

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
	model:SetModelScale(0.8, 0)
	pos = pos + (ang:Right() * -2) + (ang:Forward() * -3) + (ang:Up() * 0.5)
	
	return model, pos, ang
end
