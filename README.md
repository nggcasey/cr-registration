# cr-registration
Vehicle Registration for QB-Core Framework by Casey Reed

## Dependencies
- [qb-core](https://github.com/qbcore-framework/qb-core)
- [qb-target](https://github.com/BerkieBb/qb-target) - For Interaction
- [oxmysql](https://github.com/overextended/oxmysql) - Note: Comes standard with QBCore Framework

## Features
- Allows players to pay registration on their vehicles
- Players can check the registration on all of their vehicles
- Configurable registration periods
- Can be integrated into various MDT resources (i.e. ps-mdt instructions below - Follow carefully)

## Planned features

- Players to get a registration document on registering their vehicle

## Installation
-Drag and drop resource into your server files, make sure to remove -main in the folder name
-Run the attached SQL script (cr-registration.sql)

## Screenshots
<img src= "https://imgur.com/JkANrla.png">
<img src = "https://imgur.com/Z7XFcRB.png">
<img src = "https://imgur.com/86hbfMp.png">

## PS-MDT Integration

https://github.com/Project-Sloth/ps-mdt

Below are instructions for integrating this into ps-mdt - Follow them carefully

Screenshots:

<img src = "https://imgur.com/a/9qGzK6Y.png">
<img src = "https://imgur.com/iMFozBA.png">
<img src = "https://imgur.com/ZgX2jyO.png">

* Under /server/main.lua

Under this:

```lua
if Config.UseWolfknightRadar == true then
	RegisterNetEvent("wk:onPlateScanned")
	AddEventHandler("wk:onPlateScanned", function(cam, plate, index)
		local src = source
		local Player = QBCore.Functions.GetPlayer(src)
		local PlayerData = GetPlayerData(src)
		local vehicleOwner = GetVehicleOwner(plate)
		local bolo, title, boloId = GetBoloStatus(plate)
		local warrant, owner, incidentId = GetWarrantStatus(plate)
		local driversLicense = PlayerData.metadata['licences'].driver

		if bolo == true then
			TriggerClientEvent('QBCore:Notify', src, 'BOLO ID: '..boloId..' | Title: '..title..' | Registered Owner: '..vehicleOwner..' | Plate: '..plate, 'error', Config.WolfknightNotifyTime)
		end
		if warrant == true then
			TriggerClientEvent('QBCore:Notify', src, 'WANTED - INCIDENT ID: '..incidentId..' | Registered Owner: '..owner..' | Plate: '..plate, 'error', Config.WolfknightNotifyTime)
		end

		if Config.PlateScanForDriversLicense and driversLicense == false and vehicleOwner then
			TriggerClientEvent('QBCore:Notify', src, 'NO DRIVERS LICENCE | Registered Owner: '..vehicleOwner..' | Plate: '..plate, 'error', Config.WolfknightNotifyTime)
		end

		if bolo or warrant or (Config.PlateScanForDriversLicense and not driversLicense) and vehicleOwner then
			TriggerClientEvent("wk:togglePlateLock", src, cam, true, 1)
		end
	end)
end
```
REPLACE THIS LINE
```lua
local vehicleOwner = GetVehicleOwner(plate)
```
WITH THIS LINE
```lua
local vehicleOwner, registration = GetVehicleOwner(plate)
```
UNDER THIS CODE:
```lua
		if Config.PlateScanForDriversLicense and driversLicense == false and vehicleOwner then
			TriggerClientEvent('QBCore:Notify', src, 'NO DRIVERS LICENCE | Registered Owner: '..vehicleOwner..' | Plate: '..plate, 'error', Config.WolfknightNotifyTime)
		end
```
ADD THIS CODE:
```lua
		if not registration then
			TriggerClientEvent('QBCore:Notify', src, 'UNREGISTERED VEHICLE | Registered Owner: '..vehicleOwner..' | Plate: '..plate, 'error', Config.WolfknightNotifyTime)
			registration = false
		else
			if registration < os.time() then
				TriggerClientEvent('QBCore:Notify', src, 'UNREGISTERED VEHICLE | Registered Owner: '..vehicleOwner..' | Plate: '..plate, 'error', Config.WolfknightNotifyTime)
				registration = false
			end
		end
```
REPLACE THIS CODE:
```lua
		if bolo or warrant or (Config.PlateScanForDriversLicense and not driversLicense) and vehicleOwner then
			TriggerClientEvent("wk:togglePlateLock", src, cam, true, 1)
		end
```
WITH THIS CODE:
```lua
		if bolo or warrant or (Config.PlateScanForDriversLicense and not driversLicense) or not registration and vehicleOwner then
			TriggerClientEvent("wk:togglePlateLock", src, cam, true, 1)
		end
```
Under ```QBCore.Functions.CreateCallback('mdt:server:SearchVehicles', function(source, cb```
REPLACE THIS:
```lua
			local vehicles = MySQL.query.await("SELECT pv.id, pv.citizenid, pv.plate, pv.vehicle, pv.mods, pv.state, p.charinfo FROM `player_vehicles` pv LEFT JOIN players p ON pv.citizenid = p.citizenid WHERE LOWER(`plate`) LIKE :query OR LOWER(`vehicle`) LIKE :query LIMIT 25", {
				query = string.lower('%'..sentData..'%')
			})
```
WITH THIS:
```lua
			local vehicles = MySQL.query.await("SELECT pv.id, pv.citizenid, pv.plate, pv.vehicle, pv.registration, pv.mods, pv.state, p.charinfo FROM `player_vehicles` pv LEFT JOIN players p ON pv.citizenid = p.citizenid WHERE LOWER(`plate`) LIKE :query OR LOWER(`vehicle`) LIKE :query LIMIT 25", {
				query = string.lower('%'..sentData..'%')
			})
```
Under THIS:
```lua
			for _, value in ipairs(vehicles) do
				if value.state == 0 then
					value.state = "Out"
				elseif value.state == 1 then
					value.state = "Garaged"
				elseif value.state == 2 then
					value.state = "Impounded"
				end
```
ADD THIS:
```lua
				if not value.registration then
					value.registration = 'Never Registered'
				else
					value.registration = os.date("%d-%b-%Y %H:%Mhrs", value.registration)
				end
```
Under ```RegisterNetEvent('mdt:server:getVehicleData', function(plate)```
Under THIS:
```lua
					vehicle[1]['bolo'] = GetBoloStatus(vehicle[1]['plate'])
					vehicle[1]['information'] = ""
```
ADD THIS:
```lua
					if not vehicle[1]['registration'] then
						vehicle[1]['registration'] = 'NEVER REGISTERED'
					else
						vehicle[1]['registration'] = os.date("%d-%b-%Y %H:%Mhrs", vehicle[1]['registration'])
					end
```
REPLACE THIS:
```lua
function GetVehicleOwner(plate)

	local result = MySQL.query.await('SELECT plate, citizenid, id FROM player_vehicles WHERE plate = @plate', {['@plate'] = plate})
	if result and result[1] then
		local citizenid = result[1]['citizenid']
		local Player = QBCore.Functions.GetPlayerByCitizenId(citizenid)
		local owner = Player.PlayerData.charinfo.firstname.." "..Player.PlayerData.charinfo.lastname
		return owner
	end
end
```
WITH THIS:
```lua
function GetVehicleOwner(plate)

	local result = MySQL.query.await('SELECT plate, registration, citizenid, id FROM player_vehicles WHERE plate = @plate', {['@plate'] = plate})
	if result and result[1] then
		local citizenid = result[1]['citizenid']
		local Player = QBCore.Functions.GetPlayerByCitizenId(citizenid)
		local owner = Player.PlayerData.charinfo.firstname.." "..Player.PlayerData.charinfo.lastname
		local registration = result[1]['registration']
		return owner, registration
	end
end
```

* Under ui/app.js

REPLACE THIS:
```js
<div class="dmv-id">Plate: ${value.plate} · Owner: ${value.owner}</div>
```
WITH THIS:
```js
<div class="dmv-id">Plate: ${value.plate} · Owner: ${value.owner} | Reg Expiry: ${value.registration} </div>
```

Under ```else if (eventData.type == "getVehicleData") ```
ADD THIS ```$(".vehicle-info-registration-input").val(table["registration"]);```
underneath ````$(".vehicle-info-plate-input").val(table["plate"]);```

* Under ui/dashboard.html

UNDERNEATH THIS:
```html
                        <div class="vehicle-info-plate">Registration Plate</div>
                        <div><span class="fas fa-address-card vehicle-info-icon"></span><input type="text" readonly class="vehicle-info-plate-input"></div>
```
ADD THIS:
```html
                        <div class="vehicle-info-plate">Registration Expiry</div>
                        <div><span class="fas fa-clock vehicle-info-icon"></span><input type="text" readonly class="vehicle-info-registration-input"></div>
                        <div class="vehicle-info-line"></div>
```
 * Under style.css

 UNDERNEATH THIS:
 ```css
 .vehicle-info-owner-input {
    border: none;
    outline: none;
    margin-left: 2.5px;
    font-size: 16px;
    margin-top: 5px;
    color: white;
    background-color: rgba(0, 0, 0, 0);
    width: 80%;
}
 ```

 ADD THIS:
 ```css
 .vehicle-info-registration-input {
    border: none;
    outline: none;
    margin-left: 2.5px;
    font-size: 16px;
    margin-top: 5px;
    color: white;
    background-color: rgba(0, 0, 0, 0);
    width: 80%;
}

 ```


## Support
-I don't generally provide support as I'm too busy, but feel free to use this code, raise issues or submit pull requests etc.
