-- let we say we have, killer, and killed player
-- entityOwner: is the current player
-- entityDamage: is the player has been take damage from current player
-- so we have to check when player take damge from current player. and we will check also if the weapon is on inventory current player or not.

-- we have config file that's has some weapon name
Config = {}
Config.NormalDead = {
    ['weapon_rammed_by_car'] = true,
    ['weapon_fall'] = true,
    ['weapon_drowning'] = true,
    ['weapon_drowning_in_vehicle'] = true,
}

local PlayerData = QBCore.Functions.GetPlayerData()

-- When the players job gets updated this will trigger and update the playerdata
RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
end)

-- When the players gang gets updated this will trigger and update the playerdata
RegisterNetEvent('QBCore:Client:OnGangUpdate', function(GangInfo)
    PlayerData.gang = GangInfo
end)

-- This will update all the PlayerData that doesn't get updated with a specific event other than this like the metadata
RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
end)

-- i am not sure if i have added all normal dead name or not. so make sure if there other name in QbCore shread weapon.lua file.

-- so we need event 'gameEventTriggered'
AddEventHandler('gameEventTriggered', function(name, args)
    if name == 'CEventNetworkEntityDamage' then
        local entity = args[2]
        local damageEntity = args[1]
        if IsEntityAPed(damageEntity) then
            if IsPedAPlayer(damageEntity) then
                local ped = PlayerPedId()
                local entityOwner = GetPlayerServerId(NetworkGetEntityOwner(entity))
                local playerId = GetPlayerServerId(ped)
                if playerId == entityOwner then
                    local weapon = args[7]
                    local WeaponInformation = QBCore.Shared.Weapons[weapon]
                    if WeaponInformation ~= nil then
                        local name = WeaponInformation.name
                        if not Config.NormalDead[name] then
                            if name == 'weapon_unarmed' then
                                if not IsEntityOnScreen(damageEntity) then -- so this mean if player got unarrmed weapon damage. we will check if damge player is on player screen or is killed by cheaters script????
                                    TriggerServerEvent('dev-anticheat:server:BanMe', 'damage-gun')
                                    CancelEvent()
                                end
                            else
                                if not PlayerHasThisWeapon(name) then
                                    TriggerServerEvent('dev-anticheat:server:BanMe', 'damage-gun-no-weapon: ' .. name)
                                    CancelEvent()
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

function PlayerHasThisWeapon(name)
    local pd = nil
    if PlayerData then
        pd = PlayerData
    else
        pd = QBCore.Functions.GetPlayerData()
    end
    for _, item in pairs(pd.items) do
        if item.name == name then return true end
    end

    return false
end
