local discord = {}

-- Sensitive
discord.WebHook = nil
local _webhook_path = Megamod.Path .. "/Lua/server/modules/webhook.txt"
if File.Exists(_webhook_path) then
    discord.WebHook = File.Read(_webhook_path)
else
    discord.WebHook = nil
    Megamod.Log("Discord: webhook.txt not found at " .. _webhook_path .. ". Discord messages disabled.", true)
end

-- The discord name for the messages
discord.UserName = "server thing"

discord.RoundCounter = 0

local STARTTIMER = 300
discord.Timer = 300 -- 5 minutes

function discord.SendHTTP(str)
    if not discord.WebHook or discord.WebHook == "" then
        return
    end
    str = tostring(str)
    str = str:gsub('\\', '\\\\')
             :gsub('"', '\\"')
             :gsub('\n', '\\n')
             :gsub('\r', '\\r')
             :gsub('\t', '\\t')
    Networking.HttpPost(discord.WebHook, function(result) end,
        '{"content": "' .. str .. '", "username": "' .. discord.UserName .. '"}')
end

function discord.GetClientListStr()
    local clientListStr = ""
    for client in Client.ClientList do
        if client then
            local clientStr = "> [`" .. tostring(client.Name) .. "`](<https://steamcommunity.com/profiles/" .. tostring(client.SteamID) .. ">)"
            clientListStr = clientListStr .. clientStr .. "\n"
        end
    end
    if clientListStr ~= "" then
        clientListStr = clientListStr:sub(1, -2) -- Remove the last newline
    else -- Can happen while a round is loading
        clientListStr = "***(ERROR LOADING PLAYERS)***"
        Megamod.Log("Discord: There was an error loading the playerlist.", true)
    end
    return clientListStr
end

function discord.Loop()
    discord.Timer = discord.Timer - 1
    if discord.Timer <= 0 then
        discord.Timer = STARTTIMER
        local clientListStr = discord.GetClientListStr()
        discord.SendHTTP("**Current players (" .. tostring(#Client.ClientList) .. "/" .. tostring(Game.ServerSettings.MaxPlayers) .. "):**\n" .. clientListStr)
    end
    Timer.Wait(function()
        return discord.Loop()
    end, 1000)
end

-- Don't want to send useless HTTP if we don't have to
if not Game.ServerSettings.IsPublic then
    return discord
end

discord.Loop()

-- Send a "server is up" message when the server starts
-- Pings the discord role "Host Ping"
discord.SendHTTP("<@&1449941529425744045> The Barotrauma server has started up under the name ***" .. Game.ServerSettings.ServerName .. "***")

Hook.Add("roundStart", "Megamod.Discord.RoundStart", function()
    discord.RoundCounter = discord.RoundCounter + 1
    Timer.Wait(function()
        local str = "It is a silly round.**"
        if Megamod.RuleSetManager.RoundType == 1 then
            str = "It is a serious round.**"
        end
        discord.SendHTTP("**Round #" .. tostring(discord.RoundCounter) .. " has started. " .. str)
    end, 5000)
end)
Hook.Add("roundEnd", "Megamod.Discord.RoundEnd", function()
    discord.SendHTTP("**Round #" .. tostring(discord.RoundCounter) .. " has ended.**")
end)

return discord
