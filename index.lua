local addonName, GAC = ...

GAC.name = addonName
GAC.version = "1.0.0"

GAC.characterData = nil
GAC.db = nil
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

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("CHAT_MSG_SYSTEM")

function GAC:ADDON_LOADED(loadedAddonName)
    if loadedAddonName == self.name then
        GranAddonDeLasCosasDB = GranAddonDeLasCosasDB or {}
        GranAddonDeLasCosasCharDB = GranAddonDeLasCosasCharDB or {}

        self.db = GranAddonDeLasCosasDB
        self.characterData = GranAddonDeLasCosasCharDB
        self.characterData.progress = self.characterData.progress or {}
        self.characterData.ui = self.characterData.ui or {}

        if self.InitializeAttributeSystem then self:InitializeAttributeSystem() end
        if self.CreateQuickActionsFrame then self:CreateQuickActionsFrame() end
        if self.CreateMinimapButton then self:CreateMinimapButton() end
        if self.InitializePlayerPlate then self:InitializePlayerPlate() end
        if self.InitializeTargetPlate then self:InitializeTargetPlate() end
        if self.InitializeTransmitter then self:InitializeTransmitter() end
        if self.InitializeReceiver then self:InitializeReceiver() end

        self.eventFrame:UnregisterEvent("ADDON_LOADED")
    end
end