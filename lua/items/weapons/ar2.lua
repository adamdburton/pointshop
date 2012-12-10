ITEM.Name = 'AR2'
ITEM.Price = 200
ITEM.Model = 'models/weapons/w_irifle.mdl'
ITEM.WeaponClass = 'weapon_ar2'
ITEM.SingleUse = true

function ITEM:OnBuy(ply)
	ply:Give(self.WeaponClass)
	ply:SelectWeapon(self.WeaponClass)
end

function ITEM:OnSell(ply)
	ply:StripWeapon(self.WeaponClass)
end