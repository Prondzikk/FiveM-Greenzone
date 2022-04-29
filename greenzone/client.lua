local zones = {
	{ ['x'] = 2640.3425292969, ['y'] = 3273.8828125, ['z'] = 55.22},
}

local notifIn = false
local notifOut = false
local closestZone = 1


Citizen.CreateThread(function()
	while not NetworkIsPlayerActive(PlayerId()) do
		Citizen.Wait(0)
	end
	
	for i = 1, #zones, 1 do
		local szBlip = AddBlipForCoord(zones[i].x, zones[i].y, zones[i].z)
		SetBlipAsShortRange(szBlip, true)
		SetBlipColour(szBlip, 43)
		SetBlipSprite(szBlip, 310)
	    BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Green Zone Sandy")
		EndTextCommandSetBlipName(szBlip)
	end
end)
Citizen.CreateThread(function()
	while not NetworkIsPlayerActive(PlayerId()) do
		Citizen.Wait(0)
	end
	
	while true do
		local playerPed = GetPlayerPed(-1)
		local x, y, z = table.unpack(GetEntityCoords(playerPed, true))
		local minDistance = 100000
		for i = 1, #zones, 1 do
			dist = Vdist(zones[i].x, zones[i].y, zones[i].z, x, y, z)
			if dist < minDistance then
				minDistance = dist
				closestZone = i
			end
		end
		Citizen.Wait(15000)
	end
end)
Citizen.CreateThread(function()
	while not NetworkIsPlayerActive(PlayerId()) do
		Citizen.Wait(0)
	end
	
	while true do
		Citizen.Wait(0)
		local player = GetPlayerPed(-1)
		local x,y,z = table.unpack(GetEntityCoords(player, true))
		local dist = Vdist(zones[closestZone].x, zones[closestZone].y, zones[closestZone].z, x, y, z)
	
		if dist <= 25.0 then
			if not notifIn then	
				NetworkSetFriendlyFireOption(false)
				ClearPlayerWantedLevel(PlayerId())
				SetCurrentPedWeapon(player,GetHashKey("WEAPON_UNARMED"),true)
				TriggerEvent("pNotify:SendNotification",{
					text = "<b style='color:#1E90FF'>Jesteś w bezpiecznej strefie</b>",
					type = "success",
					timeout = (3000),
					layout = "centerRight",
					queue = "global"
				})
				notifIn = true
				notifOut = false
			end
		else
			if not notifOut then
				NetworkSetFriendlyFireOption(true)
				TriggerEvent("pNotify:SendNotification",{
					text = "<b style='color:#1E90FF'>Nie jesteś już w bezpiecznej strefie</b>",
					type = "alert",
					timeout = (3000),
					layout = "centerRight",
					queue = "global"
				})
				notifOut = true
				notifIn = false
			end
		end
		if notifIn then
		DisableControlAction(2, 37, true) 
		DisablePlayerFiring(player,true) 
      	DisableControlAction(0, 106, true) 
			if IsDisabledControlJustPressed(2, 37) then 
				SetCurrentPedWeapon(player,GetHashKey("WEAPON_UNARMED"),true) 
				TriggerEvent("pNotify:SendNotification",{
					text = "<b style='color:#1E90FF'>Nie możesz używać broni w bezpiecznej strefie</b>",
					type = "error",
					timeout = (3000),
					layout = "centerRight",
					queue = "global"
				})
			end
			if IsDisabledControlJustPressed(0, 106) then 
				SetCurrentPedWeapon(player,GetHashKey("WEAPON_UNARMED"),true) 
				TriggerEvent("pNotify:SendNotification",{
					text = "<b style='color:#1E90FF'>Nie możesz tego zrobić w bezpiecznej strefie</b>",
					type = "error",
					timeout = (3000),
					layout = "centerRight",
					queue = "global"
				})
			end
		end
	 	if DoesEntityExist(player) then	    
	 		DrawMarker(1, zones[closestZone].x, zones[closestZone].y, zones[closestZone].z-1.0001, 0, 0, 0, 0, 0, 0, 50.0, 50.0, 2.0, 233, 0, 255, 155, 0, 0, 2, 0, 0, 0, 0) 
	 	end
	end
end)