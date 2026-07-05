local addonName, GAC = ...

GAC.Screens = GAC.Screens or {}
GAC.Screens.InspectionMenu = GAC.Screens.InspectionMenu or {}

function GAC.Screens.InspectionMenu:CreateCharSheetScreen(parent)
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

    local tabCaracteristicas = GAC.Components.InspectionMenu:CreateCharacteristicsTab(contentArea)
    local tabProgresion = GAC.Components.InspectionMenu:CreateProgressionTab(contentArea)
    tabProgresion:Hide()
    local tabAtributos = GAC.Components.InspectionMenu:CreateAttributesTab(contentArea)
    tabAtributos:Hide()
    local tabExperiencia = GAC.Components.InspectionMenu:CreateExperienceTab(contentArea)
    tabExperiencia:Hide()

    -- Botones de Pestañas
    local btnCaracteristicas = GAC:CreateSubTabButton(frame, "Características", 130)
    btnCaracteristicas:SetPoint("BOTTOMLEFT", contentArea, "TOPLEFT", 5, 5)
    
    local btnProgresion = GAC:CreateSubTabButton(frame, "Progresión", 120)
    btnProgresion:SetPoint("LEFT", btnCaracteristicas, "RIGHT", 5, 0)
    
    local btnAtributos = GAC:CreateSubTabButton(frame, "Atributos y Talentos", 150)
    btnAtributos:SetPoint("LEFT", btnProgresion, "RIGHT", 5, 0)

    local btnExperiencia = GAC:CreateSubTabButton(frame, "Experiencia", 120)
    btnExperiencia:SetPoint("LEFT", btnAtributos, "RIGHT", 5, 0)

    local function SelectSubTab(id)
        btnCaracteristicas.selected = (id == 1); btnCaracteristicas:GetScript("OnLeave")(btnCaracteristicas)
        btnProgresion.selected = (id == 2); btnProgresion:GetScript("OnLeave")(btnProgresion)
        btnAtributos.selected = (id == 3); btnAtributos:GetScript("OnLeave")(btnAtributos)
        btnExperiencia.selected = (id == 4); btnExperiencia:GetScript("OnLeave")(btnExperiencia)
        
        tabCaracteristicas:SetShown(id == 1)
        tabProgresion:SetShown(id == 2)
        tabAtributos:SetShown(id == 3)
        tabExperiencia:SetShown(id == 4)
    end
    btnCaracteristicas:SetScript("OnClick", function() SelectSubTab(1) end)
    btnProgresion:SetScript("OnClick", function() SelectSubTab(2) end)
    btnAtributos:SetScript("OnClick", function() SelectSubTab(3) end)
    btnExperiencia:SetScript("OnClick", function() SelectSubTab(4) end)

    SelectSubTab(1)

    frame.Update = function(self)
        if not GAC.inspectedPlayer then return end
        local p = GAC.inspectedPlayer
        
        nameText:SetText(Ambiguate(p.name, "none"))
        
        local r1 = p.race1 or "Ninguna"
        local r2 = p.race2 or "Ninguna"
        local raceString = "Desconocida"
        if r1 ~= "Ninguna" and r2 ~= "Ninguna" then
            raceString = string.format("Mestizo (%s y %s)", GAC:_(r1) or r1, GAC:_(r2) or r2)
        elseif r1 ~= "Ninguna" then
            raceString = GAC:_(r1) or r1
        end

        infoText:SetText(string.format("Nivel %d (%s) - %s - %s", p.level, GAC:_(p.category) or p.category, raceString, p.class))
        
        if portrait then
            if UnitName("target") == p.name then
                portrait:SetUnit("target")
            end
            portrait:RefreshUnit()
        end
        
        tabCaracteristicas:Update(p)
        tabProgresion:Update(p)
        tabAtributos:Update(p)
        tabExperiencia:Update(p)

        local shortName = Ambiguate(p.name, "none")
        local isSameGroup = UnitInParty(shortName) or UnitInRaid(shortName)

        if IsInGroup() and UnitIsGroupLeader("player") and isSameGroup then
            btnExperiencia:Show()
        else
            btnExperiencia:Hide()
            if tabExperiencia:IsShown() then
                SelectSubTab(1)
            end
        end
    end

    return frame
end
