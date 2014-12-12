surface.CreateFont('PS_Heading', { font = 'coolvetica', size = 64 })
surface.CreateFont('PS_Heading2', { font = 'coolvetica', size = 24 })
surface.CreateFont('PS_Heading3', { font = 'coolvetica', size = 19 })

surface.CreateFont( "PS_Default", {
	font = system.IsLinux() and "Arial" or "Tahoma",
	size = 13, weight = 500, antialias = true,
})

surface.CreateFont( "PS_DefaultBold", {
	font = system.IsLinux() and "Arial" or "Tahoma",
	size = 13, weight = 800, antialias = true,
})

surface.CreateFont( "PS_Heading1", {
	font = system.IsLinux() and "Arial" or "Tahoma",
	size = 18, weight = 500, antialias = true,
})

surface.CreateFont( "PS_Heading1Bold", {
	font = system.IsLinux() and "Arial" or "Tahoma",
	size = 18, weight = 800, antialias = true,
})

surface.CreateFont( "PS_ButtonText1", {
	font = "Roboto",
	size = 22, weight = 700, antialias = true,
})

surface.CreateFont( "PS_ItemText", {
	font = system.IsLinux() and "Arial" or "Tahoma",
	size = 11, weight = 500, antialias = true,
})

surface.CreateFont( "PS_LargeTitle", {
	font = "Roboto",
	size = 32, weight = 500, antialias = true,
})

local ALL_ITEMS = 1
local OWNED_ITEMS = 2
local UNOWNED_ITEMS = 3

local BGColor1 = Color(52, 73, 94)
local BGColor2 = Color(40, 40, 40)
local BGColor3 = Color(57, 56, 54)

local function BuildItemMenu(menu, ply, itemstype, callback)
	local plyitems = ply:PS_GetItems()
	
	for category_id, CATEGORY in pairs(PS.Categories) do
		
		local catmenu = menu:AddSubMenu(CATEGORY.Name)
		
		table.SortByMember(PS.Items, PS.Config.SortItemsBy, function(a, b) return a > b end)
		
		for item_id, ITEM in pairs(PS.Items) do
			if ITEM.Category == CATEGORY.Name then
				if itemstype == ALL_ITEMS or (itemstype == OWNED_ITEMS and plyitems[item_id]) or (itemstype == UNOWNED_ITEMS and not plyitems[item_id]) then
					catmenu:AddOption(ITEM.Name, function() callback(item_id) end)
				end
			end
		end
	end
end

local PANEL = {}

function PANEL:Init()
	self:SetSize( math.Clamp( 1024, 0, ScrW() ), math.Clamp( 768, 0, ScrH() ) )
	self:SetPos((ScrW() / 2) - (self:GetWide() / 2), (ScrH() / 2) - (self:GetTall() / 2))
	
	-- close button
	local closeButton = vgui.Create('DButton', self)
	closeButton:SetFont('marlett')
	closeButton:SetText('r')
	closeButton.Paint = function() end
	closeButton:SetColor(Color(255, 255, 255))
	closeButton:SetSize(32, 32)
	closeButton:SetPos(self:GetWide() - 40, 8)
	closeButton.DoClick = function()
		PS:ToggleMenu()
	end

	local buttonContainer = vgui.Create("DPanel", self)
	buttonContainer:SetTall(28)
	buttonContainer:Dock(TOP)
	buttonContainer:DockMargin(0, 48, 0, 0)

	local container = vgui.Create("DPanel", self)
	
	if PS.Config.DisplayPreviewInMenu then
		container:DockMargin(0, 0, 320, 0)
	else
		container:DockMargin(0, 0, 0, 0)
	end
	container:Dock(FILL)
	
	container:SetSize(self:GetWide() - 60, self:GetTall() - 150)
	container:SetPos((self:GetWide() / 2) - (container:GetWide() / 2), 120)

	local btns = {}
	local firstBtn = true
	local function createBtn(text, material, panel, align, description)
		panel:SetParent(container)
		panel:Dock(FILL)
		panel.Paint = function(pnl, w, h) surface.SetDrawColor(232, 232, 232, 255) surface.DrawRect(0, 0, w, h) end

		if firstBtn then
			panel:SetZPos(100)
			panel:SetVisible(true)
		else
			panel:SetZPos(1)
			panel:SetVisible(false)
		end

		local btn = vgui.Create("DButton", buttonContainer)
		btn:Dock(align or LEFT)
		btn:SetText(text)
		btn:SetFont("DermaDefault")
		btn:SetImage(material)
		if description and description ~= '' then
			btn:SetToolTip(description)
		end
		
		btn.Paint = function(pnl, w, h)
			surface.SetDrawColor(218, 218, 218, 255)
			surface.DrawOutlinedRect(0, 0, w, h)

			if pnl:GetActive() then
				surface.SetDrawColor(BGColor1)
				surface.DrawRect(0, h-3, w, 3)
			end
		end
		btn.UpdateColours = function(pnl)
			if pnl:GetActive() then return pnl:SetTextColor(Color(105, 105, 105, 255)) end
			if pnl.Hovered then return pnl:SetTextColor(Color(120, 120, 120, 255)) end
			pnl:SetTextColor(Color(140, 140, 140, 255))
		end
		btn.PerformLayout = function(pnl)
			pnl:SizeToContents() pnl:SetWide(pnl:GetWide() + 12) pnl:SetTall( pnl:GetParent():GetTall() ) DLabel.PerformLayout(pnl)

			pnl.m_Image:SetSize(16, 16)
			pnl.m_Image:SetPos( 8, (pnl:GetTall() - pnl.m_Image:GetTall()) * 0.5 )
			pnl:SetContentAlignment(4)
			pnl:SetTextInset( pnl.m_Image:GetWide() + 16, 0 )
		end

		btn.GetActive = function(pnl) return pnl.Active or false end
		btn.SetActive = function(pnl, state) pnl.Active = state end

		if firstBtn then firstBtn = false; btn:SetActive(true) end

		btn.DoClick = function(pnl)
			for k, v in pairs(btns) do v:SetActive(false) v:OnDeactivate() end
			pnl:SetActive(true) pnl:OnActivate()
		end

		btn.OnDeactivate = function()
			panel:SetVisible(false)
			panel:SetZPos(1)
		end
		btn.OnActivate = function()
			panel:SetVisible(true)
			panel:SetZPos(100)
		end

		table.insert(btns, btn)

		return btn
	end

	-- sorting
	local categories = {}
	
	for _, i in pairs(PS.Categories) do
		table.insert(categories, i)
	end
	
	table.sort(categories, function(a, b) 
		if a.Order == b.Order then 
			return a.Name < b.Name
		else
			return a.Order < b.Order
		end
	end)
	
	local items = {}
	
	for _, i in pairs(PS.Items) do
		table.insert(items, i)
	end
	
	table.SortByMember(items, PS.Config.SortItemsBy, function(a, b) return a > b end)

	-- ready for the worst sorting ever??

	local tbl1 = {}
	local tbl2 = {}
	local tbl3 = {}

	for _, i in pairs(items) do
		local points = PS.Config.CalculateBuyPrice(LocalPlayer(), i)

		if 		( LocalPlayer():PS_HasItem(i.ID) ) then table.insert(tbl3, i)
		elseif	( LocalPlayer():PS_HasPoints(points) ) then table.insert(tbl1, i)
		else	table.insert(tbl2, i) end
	end

	items = {}

	for _, i in pairs(tbl1) do table.insert(items, i) end
	for _, i in pairs(tbl2) do table.insert(items, i) end
	for _, i in pairs(tbl3) do table.insert(items, i) end
	
	-- items
	for _, CATEGORY in pairs(categories) do
		if CATEGORY.AllowedUserGroups and #CATEGORY.AllowedUserGroups > 0 then
			if not table.HasValue(CATEGORY.AllowedUserGroups, LocalPlayer():PS_GetUsergroup()) then
				continue
			end
		end
		
		if CATEGORY.CanPlayerSee then
			if not CATEGORY:CanPlayerSee(LocalPlayer()) then
				continue
			end
		end
		
		--Allow addons to create custom Category display types
 		local ShopCategoryTab = hook.Run( "PS_CustomCategoryTab", CATEGORY )
		if IsValid( ShopCategoryTab ) then
			createBtn(CATEGORY.Name, 'icon16/' .. CATEGORY.Icon .. '.png', ShopCategoryTab, nil, CATEGORY.Description)
			continue
		else
			ShopCategoryTab = vgui.Create('DPanel')
		end
		
		local DScrollPanel = vgui.Create('DScrollPanel', ShopCategoryTab)
		DScrollPanel:Dock(FILL)
		
		local ShopCategoryTabLayout = vgui.Create('DIconLayout', DScrollPanel)
		ShopCategoryTabLayout:Dock(FILL)
		ShopCategoryTabLayout:SetBorder(8)
		ShopCategoryTabLayout:SetSpaceX(8)
		ShopCategoryTabLayout:SetSpaceY(8)
		
		DScrollPanel:AddItem(ShopCategoryTabLayout)
		
		for _, ITEM in pairs(items) do
			if ITEM.Category == CATEGORY.Name then
				local model = vgui.Create('DPointShopItem')
				model:SetData(ITEM)
				model:SetSize(128, 128)
				
				ShopCategoryTabLayout:Add(model)
			end
		end

		if CATEGORY.ModifyTab then
			CATEGORY:ModifyTab(ShopCategoryTab)
		end
		
		createBtn(CATEGORY.Name, 'icon16/' .. CATEGORY.Icon .. '.png', ShopCategoryTab, nil, CATEGORY.Description)
	end

	if (PS.Config.AdminCanAccessAdminTab and LocalPlayer():IsAdmin()) or (PS.Config.SuperAdminCanAccessAdminTab and LocalPlayer():IsSuperAdmin()) then
		-- admin tab
		local AdminTab = vgui.Create('DPanel')
		
		local ClientsList = vgui.Create('DListView', AdminTab)
		ClientsList:DockMargin(10, 10, 10, 10)
		ClientsList:Dock(FILL)
		
		ClientsList:SetMultiSelect(false)
		ClientsList:AddColumn('Name')
		ClientsList:AddColumn('Points'):SetFixedWidth(60)
		ClientsList:AddColumn('Items'):SetFixedWidth(60)
		
		ClientsList.OnClickLine = function(parent, line, selected)
			local ply = line.Player
			
			local menu = DermaMenu()
			
			menu:AddOption('Set '..PS.Config.PointsName..'...', function()
				Derma_StringRequest(
					"Set "..PS.Config.PointsName.." for " .. ply:GetName(),
					"Set "..PS.Config.PointsName.." to...",
					"",
					function(str)
						if not str or not tonumber(str) then return end
						
						net.Start('PS_SetPoints')
							net.WriteEntity(ply)
							net.WriteInt(tonumber(str), 32)
						net.SendToServer()
					end
				)
			end)
			
			menu:AddOption('Give '..PS.Config.PointsName..'...', function()
				Derma_StringRequest(
					"Give "..PS.Config.PointsName.." to " .. ply:GetName(),
					"Give "..PS.Config.PointsName.."...",
					"",
					function(str)
						if not str or not tonumber(str) then return end
						
						net.Start('PS_GivePoints')
							net.WriteEntity(ply)
							net.WriteInt(tonumber(str), 32)
						net.SendToServer()
					end
				)
			end)
			
			menu:AddOption('Take '..PS.Config.PointsName..'...', function()
				Derma_StringRequest(
					"Take "..PS.Config.PointsName.." from " .. ply:GetName(),
					"Take "..PS.Config.PointsName.."...",
					"",
					function(str)
						if not str or not tonumber(str) then return end
						
						net.Start('PS_TakePoints')
							net.WriteEntity(ply)
							net.WriteInt(tonumber(str), 32)
						net.SendToServer()
					end
				)
			end)
			
			menu:AddSpacer()
			
			BuildItemMenu(menu:AddSubMenu('Give Item'), ply, UNOWNED_ITEMS, function(item_id)
				net.Start('PS_GiveItem')
					net.WriteEntity(ply)
					net.WriteString(item_id)
				net.SendToServer()
			end)
			
			BuildItemMenu(menu:AddSubMenu('Take Item'), ply, OWNED_ITEMS, function(item_id)
				net.Start('PS_TakeItem')
					net.WriteEntity(ply)
					net.WriteString(item_id)
				net.SendToServer()
			end)
			
			menu:Open()
		end
		
		self.ClientsList = ClientsList

		createBtn("Admin", 'icon16/shield.png', AdminTab, RIGHT)
	end
	
	-- preview panel

	local preview
	if PS.Config.DisplayPreviewInMenu then
		preview = vgui.Create('DPanel', self)
		
		preview:DockMargin(self:GetWide() - 320, 0, 0, 0)
		preview:Dock(FILL)
		
		local previewpanel = vgui.Create('DPointShopPreview', preview)
		previewpanel:Dock(FILL)
		
		--- Drag Rotate
		previewpanel.Angles = Angle( 0, 0, 0 )

		function previewpanel:DragMousePress()
			self.PressX, self.PressY = gui.MousePos()
			self.Pressed = true
		end

		function previewpanel:DragMouseRelease()
			self.Pressed = false
			self.lastPressed = RealTime()
		end
		
		function previewpanel:LayoutEntity( thisEntity )
			if ( self.bAnimated ) then self:RunAnimation() end
			
			if ( self.Pressed ) then
				local mx, my = gui.MousePos()
				self.Angles = self.Angles - Angle( 0, ( self.PressX or mx ) - mx, 0 )
				self.PressX, self.PressY = gui.MousePos()
			end
			
			if ( RealTime() - ( self.lastPressed or 0 ) ) < 4 or self.Pressed then
				thisEntity:SetAngles( self.Angles )
			else	
				self.Angles.y = math.NormalizeAngle(self.Angles.y + (RealFrameTime() * 21))
				thisEntity:SetAngles( Angle( 0, self.Angles.y ,  0) )
			end
			
		end
		
	end
	
	-- give points button
	
	if PS.Config.CanPlayersGivePoints then
		local givebutton = vgui.Create('DButton', preview or self)
		givebutton:SetText("Give "..PS.Config.PointsName)
		if PS.Config.DisplayPreviewInMenu then
			givebutton:DockMargin(8, 8, 8, 8)
		else
			givebutton:DockMargin(8, 0, 8, 8)
		end
		givebutton:Dock(BOTTOM)
		givebutton.DoClick = function()
			vgui.Create('DPointShopGivePoints')
		end
	end
end

function PANEL:Think()
	if self.ClientsList then
		local lines = self.ClientsList:GetLines()
		
		for _, ply in pairs(player.GetAll()) do
			local found = false
			
			for _, line in pairs(lines) do
				if line.Player == ply then
					found = true
				end
			end
			
			if not found then
				self.ClientsList:AddLine(ply:GetName(), ply:PS_GetPoints(), table.Count(ply:PS_GetItems())).Player = ply
			end
		end
		
		for i, line in pairs(lines) do
			if IsValid(line.Player) then
				local ply = line.Player
				
				line:SetValue(1, ply:GetName())
				line:SetValue(2, ply:PS_GetPoints())
				line:SetValue(3, table.Count(ply:PS_GetItems()))
			else
				self.ClientsList:RemoveLine(i)
			end
		end
	end
end

function PANEL:Paint(w, h)
	Derma_DrawBackgroundBlur(self)
	
	surface.SetDrawColor(40, 40, 40, 255)
	surface.DrawRect(0, 0, w, h)

	--surface.SetDrawColor(60, 80, 104, 255)
	surface.SetDrawColor(BGColor1)
	surface.DrawRect(0, 0, w, 48)

	if PS.Config.CommunityName then
		draw.SimpleText(PS.Config.CommunityName .. " PointShop", 'PS_LargeTitle', 16, 8, color_white)
	else
		draw.SimpleText("PointShop", 'PS_LargeTitle', 16, 8, color_white)
	end

	draw.SimpleText('You have ' .. LocalPlayer():PS_GetPoints() .. ' ' .. PS.Config.PointsName, 'PS_Heading3', self:GetWide() - 40, 24, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	
end

vgui.Register('DPointShopMenu', PANEL)
