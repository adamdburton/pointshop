ITEM.Name = 'Kleiner'
ITEM.Price = 250
ITEM.Model = 'models/player/kleiner.mdl'

function ITEM:OnEquip(ply, modifications)
	if not ply._OldModel then
		ply._OldModel = ply:GetModel()
	end
	
	timer.Simple(1, function() ply:SetModel(self.Model) end)
end

function ITEM:OnHolster(ply)
	if ply._OldModel then
		ply:SetModel(ply._OldModel)
	end
end

function ITEM:PlayerSetModel(ply)
	ply:SetModel(self.Model)
end

-- This item doesn't have any modifications so we return an empty table
function ITEM:SanitizeTable( modifications )
	return {}
end
