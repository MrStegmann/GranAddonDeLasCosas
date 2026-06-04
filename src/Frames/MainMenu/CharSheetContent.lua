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

function GAC:CreateCharSheetContent(parent)
    local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    frame:SetAllPoints()

    -- Título
    local header = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    header:SetPoint("TOPLEFT", 15, -15)
    header:SetText("Ficha de Personaje")
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
    portrait:SetUnit("player")
    portrait:SetPortraitZoom(1)


    local nameText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    nameText:SetPoint("TOPLEFT", portraitBorder, "TOPRIGHT", 15, -10)
    nameText:SetText(GAC:GetRollDisplayName())
    nameText:SetTextColor(0.25, 0.78, 0.94)

    local infoText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    infoText:SetPoint("TOPLEFT", nameText, "BOTTOMLEFT", 0, -5)
    
    local level = GAC.characterData.level
    local race = GAC:GetActiveTRP3ProfileRace()
    local class = GAC:GetActiveTRP3ProfileClass()
    infoText:SetText(string.format("Nivel %d - %s - %s", level, race, class))

    -- Contenedor principal de pestañas interiores
    local contentArea = CreateFrame("Frame", nil, frame)
    contentArea:SetPoint("TOPLEFT", portraitBorder, "BOTTOMLEFT", -5, -40)
    contentArea:SetPoint("BOTTOMRIGHT", -15, 15)

    local tab1 = CreateFrame("Frame", nil, contentArea)
    tab1:SetAllPoints()
    local tab2 = CreateFrame("Frame", nil, contentArea)
    tab2:SetAllPoints()
    tab2:Hide()
    local tab3 = CreateFrame("Frame", nil, contentArea)
    tab3:SetAllPoints()
    tab3:Hide()

    -- Botones de Pestañas
    local btnHistoria = CreateSubTabButton(frame, "Historia", 100)
    btnHistoria:SetPoint("BOTTOMLEFT", contentArea, "TOPLEFT", 5, 5)
    
    local btnProgresion = CreateSubTabButton(frame, "Progresión", 120)
    btnProgresion:SetPoint("LEFT", btnHistoria, "RIGHT", 5, 0)
    
    local btnAtributos = CreateSubTabButton(frame, "Atributos y Talentos", 150)
    btnAtributos:SetPoint("LEFT", btnProgresion, "RIGHT", 5, 0)

    local function SelectSubTab(id)
        btnHistoria.selected = (id == 1); btnHistoria:GetScript("OnLeave")(btnHistoria)
        btnProgresion.selected = (id == 2); btnProgresion:GetScript("OnLeave")(btnProgresion)
        btnAtributos.selected = (id == 3); btnAtributos:GetScript("OnLeave")(btnAtributos)
        
        tab1:SetShown(id == 1)
        tab2:SetShown(id == 2)
        tab3:SetShown(id == 3)
    end
    btnHistoria:SetScript("OnClick", function() SelectSubTab(1) end)
    btnProgresion:SetScript("OnClick", function() SelectSubTab(2) end)
    btnAtributos:SetScript("OnClick", function() SelectSubTab(3) end)

    -------------------------------------------------
    -- TAB 1: HISTORIA
    -------------------------------------------------
    local descFrame = CreateFrame("Frame", nil, tab1, "BackdropTemplate")
    descFrame:SetAllPoints()
    descFrame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    descFrame:SetBackdropColor(0, 0, 0, 0.3)
    descFrame:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)

    local scrollFrame = CreateFrame("ScrollFrame", nil, descFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 8, -8)
    scrollFrame:SetPoint("BOTTOMRIGHT", -28, 40) -- dejar espacio para el boton

    local descEditBox = CreateFrame("EditBox", nil, scrollFrame)
    descEditBox:SetMultiLine(true)
    descEditBox:SetFontObject("GameFontHighlight")
    descEditBox:SetWidth(400)
    descEditBox:SetText("Escribe aquí el trasfondo de tu personaje...")
    descEditBox:SetAutoFocus(false)
    scrollFrame:SetScrollChild(descEditBox)
    scrollFrame:SetScript("OnSizeChanged", function(self, width) descEditBox:SetWidth(width) end)

    local saveBtn = CreateFrame("Button", nil, descFrame, "UIPanelButtonTemplate")
    saveBtn:SetSize(120, 26)
    saveBtn:SetPoint("BOTTOMRIGHT", -10, 10)
    saveBtn:SetText("Guardar Historia")

    -------------------------------------------------
    -- TAB 2: PROGRESIÓN (Niveles y Categorías)
    -------------------------------------------------
    local progBg = CreateFrame("Frame", nil, tab2, "BackdropTemplate")
    progBg:SetAllPoints()
    progBg:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12,
    })
    progBg:SetBackdropColor(0, 0, 0, 0.3)
    progBg:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)

    local progTitle = progBg:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    progTitle:SetPoint("TOPLEFT", 15, -15)
    progTitle:SetText("Información de Nivel Disponible")
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

    -- Controles
    local catLabel = progBg:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    catLabel:SetPoint("TOPLEFT", 380, -50)
    catLabel:SetText("Categoría:")
    
    local catDrop = CreateFrame("Frame", "GAC_CharSheetCatDrop", progBg, "UIDropDownMenuTemplate")
    catDrop:SetPoint("TOPLEFT", catLabel, "BOTTOMLEFT", -15, -5)
    UIDropDownMenu_SetWidth(catDrop, 100)

    local lvlLabel = progBg:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    lvlLabel:SetPoint("TOPLEFT", 380, -110)
    lvlLabel:SetText("Nivel:")

    local lvlDrop = CreateFrame("Frame", "GAC_CharSheetLvlDrop", progBg, "UIDropDownMenuTemplate")
    lvlDrop:SetPoint("TOPLEFT", lvlLabel, "BOTTOMLEFT", -15, -5)
    UIDropDownMenu_SetWidth(lvlDrop, 100)

    GAC.characterData.progress = GAC.characterData.progress or { category = "normal", level = 1 }
    local currentCat = GAC.characterData.progress.category or "normal"
    local currentLvl = GAC.characterData.progress.level or 1

    local saveProgBtn = CreateFrame("Button", nil, progBg, "UIPanelButtonTemplate")
    saveProgBtn:SetSize(140, 26)
    saveProgBtn:SetPoint("BOTTOM", 0, 10)
    saveProgBtn:SetText("Guardar Progresión")
    saveProgBtn:Hide()

    saveProgBtn:SetScript("OnClick", function()
        saveProgBtn:Hide()
        GAC:SetExperienceCategory(currentCat)
        GAC:SetExperienceLevel(currentLvl)
        GAC:SetCurrentExperience(0)
        if frame.Update then frame:Update() end
        print("|cFF40C7EBGAC:|r Progresión guardada correctamente.")
    end)

    local function UpdateProgressionInfo()
        if not GAC.levelsTable or not GAC.levelsTable[currentCat] then return end
        local data = GAC.levelsTable[currentCat][currentLvl]
        if data then
            hpText:SetText(data.maxHealth and tostring(data.maxHealth) or "0")
            expText:SetText(data.expToLevel and tostring(data.expToLevel) or "MAX")
            attText:SetText(data.attPoints and tostring(data.attPoints) or "0")
            skillText:SetText(data.skillPoints and tostring(data.skillPoints) or "0")
            heroicText:SetText(data.heroicPoints and tostring(data.heroicPoints) or "0")
            traitText:SetText(data.maxPositiveTraits and tostring(data.maxPositiveTraits) or "0")
        end
    end

    UIDropDownMenu_Initialize(catDrop, function(self, level, menuList)
        local categories = GAC.levelCategories or {"noob", "normal", "elite", "boss"}
        for _, cat in ipairs(categories) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = cat:gsub("^%l", string.upper)
            info.func = function() 
                if currentCat ~= cat then saveProgBtn:Show() end
                currentCat = cat
                currentLvl = 1
                UIDropDownMenu_SetText(catDrop, info.text)
                UIDropDownMenu_SetText(lvlDrop, "1")
                UpdateProgressionInfo() 
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    UIDropDownMenu_SetText(catDrop, currentCat:gsub("^%l", string.upper))

    UIDropDownMenu_Initialize(lvlDrop, function(self, level, menuList)
        if not GAC.levelsTable or not GAC.levelsTable[currentCat] then return end
        for i = 1, #GAC.levelsTable[currentCat] do
            local info = UIDropDownMenu_CreateInfo()
            info.text = tostring(i)
            info.func = function() 
                if currentLvl ~= i then saveProgBtn:Show() end
                currentLvl = i
                UIDropDownMenu_SetText(lvlDrop, info.text)
                UpdateProgressionInfo() 
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    UIDropDownMenu_SetText(lvlDrop, tostring(currentLvl))

    C_Timer.After(0.1, UpdateProgressionInfo)

    -------------------------------------------------
    -- TAB 3: ATRIBUTOS Y TALENTOS (Card Style)
    -------------------------------------------------
    local attBg = CreateFrame("Frame", nil, tab3, "BackdropTemplate")
    attBg:SetAllPoints()
    attBg:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12,
    })
    attBg:SetBackdropColor(0, 0, 0, 0.3)
    attBg:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)

    local scrollFrameAtt = CreateFrame("ScrollFrame", nil, attBg, "UIPanelScrollFrameTemplate")
    scrollFrameAtt:SetPoint("TOPLEFT", 8, -8)
    scrollFrameAtt:SetPoint("BOTTOMRIGHT", -28, 45)

    local contentContainer = CreateFrame("Frame", nil, scrollFrameAtt)
    contentContainer:SetSize(400, 10)
    scrollFrameAtt:SetScrollChild(contentContainer)

    scrollFrameAtt:SetScript("OnSizeChanged", function(self, width)
        contentContainer:SetWidth(width)
    end)

    local statInputs = {}

    local saveStatsBtn = CreateFrame("Button", nil, attBg, "UIPanelButtonTemplate")
    saveStatsBtn:SetSize(140, 26)
    saveStatsBtn:SetPoint("BOTTOM", 0, 10)
    saveStatsBtn:SetText("Guardar Cambios")
    saveStatsBtn:Hide()

    saveStatsBtn:SetScript("OnClick", function()
        saveStatsBtn:Hide()
        print("|cFF40C7EBGAC:|r Atributos y talentos guardados correctamente.")
        for key, data in pairs(statInputs) do
            local v = tonumber(data.input:GetText()) or 0
            if GAC.characterData then
                if data.isTalent then GAC.characterData.talents[key] = v
                else GAC.characterData.attributes[key] = v end
            end
        end
    end)

    local function CreateStatInput(parent, label, key, isTalent)
        local row = CreateFrame("Frame", nil, parent)
        row:SetPoint("LEFT", 5, 0)
        row:SetPoint("RIGHT", -5, 0)
        row:SetHeight(26)
        
        local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        name:SetPoint("LEFT", 5, 0)
        local localizedName = (GAC.L and GAC.L[label]) or label:gsub("^%l", string.upper)
        name:SetText(localizedName)

        local input = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
        input:SetSize(40, 20)
        input:SetPoint("RIGHT", -20, 0)
        input:SetAutoFocus(false)
        
        
        input:SetNumeric(false) -- Removed SetNumeric to prevent any WoW API rejection bugs
        input:SetFontObject("GameFontHighlight") -- Explicitly set font
        input:SetTextInsets(5, 5, 0, 0) -- Prevent text from clipping under textures

        input:SetScript("OnTextChanged", function(self, isUserInput)
            if not isUserInput then return end
            saveStatsBtn:Show()
        end)
        input:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        input:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)

        statInputs[key] = { input = input, isTalent = isTalent }
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

        local attRow, nameLabel = CreateStatInput(headerBg, group.name, group.name, false)
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
            local talRow = CreateStatInput(card, talent, talent, true)
            talRow:SetPoint("TOP", 0, currentY)
            currentY = currentY - 26
        end

        card:SetHeight(-currentY + 5)
        return card
    end

    local function RefreshStats()
        saveStatsBtn:Hide()
        if not GAC.characterData then return end
        
        local attributes = (type(GAC.characterData) == "table" and GAC.characterData.attributes) or {}
        local talents = (type(GAC.characterData) == "table" and GAC.characterData.talents) or {}

        for key, data in pairs(statInputs) do
            if data.isTalent then
                data.input:SetText(tostring(tonumber(talents[key]) or 0))
            else
                data.input:SetText(tostring(tonumber(attributes[key]) or 0))
            end
            data.input:SetCursorPosition(0) -- Ensures text is not scrolled out of view
        end
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

    tab3:SetScript("OnShow", function()
        InitCards()
        RefreshStats()
    end)

    -- Inicializar Tab 1
    SelectSubTab(1)

    -- Función Update invocada cuando se muestra la pestaña principal
    frame.Update = function(self)
        if portrait then
            portrait:SetUnit("player")
            portrait:RefreshUnit()
            portrait:SetPortraitZoom(1)
        end
        local currentClass = GAC:GetActiveTRP3ProfileClass()
        if currentClass then
            local cl = RAID_CLASS_COLORS[select(2, UnitClass("player"))] or {r=1, g=1, b=1}
            infoText:SetTextColor(cl.r, cl.g, cl.b)
            infoText:SetText(string.format("Nivel %d (%s) - %s - %s", GAC.characterData.progress.level, GAC.characterData.progress.category:gsub("^%l", string.upper), GAC:GetActiveTRP3ProfileRace(), currentClass))
        end
        nameText:SetText(GAC:GetRollDisplayName())
    end

    return frame
end
