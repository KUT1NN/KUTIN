local QBCore = exports['qb-core']:GetCoreObject()

local isAdminCreating = false

-- When admin types /createbet, show qb-input
RegisterNetEvent('betting:showCreateBetInput', function()
    local input = exports['qb-input']:ShowInput({
        header = "Create Bet",
        submitText = "Create",
        inputs = {
            { type = 'text', name = 'title', text = 'Bet Title' },
            { type = 'text', name = 'option1', text = 'Team 1' },
            { type = 'text', name = 'option2', text = 'Team 2' }
        }
    })
    if input and input.title and input.option1 and input.option2 then
        TriggerServerEvent('betting:createBet', input.title, input.option1, input.option2)
        TriggerServerEvent('betting:deleteBet', -1)

    else
        TriggerEvent('QBCore:Notify', 'Bet creation cancelled or invalid.', 'error')
    end
end)

-- Player opens menu to view bets
RegisterNetEvent('betting:openBetsMenu', function(bets)
    if #bets == 0 then
        TriggerEvent('QBCore:Notify', 'No available bets.', 'error')
        return
    end

    local menu = {}
    for i, bet in ipairs(bets) do
        table.insert(menu, {
            header = bet.title,
            txt = 'Teams: ' .. bet.options[1] .. ' vs ' .. bet.options[2],
            params = {
                event = 'betting:selectBetOption',
                args = bet
            }
        })
    end

    exports['qb-menu']:openMenu(menu)
end)

-- Player selects bet → open input for amount
RegisterNetEvent('betting:selectBetOption', function(bet)
    local input = exports['qb-input']:ShowInput({
        header = 'Bet: ' .. bet.title,
        submitText = 'Place Bet',
        inputs = {
            {
                type = 'select',
                name = 'option',
                text = 'Choose Team',
                options = {
                    { value = bet.options[1], text = bet.options[1] },
                    { value = bet.options[2], text = bet.options[2] }
                }
            },
            {
                type = 'number',
                name = 'amount',
                text = 'Bet Amount',
                default = 1,
                min = 1
            }
        }
    })

    if input and input.option and input.amount then
        TriggerServerEvent('betting:placeBet', bet.id, input.option, tonumber(input.amount))
    else
        TriggerEvent('QBCore:Notify', 'Bet cancelled or invalid.', 'error')
    end
end)

-- Add ox_target interaction
exports.ox_target:addBoxZone({
    coords = Config.BetLocation,
    size = vec3(1, 1, 1),
    rotation = 0,
    debug = false,
    options = {
        {
            name = 'open_bets',
            icon = 'fas fa-money-bill',
            label = 'View Available Bets',
            onSelect = function()
                TriggerServerEvent('betting:getOpenBets')
            end
        }
    }
})
