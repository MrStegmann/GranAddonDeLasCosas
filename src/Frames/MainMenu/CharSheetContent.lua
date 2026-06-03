local _, GAC = ...

function GAC:CreateCharSheetContent(parent)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetAllPoints()

    -- ScrollFrame para manejar muchos talentos
    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 0, -5)
    scrollFrame:SetPoint("BOTTOMRIGHT", -27, 5)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(520, 1)
    scrollFrame:SetScrollChild(content)

    -- Helper para crear inputs numéricos
    local function CreateValueInput(parent, initialValue, saveFunc)
        local eb = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
        eb:SetSize(35, 20)
        eb:SetAutoFocus(false)
        eb:SetNumeric(true)
        eb:SetText(tostring(initialValue or 0))
        eb:SetScript("OnEnterPressed", function(s) s:ClearFocus() end)
        eb:SetScript("OnEditFocusLost", function(s)
            local val = tonumber(s:GetText()) or 0
            saveFunc(val)
        end)
        return eb
    end

    -- Crear la cabecera una sola vez para evitar duplicidad de frames globales
    local header = CreateFrame("Frame", nil, content, "BackdropTemplate")
    header:SetSize(500, 55)
    header:SetPoint("TOPLEFT", 10, -10)
    header:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 8, edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    header:SetBackdropColor(0, 0, 0, 0.5)
    header:SetBackdropBorderColor(0.25, 0.78, 0.94, 0.6)

    -- Selector de Categoría
    local catLabel = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    catLabel:SetPoint("TOPLEFT", 15, -10)
    catLabel:SetText("CATEGORÍA")

    local catDropDown = CreateFrame("Frame", nil, header, "UIDropDownMenuTemplate")
    catDropDown:SetPoint("TOPLEFT", catLabel, "BOTTOMLEFT", -15, 0)
    UIDropDownMenu_SetWidth(catDropDown, 120)

    -- Selector de Nivel
    local lvlLabel = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    lvlLabel:SetPoint("LEFT", catLabel, "RIGHT", 100, 0)
    lvlLabel:SetText("NIVEL")

    local lvlDropDown = CreateFrame("Frame", nil, header, "UIDropDownMenuTemplate")
    lvlDropDown:SetPoint("TOPLEFT", lvlLabel, "BOTTOMLEFT", -15, 0)
    UIDropDownMenu_SetWidth(lvlDropDown, 60)

    -- Inicializadores de los dropdowns (Referencia: MainFrame.Shared.lua)
    local function CategoryDropDown_Initialize(self, level)
        if level ~= 1 then return end

        local snapshot = GAC:GetExperienceProgressSnapshot()
        local categories = GAC.levelCategories or {}
        for _, catName in ipairs(categories) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = catName
            info.value = catName
            info.func = function()
                GAC:SetExperienceCategory(catName)
                if frame.Update then frame:Update() end
            end
            info.checked = (catName == snapshot.category)
            UIDropDownMenu_AddButton(info, level)
        end
    end

    local function LevelDropDown_Initialize(self, level)
        if level ~= 1 then return end

        local snapshot = GAC:GetExperienceProgressSnapshot()
        local maxLevel = GAC:GetMaxLevelForCategory(snapshot.category) or 1
        for i = 1, maxLevel do
            local info = UIDropDownMenu_CreateInfo()
            info.text = tostring(i)
            info.value = i
            info.func = function()
                GAC:SetExperienceLevel(i)
                if frame.Update then frame:Update() end
            end
            info.checked = (i == snapshot.level)
            UIDropDownMenu_AddButton(info, level)
        end
    end

    UIDropDownMenu_Initialize(catDropDown, CategoryDropDown_Initialize)
    UIDropDownMenu_Initialize(lvlDropDown, LevelDropDown_Initialize)

    -- Texto informativo sobre los límites del nivel actual (Vida, Puntos, etc)
    local levelStatsText = header:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    levelStatsText:SetPoint("LEFT", lvlDropDown, "RIGHT", 10, 0)
    levelStatsText:SetTextColor(0.8, 0.8, 0.8)

    -- Contenedor para las cards para evitar fugas de memoria y solapamientos al refrescar
    local cardsContainer = CreateFrame("Frame", nil, content)
    cardsContainer:SetSize(520, 1)
    cardsContainer:SetPoint("TOPLEFT", 0, -75)

    -- Función para refrescar los datos de la ficha
    local function UpdateSheet()
        -- Ocultar cards anteriores antes de generar las nuevas
        local children = { cardsContainer:GetChildren() }
        for _, child in ipairs(children) do
            child:Hide()
        end

        local snapshot = GAC:GetExperienceProgressSnapshot()
        local charData = GAC.characterData or {}
        charData.attributes = charData.attributes or {}
        charData.talents = charData.talents or {}

        -- Refrescar los textos y valores (Similar a addon:RefreshMainExperiencePanel)
        UIDropDownMenu_Initialize(catDropDown, CategoryDropDown_Initialize)
        UIDropDownMenu_SetSelectedValue(catDropDown, snapshot.category)
        UIDropDownMenu_SetText(catDropDown, snapshot.category)

        UIDropDownMenu_Initialize(lvlDropDown, LevelDropDown_Initialize)
        UIDropDownMenu_SetSelectedValue(lvlDropDown, snapshot.level)
        UIDropDownMenu_SetText(lvlDropDown, tostring(snapshot.level))

        -- Actualizar estadísticas base del nivel seleccionado desde LevelsTable.lua
        local levelData = GAC:GetLevelEntry(snapshot.category, snapshot.level)
        if levelData then
            levelStatsText:SetText(string.format(
                "Vida: |cff00ff00%d|r  Atrib: |cff00ff00%d|r  Habil: |cff00ff00%d|r  Heroic: |cff00ff00%d|r",
                levelData.maxHealth or 0,
                levelData.attPoints or 0,
                levelData.skillPoints or 0,
                levelData.heroicPoints or 0
            ))
        else
            levelStatsText:SetText("")
        end

        local yPos = 0
        local attributeGroups = GAC.attributeGroups or {}

        -- --- CARDS DE ATRIBUTOS Y TALENTOS ---
        for _, group in ipairs(attributeGroups) do
            local card = CreateFrame("Frame", nil, cardsContainer, "BackdropTemplate")
            card:SetSize(500, 30) -- Altura dinámica
            card:SetPoint("TOPLEFT", 10, -yPos)
            card:SetBackdrop({
                bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                tile = true, tileSize = 8, edgeSize = 10,
                insets = { left = 2, right = 2, top = 2, bottom = 2 },
            })
            card:SetBackdropColor(0.1, 0.12, 0.15, 0.4)
            card:SetBackdropBorderColor(1, 1, 1, 0.15)

            -- Título Atributo
            local attrName = card:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            attrName:SetPoint("TOPLEFT", 15, -12)
            attrName:SetText(group.name:upper())
            attrName:SetTextColor(0.25, 0.78, 0.94)

            -- Input Atributo
            local attrInput = CreateValueInput(card, charData.attributes[group.name], function(v)
                charData.attributes[group.name] = v
            end)
            attrInput:SetPoint("TOPRIGHT", -15, -10)

            local cardInnerY = 40

            for _, talentName in ipairs(group.talents or {}) do
                local tLabel = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                tLabel:SetPoint("TOPLEFT", 30, -cardInnerY)
                tLabel:SetText(talentName)

                local tInput = CreateValueInput(card, charData.talents[talentName], function(v)
                    charData.talents[talentName] = v
                end)
                tInput:SetSize(30, 18)
                tInput:SetPoint("TOPRIGHT", -15, -cardInnerY + 2)

                cardInnerY = cardInnerY + 22
            end

            card:SetHeight(cardInnerY + 10)
            yPos = yPos + cardInnerY + 20
        end

        content:SetHeight(yPos + 20)
    end

    frame.Update = UpdateSheet
    return frame
end