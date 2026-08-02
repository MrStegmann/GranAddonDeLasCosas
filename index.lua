--- @module index
-- Primary entry point and initialization orchestrator for GAC_DEV.

local addonName, GAC = ...

GAC.name = addonName
GAC.version = "1.3.0"

GAC.characterData = nil
GAC.db = nil
GAC.contentFrames = {}

-- Require Hexagonal Domain Modules & Data Tables
local DataTables = require and pcall(require, "src.main.domain.DataTables") and require("src.main.domain.DataTables") or nil
local Item = require and pcall(require, "src.main.domain.Item") and require("src.main.domain.Item") or nil
local Armor = require and pcall(require, "src.main.domain.Armor") and require("src.main.domain.Armor") or nil
local Weapon = require and pcall(require, "src.main.domain.Weapon") and require("src.main.domain.Weapon") or nil
local CharacterCalculator = require and pcall(require, "src.main.domain.CharacterCalculator") and require("src.main.domain.CharacterCalculator") or nil
local Character = require and pcall(require, "src.main.domain.Character") and require("src.main.domain.Character") or nil

-- Bind Global Aliases for Backward Compatibility
GAC.DataTables = DataTables
GAC.Item = Item
GAC.Armor = Armor
GAC.Weapon = Weapon
GAC.CharacterCalculator = CharacterCalculator
GAC.Character = Character

-- Legacy Service Aliases
GAC.Services = GAC.Services or {}
GAC.Services.CharacterService = {
    GetPlayerCharacter = function() return GAC.playerCharacter end,
    GetAttributes = function()
        return GAC.playerCharacter and GAC.playerCharacter:GetAttributes() or {}
    end,
    GetTalents = function()
        return GAC.playerCharacter and GAC.playerCharacter:GetTalents() or {}
    end,
}

-- Require Technical Infrastructure Adapters
local EventDispatcher = require and pcall(require, "src.main.adapters.events.EventDispatcher") and require("src.main.adapters.events.EventDispatcher") or nil
local LocalIPCAdapter = require and pcall(require, "src.main.adapters.LocalIPCAdapter") and require("src.main.adapters.LocalIPCAdapter") or nil
local SavedVarsStorageAdapter = require and pcall(require, "src.main.adapters.SavedVarsStorageAdapter") and require("src.main.adapters.SavedVarsStorageAdapter") or nil
local TRP3Adapter = require and pcall(require, "src.main.adapters.TRP3Adapter") and require("src.main.adapters.TRP3Adapter") or nil
local LocalesAdapter = require and pcall(require, "src.main.adapters.locales.LocalesAdapter") and require("src.main.adapters.locales.LocalesAdapter") or nil

if EventDispatcher and EventDispatcher.create then GAC.eventDispatcher = EventDispatcher.create() end
if LocalIPCAdapter and LocalIPCAdapter.create then GAC.ipcAdapter = LocalIPCAdapter.create() end
if SavedVarsStorageAdapter and SavedVarsStorageAdapter.create then GAC.storageAdapter = SavedVarsStorageAdapter.create("GAC_CharacterDB") end
if TRP3Adapter and TRP3Adapter.create then GAC.trp3Adapter = TRP3Adapter.create() end
if LocalesAdapter and LocalesAdapter.create then GAC.localesAdapter = LocalesAdapter.create("esES") end

--- Data table lookups helper method.
function GAC:GetLevelEntry(category, level)
    if DataTables and DataTables.GetLevelEntry then
        return DataTables.GetLevelEntry(category, level)
    end
    return { maxHealth = 10, expToLevel = 10 }
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
        -- Load character persistent state via StorageAdapter
        if self.storageAdapter and type(self.storageAdapter.LoadCharacter) == "function" then
            self.playerCharacter = self.storageAdapter:LoadCharacter()
            if self.playerCharacter and type(self.playerCharacter.Serialize) == "function" then
                self.characterData = self.playerCharacter:Serialize()
            end
        end

        -- Publish character update over IPC to UI micro-frontends
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
end