local Player = FindMetaTable('Player')

-- Because of the huge variaty of admin mods and their various ways of handling usergroups.
-- This had to be done..
function Player:PS_GetUsergroup()
	if ( self.EV_GetRank ) then return self:EV_GetRank() end
	if ( serverguard ) then return serverguard.player:GetRank(self) end
	-- add for each conflicting admin mod.

	return self:GetNWString('UserGroup')
end
