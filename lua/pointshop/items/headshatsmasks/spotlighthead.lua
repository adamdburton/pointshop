ITEM.Name = 'Spotlight Head'
ITEM.Price = 100
ITEM.Model = 'models/props_wasteland/light_spotlight01_lamp.mdl'
ITEM.Attachment = 'eyes'

function ITEM:OnEquip(ply, modifications)
	ply:PS_AddClientsideModel(self.ID)
end

function ITEM:OnHolster(ply)
	ply:PS_RemoveClientsideModel(self.ID)
end

-- This item doesn't have any modifications so we return an empty table
function ITEM:SanitizeTable( modifications )
	return {}
end
