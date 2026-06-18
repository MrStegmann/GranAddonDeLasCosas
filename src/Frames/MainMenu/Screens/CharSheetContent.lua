local addonName, GAC = ...

function GAC:CreateCharSheetContent(parent)
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
    
    local function UpdateHeaderInfoText()
        if not GAC.characterData then return end
        
        local prog = GAC.characterData.progress or {}
        local levelStr = prog.level or 1
        if type(levelStr) ~= "number" or levelStr < 1 then levelStr = 1 end
        
        local rawCat = prog.category or "normal"
        local catStr = GAC:_(rawCat) or rawCat:gsub("^%l", string.upper)
        
        local classStr = GAC:GetActiveTRP3ProfileClass() or "Desconocida"
        local raceStr = GAC:GetActiveTRP3ProfileRace() or "Desconocida"
        
        local chars = GAC.characterData.characteristics
        if chars then
            local r1 = chars.race1 or "Ninguna"
            local r2 = chars.race2 or "Ninguna"
            
            if r1 ~= "Ninguna" and r2 ~= "Ninguna" then
                raceStr = string.format("Mestizo (%s y %s)", GAC:_(r1) or r1, GAC:_(r2) or r2)
            elseif r1 ~= "Ninguna" then
                raceStr = GAC:_(r1) or r1
            end
        end
        
        local cl = RAID_CLASS_COLORS[select(2, UnitClass("player"))] or {r=1, g=1, b=1}
        infoText:SetTextColor(cl.r, cl.g, cl.b)
        infoText:SetText(string.format("Nivel %d (%s) - %s - %s", levelStr, catStr, raceStr, classStr))
    end
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

    -------------------------------------------------
    -- TAB 1: CARACTERÍSTICAS
    -------------------------------------------------
    local characteristicsScroll = CreateFrame("ScrollFrame", "GAC_CharacteristicsScroll", tab1, "UIPanelScrollFrameTemplate")
    characteristicsScroll:SetPoint("TOPLEFT", tab1, "TOPLEFT", 4, -4)
    characteristicsScroll:SetPoint("BOTTOMRIGHT", tab1, "BOTTOMRIGHT", -28, 4)

    local characteristicsBg = CreateFrame("Frame", nil, characteristicsScroll, "BackdropTemplate")
    characteristicsBg:SetSize(400, 500)
    characteristicsScroll:SetScrollChild(characteristicsBg)

    characteristicsScroll:SetScript("OnSizeChanged", function(self, width, height)
        characteristicsBg:SetWidth(width)
    end)

    characteristicsBg:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    characteristicsBg:SetBackdropColor(0, 0, 0, 0.3)
    characteristicsBg:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)

    local raceLabel1 = GAC:CreateFontString(characteristicsBg, "Raza Principal:", "GameFontNormal", { "TOPLEFT", 15, -20 }, {1, 1, 1})
    local raceDrop1 = CreateFrame("Frame", "GAC_CharSheetRaceDrop1", characteristicsBg, "UIDropDownMenuTemplate")
    raceDrop1:SetPoint("TOPLEFT", raceLabel1, "BOTTOMLEFT", -15, -5)
    UIDropDownMenu_SetWidth(raceDrop1, 150)

    local raceLabel2 = GAC:CreateFontString(characteristicsBg, "Raza Secundaria:", "GameFontNormal", { "TOPLEFT", 220, -20 }, {1, 1, 1})
    local raceDrop2 = CreateFrame("Frame", "GAC_CharSheetRaceDrop2", characteristicsBg, "UIDropDownMenuTemplate")
    raceDrop2:SetPoint("TOPLEFT", raceLabel2, "BOTTOMLEFT", -15, -5)
    UIDropDownMenu_SetWidth(raceDrop2, 150)



    GAC.characterData.characteristics = GAC.characterData.characteristics or {}
    local currentRace1 = GAC.characterData.characteristics.race1 or "Ninguna"
    local currentRace2 = GAC.characterData.characteristics.race2 or "Ninguna"

    local saveCharBtn = CreateFrame("Button", nil, characteristicsBg, "UIPanelButtonTemplate")
    saveCharBtn:SetSize(140, 26)
    saveCharBtn:SetPoint("BOTTOMRIGHT", -10, 10)
    saveCharBtn:SetText("Guardar Cambios")
    saveCharBtn:Hide()

    local function CreateRaceSummary(anchorFrame)
        local f = CreateFrame("Frame", nil, characteristicsBg)
        f:SetSize(190, 80)
        f:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT", 15, -15)
        
        f.advLabel = GAC:CreateFontString(f, "Ventajas", "GameFontNormalSmall", { "TOPLEFT", 0, 0 }, {0.2, 1, 0.2})
        f.advText = GAC:CreateFontString(f, "", "GameFontHighlightSmall", { "TOPLEFT", f.advLabel, "BOTTOMLEFT", 0, -2 }, {1, 1, 1})
        f.advText:SetWidth(90)
        f.advText:SetJustifyH("LEFT")
        f.advText:SetJustifyV("TOP")
        
        f.disLabel = GAC:CreateFontString(f, "Desventajas", "GameFontNormalSmall", { "TOPLEFT", 100, 0 }, {1, 0.2, 0.2})
        f.disText = GAC:CreateFontString(f, "", "GameFontHighlightSmall", { "TOPLEFT", f.disLabel, "BOTTOMLEFT", 0, -2 }, {1, 1, 1})
        f.disText:SetWidth(90)
        f.disText:SetJustifyH("LEFT")
        f.disText:SetJustifyV("TOP")
        
        f.specLabel = GAC:CreateFontString(f, "Especial", "GameFontNormalSmall", { "TOPLEFT", 0, -60 }, {1, 0.8, 0})
        f.specText = GAC:CreateFontString(f, "", "GameFontHighlightSmall", { "TOPLEFT", f.specLabel, "BOTTOMLEFT", 0, -2 }, {1, 1, 1})
        f.specText:SetWidth(190)
        f.specText:SetJustifyH("LEFT")
        f.specText:SetJustifyV("TOP")

        f:Hide()
        return f
    end

    local summary1 = CreateRaceSummary(raceDrop1)
    local summary2 = CreateRaceSummary(raceDrop2)
    
    local mestizoBuilderFrame = CreateFrame("Frame", nil, characteristicsBg)
    mestizoBuilderFrame:SetPoint("TOPLEFT", raceDrop1, "BOTTOMLEFT", 15, -15)
    mestizoBuilderFrame:SetPoint("TOPRIGHT", raceDrop2, "BOTTOMRIGHT", -15, -15)
    mestizoBuilderFrame:SetHeight(150)
    mestizoBuilderFrame:Hide()

    local mestizoAdvTitle = GAC:CreateFontString(mestizoBuilderFrame, "Ventajas (0/3)", "GameFontNormalSmall", { "TOPLEFT", 0, 0 }, {0.2, 1, 0.2})
    local mestizoDisTitle = GAC:CreateFontString(mestizoBuilderFrame, "Desventajas (0/3)", "GameFontNormalSmall", { "TOPLEFT", 190, 0 }, {1, 0.2, 0.2})
    
    local mestizoAdvContainer = CreateFrame("Frame", nil, mestizoBuilderFrame)
    mestizoAdvContainer:SetPoint("TOPLEFT", mestizoAdvTitle, "BOTTOMLEFT", 0, -10)
    mestizoAdvContainer:SetSize(180, 100)

    local mestizoDisContainer = CreateFrame("Frame", nil, mestizoBuilderFrame)
    mestizoDisContainer:SetPoint("TOPLEFT", mestizoDisTitle, "BOTTOMLEFT", 0, -10)
    mestizoDisContainer:SetSize(180, 100)
    
    local mestizoSpecLabel = GAC:CreateFontString(mestizoBuilderFrame, "Especial Combinado", "GameFontNormalSmall", { "TOPLEFT", mestizoAdvContainer, "BOTTOMLEFT", 0, -15 }, {1, 0.8, 0})
    local mestizoSpecText = GAC:CreateFontString(mestizoBuilderFrame, "", "GameFontHighlightSmall", { "TOPLEFT", mestizoSpecLabel, "BOTTOMLEFT", 0, -2 }, {1, 1, 1})
    mestizoSpecText:SetWidth(380)
    mestizoSpecText:SetJustifyH("LEFT")
    mestizoSpecText:SetJustifyV("TOP")
    
    local mestizoCheckboxes = {}
    local function GetMestizoCheckbox(index, parent)
        if not mestizoCheckboxes[index] then
            local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
            cb:SetSize(20, 20)
            cb.label = GAC:CreateFontString(cb, "", "GameFontHighlightSmall", { "LEFT", cb, "RIGHT", 5, 0 }, {1, 1, 1})
            mestizoCheckboxes[index] = cb
        end
        mestizoCheckboxes[index]:SetParent(parent)
        return mestizoCheckboxes[index]
    end

    local function ParseStatValue(statString)
        local val = statString:match("([%+%-]%d+)")
        return val and tonumber(val) or 0
    end

    local function FormatRacialStatList(list)
        if type(list) == "table" then
            local t = {}
            if #list > 0 then
                for _, v in ipairs(list) do
                    table.insert(t, GAC:_(v) or v)
                end
            else
                local hasElements = false
                local sortedKeys = {}
                for k in pairs(list) do table.insert(sortedKeys, k) end
                table.sort(sortedKeys)
                
                for _, k in ipairs(sortedKeys) do
                    local v = list[k]
                    hasElements = true
                    local sign = v > 0 and "+" or ""
                    local suffix = ""
                    if k == "adaptability" and GAC.characterData and GAC.characterData.characteristics and GAC.characterData.characteristics.adaptTarget then
                        suffix = " (" .. (GAC:_(GAC.characterData.characteristics.adaptTarget) or GAC.characterData.characteristics.adaptTarget) .. ")"
                    elseif k == "perfectionism" and GAC.characterData and GAC.characterData.characteristics and GAC.characterData.characteristics.perfTarget then
                        suffix = " (" .. (GAC:_(GAC.characterData.characteristics.perfTarget) or GAC.characterData.characteristics.perfTarget) .. ")"
                    end
                    table.insert(t, sign .. v .. " " .. (GAC:_(k) or k) .. suffix)
                end
                if not hasElements then return "Ninguna" end
            end
            return table.concat(t, ", ")
        end
        return "Ninguna"
    end

    local function UpdateRaceSummary(summaryFrame, raceName)
        if raceName == "Ninguna" then
            summaryFrame:Hide()
            return
        end
        local data = GAC:GetRaceData(raceName)
        if not data then
            summaryFrame:Hide()
            return
        end
        
        summaryFrame:Show()
        summaryFrame.advText:SetText(FormatRacialStatList(data.advantages))
        summaryFrame.disText:SetText(FormatRacialStatList(data.disadvantages))
        summaryFrame.specText:SetText(FormatRacialStatList(data.special))
        
        if not data.special or #data.special == 0 then
            summaryFrame.specLabel:Hide()
            summaryFrame.specText:Hide()
        else
            summaryFrame.specLabel:Show()
            summaryFrame.specText:Show()
        end
    end

    local adaptLabel = GAC:CreateFontString(characteristicsBg, "Mejora Adaptabilidad:", "GameFontNormal", { "TOPLEFT", characteristicsBg, "TOPLEFT", 15, -160 }, {1, 1, 1})
    local adaptDrop = CreateFrame("Frame", "GAC_CharSheetAdaptDrop", characteristicsBg, "UIDropDownMenuTemplate")
    adaptDrop:SetPoint("TOPLEFT", adaptLabel, "BOTTOMLEFT", -15, -5)
    UIDropDownMenu_SetWidth(adaptDrop, 150)
    adaptLabel:Hide()
    adaptDrop:Hide()

    local perfLabel = GAC:CreateFontString(characteristicsBg, "Mejora Perfeccionismo:", "GameFontNormal", { "TOPLEFT", characteristicsBg, "TOPLEFT", 220, -160 }, {1, 1, 1})
    local perfDrop = CreateFrame("Frame", "GAC_CharSheetPerfDrop", characteristicsBg, "UIDropDownMenuTemplate")
    perfDrop:SetPoint("TOPLEFT", perfLabel, "BOTTOMLEFT", -15, -5)
    UIDropDownMenu_SetWidth(perfDrop, 150)
    perfLabel:Hide()
    perfDrop:Hide()

    local worgenCurseCheckbox = CreateFrame("CheckButton", nil, characteristicsBg, "UICheckButtonTemplate")
    worgenCurseCheckbox:SetPoint("TOPLEFT", characteristicsBg, "TOPLEFT", 20, -210)
    
    local worgenCurseLabel = GAC:CreateFontString(characteristicsBg, "Maldición Huargen", "GameFontHighlight", { "LEFT", worgenCurseCheckbox, "RIGHT", 5, 0 }, {1, 1, 1})

    worgenCurseCheckbox:SetScript("OnClick", function(self)
        if not GAC.characterData then return end
        GAC.characterData.isWorgenCurse = self:GetChecked()
    end)
    
    local function RefreshMestizoBuilder()
        for _, cb in pairs(mestizoCheckboxes) do cb:Hide() end
        if currentRace1 == "Ninguna" or currentRace2 == "Ninguna" then return end
        
        local data1 = GAC:GetRaceData(currentRace1)
        local data2 = GAC:GetRaceData(currentRace2)
        if not data1 or not data2 then return end

        local allAdv = {}
        local allDis = {}
        local allSpec = {}
        
        local function AddToDict(targetDict, sourceDict)
            if not sourceDict then return end
            for k, v in pairs(sourceDict) do
                targetDict[k] = v
            end
        end
        
        local function AddToList(targetList, sourceList)
            if not sourceList then return end
            for _, v in ipairs(sourceList) do
                if not tContains(targetList, v) then table.insert(targetList, v) end
            end
        end

        AddToDict(allAdv, data1.advantages)
        AddToDict(allAdv, data2.advantages)
        AddToDict(allDis, data1.disadvantages)
        AddToDict(allDis, data2.disadvantages)
        AddToList(allSpec, data1.special)
        AddToList(allSpec, data2.special)
        
        GAC.characterData.characteristics.mestizoTraits = GAC.characterData.characteristics.mestizoTraits or {}
        -- Limpiar traits que ya no estén en allAdv o allDis
        for k in pairs(GAC.characterData.characteristics.mestizoTraits) do
            if not allAdv[k] and not allDis[k] then
                GAC.characterData.characteristics.mestizoTraits[k] = nil
            end
        end
        
        local mestizoTraits = GAC.characterData.characteristics.mestizoTraits
        
        local currentAdvSum = 0
        local currentDisSum = 0
        
        for k, v in pairs(mestizoTraits) do
            if allAdv[k] then
                currentAdvSum = currentAdvSum + math.abs(v)
            elseif allDis[k] then
                currentDisSum = currentDisSum + math.abs(v)
            end
        end
        
        mestizoAdvTitle:SetText(string.format("Ventajas (%d/3)", currentAdvSum))
        mestizoDisTitle:SetText(string.format("Desventajas (%d/3)", currentDisSum))

        local cbIndex = 1
        local function RenderDict(dict, container, currentSum)
            local yOffset = 0
            local sortedKeys = {}
            for k in pairs(dict) do table.insert(sortedKeys, k) end
            table.sort(sortedKeys)
            
            for _, k in ipairs(sortedKeys) do
                local v = dict[k]
                local cb = GetMestizoCheckbox(cbIndex, container)
                cbIndex = cbIndex + 1
                cb:SetPoint("TOPLEFT", 0, yOffset)
                cb:Show()
                
                local sign = v > 0 and "+" or ""
                cb.label:SetText(sign .. v .. " " .. (GAC:_(k) or k))
                
                local traitVal = math.abs(v)
                local isChecked = (mestizoTraits[k] ~= nil)
                cb:SetChecked(isChecked)
                
                if not isChecked and (currentSum + traitVal > 3) then
                    cb:Disable()
                    cb.label:SetTextColor(0.5, 0.5, 0.5)
                else
                    cb:Enable()
                    cb.label:SetTextColor(1, 1, 1)
                end
                
                cb:SetScript("OnClick", function(self)
                    if self:GetChecked() then
                        mestizoTraits[k] = v
                    else
                        mestizoTraits[k] = nil
                    end
                    saveCharBtn:Show()
                    RefreshMestizoBuilder()
                end)
                yOffset = yOffset - 25
            end
            return yOffset
        end
        
        local advHeight = math.abs(RenderDict(allAdv, mestizoAdvContainer, currentAdvSum))
        local disHeight = math.abs(RenderDict(allDis, mestizoDisContainer, currentDisSum))
        
        local maxListHeight = math.max(advHeight, disHeight)
        mestizoAdvContainer:SetHeight(maxListHeight)
        mestizoDisContainer:SetHeight(maxListHeight)
        
        mestizoSpecLabel:SetPoint("TOPLEFT", mestizoAdvContainer, "BOTTOMLEFT", 0, -15)
        
        if #allSpec > 0 then
            mestizoSpecLabel:Show()
            mestizoSpecText:Show()
            local t = {}
            for _, v in ipairs(allSpec) do table.insert(t, GAC:_(v) or v) end
            mestizoSpecText:SetText(table.concat(t, "\n"))
            mestizoBuilderFrame:SetHeight(maxListHeight + 40 + mestizoSpecText:GetHeight())
        else
            mestizoSpecLabel:Hide()
            mestizoSpecText:Hide()
            mestizoBuilderFrame:SetHeight(maxListHeight + 30)
        end
    end

    local function UpdateDynamicLayout()
        local relativeFrame
        local baseOffset = -20
        if currentRace2 ~= "Ninguna" then
            summary1:Hide()
            summary2:Hide()
            mestizoBuilderFrame:Show()
            RefreshMestizoBuilder()
            relativeFrame = mestizoBuilderFrame
        else
            mestizoBuilderFrame:Hide()
            if currentRace1 ~= "Ninguna" then
                UpdateRaceSummary(summary1, currentRace1)
                relativeFrame = summary1
            else
                UpdateRaceSummary(summary1, "Ninguna")
                relativeFrame = raceDrop1
                baseOffset = -15
            end
            UpdateRaceSummary(summary2, "Ninguna")
        end
        
        adaptLabel:SetPoint("TOPLEFT", relativeFrame, "BOTTOMLEFT", 0, baseOffset)
        perfLabel:SetPoint("TOPLEFT", relativeFrame, "BOTTOMLEFT", 205, baseOffset)
        worgenCurseCheckbox:SetPoint("TOPLEFT", adaptDrop, "BOTTOMLEFT", 5, -20)
        
        local function UpdateScrollHeight()
            if not characteristicsBg:GetTop() or not worgenCurseCheckbox:GetBottom() then
                C_Timer.After(0.05, UpdateScrollHeight)
                return
            end
            local neededHeight = characteristicsBg:GetTop() - worgenCurseCheckbox:GetBottom() + 30
            characteristicsBg:SetHeight(math.max(neededHeight, characteristicsScroll:GetHeight()))
        end
        UpdateScrollHeight()
    end

    local function EvaluateDynamicRacialBonuses()
        if not GAC.characterData then return end
        local isHuman = (currentRace1 == "human" or currentRace2 == "human")
        local isGnome = (currentRace1 == "gnome" or currentRace2 == "gnome")
        
        local talents = GAC.characterData.talents or {}
        
        if isHuman then
            if GAC.characterData.characteristics.adaptLocked and GAC.characterData.characteristics.adaptTarget then
                adaptLabel:Hide()
                adaptDrop:Hide()
            else
                local minVal = math.huge
                local adaptCandidates = {}
                for k, v in pairs(talents) do
                    local val = tonumber(v) or 0
                    if val > 0 then
                        if val < minVal then
                            minVal = val
                            adaptCandidates = {k}
                        elseif val == minVal then
                            table.insert(adaptCandidates, k)
                        end
                    end
                end
                if #adaptCandidates == 0 then
                    for k, v in pairs(talents) do
                        table.insert(adaptCandidates, k)
                    end
                end
                
                if #adaptCandidates == 1 then
                    GAC.characterData.characteristics.adaptTarget = adaptCandidates[1]
                    adaptLabel:Hide()
                    adaptDrop:Hide()
                else
                    adaptLabel:Show()
                    adaptDrop:Show()
                    UIDropDownMenu_Initialize(adaptDrop, function(self, level, menuList)
                        for _, cand in ipairs(adaptCandidates) do
                            local info = UIDropDownMenu_CreateInfo()
                            info.text = GAC:_(cand) or cand
                            info.func = function()
                                GAC.characterData.characteristics.adaptTarget = cand
                                UIDropDownMenu_SetText(adaptDrop, info.text)
                                saveCharBtn:Show()
                                UpdateRaceSummary(summary1, currentRace1)
                                UpdateRaceSummary(summary2, currentRace2)
                            end
                            UIDropDownMenu_AddButton(info)
                        end
                    end)
                    local currentTarget = GAC.characterData.characteristics.adaptTarget
                    if currentTarget and tContains(adaptCandidates, currentTarget) then
                        UIDropDownMenu_SetText(adaptDrop, GAC:_(currentTarget) or currentTarget)
                    else
                        UIDropDownMenu_SetText(adaptDrop, "Elige un talento...")
                    end
                end
            end
        else
            adaptLabel:Hide()
            adaptDrop:Hide()
            GAC.characterData.characteristics.adaptTarget = nil
            GAC.characterData.characteristics.adaptLocked = false
        end

        if isGnome then
            if GAC.characterData.characteristics.perfLocked and GAC.characterData.characteristics.perfTarget then
                perfLabel:Hide()
                perfDrop:Hide()
            else
                local maxVal = -1
                local perfCandidates = {}
                for k, v in pairs(talents) do
                    local val = tonumber(v) or 0
                    if val > maxVal then
                        maxVal = val
                        perfCandidates = {k}
                    elseif val == maxVal then
                        table.insert(perfCandidates, k)
                    end
                end
                
                if #perfCandidates == 1 then
                    GAC.characterData.characteristics.perfTarget = perfCandidates[1]
                    perfLabel:Hide()
                    perfDrop:Hide()
                else
                    perfLabel:Show()
                    perfDrop:Show()
                    UIDropDownMenu_Initialize(perfDrop, function(self, level, menuList)
                        for _, cand in ipairs(perfCandidates) do
                            local info = UIDropDownMenu_CreateInfo()
                            info.text = GAC:_(cand) or cand
                            info.func = function()
                                GAC.characterData.characteristics.perfTarget = cand
                                UIDropDownMenu_SetText(perfDrop, info.text)
                                saveCharBtn:Show()
                                UpdateRaceSummary(summary1, currentRace1)
                                UpdateRaceSummary(summary2, currentRace2)
                            end
                            UIDropDownMenu_AddButton(info)
                        end
                    end)
                    local currentTarget = GAC.characterData.characteristics.perfTarget
                    if currentTarget and tContains(perfCandidates, currentTarget) then
                        UIDropDownMenu_SetText(perfDrop, GAC:_(currentTarget) or currentTarget)
                    else
                        UIDropDownMenu_SetText(perfDrop, "Elige un talento...")
                    end
                end
            end
        else
            perfLabel:Hide()
            perfDrop:Hide()
            GAC.characterData.characteristics.perfTarget = nil
            GAC.characterData.characteristics.perfLocked = false
        end
        
        UpdateDynamicLayout()
    end

    saveCharBtn:SetScript("OnClick", function()
        saveCharBtn:Hide()
        GAC.characterData.characteristics.race1 = currentRace1
        GAC.characterData.characteristics.race2 = currentRace2
        
        GAC.characterData.characteristics.adaptLocked = true
        GAC.characterData.characteristics.perfLocked = true
        
        local success, err = pcall(function()
            if currentRace2 == "Ninguna" and currentRace1 ~= "Ninguna" then
                local data = GAC:GetRaceData(currentRace1)
                if data then
                    GAC.characterData.characteristics.activeAdvantages = data.advantages
                    GAC.characterData.characteristics.activeDisadvantages = data.disadvantages
                    GAC.characterData.characteristics.activeSpecial = data.special
                end
            elseif currentRace1 ~= "Ninguna" and currentRace2 ~= "Ninguna" then
                local data1 = GAC:GetRaceData(currentRace1)
                local data2 = GAC:GetRaceData(currentRace2)
                local allSpec = {}
                if data1 and data1.special then for _,v in ipairs(data1.special) do table.insert(allSpec, v) end end
                if data2 and data2.special then for _,v in ipairs(data2.special) do if not tContains(allSpec, v) then table.insert(allSpec, v) end end end
                
                local mestizoTraits = GAC.characterData.characteristics.mestizoTraits or {}
                local allAdv = {}
                local allDis = {}
                if data1 then
                    if data1.advantages then for k, v in pairs(data1.advantages) do allAdv[k] = v end end
                    if data1.disadvantages then for k, v in pairs(data1.disadvantages) do allDis[k] = v end end
                end
                if data2 then
                    if data2.advantages then for k, v in pairs(data2.advantages) do allAdv[k] = v end end
                    if data2.disadvantages then for k, v in pairs(data2.disadvantages) do allDis[k] = v end end
                end
                
                local activeAdv = {}
                local activeDis = {}
                for k, v in pairs(mestizoTraits) do
                    if allAdv[k] then activeAdv[k] = v end
                    if allDis[k] then activeDis[k] = v end
                end
                
                GAC.characterData.characteristics.activeAdvantages = activeAdv
                GAC.characterData.characteristics.activeDisadvantages = activeDis
                GAC.characterData.characteristics.activeSpecial = allSpec
            else
                GAC.characterData.characteristics.activeAdvantages = nil
                GAC.characterData.characteristics.activeDisadvantages = nil
                GAC.characterData.characteristics.activeSpecial = nil
            end
        end)
        
        UpdateHeaderInfoText()
        EvaluateDynamicRacialBonuses()
        print("|cFF40C7EB[GAC]|r: Características guardadas correctamente.")
    end)

    local function InitializeRaceDropdown(dropdown, isSecond)
        UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
            local info = UIDropDownMenu_CreateInfo()
            info.text = "Ninguna"
            info.func = function()
                if isSecond then
                    if currentRace2 ~= "Ninguna" then saveCharBtn:Show() end
                    currentRace2 = "Ninguna"
                    UpdateDynamicLayout()
                else
                    if currentRace1 ~= "Ninguna" then saveCharBtn:Show() end
                    currentRace1 = "Ninguna"
                    currentRace2 = "Ninguna"
                    UIDropDownMenu_SetText(raceDrop2, "Ninguna")
                    UIDropDownMenu_DisableDropDown(raceDrop2)
                    UpdateDynamicLayout()
                end
                UIDropDownMenu_SetText(dropdown, info.text)
            end
            UIDropDownMenu_AddButton(info)

            local currentRaces = GAC:GetFlatRaces()
            for _, raceName in ipairs(currentRaces) do
                local infoRace = UIDropDownMenu_CreateInfo()
                infoRace.text = GAC:_(raceName) or raceName
                infoRace.func = function()
                    if isSecond then
                        if currentRace2 ~= raceName then saveCharBtn:Show() end
                        currentRace2 = raceName
                        UpdateDynamicLayout()
                    else
                        if currentRace1 ~= raceName then saveCharBtn:Show() end
                        currentRace1 = raceName
                        UIDropDownMenu_EnableDropDown(raceDrop2)
                        UpdateDynamicLayout()
                    end
                    UIDropDownMenu_SetText(dropdown, infoRace.text)
                    
                    EvaluateDynamicRacialBonuses()
                end
                UIDropDownMenu_AddButton(infoRace)
            end
        end)
    end

    InitializeRaceDropdown(raceDrop1, false)
    UIDropDownMenu_SetText(raceDrop1, GAC:_(currentRace1) or currentRace1)
    
    InitializeRaceDropdown(raceDrop2, true)
    UIDropDownMenu_SetText(raceDrop2, GAC:_(currentRace2) or currentRace2)
    
    UpdateDynamicLayout()

    if currentRace1 == "Ninguna" then
        UIDropDownMenu_DisableDropDown(raceDrop2)
    end
    
    EvaluateDynamicRacialBonuses()

    tab1:SetScript("OnShow", function()
        if GAC.characterData then
            worgenCurseCheckbox:SetChecked(GAC.characterData.isWorgenCurse or false)
            EvaluateDynamicRacialBonuses()
        end
    end)

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

    local progTitle = GAC:CreateFontString(progBg, "Información de Nivel Disponible", "GameFontNormalLarge", { "TOPLEFT", 15, -15 }, { 0.25, 0.78, 0.94 })

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
        if frame.Update then frame:Update() end
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

    return frame
end
