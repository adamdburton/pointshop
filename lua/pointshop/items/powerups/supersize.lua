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

-- This item doesn't have any modifications so we return an empty table
function ITEM:SanitizeTable( modifications )
	return {}
end
