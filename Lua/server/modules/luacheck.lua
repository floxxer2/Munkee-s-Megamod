local lc = {}

lc.ReceivedClients = {}

lc.String = ""

lc.Active = false

function lc.Check(admin, client, sendMessage)
    -- Queue calls to this function
    if lc.Active then
        if admin then Megamod.SendChatMessage(admin, "Lua check queued", Color(255, 0, 255, 255)) end
        Timer.Wait(function() lc.Check(admin, client, sendMessage) end, 1000)
        return
    end
    lc.Active = true
    lc.String = Megamod.RandomWord("abcdefghijklmnopqrstuvwxyz")

    local message = Networking.Start("mm_luacheck")
    message.WriteString(lc.String)
    if not client then
        for client in Client.ClientList do
            Networking.Send(message, client.Connection, DeliveryMethod.Reliable)
        end
    else
        Networking.Send(message, client.Connection, DeliveryMethod.Reliable)
    end

    Timer.Wait(function()
        lc.Active = false
        local unResponsiveClients = {}
        if not client then
            for client in Client.ClientList do
                if not lc.ReceivedClients[client] then
                    table.insert(unResponsiveClients, client)
                end
            end
        else
            if not lc.ReceivedClients[client] then
                table.insert(unResponsiveClients, client)
            end
        end
        if #unResponsiveClients == 0 then
            if admin then Megamod.SendChatMessage(admin, "All clients responded", Color(255, 0, 255, 255)) end
        else
            for unResponsiveClient in unResponsiveClients do
                if admin then Megamod.SendChatMessage(admin, "> Unresponsive: " .. tostring(unResponsiveClient.Name), Color(255, 0, 255, 255)) end
                if sendMessage then Megamod.SendMessage(unResponsiveClient, "You do not have client-side Lua installed, you should install it for the best experience. Search \"Lua for Barotrauma\" on the Workshop and follow the installation instructions.", Color(255, 0, 255, 255)) end
            end
        end
        lc.ReceivedClients = {}
    end, 2000)
end

Networking.Receive("mm_luacheck", function(message, client)
    if lc.Active then
        local str = message.ReadString()
        if str == lc.String then
            lc.ReceivedClients[client] = true
        else
            Megamod.Log("Client '" .. tostring(client.Name) .. "' did not send the correct Lua check string.", true)
        end
    else
        Megamod.Log("Client '" .. tostring(client.Name) .. "' sent a Lua check message randomly.", true)
    end
end)

-- Notify people joining
--[[Hook.Add("client.connected", "Megamod.LuaCheck.ClientConnected", function(client)
    Timer.Wait(function()
        if client then
            lc.Check(nil, client, true)
        end
    end, 15000)
end)]]

return lc
