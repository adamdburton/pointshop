sql.Query("CREATE TABLE IF NOT EXISTS `pointshop_data` ( `sid64` STRING, `points` REAL, `medals` REAL, `items` STRING, PRIMARY KEY(sid64) )")

function PROVIDER:GetData(ply, callback)
    local query = "SELECT * FROM `pointshop_data` WHERE sid64 = '"..ply:SteamID64().."'"

    local data = ExecuteQueryWithDebug(query)

    if data ~= false and data ~= nil and #data > 0 then
        local row = data[1]
        
        local points = row.points or 0
        local medals = row.medals or 0
        local items = util.JSONToTable(row.items or '{}')
 
        callback(points, medals, items)
    else
        callback(0, 0, {})
    end
end

function PROVIDER:SetMedals(ply, medals)
    local query = "INSERT OR IGNORE INTO `pointshop_data` (sid64, points, medals, items) VALUES ('"..ply:SteamID64().."', '0', '"..(medals or 0).."', '[]'); UPDATE `pointshop_data` SET medals = "..(medals or 0).." WHERE sid64 = '"..ply:SteamID64().."'"
    ExecuteQueryWithDebug(query)
end

function PROVIDER:GiveMedals(ply, medals)
    local query = "INSERT OR IGNORE INTO `pointshop_data` (sid64, points, medals, items) VALUES ('"..ply:SteamID64().."', '0', '"..(medals or 0).."', '[]'); UPDATE `pointshop_data` SET medals = medals + "..(medals or 0).." WHERE sid64 = '"..ply:SteamID64().."'"
    ExecuteQueryWithDebug(query)
end

function PROVIDER:TakeMedals(ply, medals)
    local query = "INSERT OR IGNORE INTO `pointshop_data` (sid64, points, medals, items) VALUES ('"..ply:SteamID64().."', '0', '"..(medals or 0).."', '[]'); UPDATE `pointshop_data` SET medals = medals - "..(medals or 0).." WHERE sid64 = '"..ply:SteamID64().."'"
    ExecuteQueryWithDebug(query)
end

function PROVIDER:SetPoints(ply, points)
    local query = "INSERT OR IGNORE INTO `pointshop_data` (sid64, points, medals, items) VALUES ('"..ply:SteamID64().."', '"..(points or 0).."', '0', '[]'); UPDATE `pointshop_data` SET points = "..(points or 0).." WHERE sid64 = '"..ply:SteamID64().."'"
    ExecuteQueryWithDebug(query)
end

function PROVIDER:GivePoints(ply, points)
    local query = "INSERT OR IGNORE INTO `pointshop_data` (sid64, points, medals, items) VALUES ('"..ply:SteamID64().."', '"..(points or 0).."', '0', '[]'); UPDATE `pointshop_data` SET points = points + "..(points or 0).." WHERE sid64 = '"..ply:SteamID64().."'"
    ExecuteQueryWithDebug(query)
end

function PROVIDER:TakePoints(ply, points)
    local query = "INSERT OR IGNORE INTO `pointshop_data` (sid64, points, medals, items) VALUES ('"..ply:SteamID64().."', '"..(points or 0).."', '0', '[]'); UPDATE `pointshop_data` SET points = points - "..(points or 0).." WHERE sid64 = '"..ply:SteamID64().."'"
    ExecuteQueryWithDebug(query)
end

function PROVIDER:SaveItem(ply, item_id, data)
    self:GiveItem(ply, item_id, data)
end

function PROVIDER:GiveItem(ply, item_id, data)
    local tmp = table.Copy(ply.PS_Items)
    tmp[item_id] = data

    local query = "INSERT OR IGNORE INTO `pointshop_data` (sid64, points, medals, items) VALUES ('"..ply:SteamID64().."', '0', '0', "..sql.SQLStr(util.TableToJSON(tmp)).."); UPDATE `pointshop_data` SET items = "..sql.SQLStr(util.TableToJSON(tmp)).." WHERE sid64 = '"..ply:SteamID64().."'"
    ExecuteQueryWithDebug(query)
end

function PROVIDER:TakeItem(ply, item_id)
    local tmp = table.Copy(ply.PS_Items)
    tmp[item_id] = nil

    local query = "INSERT OR IGNORE INTO `pointshop_data` (sid64, points, medals, items) VALUES ('"..ply:SteamID64().."', '0', '0', "..sql.SQLStr(util.TableToJSON(tmp)).."); UPDATE `pointshop_data` SET items = "..sql.SQLStr(util.TableToJSON(tmp)).." WHERE sid64 = '"..ply:SteamID64().."'"
    ExecuteQueryWithDebug(query)
end
 
function PROVIDER:SetData(ply, points, medals, items)
    local query = "INSERT OR IGNORE INTO `pointshop_data` (sid64, points, medals, items) VALUES ('"..ply:SteamID64().."', '"..(points or 0).."', "..(medals or 0)..", "..sql.SQLStr(util.TableToJSON(items)).."); UPDATE `pointshop_data` SET points = "..(points or 0)..", items = "..sql.SQLStr(util.TableToJSON(items)).." WHERE sid64 = '"..ply:SteamID64().."'"
    ExecuteQueryWithDebug(query)
end

function ExecuteQueryWithDebug(query)
    local queryReturn = sql.Query(query)
    if queryReturn == false then
        print("SQLITE ERROR!")
        print("QUERY --> '"..query.."'")
        print("ERROR --> '"..sql.LastError().."'")
        debug.Trace()
    end
    return queryReturn
end