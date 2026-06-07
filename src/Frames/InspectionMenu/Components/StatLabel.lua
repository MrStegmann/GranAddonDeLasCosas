local addonName, GAC = ...

function GAC:CreateStatLabel(parent, label, key, isTalent, statLabelsTable)
    local row = CreateFrame("Frame", nil, parent)
    row:SetPoint("LEFT", 5, 0)
    row:SetPoint("RIGHT", -5, 0)
    row:SetHeight(26)
    
    local name = GAC:CreateFontString(row, (GAC.L and GAC.L[label]) or label:gsub("^%l", string.upper), "GameFontHighlight", { "LEFT", 5, 0 }, {1, 1, 1})

    local val = GAC:CreateFontString(row, "0", "GameFontHighlight", { "RIGHT", -20, 0 }, {1, 1, 1})

    if statLabelsTable then
        statLabelsTable[key] = { val = val, isTalent = isTalent }
    end
    return row, name
end
