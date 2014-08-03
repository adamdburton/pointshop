function PROVIDER:GetData(ply, callback)
	return callback(ply:GetPData('PS_Points', 0), util.JSONToTable(ply:GetPData('PS_Items', '{}')))
end

function PROVIDER:SetPoints(ply, set_points)
	ply:SetPData('PS_Points', set_points)
end

function PROVIDER:GivePoints(ply, add_points)
	ply:SetPData('PS_Points', ply:GetPData('PS_Points', 0) + add_points)
end

function PROVIDER:TakePoints(ply, points)
	self:GivePoints(ply, -points)
end

function PROVIDER:SaveItem(ply, item_id, data)
	self:GiveItem(ply, item_id, data)
end

function PROVIDER:GiveItem(ply, item_id, data)
	local tmp = table.Copy(ply.PS_Items)
	tmp[item_id] = data
	ply:SetPData('PS_Items', util.TableToJSON(tmp))
end

function PROVIDER:TakeItem(ply, item_id)
	local tmp = util.JSONToTable(ply:GetPData('PS_Items', '{}'))
	tmp[item_id] = nil
	ply:SetPData('PS_Items', util.TableToJSON(tmp))
end

function PROVIDER:SetData(ply, points, items)
	ply:SetPData('PS_Points', points)
	ply:SetPData('PS_Items', util.TableToJSON(items))
end