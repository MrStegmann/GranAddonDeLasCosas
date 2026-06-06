local addonName, GAC = ...

function GAC:CreateNewCharMenu()
    if self.newCharMenuFrame then return end

    local frame = CreateFrame("Frame", "GACNewCharMenuFrame", UIParent, "BackdropTemplate")
    frame:Hide()
    frame:SetSize(600, 500)
    frame:SetPoint("CENTER")
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
    frame:SetBackdropBorderColor(0.94, 0.78, 0.25, 0.8)

    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4)

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -18)
    title:SetText("CREACIÓN DE PERSONAJE - PASO 1")
    title:SetTextColor(0.94, 0.78, 0.25)

    local line = frame:CreateTexture(nil, "ARTWORK")
    line:SetSize(frame:GetWidth() - 24, 1)
    line:SetPoint("TOP", 0, -45)
    line:SetColorTexture(1, 1, 1, 0.1)

    frame.state = {
        category = "normal",
        race1 = nil,
        race2 = nil,
        advPoints = 0,
        disPoints = 0,
        allocatedAttributes = {},
        allocatedTalents = {},
        positiveTraits = {},
        positiveTraitsTalents = {}
    }

    local content = CreateFrame("Frame", nil, frame)
    content:SetPoint("TOPLEFT", 15, -55)
    content:SetPoint("BOTTOMRIGHT", -15, 15)

    -- Categoria
    local catLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    catLabel:SetPoint("TOPLEFT", 10, -10)
    catLabel:SetText("Categoría Inicial:")
    
    local catDrop = CreateFrame("Frame", "GAC_NewCharCatDrop", content, "UIDropDownMenuTemplate")
    catDrop:SetPoint("TOPLEFT", catLabel, "BOTTOMLEFT", -15, -5)
    UIDropDownMenu_SetWidth(catDrop, 120)

    -- Raza 1
    local r1Label = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    r1Label:SetPoint("TOPLEFT", 200, -10)
    r1Label:SetText("Raza Principal (Obligatorio):")
    
    local r1Drop = CreateFrame("Frame", "GAC_NewCharR1Drop", content, "UIDropDownMenuTemplate")
    r1Drop:SetPoint("TOPLEFT", r1Label, "BOTTOMLEFT", -15, -5)
    UIDropDownMenu_SetWidth(r1Drop, 120)

    -- Raza 2
    local r2Label = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    r2Label:SetPoint("TOPLEFT", 390, -10)
    r2Label:SetText("Raza Secundaria (Opcional):")
    
    local r2Drop = CreateFrame("Frame", "GAC_NewCharR2Drop", content, "UIDropDownMenuTemplate")
    r2Drop:SetPoint("TOPLEFT", r2Label, "BOTTOMLEFT", -15, -5)
    UIDropDownMenu_SetWidth(r2Drop, 120)

    -- Mestizo Area
    local mestizoFrame = CreateFrame("Frame", nil, content, "BackdropTemplate")
    mestizoFrame:SetPoint("TOPLEFT", 10, -80)
    mestizoFrame:SetPoint("BOTTOMRIGHT", -10, 50)
    mestizoFrame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12,
    })
    mestizoFrame:SetBackdropColor(0, 0, 0, 0.4)
    mestizoFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.6)
    mestizoFrame:Hide()

    local mTitle = mestizoFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    mTitle:SetPoint("TOP", 0, -15)
    mTitle:SetText("Selección de Rasgos de Mestizo")

    local advLabel = mestizoFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    advLabel:SetPoint("TOPLEFT", 30, -50)
    advLabel:SetText("Ventajas (0 / 3)")

    local disLabel = mestizoFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    disLabel:SetPoint("TOPRIGHT", -100, -50)
    disLabel:SetText("Desventajas (0 / -3)")

    local advContainer = CreateFrame("Frame", nil, mestizoFrame)
    advContainer:SetPoint("TOPLEFT", 30, -70)
    advContainer:SetSize(250, 200)

    local disContainer = CreateFrame("Frame", nil, mestizoFrame)
    disContainer:SetPoint("TOPRIGHT", -30, -70)
    disContainer:SetSize(250, 200)

    local nextBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    nextBtn:SetSize(120, 30)
    nextBtn:SetPoint("BOTTOM", 0, 15)
    nextBtn:SetText("Siguiente")
    nextBtn:Disable()

    frame.UpdateNextButton = function()
        if GAC:IsStep1Valid(frame.state) then
            nextBtn:Enable()
        else
            nextBtn:Disable()
        end
    end

    local checkboxes = {}

    local function ClearMestizoUI()
        for _, cb in ipairs(checkboxes) do
            cb:Hide()
        end
        wipe(checkboxes)
        wipe(frame.state.selectedTalents)
        frame.state.advPoints = 0
        frame.state.disPoints = 0
        advLabel:SetText("Ventajas (0 / 3)")
        disLabel:SetText("Desventajas (0 / -3)")
        frame.UpdateNextButton()
    end

    local function CreateTalentCheckbox(parent, talent, value, isAdvantage, yOffset)
        local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
        cb:SetPoint("TOPLEFT", 0, yOffset)
        cb:SetSize(24, 24)
        
        local text = cb:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("LEFT", cb, "RIGHT", 5, 0)
        local localizedName = GAC:_(talent) or talent
        text:SetText(localizedName .. " (" .. (value > 0 and "+" or "") .. value .. ")")
        
        cb:SetScript("OnClick", function(self)
            local isChecked = self:GetChecked()
            if isChecked then
                if isAdvantage then
                    if frame.state.advPoints + value > 3 then
                        self:SetChecked(false)
                        return
                    end
                    frame.state.advPoints = frame.state.advPoints + value
                else
                    if frame.state.disPoints + value < -3 then
                        self:SetChecked(false)
                        return
                    end
                    frame.state.disPoints = frame.state.disPoints + value
                end
                frame.state.selectedTalents[talent] = value
            else
                if isAdvantage then
                    frame.state.advPoints = frame.state.advPoints - value
                else
                    frame.state.disPoints = frame.state.disPoints - value
                end
                frame.state.selectedTalents[talent] = nil
            end
            
            advLabel:SetText("Ventajas (" .. frame.state.advPoints .. " / 3)")
            disLabel:SetText("Desventajas (" .. frame.state.disPoints .. " / -3)")
            frame.UpdateNextButton()
        end)
        
        table.insert(checkboxes, cb)
        return cb
    end

    local function BuildMestizoUI()
        ClearMestizoUI()
        if not frame.state.race2 then
            mestizoFrame:Hide()
            frame.UpdateNextButton()
            return
        end
        mestizoFrame:Show()
        
        local advTalents, disTalents = GAC:GetMestizoTalents(frame.state.race1, frame.state.race2)

        local advY = 0
        for t, v in pairs(advTalents) do
            CreateTalentCheckbox(advContainer, t, v, true, advY)
            advY = advY - 30
        end

        local disY = 0
        for t, v in pairs(disTalents) do
            CreateTalentCheckbox(disContainer, t, v, false, disY)
            disY = disY - 30
        end
    end

    UIDropDownMenu_Initialize(catDrop, function(self, level, menuList)
        local categories = {"noob", "normal"}
        for _, cat in ipairs(categories) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = GAC:_(cat)
            info.func = function() 
                frame.state.category = cat
                UIDropDownMenu_SetText(catDrop, info.text)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    UIDropDownMenu_SetText(catDrop, GAC:_("normal"))

    local function PopulateRaces(dropdown, isSecondary)
        UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
            if isSecondary then
                local info = UIDropDownMenu_CreateInfo()
                info.text = "Ninguna"
                info.func = function()
                    frame.state.race2 = nil
                    UIDropDownMenu_SetText(r2Drop, "Ninguna")
                    BuildMestizoUI()
                end
                UIDropDownMenu_AddButton(info)
            end

            if not GAC.racesTable then return end
            for raceKey, _ in pairs(GAC.racesTable) do
                if (isSecondary and raceKey ~= frame.state.race1) or (not isSecondary and raceKey ~= frame.state.race2) then
                    local info = UIDropDownMenu_CreateInfo()
                    info.text = GAC:_(raceKey)
                    info.func = function()
                        if isSecondary then
                            frame.state.race2 = raceKey
                            UIDropDownMenu_SetText(r2Drop, info.text)
                        else
                            frame.state.race1 = raceKey
                            UIDropDownMenu_SetText(r1Drop, info.text)
                            if frame.state.race1 == frame.state.race2 then
                                frame.state.race2 = nil
                                UIDropDownMenu_SetText(r2Drop, "Ninguna")
                            end
                        end
                        BuildMestizoUI()
                    end
                    UIDropDownMenu_AddButton(info)
                end
            end
        end)
    end

    PopulateRaces(r1Drop, false)
    PopulateRaces(r2Drop, true)
    UIDropDownMenu_SetText(r1Drop, "Seleccionar...")
    UIDropDownMenu_SetText(r2Drop, "Ninguna")

    local contentStep2 = CreateFrame("Frame", nil, frame)
    contentStep2:SetPoint("TOPLEFT", 15, -55)
    contentStep2:SetPoint("BOTTOMRIGHT", -15, 15)
    contentStep2:Hide()

    local step2Available = contentStep2:CreateFontString(nil, "OVERLAY", "GameFontHighlightHuge")
    step2Available:SetPoint("TOP", 0, -10)
    step2Available:SetText("Puntos Disponibles: 5")

    local step2Distributed = contentStep2:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    step2Distributed:SetPoint("TOP", 0, -35)
    step2Distributed:SetText("Totales: 5 | Repartidos: 0")

    local step2Line = contentStep2:CreateTexture(nil, "ARTWORK")
    step2Line:SetSize(frame:GetWidth() - 24, 1)
    step2Line:SetPoint("TOP", 0, -55)
    step2Line:SetColorTexture(1, 1, 1, 0.1)

    local scrollFrameS2 = CreateFrame("ScrollFrame", nil, contentStep2, "UIPanelScrollFrameTemplate")
    scrollFrameS2:SetPoint("TOPLEFT", 8, -65)
    scrollFrameS2:SetPoint("BOTTOMRIGHT", -28, 50)

    local s2Container = CreateFrame("Frame", nil, scrollFrameS2)
    s2Container:SetSize(400, 10)
    scrollFrameS2:SetScrollChild(s2Container)
    scrollFrameS2:SetScript("OnSizeChanged", function(self, width) s2Container:SetWidth(width) end)

    local finishBtn = CreateFrame("Button", nil, contentStep2, "UIPanelButtonTemplate")
    finishBtn:SetSize(120, 30)
    finishBtn:SetPoint("BOTTOM", 0, 15)
    finishBtn:SetText("Finalizar")

    local cardsCreated = false
    local attributeLabels = {}
    local talentLabels = {}
    local talentPointsLabels = {}



    local function RefreshStep2UI()
        local levelEntry = GAC:GetLevelEntry("normal", 1)
        local totalAttPoints = levelEntry and levelEntry.attPoints or 5
        local distributedAtt = GAC:GetTotalAllocatedAttributes(frame.state)
        local availableAtt = totalAttPoints - distributedAtt

        step2Available:SetText("Puntos Disponibles: " .. availableAtt)
        step2Distributed:SetText("Totales: " .. totalAttPoints .. " | Repartidos: " .. distributedAtt)

        for _, group in ipairs(GAC.attributeGroups) do
            local attrVal = frame.state.allocatedAttributes[group.name] or 0
            if attributeLabels[group.name] then
                attributeLabels[group.name]:SetText(tostring(attrVal))
            end

            local availableTalentPoints = attrVal * 2
            local spentTalentPoints = GAC:GetAllocatedTalentsInGroup(frame.state, group.name)

            if talentPointsLabels[group.name] then
                talentPointsLabels[group.name]:SetText("Puntos de talento: " .. spentTalentPoints .. " gastados / " .. availableTalentPoints .. " disponibles")
            end

            for _, talent in ipairs(group.talents) do
                local talVal = frame.state.allocatedTalents[talent] or 0
                if talentLabels[talent] then
                    talentLabels[talent]:SetText(tostring(talVal))
                end
            end
        end
    end

    local function CreateStatRow(parent, label, key, isTalent, groupName)
        local row = CreateFrame("Frame", nil, parent)
        row:SetPoint("LEFT", 5, 0)
        row:SetPoint("RIGHT", -5, 0)
        row:SetHeight(26)
        
        local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        name:SetPoint("LEFT", 5, 0)
        name:SetText(GAC:_(label) or label)

        local btnPlus = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        btnPlus:SetSize(20, 20)
        btnPlus:SetPoint("RIGHT", -5, 0)
        btnPlus:SetText("+")

        local valLabel = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        valLabel:SetPoint("RIGHT", btnPlus, "LEFT", -10, 0)
        valLabel:SetText("0")

        local btnMinus = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        btnMinus:SetSize(20, 20)
        btnMinus:SetPoint("RIGHT", valLabel, "LEFT", -10, 0)
        btnMinus:SetText("-")

        if isTalent then
            talentLabels[key] = valLabel
            btnPlus:SetScript("OnClick", function()
                local attrVal = frame.state.allocatedAttributes[groupName] or 0
                local availableTalentPoints = attrVal * 2
                local spentTalentPoints = GAC:GetAllocatedTalentsInGroup(frame.state, groupName)
                
                if spentTalentPoints < availableTalentPoints then
                    frame.state.allocatedTalents[key] = (frame.state.allocatedTalents[key] or 0) + 1
                    RefreshStep2UI()
                else
                    UIErrorsFrame:AddMessage("No tienes más puntos de talento disponibles en esta rama.", 1, 0, 0, 1)
                end
            end)
            btnMinus:SetScript("OnClick", function()
                local current = frame.state.allocatedTalents[key] or 0
                if current > 0 then
                    frame.state.allocatedTalents[key] = current - 1
                    RefreshStep2UI()
                end
            end)
        else
            attributeLabels[key] = valLabel
            btnPlus:SetScript("OnClick", function()
                local levelEntry = GAC:GetLevelEntry("normal", 1)
                local totalAttPoints = levelEntry and levelEntry.attPoints or 5
                local distributedAtt = GAC:GetTotalAllocatedAttributes(frame.state)
                
                if distributedAtt < totalAttPoints then
                    frame.state.allocatedAttributes[key] = (frame.state.allocatedAttributes[key] or 0) + 1
                    RefreshStep2UI()
                else
                    UIErrorsFrame:AddMessage("No tienes más puntos de atributo disponibles.", 1, 0, 0, 1)
                end
            end)
            btnMinus:SetScript("OnClick", function()
                local current = frame.state.allocatedAttributes[key] or 0
                if current > 0 then
                    local spentTalentPoints = GAC:GetAllocatedTalentsInGroup(frame.state, key)
                    local newAvailableTalentPoints = (current - 1) * 2
                    
                    if spentTalentPoints > newAvailableTalentPoints then
                        UIErrorsFrame:AddMessage("No puedes reducir este atributo porque ya has gastado sus puntos de talento.", 1, 0, 0, 1)
                    else
                        frame.state.allocatedAttributes[key] = current - 1
                        RefreshStep2UI()
                    end
                end
            end)
        end

        return row, name
    end

    local function BuildStep2Cards()
        if cardsCreated then return end
        if not GAC.attributeGroups then return end
        
        local currentY = -10

        for i, group in ipairs(GAC.attributeGroups) do
            local card = CreateFrame("Frame", nil, s2Container, "BackdropTemplate")
            card:SetBackdrop({
                bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12,
                insets = { left = 3, right = 3, top = 3, bottom = 3 },
            })
            card:SetBackdropColor(0, 0, 0, 0.5)
            card:SetBackdropBorderColor(0.94, 0.78, 0.25, 0.6)

            local headerBg = CreateFrame("Frame", nil, card)
            headerBg:SetPoint("TOPLEFT", 3, -3)
            headerBg:SetPoint("TOPRIGHT", -3, -3)
            headerBg:SetHeight(30)

            local attRow, nameLabel = CreateStatRow(headerBg, group.name, group.name, false, group.name)
            attRow:SetPoint("CENTER")
            nameLabel:SetFontObject("GameFontNormalLarge")
            nameLabel:SetTextColor(0.94, 0.78, 0.25)

            local talInfo = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            talInfo:SetPoint("TOPLEFT", 10, -35)
            talInfo:SetText("Puntos de talento: 0 gastados / 0 disponibles")
            talentPointsLabels[group.name] = talInfo

            local div = card:CreateTexture(nil, "ARTWORK")
            div:SetHeight(1)
            div:SetPoint("TOPLEFT", card, "TOPLEFT", 5, -50)
            div:SetPoint("TOPRIGHT", card, "TOPRIGHT", -5, -50)
            div:SetColorTexture(1, 1, 1, 0.1)

            local rowY = -55
            for _, talent in ipairs(group.talents) do
                local talRow = CreateStatRow(card, talent, talent, true, group.name)
                talRow:SetPoint("TOP", 0, rowY)
                rowY = rowY - 26
            end

            card:SetHeight(-rowY + 5)
            card:SetPoint("TOPLEFT", 10, currentY)
            card:SetPoint("TOPRIGHT", -10, currentY)
            
            currentY = currentY - card:GetHeight() - 10
        end

        s2Container:SetHeight((currentY * -1) + 20)
        cardsCreated = true
    end

    local contentStep3 = CreateFrame("Frame", nil, frame)
    contentStep3:SetPoint("TOPLEFT", 15, -55)
    contentStep3:SetPoint("BOTTOMRIGHT", -15, 15)
    contentStep3:Hide()

    local step3Title = contentStep3:CreateFontString(nil, "OVERLAY", "GameFontHighlightHuge")
    step3Title:SetPoint("TOP", 0, -10)
    step3Title:SetText("Rasgos Positivos: 0 / 0")

    local step3Line = contentStep3:CreateTexture(nil, "ARTWORK")
    step3Line:SetSize(frame:GetWidth() - 24, 1)
    step3Line:SetPoint("TOP", 0, -40)
    step3Line:SetColorTexture(1, 1, 1, 0.1)

    local scrollFrameS3 = CreateFrame("ScrollFrame", nil, contentStep3, "UIPanelScrollFrameTemplate")
    scrollFrameS3:SetPoint("TOPLEFT", 8, -50)
    scrollFrameS3:SetPoint("BOTTOMRIGHT", -28, 50)

    local s3Container = CreateFrame("Frame", nil, scrollFrameS3)
    s3Container:SetSize(400, 10)
    scrollFrameS3:SetScrollChild(s3Container)
    scrollFrameS3:SetScript("OnSizeChanged", function(self, width) s3Container:SetWidth(width) end)

    local finishBtnS3 = CreateFrame("Button", nil, contentStep3, "UIPanelButtonTemplate")
    finishBtnS3:SetSize(120, 30)
    finishBtnS3:SetPoint("BOTTOM", 0, 15)
    finishBtnS3:SetText("Finalizar")

    local s3TraitsCreated = false
    local traitCheckboxes = {}
    local traitDropdowns = {}

    local function RefreshStep3UI()
        local levelEntry = GAC:GetLevelEntry(frame.state.category, 1)
        local maxTraits = levelEntry and levelEntry.maxPositiveTraits or 0
        local currentTraits = 0
        for k, v in pairs(frame.state.positiveTraits) do
            if v > 0 then currentTraits = currentTraits + 1 end
        end

        step3Title:SetText("Rasgos Positivos: " .. currentTraits .. " / " .. maxTraits)

        for i, cb in ipairs(traitCheckboxes) do
            local traitName = cb.traitData.name
            local isChecked = (frame.state.positiveTraits[traitName] or 0) > 0
            cb:SetChecked(isChecked)
            
            if currentTraits >= maxTraits and not isChecked then
                cb:Disable()
            else
                cb:Enable()
            end
            
            if traitDropdowns[traitName] then
                if isChecked then
                    traitDropdowns[traitName]:Show()
                else
                    traitDropdowns[traitName]:Hide()
                end
            end
        end
    end

    local function BuildStep3Traits()
        if s3TraitsCreated then return end
        if not GAC.PositiveTraits then return end
        
        local currentY = -10

        for i, trait in ipairs(GAC.PositiveTraits) do
            local row = CreateFrame("Frame", nil, s3Container)
            row:SetPoint("TOPLEFT", 10, currentY)
            row:SetPoint("RIGHT", -10, currentY)
            row:SetHeight(30)

            local cb = CreateFrame("CheckButton", nil, row, "ChatConfigCheckButtonTemplate")
            cb:SetPoint("LEFT", 5, 0)
            cb.traitData = trait
            table.insert(traitCheckboxes, cb)

            local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            name:SetPoint("LEFT", cb, "RIGHT", 5, 0)
            name:SetText(trait.label)

            cb:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(trait.label, 0.94, 0.78, 0.25)
                GameTooltip:AddLine(trait.description, 1, 1, 1, true)
                if trait.levelOne and trait.levelOne ~= "" then
                    GameTooltip:AddLine("|cFF40C7EBNivel 1:|r " .. trait.levelOne, 1, 1, 1, true)
                end
                if trait.levelTwo and trait.levelTwo ~= "" then
                    GameTooltip:AddLine("|cFF40C7EBNivel 2:|r " .. trait.levelTwo, 1, 1, 1, true)
                end
                if trait.levelThree and trait.levelThree ~= "" then
                    GameTooltip:AddLine("|cFF40C7EBNivel 3:|r " .. trait.levelThree, 1, 1, 1, true)
                end
                GameTooltip:Show()
            end)
            cb:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

            cb:SetScript("OnClick", function(self)
                local levelEntry = GAC:GetLevelEntry(frame.state.category, 1)
                local maxT = levelEntry and levelEntry.maxPositiveTraits or 0
                local currentT = 0
                for k, v in pairs(frame.state.positiveTraits) do
                    if v > 0 then currentT = currentT + 1 end
                end

                if self:GetChecked() then
                    if currentT < maxT then
                        frame.state.positiveTraits[trait.name] = 1
                    else
                        self:SetChecked(false)
                        UIErrorsFrame:AddMessage("No puedes elegir más rasgos positivos.", 1, 0, 0, 1)
                    end
                else
                    frame.state.positiveTraits[trait.name] = nil
                    if frame.state.positiveTraitsTalents[trait.name] then
                        frame.state.positiveTraitsTalents[trait.name] = nil
                        if traitDropdowns[trait.name] then
                            UIDropDownMenu_SetText(traitDropdowns[trait.name], "Seleccionar...")
                        end
                    end
                end
                RefreshStep3UI()
            end)

            if trait.requiresTalentSelection then
                local drop = CreateFrame("Frame", "GAC_NewChar_TraitDrop_" .. trait.name, row, "UIDropDownMenuTemplate")
                drop:SetPoint("LEFT", name, "RIGHT", 10, 0)
                UIDropDownMenu_SetWidth(drop, 120)
                drop:Hide()
                traitDropdowns[trait.name] = drop
                
                UIDropDownMenu_Initialize(drop, function(self, level, menuList)
                    local options = {}
                    if trait.talentOptions then
                        options = trait.talentOptions
                    elseif trait.talentGroup then
                        for _, grp in ipairs(GAC.attributeGroups) do
                            if grp.name == trait.talentGroup then
                                options = grp.talents
                                break
                            end
                        end
                    else
                        -- Todos los talentos
                        for _, grp in ipairs(GAC.attributeGroups) do
                            for _, t in ipairs(grp.talents) do
                                table.insert(options, t)
                            end
                        end
                    end
                    
                    for _, t in ipairs(options) do
                        local info = UIDropDownMenu_CreateInfo()
                        info.text = GAC:_(t) or t
                        info.func = function()
                            frame.state.positiveTraitsTalents[trait.name] = t
                            UIDropDownMenu_SetText(drop, info.text)
                        end
                        UIDropDownMenu_AddButton(info)
                    end
                end)
                UIDropDownMenu_SetText(drop, "Seleccionar...")
            end

            currentY = currentY - 35
        end

        s3Container:SetHeight((currentY * -1) + 10)
        s3TraitsCreated = true
    end

    local function ProceedToStep3()
        print("|cFF40C7EBGAC:|r Procediendo al paso 3...")
        contentStep2:Hide()
        content:Hide()
        title:SetText("CREACIÓN DE PERSONAJE - PASO 3")
        contentStep3:Show()
        BuildStep3Traits()
        RefreshStep3UI()
    end

    local function FinalizeCreation()
        print("|cFF40C7EBGAC:|r Guardando y finalizando creación...")
        if not GAC.characterData then return end

        -- Comprobar si hay dropdowns sin seleccionar
        for traitName, isSelected in pairs(frame.state.positiveTraits) do
            if isSelected and traitDropdowns[traitName] and not frame.state.positiveTraitsTalents[traitName] then
                UIErrorsFrame:AddMessage("Debes seleccionar una opción para el rasgo " .. traitName, 1, 0, 0, 1)
                return
            end
        end

        GAC:ApplyRaceTalents(frame.state)
        GAC:SaveNewCharFinal(frame.state)

        frame:Hide()
        GAC:ToggleMainMenu()
        print("|cFF40C7EBGAC:|r Personaje creado con éxito.")
    end

    nextBtn:SetScript("OnClick", function()
        print("|cFF40C7EBGAC:|r Guardando opciones del paso 1...")
        if not GAC.characterData then return end
        
        GAC:SaveNewCharStep1(frame.state)

        local levelEntry = GAC:GetLevelEntry(frame.state.category, 1)
        local attPoints = levelEntry and levelEntry.attPoints or 0
        local maxT = levelEntry and levelEntry.maxPositiveTraits or 0

        if attPoints > 0 then
            print("|cFF40C7EBGAC:|r Procediendo al paso 2...")
            content:Hide()
            nextBtn:Hide()
            title:SetText("CREACIÓN DE PERSONAJE - PASO 2")
            contentStep2:Show()
            BuildStep2Cards()
            RefreshStep2UI()
            
            if maxT > 0 then
                finishBtn:SetText("Siguiente")
                finishBtn:SetScript("OnClick", function()
                    ProceedToStep3()
                end)
            else
                finishBtn:SetText("Finalizar")
                finishBtn:SetScript("OnClick", function()
                    FinalizeCreation()
                end)
            end
        elseif maxT > 0 then
            content:Hide()
            nextBtn:Hide()
            ProceedToStep3()
        else
            FinalizeCreation()
        end
    end)

    finishBtnS3:SetScript("OnClick", function()
        FinalizeCreation()
    end)

    self.newCharMenuFrame = frame
end

function GAC:ToggleNewCharMenu()
    self:CreateNewCharMenu()
    if self.newCharMenuFrame:IsShown() then
        self.newCharMenuFrame:Hide()
    else
        self.newCharMenuFrame:Show()
    end
end
