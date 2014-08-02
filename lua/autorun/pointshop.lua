if SERVER then AddCSLuaFile() include "pointshop/sv_init.lua" end
if CLIENT then include "pointshop/cl_init.lua" end

PS:Initialize()