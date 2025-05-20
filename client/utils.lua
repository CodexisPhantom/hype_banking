local utils = {}
local config = require 'shared.config'
local points = {}
local interactionId = 'hype_banking:client:openBankUI'

--- Send NUI Message
---@param action string
---@param data any
function utils.sendMessage(action, data)
    return SendNUIMessage({
        action = action,
        data = data
    })
end

function utils.createBlip(data)
    local blip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
    SetBlipSprite(blip, data.sprite)
    SetBlipDisplay(blip, data.display)
    SetBlipScale(blip, data.scale)
    SetBlipColour(blip, data.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(data.label)
    EndTextCommandSetBlipName(blip)
end

--- Create Peds
---@param openBank function
function utils.createPeds(openBank)
    for k, v in pairs(config.peds) do
        local blipdata = v.blip or config.blip
        blipdata.coords = v.coords
        local blip = utils.createBlip(blipdata)
        local pts = lib.points.new({
            coords = vec4(v.coords.x, v.coords.y, v.coords.z, v.coords.w),
            heading = v.coords.w,
            distance = 100,
            model = v.model,
            manager = v.createAccounts
        })

        function pts:registerInteraction()
            pts:createPed()
            if config.interactionType == 'ox_target' then
                exports.ox_target:addLocalEntity(self.entity, {
                    {
                        label = locale('view_bank'),
                        icon = 'fas fa-university',
                        name = interactionId,
                        id = interactionId,
                        onSelect = function ()
                            openBank(false)
                            -- Handle Open Bank
                        end
                    },
                    {
                        label = locale('manage_bank'),
                        icon = 'fas fa-university',
                        name = interactionId,
                        id = interactionId,
                        onSelect = function ()
                            if openBank(false) then
                                utils.sendMessage('setManagementConfig', true)
                            end
                            -- Todo: Open Manage Bank
                        end,
                        canInteract = function ()
                            return self.manager
                        end
                    }
                })
            elseif config.interactionType == 'interact' then
                exports.interact:AddLocalEntityInteraction({
                    entity = self.entity,
                    name = interactionId,
                    id = interactionId,
                    distance = 5.0,
                    interactDst = 4.0,
                    ignoreLos = true,
                    options = {
                        {
                            label = locale('view_bank'),
                            action = function ()
                                openBank(false)
                                -- Handle Open Bank
                            end
                        },
                        {
                            label = locale('manage_bank'),
                            name = interactionId,
                            id = interactionId,
                            action = function ()
                                -- Todo: Open Manage Bank
                                if openBank(false) then
                                    utils.sendMessage('setManagementConfig', true)
                                end
                            end,
                            canInteract = function ()
                                return self.manager
                            end
                        }
                    }
                })
            end
        end

        function pts:removeInteraction()
            if config.interactionType == 'ox_target' then
                exports.ox_target:removeLocalEntity(self.entity)
            elseif config.interactionType == 'interact' then
                exports.interact:RemoveLocalEntityInteraction(self.entity)
            end
            pts:deletePed()
        end

        function pts:deletePed()
            if DoesEntityExist(self.entity) then
                DeleteEntity(self.entity)
            end
            self.entity = nil
        end

        function pts:createPed()
            pts:deletePed()
            local model = lib.requestModel(self.model, 120000)
            self.entity = CreatePed(0, model, self.coords.x, self.coords.y, self.coords.z - 1.0, self.heading, false, false)
            SetEntityHeading(self.entity, self.heading)
            
            TaskStartScenarioInPlace(self.ped, 'PROP_HUMAN_STAND_IMPATIENT', 0, true)
            FreezeEntityPosition(self.entity, true)
            SetEntityInvincible(self.entity, true)
            SetBlockingOfNonTemporaryEvents(self.entity, true)
        end


        function pts:onEnter()
            pts:registerInteraction()
        end

        function pts:onExit()
            pts:removeInteraction()
        end
        points[#points+1] = pts
    end
end

--- Register Prop Interaction
--- @param openBank function
function utils.addModelInteraction(openBank)
    if config.interactionType == 'ox_target' then
        exports.ox_target:addModel(config.atmProps, {
            {
                name = interactionId,
                label = locale('view_bank'),
                icon = 'fas fa-university',
                onSelect = function ()
                    openBank(true)
                end
            }
        })
    else
        for _, v in pairs(config.atmProps) do
            exports.interact:AddModelInteraction({
                model = v,
                name = interactionId,
                id = interactionId,
                distance = 5.0,
                interactDst = 3.0,
                offset = vec3(0.0, 0.0, 0.8),
                options = {
                    {
                        label = locale('view_bank'),
                        action = function ()
                            openBank(true)
                        end
                    }
                }
            })
        end
    end
end

function utils.removeModelInteraction()
    if config.interactionType == 'ox_target' then
        exports.ox_target:removeModel(config.atmProps, interactionId)
    else
        for _, v in pairs(config.atmProps) do
            exports.interact:RemoveModelInteraction(v, interactionId)
        end
    end
end

AddEventHandler('onResourceStop', function (res)
    if res ~= cache.resource then return end
    for _, v in pairs(points) do
        if DoesEntityExist(v.entity) then
            DeleteEntity(v.entity)
        end
    end

    utils.removeModelInteraction()
end)

return utils