local addonName, GAC = ...

GAC.Components = GAC.Components or {}
GAC.Components.InspectionMenu = GAC.Components.InspectionMenu or {}

function GAC.Components.InspectionMenu:CreateProgressionTab(parent)
    local progBg = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    progBg:SetAllPoints()
    progBg:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12,
    })
    progBg:SetBackdropColor(0, 0, 0, 0.3)
    progBg:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)

    local progTitle = progBg:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    progTitle:SetPoint("TOPLEFT", 15, -15)
    progTitle:SetText("Información de Nivel y Categoría")
    progTitle:SetTextColor(0.25, 0.78, 0.94)

    local _, hpText = GAC:CreateInfoBox(progBg, "Salud Máxima", 20, -50)
    local _, expText = GAC:CreateInfoBox(progBg, "Exp para Nivel", 190, -50)
    local _, attText = GAC:CreateInfoBox(progBg, "Puntos de Atributo", 20, -100)
    local _, skillText = GAC:CreateInfoBox(progBg, "Puntos de Talento", 190, -100)
    local _, heroicText = GAC:CreateInfoBox(progBg, "Puntos Heroicos", 20, -150)
    local _, traitText = GAC:CreateInfoBox(progBg, "Rasgos Positivos", 190, -150)

    local catLabel = progBg:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    catLabel:SetPoint("TOPLEFT", 380, -50)
    catLabel:SetText("Categoría:")
    
    local catValue = progBg:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    catValue:SetPoint("TOPLEFT", catLabel, "BOTTOMLEFT", 0, -5)
    catValue:SetText("-")

    local lvlLabel = progBg:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    lvlLabel:SetPoint("TOPLEFT", 380, -110)
    lvlLabel:SetText("Nivel:")

    local lvlValue = progBg:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    lvlValue:SetPoint("TOPLEFT", lvlLabel, "BOTTOMLEFT", 0, -5)
    lvlValue:SetText("-")

    progBg.Update = function(self, p)
        catValue:SetText(GAC:_(p.category) or p.category)
        lvlValue:SetText(tostring(p.level))
        
        if not GAC.levelsTable or not GAC.levelsTable[p.category] then return end
        local data = GAC.levelsTable[p.category][p.level]
        if data then
            hpText:SetText(data.maxHealth and tostring(data.maxHealth) or "0")
            expText:SetText(data.expToLevel and tostring(data.expToLevel) or "MAX")
            attText:SetText(data.attPoints and tostring(data.attPoints) or "0")
            skillText:SetText(data.skillPoints and tostring(data.skillPoints) or "0")
            heroicText:SetText(data.heroicPoints and tostring(data.heroicPoints) or "0")
            traitText:SetText(data.maxPositiveTraits and tostring(data.maxPositiveTraits) or "0")
        end
    end

    return progBg
end
