ITEM.Name = 'Clock Mask'
ITEM.Price = 50
ITEM.Model = 'models/props_c17/clock01.mdl'
ITEM.Attachment = 'eyes'

function ITEM:OnEquip(ply, modifications)
	ply:PS_AddClientsideModel(self.ID)
end

function ITEM:OnHolster(ply)
	ply:PS_RemoveClientsideModel(self.ID)
end

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
	ang:RotateAroundAxis(ang:Right(), -90)
	
	return model, pos, ang
end

-- This item doesn't have any modifications so we return an empty table
function ITEM:SanitizeTable( modifications )
	return {}
end
