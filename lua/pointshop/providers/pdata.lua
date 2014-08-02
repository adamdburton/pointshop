function PROVIDER:GetData(ply, callback)
	return callback(ply:GetPData('PS_Points', 0), util.JSONToTable(ply:GetPData('PS_Items', '{}')))
end

function PROVIDER:SetData(ply, points, items)
	ply:SetPData('PS_Points', points)
	ply:SetPData('PS_Items', util.TableToJSON(items))
end