ITEM.Name = 'Crowbar'
ITEM.Price = 200
ITEM.Model = 'models/weapons/w_crowbar.mdl'
ITEM.WeaponClass = 'weapon_crowbar'
ITEM.SingleUse = true

function ITEM:OnBuy(ply)
	ply:Give(self.WeaponClass)
	ply:SelectWeapon(self.WeaponClass)
end

function ITEM:OnSell(ply)
	ply:StripWeapon(self.WeaponClass)
end