ITEM.Name = 'Grenade'
ITEM.Price = 200
ITEM.Model = 'models/weapons/w_grenade.mdl'
ITEM.WeaponClass = 'weapon_frag'
ITEM.SingleUse = true

function ITEM:OnBuy(ply)
	ply:Give(self.WeaponClass)
	ply:SelectWeapon(self.WeaponClass)
end

function ITEM:OnSell(ply)
	ply:StripWeapon(self.WeaponClass)
end