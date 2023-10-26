local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = QBCore.Functions.GetPlayerData()
local isLoggedIn = LocalPlayer.state.isLoggedIn
local pedsSpawned = false

--Functions

local function spawnPeds()
    if not Config.Peds or not next(Config.Peds) or pedsSpawned then return end
    for i = 1, #Config.Peds do
        local current = Config.Peds[i]
        RequestModel(current.model)
        while not HasModelLoaded(current.model) do
            Wait(0)
        end
        local ped = CreatePed(0, current.model, current.coords.x, current.coords.y, current.coords.z, current.coords.w, false, false)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        TaskStartScenarioInPlace(ped, current.scenario, true, true)
        current.pedHandle = ped
        if Config.UseTarget then
            exports['qb-target']:AddTargetEntity(ped, {
                options = {
                    {
                        type = 'client',
                        event = 'qb-registration:client:MainMenu',
                        label = 'Register Vehicle',
                        icon = 'fa-solid fa-car',
                    }
                },
                distance = 2.0
            })
        end
    end
    pedsSpawned = true
end

local function deletePeds()
    if not Config.Peds or not next(Config.Peds) or not pedsSpawned then return end
    for i = 1, #Config.Peds do
        local current = Config.Peds[i]
        if current.pedHandle then
            DeletePed(current.pedHandle)
        end
    end
    pedsSpawned = false
end

--Events

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    isLoggedIn = true
    spawnPeds()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
    isLoggedIn = false
    deletePeds()
end)

RegisterNetEvent('onResourceStart', function()
    spawnPeds()
end)

RegisterNetEvent('onResourceStop', function()
    deletePeds()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    deletePeds()
end)

RegisterNetEvent('qb-registration:client:MainMenu', function()
    exports['qb-menu']:openMenu({
        {
            header = 'Vehicle Registration Menu',
            icon = 'fa-solid fa-car',
            isMenuHeader = true,
        },
        {
            header = 'Check vehicles',
            txt = 'See a list of vehicles you own',
            icon = 'fa-solid fa-car',
            params = {
                event  = 'qb-registration:client:vehicleSubMenu',
            }
        }
    }

    )
end)

RegisterNetEvent('qb-registration:client:vehicleSubMenu', function()
    QBCore.Functions.TriggerCallback('qb-registration:server:getOwnedVehicles', function(result)
        local ownedVehicles = {}
        ownedVehicles[#ownedVehicles+1] = {
            isMenuHeader = true,
            header = 'Owned Vehicles',
            icon = 'fa-solid fa-car'
        }
        for k,v in pairs(result) do
            local regExpiry = v.registration

            ownedVehicles[#ownedVehicles+1] = {
                header = tostring(k..' - '..v.vehicle..' [Plate: '..v.plate..']'),
                txt = regExpiry,
                params = {
                    event = 'qb-registration:client:registrationSubMenu',
                    args = {
                        vehicle = v.vehicle,
                        plate = v.plate
                    }
                }
            }
        end
        exports['qb-menu']:openMenu(ownedVehicles)
    end)
end)

RegisterNetEvent('qb-registration:client:registrationSubMenu', function(data)
    local feeMenu = {}
    feeMenu[#feeMenu+1] = {
        isMenuHeader = true,
        header = tostring(data.vehicle..' - [Plate: '..data.plate..']'),
        icon = 'fa-solid fa-car'
    }
    for k,v in pairs(Config.Fees) do
        feeMenu[#feeMenu+1] = {
            header = tostring(v.days..' days - $'..v.fee),
            txt = 'Register your vehicle for '..v.days..' days',
            params = {
                event = 'qb-registration:client:registerVehicle',
                args = {
                    days = v.days,
                    fee = v.fee,
                    vehicle = data.vehicle,
                    plate = data.plate
                }
            }
        }
    end
    exports['qb-menu']:openMenu(feeMenu)
end)

RegisterNetEvent('qb-registration:client:registerVehicle', function(data)
    TriggerServerEvent('qb-registration:server:registerVehicle', data)
end)