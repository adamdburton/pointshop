ITEM.Name = '357 Magnum'
ITEM.Price = 200
ITEM.Model = 'models/weapons/w_357.mdl'
ITEM.WeaponClass = 'weapon_357'
ITEM.SingleUse = true

function ITEM:OnBuy(ply)
    if (!ply:HasWeapon(self.WeaponClass)) then
	ply:Give(self.WeaponClass)
    else
        ply:GiveAmmo(6, "357", false)
    end
	ply:SelectWeapon(self.WeaponClass)
end

function ITEM:OnSell(ply)
	ply:StripWeapon(self.WeaponClass)
end
