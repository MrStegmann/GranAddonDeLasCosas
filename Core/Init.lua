local addonName, addon = ...

addon.name = addonName
addon.version = "0.1.0"

GranAddonDeLasCosasDB = GranAddonDeLasCosasDB or {
    debug = true,
}

local eventFrame = CreateFrame("Frame")
addon.eventFrame = eventFrame

eventFrame:SetScript("OnEvent", function(_, event, ...)
    if addon[event] then
        addon[event](addon, ...)
    end
end)

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("CHAT_MSG_SYSTEM")
