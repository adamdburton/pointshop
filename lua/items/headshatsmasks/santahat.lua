ITEM.Name = 'Santa Hat'
ITEM.Price = 100
ITEM.Model = 'models/santa/santa.mdl'
ITEM.Attachment = 'eyes'

function ITEM:OnEquip(ply, modifications)
	ply:PS_AddClientsideModel(self.ID)
end

function ITEM:OnHolster(ply)
	ply:PS_RemoveClientsideModel(self.ID)
end

function ITEM:CanPlayerBuy(ply)
	return os.date("%m") == "12" and true or false, 'It\'s not winter!'
end

-- Credit for santa hat model to Shane at http://www.facepunch.com/showthread.php?t=860165

if SERVER then
	resource.AddFile("materials/models/santa/santa.vmt")
	resource.AddFile("materials/models/santa/santa.vtf")
	resource.AddFile("materials/models/santa/ball.vmt")
	resource.AddFile("materials/models/santa/ball.vtf")
	resource.AddFile("models/santa/santa.dx80.vtx")
	resource.AddFile("models/santa/santa.dx90.vtx")
	resource.AddFile("models/santa/santa.mdl")
	resource.AddFile("models/santa/santa.sw.vtx")
	resource.AddFile("models/santa/santa.vvd")
end