ITEM.Name = 'Super Small'
ITEM.Price = 1000
ITEM.Model = 'models/props_junk/garbage_glassbottle003a.mdl'
ITEM.NoPreview = true

function ITEM:OnEquip(ply, modifications)
	ply:SetModelScale(0.5, 1)
end

function ITEM:OnHolster(ply)
	ply:SetModelScale(1, 1)
end
