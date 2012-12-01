ITEM.Name = 'Plasma Trail'
ITEM.Price = 150
ITEM.Material = 'trails/plasma.vmt'

function ITEM:OnEquip(ply, modifications)
	ply.PlasmaTrail = util.SpriteTrail(ply, 0, modifications.color, false, 15, 1, 4, 0.125, self.Material)
end

function ITEM:OnHolster(ply)
	SafeRemoveEntity(ply.PlasmaTrail)
end

function ITEM:Modify(modifications)
	PS:ShowColorChooser(self, modifications)
end

function ITEM:OnModify(ply, modifications)
	SafeRemoveEntity(ply.PlasmaTrail)
	self:OnEquip(ply, modifications)
end
