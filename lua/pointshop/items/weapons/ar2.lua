ITEM.Name = 'AR2'
ITEM.Price = 200
ITEM.Model = 'models/weapons/w_irifle.mdl'
ITEM.WeaponClass = 'weapon_ar2'
ITEM.SingleUse = true

function ITEM:OnBuy(ply)
	if (!ply:HasWeapon(self.WeaponClass)) then
	   ply:Give(self.WeaponClass)
    else
        ply:GiveAmmo(60, "AR2", false)
    end
	ply:SelectWeapon(self.WeaponClass)
end

function ITEM:OnSell(ply)
	ply:StripWeapon(self.WeaponClass)
end
