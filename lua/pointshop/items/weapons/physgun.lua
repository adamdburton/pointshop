ITEM.Name = 'Physics Gun'
ITEM.Price = 200
ITEM.Model = 'models/weapons/w_physics.mdl'
ITEM.Skin = 2
ITEM.WeaponClass = 'weapon_physgun'
ITEM.SingleUse = true

function ITEM:OnBuy(ply)
	ply:Give(self.WeaponClass)
	ply:SelectWeapon(self.WeaponClass)
end

function ITEM:OnSell(ply)
	ply:StripWeapon(self.WeaponClass)
end