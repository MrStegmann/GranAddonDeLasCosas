local addonName, GAC = ...

GAC.Screens = GAC.Screens or {}
GAC.Screens.MainMenu = GAC.Screens.MainMenu or {}

function GAC.Screens.MainMenu:CreateCharSheetScreen(parent)
    local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    frame:SetAllPoints()

    -- Título
    local header = GAC:CreateFontString(frame, "Ficha de Personaje", "GameFontNormalLarge", { "TOPLEFT", 15, -15 }, { 1, 1, 1 })

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

    local infoText = GAC:CreateFontString(frame, "", "GameFontHighlight", { "TOPLEFT", nameText, "BOTTOMLEFT", 0, -5 }, {1, 1, 1}) 
    
    local function UpdateHeaderInfoText(previewRace1, previewRace2)
        if not GAC.characterData then return end
        
        local prog = GAC.characterData.progress or {}
        local levelStr = prog.level or 1
        if type(levelStr) ~= "number" or levelStr < 1 then levelStr = 1 end
        
        local rawCat = prog.category or "normal"
        local catStr = GAC:_(rawCat) or rawCat:gsub("^%l", string.upper)
        
        local classStr = GAC:GetActiveTRP3ProfileClass() or "Desconocida"
        local raceStr = GAC:GetActiveTRP3ProfileRace() or "Desconocida"
        
        local chars = GAC.characterData.characteristics
        local r1 = previewRace1 or (chars and chars.race1) or "Ninguna"
        local r2 = previewRace2 or (chars and chars.race2) or "Ninguna"
        
        if r1 ~= "Ninguna" and r2 ~= "Ninguna" then
            raceStr = string.format("Mestizo (%s y %s)", GAC:_(r1) or r1, GAC:_(r2) or r2)
        elseif r1 ~= "Ninguna" then
            raceStr = GAC:_(r1) or r1
        end
        
        local cl = RAID_CLASS_COLORS[select(2, UnitClass("player"))] or {r=1, g=1, b=1}
        infoText:SetTextColor(cl.r, cl.g, cl.b)
        infoText:SetText(string.format("Nivel %d (%s) - %s - %s", levelStr, catStr, raceStr, classStr))
    end
    frame.UpdateHeaderInfoText = UpdateHeaderInfoText
    UpdateHeaderInfoText()

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
    local btnHistoria = GAC:CreateSubTabButton(frame, "Características", 120)
    btnHistoria:SetPoint("BOTTOMLEFT", contentArea, "TOPLEFT", 5, 5)
    
    local btnProgresion = GAC:CreateSubTabButton(frame, "Progresión", 120)
    btnProgresion:SetPoint("LEFT", btnHistoria, "RIGHT", 5, 0)
    
    local btnAtributos = GAC:CreateSubTabButton(frame, "Atributos y Talentos", 150)
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

    -- Inicializar Sub-Módulos
    GAC.Components.MainMenu:CreateCharacteristicsTab(tab1, frame)
    GAC.Components.MainMenu:CreateProgressionTab(tab2, frame)
    GAC.Components.MainMenu:CreateCharSheetAttributesTab(tab3, frame)

    -- Inicializar Tab 1
    SelectSubTab(1)

    -- Función Update invocada cuando se muestra la pestaña principal
    frame.Update = function(self)
        if portrait then
            portrait:SetUnit("player")
            portrait:RefreshUnit()
            portrait:SetPortraitZoom(1)
        end
        UpdateHeaderInfoText()
        nameText:SetText(GAC:GetRollDisplayName())

        -- Update progression dropdowns to reflect current actual progress, 
        -- assuming the user wants to see their current level when updated.
        if GAC.characterData and GAC.characterData.progress then
            local currentCat = GAC.characterData.progress.category or "normal"
            local currentLvl = GAC.characterData.progress.level or 1
            if frame.catDrop and UIDropDownMenu_SetText then
                UIDropDownMenu_SetText(frame.catDrop, GAC:_(currentCat))
            end
            if frame.lvlDrop and UIDropDownMenu_SetText then
                UIDropDownMenu_SetText(frame.lvlDrop, tostring(currentLvl))
            end
            if frame.UpdateProgressionInfo then
                frame:UpdateProgressionInfo()
            end
            if frame.saveProgBtn then frame.saveProgBtn:Hide() end
        end
    end

    return frame
end
