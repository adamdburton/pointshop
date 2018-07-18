ITEM.Name = 'Backpack'
ITEM.Price = 100
ITEM.Model = 'models/props_c17/SuitCase_Passenger_Physics.mdl'
ITEM.Bone = 'ValveBiped.Bip01_Spine2'

function ITEM:OnEquip(ply, modifications)
	ply:PS_AddClientsideModel(self.ID)
end

function ITEM:OnHolster(ply)
	ply:PS_RemoveClientsideModel(self.ID)
end

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
	model:SetModelScale(0.8, 0)
	pos = pos + (ang:Right() * 5) + (ang:Up() * 6) + (ang:Forward() * 2)
	
	return model, pos, ang
end