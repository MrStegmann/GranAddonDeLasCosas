local addonName, addonTable = ...

-- Ensure global UI namespace exists
addonTable.UI = addonTable.UI or {}
addonTable.UI.CharacterBook = addonTable.UI.CharacterBook or {}

local CharacterBook = addonTable.UI.CharacterBook

function CharacterBook.Init()
    if CharacterBook.Controller and CharacterBook.Controller.Init then
        local success, err = pcall(CharacterBook.Controller.Init)
        if not success then
            print("|cFFFF0000[GAC_DEV] Error in Controller.Init: " .. tostring(err) .. "|r")
        end
    end
    if CharacterBook.Components and CharacterBook.Components.MinimapButton and CharacterBook.Components.MinimapButton.Init then
        CharacterBook.Components.MinimapButton.Init()
    end
end

-- Hook initialization to PLAYER_LOGIN to ensure all data and DBs are loaded
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:SetScript("OnEvent", function(self, event)
    print("onEvent CharacterBook Init")
    CharacterBook.Init()
    self:UnregisterEvent("PLAYER_LOGIN")
end)

function CharacterBook.Toggle()
    if CharacterBook.Frame and CharacterBook.Frame.Toggle then
        CharacterBook.Frame.Toggle()
    end
end
