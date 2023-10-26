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

RegisterNetEvent('qb-registration:server:registerVehicle', function(data)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    Player.Functions.RemoveMoney('bank', data.fee)
    TriggerClientEvent('QBCore:Notify', source, 'You just paid $ '..data.fee.. ' for '..data.days..' days registration on your '..data.vehicle..' [Plate: '..data.plate..']')
    local timestamp = os.time()
    local regExpiry = timestamp + data.days * 86400
    local result = MySQL.query.await('SELECT plate FROM player_vehicles WHERE plate = ?', {data.plate})
    if result[1] ~= nil then
        MySQL.update('UPDATE player_vehicles SET registration = ? WHERE plate = ?', {regExpiry, data.plate})
    end

end)