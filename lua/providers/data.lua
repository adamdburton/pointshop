function PROVIDER:GetData(ply, callback)
	if not file.IsDir('pointshop', 'DATA') then
		file.CreateDir('pointshop')
	end
	
	local points, items
	
	local filename = string.replace(ply:SteamID(), ':', '_')
	
	if not file.Exists('pointshop/' .. filename .. '.txt') then
		file.Create('pointshop/' .. filename .. '.txt')
		
		points = 0
		items = {}
	else
		local data = util.KeyValuesToTable(file.Read('pointshop/' .. filename .. '.txt', 'DATA'))
		
		points = data.Points
		items = util.JSONToTable(data.Items)
	end
	
	return callback(points, items)
end

function PROVIDER:SetData(ply, points, items)
	if not file.IsDir('pointshop', 'DATA') then
		file.CreateDir('pointshop')
	end
	
	local filename = string.replace(ply:SteamID(), ':', '_')
	
	file.Write('pointshop/' .. filename .. '.txt', util.TableToKeyValues({
		Points = points,
		Items = util.TableToJSON(items)
	})
end