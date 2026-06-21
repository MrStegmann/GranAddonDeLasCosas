local addonName, GAC = ...

GAC.Components = GAC.Components or {}
GAC.Components.InspectionMenu = GAC.Components.InspectionMenu or {}

function GAC.Components.InspectionMenu:CreateCharacteristicsTab(parent)
    local charBg = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    charBg:SetAllPoints()
    charBg:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12,
    })
    charBg:SetBackdropColor(0, 0, 0, 0.3)
    charBg:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)

    local charTitle = charBg:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    charTitle:SetPoint("TOPLEFT", 15, -15)
    charTitle:SetText("Características Raciales")
    charTitle:SetTextColor(0.25, 0.78, 0.94)

    local readRaceLabel = charBg:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    readRaceLabel:SetPoint("TOPLEFT", 15, -50)
    readRaceLabel:SetText("Raza:")
    
    local readRaceValue = charBg:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    readRaceValue:SetPoint("TOPLEFT", readRaceLabel, "BOTTOMLEFT", 0, -5)
    readRaceValue:SetText("-")

    local raceSummaryLabel = charBg:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    raceSummaryLabel:SetPoint("TOPLEFT", 15, -110)
    raceSummaryLabel:SetText("Resumen Racial:")
    
    local raceAdvText = charBg:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    raceAdvText:SetPoint("TOPLEFT", raceSummaryLabel, "BOTTOMLEFT", 0, -5)
    raceAdvText:SetJustifyH("LEFT")
    raceAdvText:SetWidth(400)
    
    local raceDisText = charBg:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    raceDisText:SetPoint("TOPLEFT", raceAdvText, "BOTTOMLEFT", 0, -5)
    raceDisText:SetJustifyH("LEFT")
    raceDisText:SetWidth(400)
    
    local raceSpcText = charBg:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    raceSpcText:SetPoint("TOPLEFT", raceDisText, "BOTTOMLEFT", 0, -5)
    raceSpcText:SetJustifyH("LEFT")
    raceSpcText:SetWidth(400)

    local readWorgenLabel = charBg:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    readWorgenLabel:SetPoint("TOPLEFT", 15, -200)
    readWorgenLabel:SetText("Maldición Huargen:")
    
    local readWorgenValue = charBg:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    readWorgenValue:SetPoint("TOPLEFT", readWorgenLabel, "BOTTOMLEFT", 0, -5)
    readWorgenValue:SetText("No")

    charBg.Update = function(self, p)
        local r1 = p.race1 or "Ninguna"
        local r2 = p.race2 or "Ninguna"
        local raceString = ""
        if r1 ~= "Ninguna" and r2 ~= "Ninguna" then
            raceString = string.format("Mestizo (%s y %s)", GAC:_(r1) or r1, GAC:_(r2) or r2)
        elseif r1 ~= "Ninguna" then
            raceString = GAC:_(r1) or r1
        else
            raceString = "Ninguna"
        end
        readRaceValue:SetText(raceString)
        
        local adv = p.advantages and GAC.Utils.InspectionMenu:FormatStatList(p.advantages) or "Ninguna"
        local dis = p.disadvantages and GAC.Utils.InspectionMenu:FormatStatList(p.disadvantages) or "Ninguna"
        local spc = p.special and GAC.Utils.InspectionMenu:FormatStatList(p.special) or "Ninguna"
        
        raceAdvText:SetText("|cFFa3f5a3Ventajas:|r " .. adv)
        raceDisText:SetText("|cFFf5a3a3Desventajas:|r " .. dis)
        raceSpcText:SetText("|cFFd1a3f5Especial:|r " .. spc)
        
        if p.worgenCurse then
            readWorgenValue:SetText("|cFFa3f5a3Sí|r")
        else
            readWorgenValue:SetText("|cFFf5a3a3No|r")
        end
    end

    return charBg
end
