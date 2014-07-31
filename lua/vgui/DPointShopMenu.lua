surface.CreateFont('PS_Heading', { font = 'coolvetica', size = 64 })
surface.CreateFont('PS_Heading2', { font = 'coolvetica', size = 24 })
surface.CreateFont('PS_Heading3', { font = 'coolvetica', size = 19 })

local ALL_ITEMS = 1
local OWNED_ITEMS = 2
local UNOWNED_ITEMS = 3

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
	closeButton:SetColor(Color(255, 255, 255))
	closeButton:SetSize(15, 15)
	closeButton:SetDrawBackground(false)
	closeButton:SetPos(self:GetWide() - 25, 10)
	closeButton.DoClick = function()
		PS:ToggleMenu()
	end
	
	local tabs = vgui.Create('DPropertySheet', self)
	
	if PS.Config.DisplayPreviewInMenu then
		tabs:DockMargin(10, 80, 410, 10)
	else
		tabs:DockMargin(10, 80, 10, 10)
	end
	tabs:Dock(FILL)
	
	tabs:SetSize(self:GetWide() - 60, self:GetTall() - 150)
	tabs:SetPos((self:GetWide() / 2) - (tabs:GetWide() / 2), 120)
	
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
			tabs:AddSheet(CATEGORY.Name, ShopCategoryTab, 'icon16/' .. CATEGORY.Icon .. '.png', false, false, '')
			continue
		else
			ShopCategoryTab = vgui.Create('DPanel')
		end
		
		ShopCategoryTab.DScrollPanel = vgui.Create('DScrollPanel', ShopCategoryTab)
		ShopCategoryTab.DScrollPanel:Dock(FILL)
		
		ShopCategoryTab.DIconLayout = vgui.Create('DIconLayout', ShopCategoryTab.DScrollPanel)
		ShopCategoryTab.DIconLayout:Dock(FILL)
		ShopCategoryTab.DIconLayout:SetBorder(10)
		ShopCategoryTab.DIconLayout:SetSpaceX(10)
		ShopCategoryTab.DIconLayout:SetSpaceY(10)
		
		ShopCategoryTab.DScrollPanel:AddItem(ShopCategoryTab.DIconLayout)
		
		for _, ITEM in pairs(items) do
			if ITEM.Category == CATEGORY.Name then
				local model = vgui.Create('DPointShopItem')
				model:SetData(ITEM)
				model:SetSize(126, 126)
				
				ShopCategoryTab.DIconLayout:Add(model)
			end
		end
		
		local itemDescription = ''
		if CATEGORY.Description then
			itemDescription = CATEGORY.Description
		end
		
		if CATEGORY.ModifyTab then
			CATEGORY:ModifyTab(ShopCategoryTab)
		end
		
		tabs:AddSheet(CATEGORY.Name, ShopCategoryTab, 'icon16/' .. CATEGORY.Icon .. '.png', false, false, itemDescription)
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
		
		tabs:AddSheet('Admin', AdminTab, 'icon16/shield.png', false, false, '')
	end
	
	-- preview panel

	local preview
	if PS.Config.DisplayPreviewInMenu then
		preview = vgui.Create('DPanel', self)
		
		preview:DockMargin(self:GetWide() - 400, 100, 10, 10)
		preview:Dock(FILL)
		
		local previewpanel = vgui.Create('DPointShopPreview', preview)
		previewpanel:Dock(FILL)
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

function PANEL:Paint()
	Derma_DrawBackgroundBlur(self)
	
	draw.RoundedBox(10, 0, 0, self:GetWide(), self:GetTall(), Color(0, 0, 0, 150))
	
	draw.SimpleText('PointShop', 'PS_Heading', 20, 10, color_white)
	draw.SimpleText('by _Undefined', 'PS_Heading2', 275, 50, color_white)
	draw.SimpleText('You have ' .. LocalPlayer():PS_GetPoints() .. ' ' .. PS.Config.PointsName, 'PS_Heading3', self:GetWide() - 10, 60, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
end

vgui.Register('DPointShopMenu', PANEL)
