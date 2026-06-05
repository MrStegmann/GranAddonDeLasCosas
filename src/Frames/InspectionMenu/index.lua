local addonName, GAC = ...

-- Helper for TRP3 style sub-tab buttons
local function CreateSubTabButton(parent, text, width)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(width, 26)
    btn:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    btn:SetBackdropColor(0, 0, 0, 0.6)
    btn:SetBackdropBorderColor(0.25, 0.78, 0.94, 0.5)

    btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    btn.text:SetPoint("CENTER")
    btn.text:SetText(text)

    btn:SetScript("OnEnter", function(self) self:SetBackdropColor(0.25, 0.78, 0.94, 0.3) end)
    btn:SetScript("OnLeave", function(self)
        if not self.selected then 
            self:SetBackdropColor(0, 0, 0, 0.6) 
            self.text:SetTextColor(1, 1, 1)
        else 
            self:SetBackdropColor(0.25, 0.78, 0.94, 0.15) 
            self.text:SetTextColor(0.25, 0.78, 0.94)
        end
    end)

    return btn
end

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
    local btnProgresion = CreateSubTabButton(frame, "Progresión", 120)
    btnProgresion:SetPoint("BOTTOMLEFT", contentArea, "TOPLEFT", 5, 5)
    
    local btnAtributos = CreateSubTabButton(frame, "Atributos y Talentos", 150)
    btnAtributos:SetPoint("LEFT", btnProgresion, "RIGHT", 5, 0)

    local btnExperiencia = CreateSubTabButton(frame, "Experiencia", 120)
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

    -- Cajas de información
    local function CreateInfoBox(parent, label, x, y)
        local box = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        box:SetSize(160, 45)
        box:SetPoint("TOPLEFT", x, y)
        box:SetBackdrop({bgFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 8})
        box:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
        
        local lText = box:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        lText:SetPoint("TOPLEFT", 5, -5)
        lText:SetText(label)
        lText:SetTextColor(0.25, 0.78, 0.94)

        local vText = box:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
        vText:SetPoint("BOTTOMRIGHT", -10, 5)
        vText:SetText("-")
        
        return box, vText
    end

    local _, hpText = CreateInfoBox(progBg, "Salud Máxima", 20, -50)
    local _, expText = CreateInfoBox(progBg, "Exp para Nivel", 190, -50)
    local _, attText = CreateInfoBox(progBg, "Puntos de Atributo", 20, -100)
    local _, skillText = CreateInfoBox(progBg, "Puntos de Talento", 190, -100)
    local _, heroicText = CreateInfoBox(progBg, "Puntos Heroicos", 20, -150)
    local _, traitText = CreateInfoBox(progBg, "Rasgos Positivos", 190, -150)

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

    local function CreateStatLabel(parent, label, key, isTalent)
        local row = CreateFrame("Frame", nil, parent)
        row:SetPoint("LEFT", 5, 0)
        row:SetPoint("RIGHT", -5, 0)
        row:SetHeight(26)
        
        local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        name:SetPoint("LEFT", 5, 0)
        local localizedName = (GAC.L and GAC.L[label]) or label:gsub("^%l", string.upper)
        name:SetText(localizedName)

        local val = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        val:SetPoint("RIGHT", -20, 0)
        val:SetText("0")

        statLabels[key] = { val = val, isTalent = isTalent }
        return row, name
    end

    local function CreateCard(parent, group)
        local card = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        card:SetBackdrop({
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 },
        })
        card:SetBackdropColor(0, 0, 0, 0.5)
        card:SetBackdropBorderColor(0.25, 0.78, 0.94, 0.6)

        local headerBg = CreateFrame("Frame", nil, card)
        headerBg:SetPoint("TOPLEFT", 3, -3)
        headerBg:SetPoint("TOPRIGHT", -3, -3)
        headerBg:SetHeight(30)

        local attRow, nameLabel = CreateStatLabel(headerBg, GAC:_(group.name), group.name, false)
        attRow:SetPoint("CENTER")
        nameLabel:SetFontObject("GameFontNormalLarge")
        nameLabel:SetTextColor(0.25, 0.78, 0.94)

        local div = card:CreateTexture(nil, "ARTWORK")
        div:SetHeight(1)
        div:SetPoint("TOPLEFT", headerBg, "BOTTOMLEFT", 5, 0)
        div:SetPoint("TOPRIGHT", headerBg, "BOTTOMRIGHT", -5, 0)
        div:SetColorTexture(1, 1, 1, 0.1)

        local currentY = -40
        for _, talent in ipairs(group.talents) do
            local talRow = CreateStatLabel(card, GAC:_(talent), talent, true)
            talRow:SetPoint("TOP", 0, currentY)
            currentY = currentY - 26
        end

        card:SetHeight(-currentY + 5)
        return card
    end

    local function InitCards()
        if contentContainer.cardsCreated then return end
        if not GAC.attributeGroups then return end
        
        local currentY = -10

        for i, group in ipairs(GAC.attributeGroups) do
            local card = CreateCard(contentContainer, group)
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

function GAC:CreateInspectionMenu()
    if self.inspectionMenuFrame then return end

    -- Marco principal
    local frame = CreateFrame("Frame", "GACInspectionMenuFrame", UIParent, "BackdropTemplate")
    frame:Hide()
    frame:SetSize(750, 550)
    frame:SetPoint("CENTER", UIParent, "CENTER", 100, 0)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetClampedToScreen(true)
    frame:SetFrameStrata("HIGH")

    frame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    frame:SetBackdropColor(0.05, 0.06, 0.08, 0.95)
    frame:SetBackdropBorderColor(0.94, 0.25, 0.25, 0.8) -- Borde rojo para diferenciar de MainMenu

    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(s) s:StopMovingOrSizing() end)

    -- Botón cerrar
    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4)

    -- Título del Addon
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 20, -18)
    title:SetText("INSPECCIÓN - GRAN ADDON DE LAS COSAS")
    title:SetTextColor(0.94, 0.25, 0.25)

    -- Línea divisoria
    local line = frame:CreateTexture(nil, "ARTWORK")
    line:SetSize(frame:GetWidth() - 24, 1)
    line:SetPoint("TOP", 0, -45)
    line:SetColorTexture(1, 1, 1, 0.1)

    -- Barra lateral estática (solo para mantener estructura visual)
    local sidebar = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    sidebar:SetSize(180, 0)
    sidebar:SetPoint("TOPLEFT", 12, -50)
    sidebar:SetPoint("BOTTOMLEFT", 12, 12)
    sidebar:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 8, edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    sidebar:SetBackdropColor(0, 0, 0, 0.4)
    sidebar:SetBackdropBorderColor(0.94, 0.25, 0.25, 0.15)
    
    local sidebarTitle = sidebar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    sidebarTitle:SetPoint("TOP", 0, -15)
    sidebarTitle:SetText("Modo Inspección")

    local contentArea = CreateFrame("Frame", nil, frame)
    contentArea:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 10, 0)
    contentArea:SetPoint("BOTTOMRIGHT", -12, 12)
    
    -- Inyectar contenido
    local content = GAC:CreateInspectionMenuContent(contentArea)
    frame.contentArea = content

    self.inspectionMenuFrame = frame
end

function GAC:OpenInspectionMenu()
    if not self.inspectionMenuFrame then
        self:CreateInspectionMenu()
    end
    self.inspectionMenuFrame:Show()
    if self.inspectionMenuFrame.contentArea.Update then
        self.inspectionMenuFrame.contentArea:Update()
    end
end
