-- Server-Side Script with Webhooks for FiveM Logs

-- Replace these with your actual Discord Webhook URLs
local connectionWebhook = "https://discord.com/api/webhooks/1284148786779914326/kkUGEs6ZrUgewKxmKfoSwdqgmL6UiByml74HjArg0YhVSSHrqF3O_HwPliZ-V-qAJui-"
local chatWebhook = "https://discord.com/api/webhooks/1284148549797281922/5-nRJtL0oW3AHZFSFBgWIxc9CEUGIyPg1U3mK1GBwVsZEmQo79FnIURTuYdajkUX3_tS"
local banWebhook = "https://discord.com/api/webhooks/1284148928802979961/FihrZFqrMKtSh-KOkJrmTd8MK-1l0R2dqkGjPizDWb6kpx56Q7LhcwwzKj3oibOAdBQX"
local kickWebhook = "https://discord.com/api/webhooks/1284149081266061373/Cxwrya5HS_B4NM0REYI3jPvEK5G7dBu9wpkvE4WhDCQ_4YWOlcdVlfhYAEWgb-EXwm9v"
local leavingWebhook = "https://discord.com/api/webhooks/1284149196638650378/66jXEpEKghY6NWExljHcOjszHuRjNkbRofze09vZ94S-u38O8HUTSn12r2ZiPWgiXF25"

-- Function to send logs to Discord webhook
function sendToDiscord(webhook, message)
    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({content = message}), { ['Content-Type'] = 'application/json' })
end

-- Log connections
AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
    local playerId = source
    local playerIP = GetPlayerEndpoint(playerId)
    local playerSteam = GetPlayerIdentifier(playerId, 0)
    local logMessage = ('[Connection] Player: %s (ID: %d) is connecting with Steam: %s'):format(playerName, playerId, playerSteam)
    
    print(logMessage)
    sendToDiscord(connectionWebhook, logMessage)  -- Send to Discord webhook
end)

-- Log disconnections
AddEventHandler('playerDropped', function(reason)
    local playerId = source
    local playerName = GetPlayerName(playerId)
    local logMessage = ('[Disconnect] Player: %s (ID: %d) has disconnected for reason: %s'):format(playerName, playerId, reason)
    
    print(logMessage)
    sendToDiscord(leavingWebhook, logMessage)  -- Send to Discord webhook
end)

-- Log chat messages
RegisterServerEvent('chatMessage')
AddEventHandler('chatMessage', function(source, name, msg)
    local logMessage = ('[Chat] %s (ID: %d): %s'):format(name, source, msg)
    
    print(logMessage)
    sendToDiscord(chatWebhook, logMessage)  -- Send to Discord webhook
end)

-- Log bans
RegisterServerEvent('BanPlayer')
AddEventHandler('BanPlayer', function(playerId, reason)
    local playerName = GetPlayerName(playerId)
    local logMessage = ('[Ban] Player: %s (ID: %d) has been banned for reason: %s'):format(playerName, playerId, reason)
    
    print(logMessage)
    sendToDiscord(banWebhook, logMessage)  -- Send to Discord webhook
end)

-- Log kicks
RegisterServerEvent('KickPlayer')
AddEventHandler('KickPlayer', function(playerId, reason)
    local playerName = GetPlayerName(playerId)
    local logMessage = ('[Kick] Player: %s (ID: %d) has been kicked for reason: %s'):format(playerName, playerId, reason)
    
    print(logMessage)
    sendToDiscord(kickWebhook, logMessage)  -- Send to Discord webhook
end)

-- Ban Command Example
RegisterCommand('ban', function(source, args, rawCommand)
    local targetId = tonumber(args[1])
    local reason = table.concat(args, " ", 2)
    
    if targetId then
        TriggerEvent('BanPlayer', targetId, reason)
        DropPlayer(targetId, 'You have been banned for: ' .. reason)
    else
        print('Invalid player ID.')
    end
end, true)

-- Kick Command Example
RegisterCommand('kick', function(source, args, rawCommand)
    local targetId = tonumber(args[1])
    local reason = table.concat(args, " ", 2)
    
    if targetId then
        TriggerEvent('KickPlayer', targetId, reason)
        DropPlayer(targetId, 'You have been kicked for: ' .. reason)
    else
        print('Invalid player ID.')
    end
end, true)
