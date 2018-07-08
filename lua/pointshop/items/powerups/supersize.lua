ITEM.Name = 'Super Size'
ITEM.Price = 1000
ITEM.Model = 'models/props_junk/GlassBottle01a.mdl'
ITEM.NoPreview = true

function ITEM:OnEquip(ply, modifications)
	ply:SetModelScale(2, 1)
end

function ITEM:OnHolster(ply)
	ply:SetModelScale(1, 1)
end
