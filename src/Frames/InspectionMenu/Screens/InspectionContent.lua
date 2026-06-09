local addonName, GAC = ...

function GAC:CreateInspectionMenuContent(parent)
    local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    frame:SetAllPoints()

    -- Título
    local header = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    header:SetPoint("TOPLEFT", 15, -15)
    header:SetText("Inspeccionando Ficha de Personaje")
    header:SetTextColor(1, 1, 1)

    local line = frame:CreateTexture(nil, "ARTWORK")
    line:SetPoint("TOPLEFT", 15, -40)
    line:SetPoint("TOPRIGHT", -15, -40)
    line:SetHeight(1)
    line:SetColorTexture(1, 1, 1, 0.1)

    -- Retrato
    local portraitBorder = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    portraitBorder:SetSize(80, 80)
    portraitBorder:SetPoint("TOPLEFT", 20, -50)
    portraitBorder:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12, insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    portraitBorder:SetBackdropColor(0, 0, 0, 0.5)
    portraitBorder:SetBackdropBorderColor(0.25, 0.78, 0.94, 0.5)

    local portrait = CreateFrame("PlayerModel", nil, portraitBorder)
    portrait:SetPoint("TOPLEFT", 4, -4)
    portrait:SetPoint("BOTTOMRIGHT", -4, 4)
    portrait:SetUnit("target")
    portrait:SetPortraitZoom(1)


    local nameText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    nameText:SetPoint("TOPLEFT", portraitBorder, "TOPRIGHT", 15, -10)
    nameText:SetText("Cargando...")
    nameText:SetTextColor(0.25, 0.78, 0.94)

    local infoText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    infoText:SetPoint("TOPLEFT", nameText, "BOTTOMLEFT", 0, -5)
    infoText:SetText("Nivel - Raza - Clase")

    -- Contenedor principal de pestañas interiores
    local contentArea = CreateFrame("Frame", nil, frame)
    contentArea:SetPoint("TOPLEFT", portraitBorder, "BOTTOMLEFT", -5, -40)
    contentArea:SetPoint("BOTTOMRIGHT", -15, 15)

    local tabProgresion = CreateFrame("Frame", nil, contentArea)
    tabProgresion:SetAllPoints()
    local tabAtributos = CreateFrame("Frame", nil, contentArea)
    tabAtributos:SetAllPoints()
    tabAtributos:Hide()
    local tabExperiencia = CreateFrame("Frame", nil, contentArea)
    tabExperiencia:SetAllPoints()
    tabExperiencia:Hide()

    -- Botones de Pestañas
    local btnProgresion = GAC:CreateSubTabButton(frame, "Progresión", 120)
    btnProgresion:SetPoint("BOTTOMLEFT", contentArea, "TOPLEFT", 5, 5)
    
    local btnAtributos = GAC:CreateSubTabButton(frame, "Atributos y Talentos", 150)
    btnAtributos:SetPoint("LEFT", btnProgresion, "RIGHT", 5, 0)

    local btnExperiencia = GAC:CreateSubTabButton(frame, "Experiencia", 120)
    btnExperiencia:SetPoint("LEFT", btnAtributos, "RIGHT", 5, 0)

    local function SelectSubTab(id)
        btnProgresion.selected = (id == 1); btnProgresion:GetScript("OnLeave")(btnProgresion)
        btnAtributos.selected = (id == 2); btnAtributos:GetScript("OnLeave")(btnAtributos)
        btnExperiencia.selected = (id == 3); btnExperiencia:GetScript("OnLeave")(btnExperiencia)
        
        tabProgresion:SetShown(id == 1)
        tabAtributos:SetShown(id == 2)
        tabExperiencia:SetShown(id == 3)
    end
    btnProgresion:SetScript("OnClick", function() SelectSubTab(1) end)
    btnAtributos:SetScript("OnClick", function() SelectSubTab(2) end)
    btnExperiencia:SetScript("OnClick", function() SelectSubTab(3) end)

    -------------------------------------------------
    -- TAB 1: PROGRESIÓN (Niveles y Categorías)
    -------------------------------------------------
    local progBg = CreateFrame("Frame", nil, tabProgresion, "BackdropTemplate")
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

    -- Controles estáticos
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

    local function UpdateProgressionInfo(cat, lvl)
        catValue:SetText(GAC:_(cat))
        lvlValue:SetText(tostring(lvl))
        
        if not GAC.levelsTable or not GAC.levelsTable[cat] then return end
        local data = GAC.levelsTable[cat][lvl]
        if data then
            hpText:SetText(data.maxHealth and tostring(data.maxHealth) or "0")
            expText:SetText(data.expToLevel and tostring(data.expToLevel) or "MAX")
            attText:SetText(data.attPoints and tostring(data.attPoints) or "0")
            skillText:SetText(data.skillPoints and tostring(data.skillPoints) or "0")
            heroicText:SetText(data.heroicPoints and tostring(data.heroicPoints) or "0")
            traitText:SetText(data.maxPositiveTraits and tostring(data.maxPositiveTraits) or "0")
        end
    end

    -------------------------------------------------
    -- TAB 2: ATRIBUTOS Y TALENTOS (Card Style ReadOnly)
    -------------------------------------------------
    local attBg = CreateFrame("Frame", nil, tabAtributos, "BackdropTemplate")
    attBg:SetAllPoints()
    attBg:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12,
    })
    attBg:SetBackdropColor(0, 0, 0, 0.3)
    attBg:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)

    local scrollFrameAtt = CreateFrame("ScrollFrame", nil, attBg, "UIPanelScrollFrameTemplate")
    scrollFrameAtt:SetPoint("TOPLEFT", 8, -8)
    scrollFrameAtt:SetPoint("BOTTOMRIGHT", -28, 15)

    local contentContainer = CreateFrame("Frame", nil, scrollFrameAtt)
    contentContainer:SetSize(400, 10)
    scrollFrameAtt:SetScrollChild(contentContainer)

    scrollFrameAtt:SetScript("OnSizeChanged", function(self, width)
        contentContainer:SetWidth(width)
    end)

    local statLabels = {}

    local function InitCards()
        if contentContainer.cardsCreated then return end
        if not GAC.attributeGroups then return end
        
        local currentY = -10

        for i, group in ipairs(GAC.attributeGroups) do
            local card = GAC:CreateReadOnlyCard(contentContainer, group, statLabels)
            card:SetPoint("TOPLEFT", 10, currentY)
            card:SetPoint("TOPRIGHT", -10, currentY)
            
            currentY = currentY - card:GetHeight() - 10
        end

        contentContainer:SetHeight((currentY * -1) + 20)
        contentContainer.cardsCreated = true
    end

    -------------------------------------------------
    -- TAB 3: EXPERIENCIA (Líder)
    -------------------------------------------------
    local expBg = CreateFrame("Frame", nil, tabExperiencia, "BackdropTemplate")
    expBg:SetAllPoints()
    expBg:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12,
    })
    expBg:SetBackdropColor(0, 0, 0, 0.3)
    expBg:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)

    local expTitle = expBg:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    expTitle:SetPoint("TOPLEFT", 15, -15)
    expTitle:SetText("Gestión de Experiencia")
    expTitle:SetTextColor(0.25, 0.78, 0.94)

    local expBarBg = CreateFrame("Frame", nil, expBg, "BackdropTemplate")
    expBarBg:SetSize(400, 30)
    expBarBg:SetPoint("TOPLEFT", 20, -60)
    expBarBg:SetBackdrop({bgFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 8})
    expBarBg:SetBackdropColor(0.1, 0.1, 0.1, 0.8)

    local expBar = CreateFrame("StatusBar", nil, expBarBg)
    expBar:SetPoint("TOPLEFT", 3, -3)
    expBar:SetPoint("BOTTOMRIGHT", -3, 3)
    expBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    expBar:SetStatusBarColor(0.58, 0.0, 0.82)

    local expBarText = expBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    expBarText:SetPoint("CENTER")
    expBarText:SetText("0 / 0")

    local giveExpLabel = expBg:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    giveExpLabel:SetPoint("TOPLEFT", 20, -110)
    giveExpLabel:SetText("Otorgar Exp:")

    local giveExpInput = CreateFrame("EditBox", nil, expBg, "InputBoxTemplate")
    giveExpInput:SetSize(80, 25)
    giveExpInput:SetPoint("LEFT", giveExpLabel, "RIGHT", 10, 0)
    giveExpInput:SetAutoFocus(false)
    giveExpInput:SetNumeric(true)

    local giveExpBtn = CreateFrame("Button", nil, expBg, "UIPanelButtonTemplate")
    giveExpBtn:SetSize(80, 25)
    giveExpBtn:SetPoint("LEFT", giveExpInput, "RIGHT", 10, 0)
    giveExpBtn:SetText("Otorgar")
    giveExpBtn:SetScript("OnClick", function()
        local val = tonumber(giveExpInput:GetText())
        if val and val > 0 and GAC.inspectedPlayer then
            if GAC.SendExperienceToTarget then
                GAC:SendExperienceToTarget(GAC.inspectedPlayer.name, val)
                giveExpInput:SetText("")
                print("|cff00ccff[GAC]|r Has otorgado " .. val .. " de experiencia a " .. Ambiguate(GAC.inspectedPlayer.name, "none"))
                
                -- Refrescar inspección para actualizar la barra en el menú
                if GAC.RequestInspection then
                    GAC:RequestInspection(GAC.inspectedPlayer.name)
                end
            end
        end
    end)

    tabExperiencia:SetScript("OnShow", function()
        if GAC.inspectedPlayer then
            local curr = GAC.inspectedPlayer.currentExp or 0
            local mx = GAC.inspectedPlayer.maxExp or 0
            if mx <= 0 then mx = 1 end
            expBar:SetMinMaxValues(0, mx)
            expBar:SetValue(curr)
            expBarText:SetText(curr .. " / " .. mx)
        end
    end)

    tabAtributos:SetScript("OnShow", function()
        InitCards()
        if GAC.inspectedPlayer then
            for key, data in pairs(statLabels) do
                if data.isTalent then
                    data.val:SetText(tostring(GAC.inspectedPlayer.talents[key] or 0))
                else
                    data.val:SetText(tostring(GAC.inspectedPlayer.attributes[key] or 0))
                end
            end
        end
    end)

    -- Inicializar Tab 1
    SelectSubTab(1)

    -- Función Update invocada cuando se muestran nuevos datos
    frame.Update = function(self)
        if not GAC.inspectedPlayer then return end
        local p = GAC.inspectedPlayer
        
        nameText:SetText(Ambiguate(p.name, "none"))
        infoText:SetText(string.format("Nivel %d (%s) - %s - %s", p.level, GAC:_(p.category), p.race, p.class))
        
        if portrait then
            if UnitName("target") == p.name then
                portrait:SetUnit("target")
            end
            portrait:RefreshUnit()
        end
        
        UpdateProgressionInfo(p.category, p.level)
        
        if UnitIsGroupLeader("player") or not IsInGroup() then
            btnExperiencia:Show()
        else
            btnExperiencia:Hide()
            if tabExperiencia:IsShown() then
                SelectSubTab(1)
            end
        end

        if tabAtributos:IsShown() then
            tabAtributos:GetScript("OnShow")()
        end
        if tabExperiencia:IsShown() then
            tabExperiencia:GetScript("OnShow")()
        end
    end

    return frame
end
