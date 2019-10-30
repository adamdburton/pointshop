ITEM.Name = 'Shotgun'
ITEM.Price = 200
ITEM.Model = 'models/weapons/w_shotgun.mdl'
ITEM.WeaponClass = 'weapon_shotgun'
ITEM.SingleUse = true

function ITEM:OnBuy(ply)
    if (!ply:HasWeapon(self.WeaponClass)) then
	ply:Give(self.WeaponClass)
    else
        ply:GiveAmmo(70, "Buckshot", false)
    end
	ply:SelectWeapon(self.WeaponClass)
end

function ITEM:OnSell(ply)
	ply:StripWeapon(self.WeaponClass)
end
