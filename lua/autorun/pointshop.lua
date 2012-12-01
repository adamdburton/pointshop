if SERVER then
	AddCSLuaFile()
	AddCSLuaFile('vgui/DPointShopMenu.lua')
	AddCSLuaFile('vgui/DPointShopItem.lua')
	AddCSLuaFile('sh_pointshop.lua')
	AddCSLuaFile('sh_config.lua')
	AddCSLuaFile('cl_player_extension.lua')
	AddCSLuaFile('cl_pointshop.lua')
	
	include('sh_pointshop.lua')
	include('sh_config.lua')
	include('sv_player_extension.lua')
	include('sv_pointshop.lua')
end

if CLIENT then
	include('vgui/DPointShopMenu.lua')
	include('vgui/DPointShopItem.lua')
	include('sh_pointshop.lua')
	include('sh_config.lua')
	include('cl_player_extension.lua')
	include('cl_pointshop.lua')
end

PS:LoadItems()