ITEM.Name = 'Monitor Head'
ITEM.Price = 100
ITEM.Model = 'models/props_lab/monitor02.mdl'
ITEM.Attachment = 'eyes'

function ITEM:OnEquip(ply, modifications)
	ply:PS_AddClientsideModel(self.ID)
end

function ITEM:OnHolster(ply)
	ply:PS_RemoveClientsideModel(self.ID)
end

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
	model:SetModelScale(0.75, 0)
	pos = pos + (ang:Forward() * -5) + (ang:Up() * -5)
	
	return model, pos, ang
end
