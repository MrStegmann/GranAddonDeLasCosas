local addonName, addonTable = ...

local CharacterBookPresenter = {}
addonTable.UI.CharacterBook.Presenter = CharacterBookPresenter

--- Formats the trait limits into a display string
function CharacterBookPresenter.FormatTraitLimits(currentPos, maxPos, currentNeg, maxNeg)
    local posColor = (currentPos == maxPos) and "|cFF00FF00" or "|cFFFFFFFF"
    local negColor = (currentNeg == maxNeg) and "|cFFFF0000" or "|cFFFFFFFF"
    return string.format("Advantages: %s%d/%d|r | Disadvantages: %s%d/%d|r", 
        posColor, currentPos, maxPos, 
        negColor, currentNeg, maxNeg)
end
