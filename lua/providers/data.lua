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