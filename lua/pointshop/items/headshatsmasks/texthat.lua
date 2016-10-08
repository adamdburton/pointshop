ITEM.Name = 'Text Hat'
ITEM.Price = 1000
ITEM.Model = 'models/extras/info_speech.mdl'
ITEM.NoPreview = true

local MaxTextLength = 32

function ITEM:PostPlayerDraw(ply, modifications, ply2)
	if not ply == ply2 then return end
	if not ply:Alive() then return end
	if ply.IsSpec and ply:IsSpec() then return end
	
	local offset = Vector(0, 0, 79)
	local ang = LocalPlayer():EyeAngles()
	local pos = ply:GetPos() + offset + ang:Up()
	
	ang:RotateAroundAxis(ang:Forward(), 90)
	ang:RotateAroundAxis(ang:Right(), 90)
	
	cam.Start3D2D(pos, Angle(0, ang.y, 90), 0.1)
		draw.DrawText(string.sub(modifications.text or ply:Nick(), 1, MaxTextLength), "PS_Heading", 2, 2, modifications.color or Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
	cam.End3D2D()
end

function ITEM:Modify(modifications)
	Derma_StringRequest("Text", "What text do you want your hat to say?", "", function(text)
		
		if string.find(text, "#") then
			text = string.gsub(text, "#", "")
		end
		
		modifications.text = string.sub(text, 1, MaxTextLength)
		PS:ShowColorChooser(self, modifications)
	end)
end

