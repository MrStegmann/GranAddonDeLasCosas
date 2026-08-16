--- @module AddonLoadedHandler
--- Event adapter listening for ADDON_LOADED to initialize and cache persistent Character sheet data.

local addonName, GAC = ...
GAC = GAC or {}

local AddonLoadedHandler = {}
AddonLoadedHandler.__index = AddonLoadedHandler

local frame = CreateFrame("Frame", "GAC_AddonLoadedFrame")

local function OnAddonLoaded(self, event, loadedAddonName)
    if loadedAddonName ~= (addonName or "GAC_DEV") then
        return
    end

    -- Ensure SavedVariablesPerCharacter container exists
    _G.GAC_CharacterDB = _G.GAC_CharacterDB or {}

    local CharacterModel = _G.Character or (require and pcall(require, "src.main.domain.models.Character") and require("src.main.domain.models.Character") or nil)

    local playerCharacter = nil
    if type(_G.GAC_CharacterDB.character) == "table" then
        if CharacterModel and CharacterModel.create then
            playerCharacter = CharacterModel.create(_G.GAC_CharacterDB.character)
        else
            playerCharacter = _G.GAC_CharacterDB.character
        end
    else
        if CharacterModel and CharacterModel.createDefault then
            playerCharacter = CharacterModel.createDefault()
        else
            playerCharacter = {}
        end
    end

    -- Cache in memory and ensure persistent table state
    GAC.playerCharacter = playerCharacter
    _G.GAC_CharacterDB.character = playerCharacter

    -- Unregister listener once initialized
    frame:UnregisterEvent("ADDON_LOADED")
end

frame:SetScript("OnEvent", OnAddonLoaded)
frame:RegisterEvent("ADDON_LOADED")

return AddonLoadedHandler
