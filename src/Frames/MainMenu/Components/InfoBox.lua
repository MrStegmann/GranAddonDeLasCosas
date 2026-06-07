local addonName, GAC = ...

function GAC:CreateInfoBox(parent, label, x, y)
    local box = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    box:SetSize(160, 45)
    box:SetPoint("TOPLEFT", x, y)
    box:SetBackdrop({bgFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 8})
    box:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    
    local lText = GAC:CreateFontString(box, label, "GameFontNormalSmall", { "TOPLEFT", 5, -5 }, { 0.25, 0.78, 0.94 })
    
    local vText = GAC:CreateFontString(box, "-", "GameFontHighlightLarge", { "BOTTOMRIGHT", -10, 5 }, {1, 1, 1})
    
    return box, vText
end