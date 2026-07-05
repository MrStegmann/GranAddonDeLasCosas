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

function GAC:ADDON_LOADED(loadedAddonName)
    if loadedAddonName == self.name then
        GranAddonDeLasCosasDB = GranAddonDeLasCosasDB or {}
        GranAddonDeLasCosasCharDB = GranAddonDeLasCosasCharDB or {}

        self.db = GranAddonDeLasCosasDB
        self.characterData = GranAddonDeLasCosasCharDB
        self.characterData.progress = self.characterData.progress or {}
        self.characterData.ui = self.characterData.ui or {}

        if self.MigrateToModelData then
            self:MigrateToModelData()
        end

        if self.Character then
            self.playerCharacter = self.Character:new(self.characterData.modelData)
        end

        self.inspectedPlayersCache = {}
        self.tempInsp = {}
        self.targetDataCache = self.inspectedPlayersCache

        if self.InitializeAttributeSystem then self:InitializeAttributeSystem() end
        if self.CreateQuickActionsFrame then self:CreateQuickActionsFrame() end
        if self.CreateMinimapButton then self:CreateMinimapButton() end
        if self.InitializePlayerPlate then self:InitializePlayerPlate() end
        if self.InitializeTargetPlate then self:InitializeTargetPlate() end
        if self.InitializeRaidPlate then self:InitializeRaidPlate() end
        if self.InitializeTargetTooltip then self:InitializeTargetTooltip() end
        if self.InitializeTransmitter then self:InitializeTransmitter() end
        if self.InitializeReceiver then self:InitializeReceiver() end
        if self.InitTRP3ArmorHook then self:InitTRP3ArmorHook() end

        print("¡|cFF00FF00[" .. self.name .. "]|r listo! Version: " .. self.version)
        self.eventFrame:UnregisterEvent("ADDON_LOADED")
    end
end

function GAC:PLAYER_ENTERING_WORLD(isInitialLogin, isReloadingUi)
    -- Le damos un margen de 1 segundo para que TRP3 Extended inicialice su inventario
    C_Timer.After(1.5, function()
        if GAC.InitTRP3ArmorHook then GAC:InitTRP3ArmorHook() end
        if GAC.UpdateEquippedArmor then
            GAC:UpdateEquippedArmor()
        end
    end)
end

function GAC:PLAYER_LOGOUT()
    if self.playerCharacter then
        self.characterData.modelData = self.playerCharacter:Serialize()
    end
end