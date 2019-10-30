ITEM.Name = 'RPG'
ITEM.Price = 200
ITEM.Model = 'models/weapons/w_rocket_launcher.mdl'
ITEM.WeaponClass = 'weapon_rpg'
ITEM.SingleUse = true

function ITEM:OnBuy(ply)
    if (!ply:HasWeapon(self.WeaponClass)) then
	   ply:Give(self.WeaponClass)
    else
        ply:GiveAmmo(3, "RPG_Round", false)
    end
	ply:SelectWeapon(self.WeaponClass)
end

function ITEM:OnSell(ply)
	ply:StripWeapon(self.WeaponClass)
end
