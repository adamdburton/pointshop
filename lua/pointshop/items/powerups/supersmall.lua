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

-- This item doesn't have any modifications so we return an empty table
function ITEM:SanitizeTable( modifications )
	return {}
end
