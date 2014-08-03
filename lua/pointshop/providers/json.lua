function PROVIDER:GetData(ply, callback)
	if not file.IsDir('pointshop', 'DATA') then
		file.CreateDir('pointshop')
	end
	
	local points, items
	
	local filename = string.Replace(ply:SteamID(), ':', '_')
	
	if not file.Exists('pointshop/' .. filename .. '.txt', 'DATA') then
		file.Write('pointshop/' .. filename .. '.txt', util.TableToJSON({
			Points = 0,
			Items = {}
		}))
		
		points = 0
		items = {}
	else
		local data = util.JSONToTable(file.Read('pointshop/' .. filename .. '.txt', 'DATA'))
		
		points = data.Points or 0
		items = data.Items or {}
	end
	
	return callback(points, items)
end

function PROVIDER:SetPoints( ply, set_points )
	self:GetData(ply, function(points, items)
		self:SetData(ply, set_points, items)
	end)
end

function PROVIDER:GivePoints( ply, add_points )
	self:GetData(ply, function(points, items)
		self:SetData(ply, points + add_points, items)
	end)
end

function PROVIDER:TakePoints( ply, points )
	self:GivePoints(ply, -points)
end

function PROVIDER:SaveItem( ply, item_id, data)
	self:GiveItem(ply, item_id, data)
end

function PROVIDER:GiveItem( ply, item_id, data)
	self:GetData(ply, function(points, items)
		local tmp = table.Copy(ply.PS_Items)
		tmp[item_id] = data
		self:SetData(ply, points, tmp)
	end)
end

function PROVIDER:TakeItem( ply, item_id )
	self:GetData(ply, function(points, items)
		local tmp = table.Copy(ply.PS_Items)
		tmp[item_id] = nil
		self:SetData(ply, points, tmp)
	end)
end

function PROVIDER:SetData(ply, points, items)
	if not file.IsDir('pointshop', 'DATA') then
		file.CreateDir('pointshop')
	end
	
	local filename = string.Replace(ply:SteamID(), ':', '_')
	
	file.Write('pointshop/' .. filename .. '.txt', util.TableToJSON({
		Points = points,
		Items = items
	}))
end