ITEM.Name = 'Pistol'
ITEM.Price = 200
ITEM.Model = 'models/weapons/W_pistol.mdl'
ITEM.WeaponClass = 'weapon_pistol'
ITEM.SingleUse = true

function ITEM:OnBuy(ply)
    if (!ply:HasWeapon(self.WeaponClass)) then
	   ply:Give(self.WeaponClass)
    else
        ply:GiveAmmo(18, "Pistol", false)
    end
	ply:SelectWeapon(self.WeaponClass)
end

function ITEM:OnSell(ply)
	ply:StripWeapon(self.WeaponClass)
end
