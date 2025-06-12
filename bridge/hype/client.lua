if GetResourceState('hype_core') ~= 'started' then
    return
end

PlayerData = {}
local success, hype = pcall(function ()
    local obj = exports.hype_core:getSharedObject()
    if obj.PlayerLoaded then
        PlayerData.job = {
            name = obj.PlayerData.job.name,
            grade = obj.PlayerData.job.grade,
        }
    end
    return obj
end)

if not success then return end

RegisterNetEvent('esx:setJob', function (job)
    if source == '' then return end
    PlayerData.job = {
        name = job.name,
        grade = job.grade,
    }
end)

RegisterNetEvent('esx:playerLoaded', function (xPlayer, isNew, skin)
    if source == '' then return end
    PlayerData.job = {
        name = xPlayer.job.name,
        grade = xPlayer.job.grade,
    }
end)
