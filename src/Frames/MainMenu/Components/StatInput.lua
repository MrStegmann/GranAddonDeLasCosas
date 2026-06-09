local addonName, GAC = ...

function GAC:CreateStatInput(parent, label, key, isTalent, saveCallback, statInputsTable)
    local row = CreateFrame("Frame", nil, parent)
    row:SetPoint("LEFT", 5, 0)
    row:SetPoint("RIGHT", -5, 0)
    row:SetHeight(26)
    
    local name = GAC:CreateFontString(row, (GAC.L and GAC.L[label]) or label:gsub("^%l", string.upper), "GameFontHighlight", { "LEFT", 5, 0 }, {1, 1, 1})

    local input = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
    input:SetSize(40, 20)
    input:SetPoint("RIGHT", -20, 0)
    input:SetAutoFocus(false)
    
    
    input:SetNumeric(false) -- Removed SetNumeric to prevent any WoW API rejection bugs
    input:SetFontObject("GameFontHighlight") -- Explicitly set font
    input:SetTextInsets(5, 5, 0, 0) -- Prevent text from clipping under textures

    input:SetScript("OnTextChanged", function(self, isUserInput)
        if not isUserInput then return end
        if saveCallback then saveCallback() end
    end)
    input:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    input:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)

    if statInputsTable then
        statInputsTable[key] = { input = input, isTalent = isTalent }
    end
    return row, name
end