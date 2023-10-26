local QBCore = exports['qb-core']:GetCoreObject()

local function formatUnixTimestamp(timestamp)
    if type(timestamp) == "number" then
        return os.date("%d-%b-%Y %H:%Mhrs", timestamp)
    else
        return "Invalid Date" -- Handle the case where 'timestamp' is not an integer
    end
end

QBCore.Functions.CreateCallback('qb-registration:server:getOwnedVehicles', function(source, cb)
    local pData = QBCore.Functions.GetPlayer(source)
    print(citizenid)
    if pData then
        MySQL.query('SELECT * FROM player_vehicles WHERE citizenid = ?', {pData.PlayerData.citizenid},
            function(result)
                if result[1] then
                    for _, row in ipairs(result) do
                        if row.registration then
                            if row.registration >= os.time() then
                                row.registration = 'REGISTRATION: <span style="color: green; font-weight: bold;">CURRENT</span><br>Expires: '..formatUnixTimestamp(row.registration)
                            else
                                row.registration = 'REGISTRATION: <span style="color: red; font-weight: bold;">EXPIRED</span><br>Expired: '..formatUnixTimestamp(row.registration)
                            end
                        else
                            row.registration = '<span style="color: orange; font-weight: bold;">NEVER REGISTERED</span>'
                        end
                    end
                    cb(result)
                else
                    cb(nil)
                end
            end)
    end
end)

-- QBCore.Functions.CreateCallback('qb-registration:server:searchPlate', function(source, cb, plate)
--     --print(source)
--     print("Received string on the server: " .. plate)
--     local vehicles = MySQL.query.await("SELECT pv.id, pv.citizenid, pv.plate, pv.vehicle, pv.mods, pv.state, p.charinfo FROM `player_vehicles` pv LEFT JOIN players p ON pv.citizenid = p.citizenid WHERE LOWER(`plate`) LIKE :query OR LOWER(`vehicle`) LIKE :query LIMIT 25", {
--         query = string.lower('%'..plate..'%')})

--     if not vehicles[1] then
--         --cb('No vehicles found')
--         TriggerClientEvent('QBCore:Notify', source, "No vehicle registration details found", 'error')
--         cb('ERROR: No vehicle registration details found')
--     return end

--     return cb(vehicles)
-- end)

RegisterNetEvent('qb-registration:server:registerVehicle', function(data)
    print('ID: '..source..' just paid $'..data.fee..' for '..data.days..' days registration on their '..data.vehicle..' [Plate: '..data.plate..']')
    local timestamp = os.time()
    local regExpiry = timestamp + data.days * 86400
    local result = MySQL.query.await('SELECT plate FROM player_vehicles WHERE plate = ?', {data.plate})
    if result[1] ~= nil then
        MySQL.update('UPDATE player_vehicles SET registration = ? WHERE plate = ?', {regExpiry, data.plate})
    end

end)

--Commands

-- QBCore.Commands.Add('checkplate', 'Check vehicle registration details (Law enforcement only)', {}, false, function(source)
--     local src = source
-- 	local Player = QBCore.Functions.GetPlayer(src)
-- 	if Player.PlayerData.job.name == "police" or Player.PlayerData.job.type == "leo" then
-- 		TriggerClientEvent("qb-registration:client:checkPlateMenu", src)
-- 	else
-- 		TriggerClientEvent('QBCore:Notify', src, 'Only Police or Law Enforcement can check plates', "error")
-- 	end
-- end)