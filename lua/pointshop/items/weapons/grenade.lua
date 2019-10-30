ITEM.Name = 'Grenade'
ITEM.Price = 200
ITEM.Model = 'models/weapons/w_grenade.mdl'
ITEM.WeaponClass = 'weapon_frag'
ITEM.SingleUse = true

function ITEM:OnBuy(ply)
    if (!ply:HasWeapon(self.WeaponClass)) then
        ply:Give(self.WeaponClass)
    else
        ply:GiveAmmo(1, "Grenade", false)
    end
	ply:SelectWeapon(self.WeaponClass)
end

function ITEM:OnSell(ply)
	ply:StripWeapon(self.WeaponClass)
end
