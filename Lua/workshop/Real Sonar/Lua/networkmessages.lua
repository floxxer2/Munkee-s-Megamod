if not SERVER then return end

Networking.Receive("realsonar_reloadserverconfig", function(msg, sender)
    dofile(RealSonar.Path .. "/Lua/loadconfig.lua")
end)

Networking.Receive("realsonar_getsonaritems", function(msg, sender)
    RealSonar.getSonarItems()
end)

Networking.Receive("realsonar_setitemtags", function(msg, sender)
    RealSonar.setItemTags()
end)

