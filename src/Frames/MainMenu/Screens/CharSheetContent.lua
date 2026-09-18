local addonName, GAC = ...

function GAC:CreateCharSheetContent(parent)
    local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    frame:SetAllPoints()

    -- Título
    local header = GAC:CreateFontString(frame, GAC:_("charSheetTitle"), "GameFontNormalLarge", { "TOPLEFT", 15, -15 }, { 1, 1, 1 })

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


    local nameText = GAC:CreateFontString(frame, GAC:GetRollDisplayName(), "GameFontNormalHuge", { "TOPLEFT", portraitBorder, "TOPRIGHT", 15, -10 }, { 0.25, 0.78, 0.94 })

    local level = GAC.characterData.level
    local race = GAC:GetActiveTRP3ProfileRace()
    local class = GAC:GetActiveTRP3ProfileClass()
    
    local infoText = GAC:CreateFontString(frame, string.format(GAC:_("charSheetInfoTextFmt"), level, race, class), "GameFontHighlight", { "TOPLEFT", nameText, "BOTTOMLEFT", 0, -5 }, {1, 1, 1}) 
    

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
    local tab4 = CreateFrame("Frame", nil, contentArea)
    tab4:SetAllPoints()
    tab4:Hide()

    -- Botones de Pestañas
    local btnHistoria = GAC:CreateSubTabButton(frame, GAC:_("charSheetTabHistory"), 100)
    btnHistoria:SetPoint("BOTTOMLEFT", contentArea, "TOPLEFT", 5, 5)
    
    local btnProgresion = GAC:CreateSubTabButton(frame, GAC:_("charSheetTabProgression"), 120)
    btnProgresion:SetPoint("LEFT", btnHistoria, "RIGHT", 5, 0)
    
    local btnAtributos = GAC:CreateSubTabButton(frame, GAC:_("charSheetTabAttributes"), 150)
    btnAtributos:SetPoint("LEFT", btnProgresion, "RIGHT", 5, 0)
    
    local btnOtros = GAC:CreateSubTabButton(frame, GAC:_("charSheetTabOther"), 80)
    btnOtros:SetPoint("LEFT", btnAtributos, "RIGHT", 5, 0)

    local function SelectSubTab(id)
        btnHistoria.selected = (id == 1); btnHistoria:GetScript("OnLeave")(btnHistoria)
        btnProgresion.selected = (id == 2); btnProgresion:GetScript("OnLeave")(btnProgresion)
        btnAtributos.selected = (id == 3); btnAtributos:GetScript("OnLeave")(btnAtributos)
        btnOtros.selected = (id == 4); btnOtros:GetScript("OnLeave")(btnOtros)
        
        tab1:SetShown(id == 1)
        tab2:SetShown(id == 2)
        tab3:SetShown(id == 3)
        tab4:SetShown(id == 4)
    end
    btnHistoria:SetScript("OnClick", function() SelectSubTab(1) end)
    btnProgresion:SetScript("OnClick", function() SelectSubTab(2) end)
    btnAtributos:SetScript("OnClick", function() SelectSubTab(3) end)
    btnOtros:SetScript("OnClick", function() SelectSubTab(4) end)

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
    descEditBox:SetText(GAC:_("charSheetBackgroundPlaceholder"))
    descEditBox:SetAutoFocus(false)
    scrollFrame:SetScrollChild(descEditBox)
    scrollFrame:SetScript("OnSizeChanged", function(self, width) descEditBox:SetWidth(width) end)

    local saveBtn = CreateFrame("Button", nil, descFrame, "UIPanelButtonTemplate")
    saveBtn:SetSize(120, 26)
    saveBtn:SetPoint("BOTTOMRIGHT", -10, 10)
    saveBtn:SetText(GAC:_("charSheetSaveStory"))

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

    local progTitle = GAC:CreateFontString(progBg, GAC:_("charSheetProgressionTitle"), "GameFontNormalLarge", { "TOPLEFT", 15, -15 }, { 0.25, 0.78, 0.94 })

    local _, hpText = GAC:CreateInfoBox(progBg, GAC:_("charSheetMaxHealth"), 20, -50)
    local _, expText = GAC:CreateInfoBox(progBg, GAC:_("charSheetExpToLevel"), 190, -50)
    local _, attText = GAC:CreateInfoBox(progBg, GAC:_("charSheetAttributePoints"), 20, -100)
    local _, skillText = GAC:CreateInfoBox(progBg, GAC:_("charSheetSkillSlots"), 190, -100)
    local _, heroicText = GAC:CreateInfoBox(progBg, GAC:_("charSheetHeroicPoints"), 20, -150)
    local _, traitText = GAC:CreateInfoBox(progBg, GAC:_("charSheetPositiveTraits"), 190, -150)

    -- Controles
    local catLabel = GAC:CreateFontString(progBg, GAC:_("charSheetCategoryLabel"), "GameFontNormal", { "TOPLEFT", 380, -50 }, {1, 1, 1})
    
    local catDrop = CreateFrame("Frame", "GAC_CharSheetCatDrop", progBg, "UIDropDownMenuTemplate")
    catDrop:SetPoint("TOPLEFT", catLabel, "BOTTOMLEFT", -15, -5)
    UIDropDownMenu_SetWidth(catDrop, 100)

    local lvlLabel = GAC:CreateFontString(progBg, GAC:_("charSheetLevelLabel"), "GameFontNormal", { "TOPLEFT", 380, -110 }, {1, 1, 1})
    
    local lvlDrop = CreateFrame("Frame", "GAC_CharSheetLvlDrop", progBg, "UIDropDownMenuTemplate")
    lvlDrop:SetPoint("TOPLEFT", lvlLabel, "BOTTOMLEFT", -15, -5)
    UIDropDownMenu_SetWidth(lvlDrop, 100)

    GAC.characterData.progress = GAC.characterData.progress or { category = "normal", level = 1 }
    local currentCat = GAC.characterData.progress.category or "normal"
    local currentLvl = GAC.characterData.progress.level or 1

    local saveProgBtn = CreateFrame("Button", nil, progBg, "UIPanelButtonTemplate")
    saveProgBtn:SetSize(140, 26)
    saveProgBtn:SetPoint("BOTTOM", 0, 10)
    saveProgBtn:SetText(GAC:_("charSheetSaveProgression"))
    saveProgBtn:Hide()

    saveProgBtn:SetScript("OnClick", function()
        saveProgBtn:Hide()
        if GAC.Dispatcher and GAC.Actions then
            GAC.Dispatcher:Dispatch(GAC.Actions.UPDATE_PROGRESS, { category = currentCat, level = currentLvl })
        else
            GAC:SetExperienceCategory(currentCat)
            GAC:SetExperienceLevel(currentLvl)
            GAC:SetCurrentExperience(0)
            
            if GAC.characterData then
                local levelEntry = GAC.GetLevelEntry and GAC:GetLevelEntry(currentCat, currentLvl)
                local baseHealth = 10
                if levelEntry and levelEntry.maxHealth then
                    baseHealth = levelEntry.maxHealth
                elseif GAC.levelsTable and GAC.levelsTable[currentCat] and GAC.levelsTable[currentCat][currentLvl] then
                    baseHealth = GAC.levelsTable[currentCat][currentLvl].maxHealth or 10
                end
                
                local constitution = (GAC.characterData.attributes and GAC.characterData.attributes["constitution"]) or 0
                local maxHealth = baseHealth + constitution
                if maxHealth < 1 then maxHealth = 1 end
                
                GAC.characterData.currentHealth = maxHealth
                
                if PlayerFrameHealthBar then
                    UnitFrameHealthBar_Update(PlayerFrameHealthBar, "player")
                    if TextStatusBar_UpdateTextString then
                        TextStatusBar_UpdateTextString(PlayerFrameHealthBar)
                    end
                end
            end

            GAC:UpdateGameExpBar()
        end
        if frame.Update then frame:Update() end
        print("|cFF40C7EBGAC:|r " .. GAC:_("charSheetSaveSuccessMsg"))
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
            info.text = GAC:_(cat)
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
    UIDropDownMenu_SetText(catDrop, GAC:_(currentCat))

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
        print("|cFF40C7EB[GAC]|r: Atributos y talentos guardados correctamente.")
        for key, data in pairs(statInputs) do
            local v = tonumber(data.input:GetText()) or 0
            if GAC.characterData then
                if data.isTalent then GAC.characterData.talents[key] = v
                else GAC.characterData.attributes[key] = v end
            end
        end
    end)

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
            local card = GAC:CreateCard(contentContainer, group, function() saveStatsBtn:Show() end, statInputs)
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

    -------------------------------------------------
    -- TAB 4: OTROS
    -------------------------------------------------
    local otrosBg = CreateFrame("Frame", nil, tab4, "BackdropTemplate")
    otrosBg:SetAllPoints()
    otrosBg:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12,
    })
    otrosBg:SetBackdropColor(0, 0, 0, 0.3)
    otrosBg:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)

    local worgenCurseCheckbox = CreateFrame("CheckButton", nil, otrosBg, "UICheckButtonTemplate")
    worgenCurseCheckbox:SetPoint("TOPLEFT", 15, -15)
    
    local worgenCurseLabel = GAC:CreateFontString(otrosBg, GAC:_("charSheetWorgenCurse"), "GameFontHighlight", { "LEFT", worgenCurseCheckbox, "RIGHT", 5, 0 }, {1, 1, 1})

    worgenCurseCheckbox:SetScript("OnClick", function(self)
        if not GAC.characterData then return end
        GAC.characterData.isWorgenCurse = self:GetChecked()
    end)

    tab4:SetScript("OnShow", function()
        if GAC.characterData then
            worgenCurseCheckbox:SetChecked(GAC.characterData.isWorgenCurse or false)
        end
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
        local currentClass = GAC:GetActiveTRP3ProfileClass() or select(1, UnitClass("player")) or ""
        local currentRace = GAC:GetActiveTRP3ProfileRace() or select(1, UnitRace("player")) or ""
        local progress = GAC.characterData and GAC.characterData.progress or {}
        local level = progress.level or 1
        local category = progress.category or "normal"
        local localizedCategory = GAC:_(category) or category
        if type(localizedCategory) == "string" then
            localizedCategory = localizedCategory:gsub("^%l", string.upper)
        else
            localizedCategory = tostring(category)
        end

        local cl = RAID_CLASS_COLORS[select(2, UnitClass("player"))] or {r=1, g=1, b=1}
        infoText:SetTextColor(cl.r, cl.g, cl.b)
        infoText:SetText(string.format(GAC:_("charSheetInfoTextWithCategoryFmt"), level, localizedCategory, currentRace, currentClass))
        nameText:SetText(GAC:GetRollDisplayName() or UnitName("player") or "")

        -- Update progression dropdowns to reflect current actual progress, 
        -- assuming the user wants to see their current level when updated.
        if GAC.characterData and GAC.characterData.progress then
            currentCat = GAC.characterData.progress.category or "normal"
            currentLvl = GAC.characterData.progress.level or 1
            if catDrop and UIDropDownMenu_SetText then
                UIDropDownMenu_SetText(catDrop, GAC:_(currentCat))
            end
            if lvlDrop and UIDropDownMenu_SetText then
                UIDropDownMenu_SetText(lvlDrop, tostring(currentLvl))
            end
            if UpdateProgressionInfo then
                UpdateProgressionInfo()
            end
            if saveProgBtn then saveProgBtn:Hide() end
        end
    end

    if GAC.Store and GAC.Store.Subscribe then
        GAC.Store:Subscribe(function()
            if frame:IsShown() and frame.Update then
                frame:Update()
            end
        end)
    end

    return frame
end
