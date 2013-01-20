-- net hooks

net.Receive('PS_BuyItem', function(length, ply)
	ply:PS_BuyItem(net.ReadString())
end)

net.Receive('PS_SellItem', function(length, ply)
	ply:PS_SellItem(net.ReadString())
end)

net.Receive('PS_EquipItem', function(length, ply)
	ply:PS_EquipItem(net.ReadString())
end)

net.Receive('PS_HolsterItem', function(length, ply)
	ply:PS_HolsterItem(net.ReadString())
end)

net.Receive('PS_ModifyItem', function(length, ply)
	ply:PS_ModifyItem(net.ReadString(), net.ReadTable())
end)

-- player to player

net.Receive('PS_SendPoints', function(length, ply)
	local other = net.ReadEntity()
	local points = net.ReadInt(32)
	
	if PS.Config.CanPlayersGivePoints and other and points and IsValid(other) and other:IsPlayer() and ply and IsValid(ply) and ply:IsPlayer() and ply:PS_HasPoints(points) then
		ply:PS_TakePoints(points)
		ply:PS_Notify('You gave ', other:Nick(), ' ', points, ' of your points.')
		
		other:PS_GivePoints(points)
		other:PS_Notify(ply:Nick(), ' gave you ', points, ' of their points.')
	end
end)

-- admin points

net.Receive('PS_GivePoints', function(length, ply)
	local other = net.ReadEntity()
	local points = net.ReadInt(32)
	
	if not PS.Config.AdminCanAccessAdminTab and not PS.Config.SuperAdminCanAccessAdminTab then return end
	
	local admin_allowed = PS.Config.AdminCanAccessAdminTab and ply:IsAdmin()
	local super_admin_allowed = PS.Config.SuperAdminCanAccessAdminTab and ply:IsSuperAdmin()
	
	if (admin_allowed or super_admin_allowed) and other and points and IsValid(other) and other:IsPlayer() then
		other:PS_GivePoints(points)
		other:PS_Notify(ply:Nick(), ' gave you ', points, ' points.')
	end
end)

net.Receive('PS_TakePoints', function(length, ply)
	local other = net.ReadEntity()
	local points = net.ReadInt(32)
	
	if not PS.Config.AdminCanAccessAdminTab and not PS.Config.SuperAdminCanAccessAdminTab then return end
	
	local admin_allowed = PS.Config.AdminCanAccessAdminTab and ply:IsAdmin()
	local super_admin_allowed = PS.Config.SuperAdminCanAccessAdminTab and ply:IsSuperAdmin()
	
	if (admin_allowed or super_admin_allowed) and other and points and IsValid(other) and other:IsPlayer() then
		other:PS_TakePoints(points)
		other:PS_Notify(ply:Nick(), ' took ', points, ' points from you.')
	end
end)

net.Receive('PS_SetPoints', function(length, ply)
	local other = net.ReadEntity()
	local points = net.ReadInt(32)
	
	if not PS.Config.AdminCanAccessAdminTab and not PS.Config.SuperAdminCanAccessAdminTab then return end
	
	local admin_allowed = PS.Config.AdminCanAccessAdminTab and ply:IsAdmin()
	local super_admin_allowed = PS.Config.SuperAdminCanAccessAdminTab and ply:IsSuperAdmin()
	
	if (admin_allowed or super_admin_allowed) and other and points and IsValid(other) and other:IsPlayer() then
		other:PS_SetPoints(points)
		other:PS_Notify(ply:Nick(), ' set your points to ', points, '.')
	end
end)

-- admin items

net.Receive('PS_GiveItem', function(length, ply)
	local other = net.ReadEntity()
	local item_id = net.ReadString()
	
	if not PS.Config.AdminCanAccessAdminTab and not PS.Config.SuperAdminCanAccessAdminTab then return end
	
	local admin_allowed = PS.Config.AdminCanAccessAdminTab and ply:IsAdmin()
	local super_admin_allowed = PS.Config.SuperAdminCanAccessAdminTab and ply:IsSuperAdmin()
	
	if (admin_allowed or super_admin_allowed) and other and item_id and PS.Items[item_id] and IsValid(other) and other:IsPlayer() and not other:PS_HasItem(item_id) then
		other:PS_GiveItem(item_id)
	end
end)

net.Receive('PS_TakeItem', function(length, ply)
	local other = net.ReadEntity()
	local item_id = net.ReadString()
	
	if not PS.Config.AdminCanAccessAdminTab and not PS.Config.SuperAdminCanAccessAdminTab then return end
	
	local admin_allowed = PS.Config.AdminCanAccessAdminTab and ply:IsAdmin()
	local super_admin_allowed = PS.Config.SuperAdminCanAccessAdminTab and ply:IsSuperAdmin()
	
	if (admin_allowed or super_admin_allowed) and other and item_id and PS.Items[item_id] and IsValid(other) and other:IsPlayer() and other:PS_HasItem(item_id) then
		-- holster it first without notificaiton
		other.PS_Items[item_id].Equipped = false
	
		local ITEM = PS.Items[item_id]
		ITEM:OnHolster(other)
		other:PS_TakeItem(item_id)
	end
end)

-- hooks

local KeyToHook = {
	F1 = "ShowHelp",
	F2 = "ShowTeam",
	F3 = "ShowSpare1",
	F4 = "ShowSpare2",
	None = "ThisHookDoesNotExist"
}

hook.Add(KeyToHook[PS.Config.ShopKey], "PS_ShopKey", function(ply)
	ply:PS_ToggleMenu()
end)

hook.Add('PlayerSpawn', 'PS_PlayerSpawn', function(ply) ply:PS_PlayerSpawn() end)
hook.Add('PlayerDeath', 'PS_PlayerDeath', function(ply) ply:PS_PlayerDeath() end)
hook.Add('PlayerInitialSpawn', 'PS_PlayerInitialSpawn', function(ply) ply:PS_PlayerInitialSpawn() end)
hook.Add('PlayerDisconnected', 'PS_PlayerDisconnected', function(ply) ply:PS_PlayerDisconnected() end)

hook.Add('PlayerSay', 'PS_PlayerSay', function(ply, text)
	if string.len(PS.Config.ShopChatCommand) > 0 then
		if string.sub(text, 0, string.len(PS.Config.ShopChatCommand)) == PS.Config.ShopChatCommand then
			ply:PS_ToggleMenu()
			return ''
		end
	end
end)

-- ugly networked strings

util.AddNetworkString('PS_Items')
util.AddNetworkString('PS_Points')
util.AddNetworkString('PS_BuyItem')
util.AddNetworkString('PS_SellItem')
util.AddNetworkString('PS_EquipItem')
util.AddNetworkString('PS_HolsterItem')
util.AddNetworkString('PS_ModifyItem')
util.AddNetworkString('PS_SendPoints')
util.AddNetworkString('PS_GivePoints')
util.AddNetworkString('PS_TakePoints')
util.AddNetworkString('PS_SetPoints')
util.AddNetworkString('PS_GiveItem')
util.AddNetworkString('PS_TakeItem')
util.AddNetworkString('PS_AddClientsideModel')
util.AddNetworkString('PS_RemoveClientsideModel')
util.AddNetworkString('PS_SendClientsideModels')
util.AddNetworkString('PS_ToggleMenu')

-- console commands

concommand.Add(PS.Config.ShopCommand, function(ply, cmd, args)
	ply:PS_ToggleMenu()
end)

concommand.Add('ps_clear_points', function(ply, cmd, args)
	if IsValid(ply) then return end -- only allowed from server console
	
	for _, ply in pairs(player.GetAll()) do
		ply:PS_SetPoints(0)
	end
	
	sql.Query("DELETE FROM playerpdata WHERE infoid LIKE '%PS_Points%'")
end)

concommand.Add('ps_clear_items', function(ply, cmd, args)
	if IsValid(ply) then return end -- only allowed from server console
	
	for _, ply in pairs(player.GetAll()) do
		ply.PS_Items = {}
		ply:PS_SendItems()
	end
	
	sql.Query("DELETE FROM playerpdata WHERE infoid LIKE '%PS_Items%'")
end)

-- version checker

PS.CurrentBuild = 0
PS.LatestBuild = 0
PS.BuildOutdated = false

local function CompareVersions()
	if ( PS.CurrentBuild < PS.LatestBuild ) then
		print( "Pointshop is out of date!" )
		print( "Local version: " .. PS.CurrentBuild .. " Latest version: " .. PS.LatestBuild )

		PS.BuildOutdated = true
	else
		print( "Pointshop is on the latest version." )
	end
end

function PS:CheckVersion()
	if ( file.Exists( "pointshop_build.txt", "DATA" ) ) then
		PS.CurrentBuild = tonumber(file.Read( "pointshop_build.txt", "DATA" ))
	end

	local url = self.Config.Branch .. "data/pointshop_build.txt"
	http.Fetch( url,
		function( content ) -- onSuccess
			PS.LatestBuild = tonumber( content )
			CompareVersions()
		end,
		function( failCode ) -- onFailure
			print( "Pointshop couldn't check version." )
			print( url, " returned ", failCode )
		end
	)
end