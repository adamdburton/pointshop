CATEGORY.Name = 'Accessories'
CATEGORY.Icon = 'add'

function CATEGORY:ModifyTab(tab)
	local button = vgui.Create('DButton', tab)
	
	button:SetText('Click me!')
	button:Dock(BOTTOM)
	
	button.DoClick = function()
		Derma_Message('You clicked the button!', 'CLICKED', 'OK')
	end
end