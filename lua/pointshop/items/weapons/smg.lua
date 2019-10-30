ITEM.Name = 'SMG'
ITEM.Price = 200
ITEM.Model = 'models/weapons/w_smg1.mdl'
ITEM.WeaponClass = 'weapon_smg1'
ITEM.SingleUse = true

function ITEM:OnBuy(ply)
    if (!ply:HasWeapon(self.WeaponClass)) then
	ply:Give(self.WeaponClass)
    else
        ply:GiveAmmo(180, "SMG1", false)
    end
	ply:SelectWeapon(self.WeaponClass)
end

function ITEM:OnSell(ply)
	ply:StripWeapon(self.WeaponClass)
end
