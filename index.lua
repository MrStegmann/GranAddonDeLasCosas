local addonName, GAC = ...

GAC.name = addonName
GAC.version = "1.0.0"

GAC.characterData = {}
GAC.contentFrames = {}

local eventFrame = CreateFrame("Frame")
GAC.eventFrame = eventFrame

eventFrame:SetScript("OnEvent", function(_, event, ...)
    if GAC[event] then
        GAC[event](GAC, ...)
    end
end)

eventFrame:SetScript("OnUpdate", function(_, elapsed)
    if GAC.OnUpdate then
        GAC:OnUpdate(elapsed)
    end
end)

eventFrame:RegisterEvent("CHAT_MSG_SYSTEM")