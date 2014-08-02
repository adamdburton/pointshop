ITEM.Name = '357 Magnum'
ITEM.Price = 200
ITEM.Model = 'models/weapons/w_357.mdl'
ITEM.WeaponClass = 'weapon_357'
ITEM.SingleUse = true

function ITEM:OnBuy(ply)
	ply:Give(self.WeaponClass)
	ply:SelectWeapon(self.WeaponClass)
end

function ITEM:OnSell(ply)
	ply:StripWeapon(self.WeaponClass)
end