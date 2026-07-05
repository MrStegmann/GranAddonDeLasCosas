local addonName, GAC = ...

GAC.Components = GAC.Components or {}
GAC.Components.MainMenu = GAC.Components.MainMenu or {}

function GAC.Components.MainMenu:CreateProgressionTab(tab, mainFrame)
    local progBg = GAC.Components.MainMenu:CreateDarkTabBackground(tab)

    local progTitle = GAC:CreateFontString(progBg, "Información de Nivel Disponible", "GameFontNormalLarge", { "TOPLEFT", 15, -15 }, GAC.Stores.MainMenu.Constants.TITLE_COLOR)

    local _, hpText = GAC:CreateInfoBox(progBg, "Salud Máxima", 20, -50)
    local _, expText = GAC:CreateInfoBox(progBg, "Exp para Nivel", 190, -50)
    local _, attText = GAC:CreateInfoBox(progBg, "Puntos de Atributo", 20, -100)
    local _, skillText = GAC:CreateInfoBox(progBg, "Ranuras de hechisos/habilidadeh", 190, -100)
    local _, heroicText = GAC:CreateInfoBox(progBg, "Puntos Heroicos", 20, -150)
    local _, traitText = GAC:CreateInfoBox(progBg, "Rasgos Positivos", 190, -150)

    -- Controles
    local catLabel = GAC:CreateFontString(progBg, "Categoría:", "GameFontNormal", { "TOPLEFT", 380, -50 }, {1, 1, 1})
    
    local catDrop = CreateFrame("Frame", "GAC_CharSheetCatDrop", progBg, "UIDropDownMenuTemplate")
    catDrop:SetPoint("TOPLEFT", catLabel, "BOTTOMLEFT", -15, -5)
    UIDropDownMenu_SetWidth(catDrop, 100)

    local lvlLabel = GAC:CreateFontString(progBg, "Nivel:", "GameFontNormal", { "TOPLEFT", 380, -110 }, {1, 1, 1})
    
    local lvlDrop = CreateFrame("Frame", "GAC_CharSheetLvlDrop", progBg, "UIDropDownMenuTemplate")
    lvlDrop:SetPoint("TOPLEFT", lvlLabel, "BOTTOMLEFT", -15, -5)
    UIDropDownMenu_SetWidth(lvlDrop, 100)

    GAC.characterData.progress = GAC.characterData.progress or { category = "normal", level = 1 }
    local currentCat = GAC.characterData.progress.category or "normal"
    local currentLvl = GAC.characterData.progress.level or 1
    if type(currentLvl) ~= "number" or currentLvl < 1 then currentLvl = 1 end

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
        
        if GAC.playerCharacter then
            GAC.playerCharacter:IncrementVersion()
            GAC.characterData.modelData = GAC.playerCharacter:Serialize()
        end

        GAC:UpdateGameExpBar()
        if mainFrame.Update then mainFrame:Update() end
        print("|cFF40C7EBGAC:|r Progresión guardada correctamente. Salud restablecida al máximo.")
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
    UpdateProgressionInfo()

    -- Expose objects to mainFrame so frame.Update can update them if needed
    mainFrame.catDrop = catDrop
    mainFrame.lvlDrop = lvlDrop
    mainFrame.saveProgBtn = saveProgBtn
    mainFrame.UpdateProgressionInfo = UpdateProgressionInfo
end
