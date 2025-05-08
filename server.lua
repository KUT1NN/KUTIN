local QBCore = exports['qb-core']:GetCoreObject()
local bets = {}
local nextBetId = 1

-- ADMIN uses /createbet → triggers client input
RegisterCommand('createbet', function(source)
    if IsPlayerAceAllowed(source, 'betting.admin') then
        TriggerClientEvent('betting:showCreateBetInput', source)
    else
        TriggerClientEvent('QBCore:Notify', source, 'No permission.', 'error')
    end
end)

-- Receive bet data from client input
RegisterNetEvent('betting:createBet', function(title, option1, option2)
    local src = source
    local betId = nextBetId
    nextBetId = nextBetId + 1
    bets[betId] = {
        id = betId,
        title = title,
        options = { option1, option2 },
        expires = os.time() + Config.BetDuration
    }

    TriggerClientEvent('QBCore:Notify', src, 'Bet created: ' .. title, 'success')

    -- Optional: Broadcast to all players that a bet was created
    print('[BET] Created bet ID ' .. betId .. ': ' .. title)

    -- Auto-close bet after duration
    SetTimeout(Config.BetDuration * 1000, function()
        bets[betId] = nil
        print('[BET] Bet ID ' .. betId .. ' expired')
    end)
end)
-- ADMIN deletes a bet by ID
RegisterCommand('deletebet', function(source, args)
    if IsPlayerAceAllowed(source, 'betting.admin') then
        local betId = tonumber(args[1])
        if betId and bets[betId] then
            bets[betId] = nil
            TriggerClientEvent('QBCore:Notify', source, 'Bet ID ' .. betId .. ' deleted.', 'success')
            refreshAllPlayers()
        else
            TriggerClientEvent('QBCore:Notify', source, 'Invalid bet ID.', 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', source, 'No permission.', 'error')
    end
end)

-- Player requests available bets
RegisterNetEvent('betting:getOpenBets', function()
    local src = source
    local openBets = {}
    for id, bet in pairs(bets) do
        if os.time() < bet.expires then
            table.insert(openBets, bet)
        end
    end
    TriggerClientEvent('betting:openBetsMenu', src, openBets)
end)

-- Player places a bet
RegisterNetEvent('betting:placeBet', function(betId, option, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not bets[betId] then
        TriggerClientEvent('QBCore:Notify', src, 'Bet is closed or invalid.', 'error')
        return
    end

    if not option or not amount or amount <= 0 then
        TriggerClientEvent('QBCore:Notify', src, 'Invalid bet.', 'error')
        return
    end

    MySQL.insert('INSERT INTO betting_bets (player, bet_id, option, amount) VALUES (?, ?, ?, ?)', {
        Player.PlayerData.name,
        betId,
        option,
        amount
    }, function(id)
        TriggerClientEvent('QBCore:Notify', src, 'Bet placed successfully!', 'success')
    end)
end)
