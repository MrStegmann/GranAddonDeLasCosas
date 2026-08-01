--- @module index
-- Entry point and initialization orchestrator for GAC_DEV.

local addonName, GAC = ...

GAC.name = addonName
GAC.version = "1.3.0"

GAC.characterData = nil
GAC.db = nil
GAC.contentFrames = {}

-- Initialize Hexagonal Ports & Adapters
local EventDispatcher = require and pcall(require, "src.main.adapters.events.EventDispatcher") and require("src.main.adapters.events.EventDispatcher") or nil
local LocalIPCAdapter = require and pcall(require, "src.main.adapters.LocalIPCAdapter") and require("src.main.adapters.LocalIPCAdapter") or nil
local SavedVarsStorageAdapter = require and pcall(require, "src.main.adapters.SavedVarsStorageAdapter") and require("src.main.adapters.SavedVarsStorageAdapter") or nil
local TRP3Adapter = require and pcall(require, "src.main.adapters.TRP3Adapter") and require("src.main.adapters.TRP3Adapter") or nil

if EventDispatcher and EventDispatcher.create then
    GAC.eventDispatcher = EventDispatcher.create()
end

if LocalIPCAdapter and LocalIPCAdapter.create then
    GAC.ipcAdapter = LocalIPCAdapter.create()
end

if SavedVarsStorageAdapter and SavedVarsStorageAdapter.create then
    GAC.storageAdapter = SavedVarsStorageAdapter.create("GAC_CharacterDB")
end

if TRP3Adapter and TRP3Adapter.create then
    GAC.trp3Adapter = TRP3Adapter.create()
end

local eventFrame = CreateFrame("Frame")
GAC.eventFrame = eventFrame

eventFrame:SetScript("OnEvent", function(_, event, ...)
    if GAC[event] then
        GAC[event](GAC, ...)
    end

    if GAC.eventDispatcher then
        GAC.eventDispatcher:Dispatch(event, ...)
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
        -- Bind character storage adapter
        if self.storageAdapter and type(self.storageAdapter.LoadCharacter) == "function" then
            self.playerCharacter = self.storageAdapter:LoadCharacter()
            if self.playerCharacter and type(self.playerCharacter.Serialize) == "function" then
                self.characterData = self.playerCharacter:Serialize()
            end
        end

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

        -- Broadcast character loaded state to UI subscribers via IPC
        if self.ipcAdapter and self.characterData then
            self.ipcAdapter:Publish("CHARACTER_UPDATED", self.characterData)
        end

        self.eventFrame:UnregisterEvent("ADDON_LOADED")
    end
end

--- Handles PLAYER_ENTERING_WORLD event.
-- @param isInitialLogin boolean
-- @param isReloadingUi boolean
function GAC:PLAYER_ENTERING_WORLD(isInitialLogin, isReloadingUi)
    if C_Timer and C_Timer.After then
        C_Timer.After(1.5, function()
            if GAC.InitTRP3ArmorHook then GAC:InitTRP3ArmorHook() end
            if GAC.UpdateEquippedArmor then
                GAC:UpdateEquippedArmor()
            end
        end)
    end
end

--- Handles PLAYER_LOGOUT event.
function GAC:PLAYER_LOGOUT()
    if self.storageAdapter and self.playerCharacter then
        self.storageAdapter:SaveCharacter(self.playerCharacter)
    end

    if self.FlushPersistence then
        self:FlushPersistence()
    end
end