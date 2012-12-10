ITEM.Name = 'SMG'
ITEM.Price = 200
ITEM.Model = 'models/weapons/w_smg1.mdl'
ITEM.WeaponClass = 'weapon_smg1'
ITEM.SingleUse = true

function ITEM:OnBuy(ply)
	ply:Give(self.WeaponClass)
	ply:SelectWeapon(self.WeaponClass)
end

function ITEM:OnSell(ply)
	ply:StripWeapon(self.WeaponClass)
end