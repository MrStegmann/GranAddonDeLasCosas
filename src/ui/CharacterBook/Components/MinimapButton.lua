local addonName, addonTable = ...
addonTable.UI = addonTable.UI or {}
addonTable.UI.CharacterBook = addonTable.UI.CharacterBook or {}
addonTable.UI.CharacterBook.Components = addonTable.UI.CharacterBook.Components or {}
local MinimapButton = {}
addonTable.UI.CharacterBook.Components.MinimapButton = MinimapButton

function MinimapButton.Init()
    local LDB = LibStub("LibDataBroker-1.1")
    local icon = LibStub("LibDBIcon-1.0")

    -- Task 2.2: Implement LibDataBroker-1.1 object
    local ldbObject = LDB:NewDataObject("GAC_CharacterBook", {
        type = "launcher",
        text = "GAC - Character Book",
        icon = "Interface\\Icons\\inv_misc_book_09",
        OnClick = function(self, button)
            if button == "LeftButton" then
                addonTable.UI.CharacterBook.Toggle()
            end
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine("GAC - Character Book", 1, 1, 1)
            tooltip:AddLine("Left-click to open or close the Character Book.", 0.8, 0.8, 0.8)
        end
    })

    -- Task 2.3: Implement LibDBIcon-1.0 registration
    -- We are already called from PLAYER_LOGIN via index.lua, so GAC_CharacterDB is ready.
    if _G.GAC_CharacterDB and _G.GAC_CharacterDB.minimap then
        icon:Register("GAC_CharacterBook", ldbObject, _G.GAC_CharacterDB.minimap)
    else
        -- Fallback if DB didn't load properly
        icon:Register("GAC_CharacterBook", ldbObject, { hide = false })
    end
end
