ITEM.Name = 'Crossbow'
ITEM.Price = 200
ITEM.Model = 'models/weapons/w_crossbow.mdl'
ITEM.WeaponClass = 'weapon_crossbow'
ITEM.SingleUse = true

function ITEM:OnBuy(ply)
    if (!ply:HasWeapon(self.WeaponClass)) then
        ply:Give(self.WeaponClass)
    else
        ply:GiveAmmo(5, "XBowBolt", false)
    end
	ply:SelectWeapon(self.WeaponClass)
end

function ITEM:OnSell(ply)
	ply:StripWeapon(self.WeaponClass)
end
