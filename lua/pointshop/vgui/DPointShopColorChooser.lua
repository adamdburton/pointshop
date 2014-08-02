local PANEL = {}

function PANEL:Init()
	self:SetTitle("PointShop Color Chooser")
	self:SetSize(300, 300)
	
	self:SetBackgroundBlur(true)
	self:SetDrawOnTop(true)
	
	self.colorpicker = vgui.Create('DColorMixer', self)
	--colorpicker:DockMargin(0, 0, 0, 60)
	self.colorpicker:Dock(FILL)
	
	local done = vgui.Create('DButton', self)
	done:DockMargin(0, 5, 0, 0)
	done:Dock(BOTTOM)
	
	done:SetText('Done')
	
	done.DoClick = function()
		self.OnChoose(self.colorpicker:GetColor())
		self:Close()
	end
	
	self:Center()
	self:Show()
end

function PANEL:OnChoose(color)
	-- nothing, gets over-ridden
end

function PANEL:SetColor(color)
	self.colorpicker:SetColor(color or Color(255, 255, 255, 255))
end

vgui.Register('DPointShopColorChooser', PANEL, 'DFrame')
