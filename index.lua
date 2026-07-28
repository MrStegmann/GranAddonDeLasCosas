--- @module index
-- Entry point and initialization orchestrator for GAC_DEV.

local addonName, GAC = ...

GAC.name = addonName
GAC.version = "1.3.0"

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
eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_LOGOUT")

--- Handles ADDON_LOADED event.
-- @param loadedAddonName string Name of loaded addon
function GAC:ADDON_LOADED(loadedAddonName)
    if loadedAddonName == self.name then
        if self.InitPersistence then
            self:InitPersistence(loadedAddonName)
        end

        if self.CreateQuickActionsFrame then self:CreateQuickActionsFrame() end
        if self.CreateMinimapButton then self:CreateMinimapButton() end
        if self.InitializePlayerPlate then self:InitializePlayerPlate() end
        if self.InitializeTargetPlate then self:InitializeTargetPlate() end
        if self.InitializeRaidPlate then self:InitializeRaidPlate() end
        if self.InitializeTargetTooltip then self:InitializeTargetTooltip() end
        if self.InitializeTransmitter then self:InitializeTransmitter() end
        if self.InitializeReceiver then self:InitializeReceiver() end
        if self.InitTRP3ArmorHook then self:InitTRP3ArmorHook() end

        self.eventFrame:UnregisterEvent("ADDON_LOADED")
    end
end

--- Handles PLAYER_ENTERING_WORLD event.
-- @param isInitialLogin boolean
-- @param isReloadingUi boolean
function GAC:PLAYER_ENTERING_WORLD(isInitialLogin, isReloadingUi)
    C_Timer.After(1.5, function()
        if GAC.InitTRP3ArmorHook then GAC:InitTRP3ArmorHook() end
        if GAC.UpdateEquippedArmor then
            GAC:UpdateEquippedArmor()
        end
    end)
end

--- Handles PLAYER_LOGOUT event.
function GAC:PLAYER_LOGOUT()
    if self.FlushPersistence then
        self:FlushPersistence()
    end
end