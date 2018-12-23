local function QueryWithInsertOrIgnore(ply, query, ...)
    local insertOrIgnoreStatement = [[INSERT OR IGNORE INTO `pointshop_data` VALUES ('%s', '0', '[]');]]..query
    local query = string.format(insertOrIgnoreStatement, ply:SteamID64(), ...)
    return sql.Query(query)
end

sql.Query("CREATE TABLE IF NOT EXISTS `pointshop_data` ( `sid64` STRING, `points` REAL, `items` STRING, PRIMARY KEY(sid64) )")

function PROVIDER:GetData(ply, callback)
    local query = [[SELECT * FROM `pointshop_data` WHERE sid64 = '%s']]
    local data = sql.Query(string.format(query, ply:SteamID64()))

    if data and #data > 0 then
        local row = data[1]
        
        local points = row.points or 0
        local items = util.JSONToTable(row.items or '{}')
 
        callback(points, items)
    else
        callback(0, {})
    end
end

function PROVIDER:SetPoints(ply, points)
    local query = [[UPDATE `pointshop_data` SET points = '%s' WHERE sid64 = '%s']]
    QueryWithInsertOrIgnore(ply, query, points, ply:SteamID64())
end

function PROVIDER:GivePoints(ply, points)
    local query = [[UPDATE `pointshop_data` SET points = points + '%s' WHERE sid64 = '%s']]
    QueryWithInsertOrIgnore(ply, query, points, ply:SteamID64())
end

function PROVIDER:TakePoints(ply, points)
    local query = [[UPDATE `pointshop_data` SET points = points - '%s' WHERE sid64 = '%s']]
    QueryWithInsertOrIgnore(ply, query, points, ply:SteamID64())
end

function PROVIDER:SaveItem(ply, item_id, data)
    self:GiveItem(ply, item_id, data)
end

function PROVIDER:GiveItem(ply, item_id, data)
    local tmp = table.Copy(ply.PS_Items)
    tmp[item_id] = data

    local query = [[UPDATE `pointshop_data` SET items = %s WHERE sid64 = '%s']]
    QueryWithInsertOrIgnore(ply, query, sql.SQLStr(util.TableToJSON(tmp)), ply:SteamID64())
end

function PROVIDER:TakeItem(ply, item_id)
    local tmp = table.Copy(ply.PS_Items)
    tmp[item_id] = nil

    local query = [[UPDATE `pointshop_data` SET items = %s WHERE sid64 = '%s']]
    QueryWithInsertOrIgnore(ply, query, sql.SQLStr(util.TableToJSON(tmp)), ply:SteamID64())
end
 
function PROVIDER:SetData(ply, points, items)
    local query = [[UPDATE `pointshop_data` SET points = '%s', items = %s WHERE sid64 = '%s']]
    QueryWithInsertOrIgnore(ply, query, points, sql.SQLStr(util.TableToJSON(items)), ply:SteamID64())
end