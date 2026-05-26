local addonName, addon = ...
local mainFrame = addon.mainFrame or {}

function addon:BuildAttributesUI()
    if self.uiBuilt then
        return
    end

    local frame = _G.GACAttributesFrame
    if not frame then
        return
    end

    self.uiControls = {
        attributes = {},
        talents = {},
    }

    local inspectNavPanel = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    inspectNavPanel:SetSize(128, 530)
    inspectNavPanel:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -30)

    inspectNavPanel:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 8,
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    inspectNavPanel:SetBackdropColor(0.03, 0.05, 0.08, 0.78)
    inspectNavPanel:SetBackdropBorderColor(0.18, 0.36, 0.62, 0.80)

    local inspectNavTitle = inspectNavPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    inspectNavTitle:SetPoint("TOP", inspectNavPanel, "TOP", 0, -10)
    inspectNavTitle:SetText("Navegacion")

    local inspectNavAttributesButton = CreateFrame("Button", nil, inspectNavPanel, "UIPanelButtonTemplate")
    inspectNavAttributesButton:SetSize(88, 24)
    inspectNavAttributesButton:SetPoint("TOP", inspectNavTitle, "BOTTOM", 0, -10)
    inspectNavAttributesButton:SetText("Atributos")
    inspectNavAttributesButton:SetScript("OnClick", function()
        addon:SelectMainFrameView("attributes")
    end)

    local inspectNavExperienceButton = CreateFrame("Button", nil, inspectNavPanel, "UIPanelButtonTemplate")
    inspectNavExperienceButton:SetSize(88, 24)
    inspectNavExperienceButton:SetPoint("TOP", inspectNavAttributesButton, "BOTTOM", 0, -6)
    inspectNavExperienceButton:SetText("Experiencia")
    inspectNavExperienceButton:SetScript("OnClick", function()
        addon:SelectMainFrameView("experience")
    end)

    local inspectNavHealthBarButton = CreateFrame("Button", nil, inspectNavPanel, "UIPanelButtonTemplate")
    inspectNavHealthBarButton:SetSize(112, 24)
    inspectNavHealthBarButton:SetPoint("TOP", inspectNavExperienceButton, "BOTTOM", 0, -6)
    inspectNavHealthBarButton:SetText("Barra de salud")
    inspectNavHealthBarButton:SetScript("OnClick", function()
        addon:SelectMainFrameView("healthBar")
    end)

    local inspectNavArmourButton = CreateFrame("Button", nil, inspectNavPanel, "UIPanelButtonTemplate")
    inspectNavArmourButton:SetSize(112, 24)
    inspectNavArmourButton:SetPoint("TOP", inspectNavHealthBarButton, "BOTTOM", 0, -6)
    inspectNavArmourButton:SetText("Armadura")
    inspectNavArmourButton:SetScript("OnClick", function()
        addon:SelectMainFrameView("armour")
    end)

    local inspectContentPanel = CreateFrame("Frame", nil, frame)
    inspectContentPanel:SetPoint("TOPLEFT", inspectNavPanel, "TOPRIGHT", 8, 0)
    inspectContentPanel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -32, 54)

    local inspectInfoPanel = CreateFrame("Frame", nil, inspectContentPanel, "BackdropTemplate")
    inspectInfoPanel:SetAllPoints()
    inspectInfoPanel:Hide()

    inspectInfoPanel:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 8,
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    inspectInfoPanel:SetBackdropColor(0.04, 0.07, 0.12, 0.72)
    inspectInfoPanel:SetBackdropBorderColor(0.20, 0.45, 0.82, 0.85)

    local infoTitle = inspectInfoPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    infoTitle:SetPoint("TOPLEFT", 12, -12)
    infoTitle:SetText("Informacion de progreso")

    local categoryLabel = inspectInfoPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    categoryLabel:SetPoint("TOPLEFT", 12, -28)
    categoryLabel:SetText("Categoria:")

    local categoryValue = inspectInfoPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    categoryValue:SetPoint("LEFT", categoryLabel, "RIGHT", 6, 0)
    categoryValue:SetText("-")

    local levelLabel = inspectInfoPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    levelLabel:SetPoint("LEFT", categoryValue, "RIGHT", 28, 0)
    levelLabel:SetText("Nivel:")

    local levelValue = inspectInfoPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    levelValue:SetPoint("LEFT", levelLabel, "RIGHT", 6, 0)
    levelValue:SetText("-")

    local experienceLabel = inspectInfoPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    experienceLabel:SetPoint("TOPLEFT", categoryLabel, "BOTTOMLEFT", 0, -6)
    experienceLabel:SetText("EXP:")

    local experienceValue = inspectInfoPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    experienceValue:SetPoint("LEFT", experienceLabel, "RIGHT", 6, 0)
    experienceValue:SetText("-")

    local grantInfoText = inspectInfoPanel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    grantInfoText:SetPoint("TOPLEFT", experienceLabel, "BOTTOMLEFT", 0, -12)
    grantInfoText:SetText("Solo lider de grupo/banda")

    local grantExpLabel = inspectInfoPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    grantExpLabel:SetPoint("TOPLEFT", grantInfoText, "BOTTOMLEFT", 0, -10)
    grantExpLabel:SetText("EXP a entregar:")
    grantExpLabel:Hide()

    local grantExpInput = CreateFrame("EditBox", nil, inspectInfoPanel, "InputBoxTemplate")
    grantExpInput:SetSize(84, 20)
    grantExpInput:SetPoint("LEFT", grantExpLabel, "RIGHT", 8, 0)
    grantExpInput:SetAutoFocus(false)
    grantExpInput:SetNumeric(true)
    grantExpInput:SetMaxLetters(8)
    grantExpInput:SetText("0")
    grantExpInput:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    grantExpInput:SetScript("OnEnterPressed", function(self)
        if addon and addon.GrantExperienceToInspectedTarget then
            local _, reason = addon:GrantExperienceToInspectedTarget(self:GetText())
            if reason then
                print("|cffff4040" .. addonName .. "|r " .. reason)
            end
        end
        self:ClearFocus()
    end)
    grantExpInput:Hide()

    local grantExpButton = CreateFrame("Button", nil, inspectInfoPanel, "UIPanelButtonTemplate")
    grantExpButton:SetSize(84, 22)
    grantExpButton:SetPoint("LEFT", grantExpInput, "RIGHT", 8, 0)
    grantExpButton:SetText("Dar EXP")
    grantExpButton:SetScript("OnClick", function()
        if addon and addon.GrantExperienceToInspectedTarget then
            local _, reason = addon:GrantExperienceToInspectedTarget(grantExpInput:GetText())
            if reason then
                print("|cffff4040" .. addonName .. "|r " .. reason)
            end
        end
    end)
    grantExpButton:Hide()

    local mainExperiencePanel = CreateFrame("Frame", nil, inspectContentPanel, "BackdropTemplate")
    mainExperiencePanel:SetAllPoints()
    mainExperiencePanel:Hide()

    mainExperiencePanel:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 8,
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    mainExperiencePanel:SetBackdropColor(0.04, 0.07, 0.12, 0.72)
    mainExperiencePanel:SetBackdropBorderColor(0.20, 0.45, 0.82, 0.85)

    local configTitle = mainExperiencePanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    configTitle:SetPoint("TOPLEFT", 12, -12)
    configTitle:SetText("Configuracion de EXP")

    local categoryLabelMain = mainExperiencePanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    categoryLabelMain:SetPoint("TOPLEFT", 18, -36)
    categoryLabelMain:SetText("Categoria")

    local categoryValueMain = mainExperiencePanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    categoryValueMain:SetPoint("LEFT", categoryLabelMain, "RIGHT", 8, 0)
    categoryValueMain:SetText("-")

    local categoryDropdownMain = CreateFrame("Frame", nil, mainExperiencePanel, "UIDropDownMenuTemplate")
    categoryDropdownMain:SetPoint("TOPLEFT", categoryLabelMain, "BOTTOMLEFT", -16, -6)
    UIDropDownMenu_SetWidth(categoryDropdownMain, 150)

    local levelLabelMain = mainExperiencePanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    levelLabelMain:SetPoint("TOPRIGHT", -120, -36)
    levelLabelMain:SetText("Nivel")

    local levelValueMain = mainExperiencePanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    levelValueMain:SetPoint("LEFT", levelLabelMain, "RIGHT", 8, 0)
    levelValueMain:SetText("1")

    local levelDropdownMain = CreateFrame("Frame", nil, mainExperiencePanel, "UIDropDownMenuTemplate")
    levelDropdownMain:SetPoint("TOPLEFT", levelLabelMain, "BOTTOMLEFT", -16, -6)
    UIDropDownMenu_SetWidth(levelDropdownMain, 90)

    local currentExperienceLabelMain = mainExperiencePanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    currentExperienceLabelMain:SetPoint("TOPLEFT", categoryDropdownMain, "BOTTOMLEFT", 16, -16)
    currentExperienceLabelMain:SetText("EXP actual")

    local currentExperienceInputMain = CreateFrame("EditBox", nil, mainExperiencePanel, "InputBoxTemplate")
    currentExperienceInputMain:SetSize(100, 20)
    currentExperienceInputMain:SetPoint("LEFT", currentExperienceLabelMain, "RIGHT", 10, 0)
    currentExperienceInputMain:SetAutoFocus(false)
    currentExperienceInputMain:SetNumeric(true)
    currentExperienceInputMain:SetMaxLetters(8)
    currentExperienceInputMain:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
        addon:RefreshMainExperiencePanel()
    end)
    currentExperienceInputMain:SetScript("OnEnterPressed", function(self)
        addon:SetCurrentExperience(self:GetText())
        addon:RefreshMainExperiencePanel()
        if addon.UpdateQuickExperienceBar then
            addon:UpdateQuickExperienceBar()
        end
        self:ClearFocus()
    end)

    local requiredExperienceLabelMain = mainExperiencePanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    requiredExperienceLabelMain:SetPoint("TOPLEFT", currentExperienceLabelMain, "BOTTOMLEFT", 0, -22)
    requiredExperienceLabelMain:SetText("EXP necesaria")

    local requiredExperienceValueMain = mainExperiencePanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    requiredExperienceValueMain:SetPoint("LEFT", requiredExperienceLabelMain, "RIGHT", 10, 0)
    requiredExperienceValueMain:SetText("-")

    local applyButtonMain = CreateFrame("Button", nil, mainExperiencePanel, "UIPanelButtonTemplate")
    applyButtonMain:SetSize(120, 24)
    applyButtonMain:SetPoint("BOTTOM", mainExperiencePanel, "BOTTOM", 0, 14)
    applyButtonMain:SetText("Aplicar")
    applyButtonMain:SetScript("OnClick", function()
        addon:SetCurrentExperience(currentExperienceInputMain:GetText())
        addon:RefreshMainExperiencePanel()
        if addon.UpdateQuickExperienceBar then
            addon:UpdateQuickExperienceBar()
        end
        currentExperienceInputMain:ClearFocus()
    end)

    local helpTextMain = mainExperiencePanel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    helpTextMain:SetPoint("BOTTOM", applyButtonMain, "TOP", 0, 6)
    helpTextMain:SetText("Usa Enter o el boton Aplicar para confirmar EXP. Comando: /gacExp")

    local prestigeMessageTextMain = mainExperiencePanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    prestigeMessageTextMain:SetPoint("TOPLEFT", requiredExperienceLabelMain, "BOTTOMLEFT", 0, -20)
    prestigeMessageTextMain:SetPoint("RIGHT", mainExperiencePanel, "RIGHT", -20, 0)
    prestigeMessageTextMain:SetJustifyH("LEFT")
    prestigeMessageTextMain:SetText("Prestigio disponible. Reiniciaras tus atributos y talentos y volveras al nivel 1 de la siguiente categoria.")
    prestigeMessageTextMain:Hide()

    local prestigeButtonMain = CreateFrame("Button", nil, mainExperiencePanel, "UIPanelButtonTemplate")
    prestigeButtonMain:SetSize(120, 24)
    prestigeButtonMain:SetPoint("TOPLEFT", prestigeMessageTextMain, "BOTTOMLEFT", 0, -8)
    prestigeButtonMain:SetText("Prestigiar")
    prestigeButtonMain:SetScript("OnClick", function()
        if addon.PrestigeToNextCategory and addon:PrestigeToNextCategory() then
            addon:RefreshMainExperiencePanel()
            if addon.RefreshAttributesUIValues then
                addon:RefreshAttributesUIValues()
            end
            if addon.UpdateQuickExperienceBar then
                addon:UpdateQuickExperienceBar()
            end
        end
    end)
    prestigeButtonMain:Hide()

    local mainHealthBarPanel = CreateFrame("Frame", nil, inspectContentPanel, "BackdropTemplate")
    mainHealthBarPanel:SetAllPoints()
    mainHealthBarPanel:Hide()

    mainHealthBarPanel:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 8,
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    mainHealthBarPanel:SetBackdropColor(0.04, 0.07, 0.12, 0.72)
    mainHealthBarPanel:SetBackdropBorderColor(0.20, 0.45, 0.82, 0.85)

    local healthConfigTitle = mainHealthBarPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    healthConfigTitle:SetPoint("TOPLEFT", 12, -12)
    healthConfigTitle:SetText("Barra de salud")

    local healthConfigSection = mainHealthBarPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    healthConfigSection:SetPoint("TOPLEFT", 18, -38)
    healthConfigSection:SetText("Modificadores de vida maxima")

    local amountLabel = mainHealthBarPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    amountLabel:SetPoint("TOPLEFT", healthConfigSection, "BOTTOMLEFT", 0, -12)
    amountLabel:SetText("Cantidad mod. maxima")

    local amountInput = mainFrame.createNumericInput(mainHealthBarPanel, 64, 20)
    amountInput:SetPoint("LEFT", amountLabel, "RIGHT", 10, 0)
    amountInput:SetText("10")
    amountInput:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
        addon:RefreshMainHealthConfigPanel()
    end)
    amountInput:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
        addon:RefreshMainHealthConfigPanel()
    end)

    local currentModifierLabel = mainHealthBarPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    currentModifierLabel:SetPoint("LEFT", amountInput, "RIGHT", 24, 0)
    currentModifierLabel:SetText("Modificador actual:")

    local currentModifierValue = mainHealthBarPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    currentModifierValue:SetPoint("LEFT", currentModifierLabel, "RIGHT", 8, 0)
    currentModifierValue:SetText("0")

    local addMaxButton = CreateFrame("Button", nil, mainHealthBarPanel, "UIPanelButtonTemplate")
    addMaxButton:SetSize(170, 24)
    addMaxButton:SetPoint("TOPLEFT", amountLabel, "BOTTOMLEFT", 0, -12)
    addMaxButton:SetText("Añadir a vida maxima")
    addMaxButton:SetScript("OnClick", function()
        local amount = math.max(1, math.floor(tonumber(amountInput:GetText()) or 0))
        addon:AddPlayerHealthMaxModifier(amount)
    end)

    local removeMaxButton = CreateFrame("Button", nil, mainHealthBarPanel, "UIPanelButtonTemplate")
    removeMaxButton:SetSize(170, 24)
    removeMaxButton:SetPoint("LEFT", addMaxButton, "RIGHT", 8, 0)
    removeMaxButton:SetText("Quitar de vida maxima")
    removeMaxButton:SetScript("OnClick", function()
        local amount = math.max(1, math.floor(tonumber(amountInput:GetText()) or 0))
        addon:AddPlayerHealthMaxModifier(-amount)
    end)

    local lifeSection = mainHealthBarPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    lifeSection:SetPoint("TOPLEFT", addMaxButton, "BOTTOMLEFT", 0, -20)
    lifeSection:SetText("Ajuste de vida")

    local lifeAmountLabel = mainHealthBarPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    lifeAmountLabel:SetPoint("TOPLEFT", lifeSection, "BOTTOMLEFT", 0, -10)
    lifeAmountLabel:SetText("Cantidad de vida")

    local lifeAmountInput = mainFrame.createNumericInput(mainHealthBarPanel, 64, 20)
    lifeAmountInput:SetPoint("LEFT", lifeAmountLabel, "RIGHT", 10, 0)
    lifeAmountInput:SetText("10")
    lifeAmountInput:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
        addon:RefreshMainHealthConfigPanel()
    end)
    lifeAmountInput:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
        addon:RefreshMainHealthConfigPanel()
    end)

    local addLifeButton = CreateFrame("Button", nil, mainHealthBarPanel, "UIPanelButtonTemplate")
    addLifeButton:SetSize(170, 24)
    addLifeButton:SetPoint("TOPLEFT", lifeAmountLabel, "BOTTOMLEFT", 0, -10)
    addLifeButton:SetText("Dar vida")
    addLifeButton:SetScript("OnClick", function()
        local amount = math.max(1, math.floor(tonumber(lifeAmountInput:GetText()) or 0))
        addon:ModifyPlayerLife(amount)
    end)

    local removeLifeButton = CreateFrame("Button", nil, mainHealthBarPanel, "UIPanelButtonTemplate")
    removeLifeButton:SetSize(170, 24)
    removeLifeButton:SetPoint("LEFT", addLifeButton, "RIGHT", 8, 0)
    removeLifeButton:SetText("Quitar vida")
    removeLifeButton:SetScript("OnClick", function()
        local amount = math.max(1, math.floor(tonumber(lifeAmountInput:GetText()) or 0))
        addon:ModifyPlayerLife(-amount)
    end)

    local shieldSection = mainHealthBarPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    shieldSection:SetPoint("TOPLEFT", addLifeButton, "BOTTOMLEFT", 0, -20)
    shieldSection:SetText("Escudo")

    local shieldAmountLabel = mainHealthBarPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    shieldAmountLabel:SetPoint("TOPLEFT", shieldSection, "BOTTOMLEFT", 0, -10)
    shieldAmountLabel:SetText("Cantidad de escudo")

    local shieldAmountInput = mainFrame.createNumericInput(mainHealthBarPanel, 64, 20)
    shieldAmountInput:SetPoint("LEFT", shieldAmountLabel, "RIGHT", 10, 0)
    shieldAmountInput:SetText("10")
    shieldAmountInput:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
        addon:RefreshMainHealthConfigPanel()
    end)
    shieldAmountInput:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
        addon:RefreshMainHealthConfigPanel()
    end)

    local currentShieldLabel = mainHealthBarPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    currentShieldLabel:SetPoint("TOPLEFT", shieldAmountLabel, "BOTTOMLEFT", 0, -10)
    currentShieldLabel:SetText("Escudo actual:")

    local currentShieldValue = mainHealthBarPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    currentShieldValue:SetPoint("LEFT", currentShieldLabel, "RIGHT", 8, 0)
    currentShieldValue:SetText("0")

    local addShieldButton = CreateFrame("Button", nil, mainHealthBarPanel, "UIPanelButtonTemplate")
    addShieldButton:SetSize(170, 24)
    addShieldButton:SetPoint("TOPLEFT", currentShieldLabel, "BOTTOMLEFT", 0, -10)
    addShieldButton:SetText("Dar escudo")
    addShieldButton:SetScript("OnClick", function()
        local amount = math.max(1, math.floor(tonumber(shieldAmountInput:GetText()) or 0))
        addon:ModifyPlayerShield(amount)
    end)

    local removeShieldButton = CreateFrame("Button", nil, mainHealthBarPanel, "UIPanelButtonTemplate")
    removeShieldButton:SetSize(170, 24)
    removeShieldButton:SetPoint("LEFT", addShieldButton, "RIGHT", 8, 0)
    removeShieldButton:SetText("Quitar escudo")
    removeShieldButton:SetScript("OnClick", function()
        local amount = math.max(1, math.floor(tonumber(shieldAmountInput:GetText()) or 0))
        addon:ModifyPlayerShield(-amount)
    end)

    frame.InspectNavPanel = inspectNavPanel
    frame.InspectNavAttributesButton = inspectNavAttributesButton
    frame.InspectNavExperienceButton = inspectNavExperienceButton
    frame.InspectNavHealthBarButton = inspectNavHealthBarButton
    frame.InspectNavArmourButton = inspectNavArmourButton
    frame.InspectContentPanel = inspectContentPanel
    frame.InspectExperiencePanel = inspectInfoPanel
    frame.InspectInfoCategoryValue = categoryValue
    frame.InspectInfoLevelValue = levelValue
    frame.InspectInfoExperienceValue = experienceValue
    frame.InspectGrantInfoText = grantInfoText
    frame.InspectGrantExpLabel = grantExpLabel
    frame.InspectGrantExpInput = grantExpInput
    frame.InspectGrantExpButton = grantExpButton
    frame.MainExperiencePanel = mainExperiencePanel
    frame.MainExperienceCategoryDropdown = categoryDropdownMain
    frame.MainExperienceLevelDropdown = levelDropdownMain
    frame.MainExperienceLevelValue = levelValueMain
    frame.MainExperienceCategoryValue = categoryValueMain
    frame.MainExperienceCurrentInput = currentExperienceInputMain
    frame.MainExperienceRequiredValue = requiredExperienceValueMain
    frame.MainExperiencePrestigeMessage = prestigeMessageTextMain
    frame.MainExperiencePrestigeButton = prestigeButtonMain
    frame.MainHealthBarPanel = mainHealthBarPanel
    frame.HealthBarAmountInput = amountInput
    frame.HealthBarLifeAmountInput = lifeAmountInput
    frame.HealthBarShieldAmountInput = shieldAmountInput
    frame.HealthBarCurrentModifierValue = currentModifierValue
    frame.HealthBarCurrentShieldValue = currentShieldValue
    frame.HealthBarAddMaxButton = addMaxButton
    frame.HealthBarRemoveMaxButton = removeMaxButton
    frame.HealthBarAddLifeButton = addLifeButton
    frame.HealthBarRemoveLifeButton = removeLifeButton
    frame.HealthBarAddShieldButton = addShieldButton
    frame.HealthBarRemoveShieldButton = removeShieldButton

    local content = frame.AttributesPanel.ScrollFrame.ScrollChild
    local columns = 3
    local cardWidth = 142
    local cardSpacingX = 8
    local cardSpacingY = 14
    local startX = 8
    local currentY = -12
    local columnIndex = 0
    local rowMaxHeight = 0

    for groupIndex, group in ipairs(self.attributeGroups) do
        local cardHeight = 48 + (#(group.talents or {}) * 22)
        local cardX = startX + (columnIndex * (cardWidth + cardSpacingX))

        local card = CreateFrame("Frame", nil, content)
        card:SetSize(cardWidth, cardHeight)
        card:SetPoint("TOPLEFT", cardX, currentY)

        local cardBackground = card:CreateTexture(nil, "BACKGROUND")
        cardBackground:SetAllPoints()
        cardBackground:SetColorTexture(0.08, 0.10, 0.13, 0.92)

        local cardHeaderAccent = card:CreateTexture(nil, "ARTWORK")
        cardHeaderAccent:SetPoint("TOPLEFT", 0, 0)
        cardHeaderAccent:SetPoint("TOPRIGHT", 0, 0)
        cardHeaderAccent:SetHeight(3)
        cardHeaderAccent:SetColorTexture(0.20, 0.68, 1, 0.65)

        local borderTop = card:CreateTexture(nil, "BORDER")
        borderTop:SetPoint("TOPLEFT", 0, 0)
        borderTop:SetPoint("TOPRIGHT", 0, 0)
        borderTop:SetHeight(1)
        borderTop:SetColorTexture(1, 1, 1, 0.20)

        local borderBottom = card:CreateTexture(nil, "BORDER")
        borderBottom:SetPoint("BOTTOMLEFT", 0, 0)
        borderBottom:SetPoint("BOTTOMRIGHT", 0, 0)
        borderBottom:SetHeight(1)
        borderBottom:SetColorTexture(1, 1, 1, 0.20)

        local borderLeft = card:CreateTexture(nil, "BORDER")
        borderLeft:SetPoint("TOPLEFT", 0, 0)
        borderLeft:SetPoint("BOTTOMLEFT", 0, 0)
        borderLeft:SetWidth(1)
        borderLeft:SetColorTexture(1, 1, 1, 0.20)

        local borderRight = card:CreateTexture(nil, "BORDER")
        borderRight:SetPoint("TOPRIGHT", 0, 0)
        borderRight:SetPoint("BOTTOMRIGHT", 0, 0)
        borderRight:SetWidth(1)
        borderRight:SetColorTexture(1, 1, 1, 0.20)

        local header = card:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        header:SetPoint("TOPLEFT", 8, -8)
        header:SetText(addon:GetLocalizedText(group.name))

        local attrInput = mainFrame.createNumericInput(card, 44, 20)
        attrInput:SetPoint("TOPRIGHT", -8, -6)
        self.uiControls.attributes[group.name] = attrInput

        local attributeDivider = card:CreateTexture(nil, "ARTWORK")
        attributeDivider:SetColorTexture(1, 1, 1, 0.13)
        attributeDivider:SetPoint("TOPLEFT", 8, -30)
        attributeDivider:SetPoint("TOPRIGHT", -8, -30)
        attributeDivider:SetHeight(1)

        local cursorYInCard = -39
        for _, talent in ipairs(group.talents) do
            local talentLabel = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            talentLabel:SetPoint("TOPLEFT", 8, cursorYInCard)
            talentLabel:SetWidth(cardWidth - 62)
            talentLabel:SetJustifyH("LEFT")
            talentLabel:SetText(addon:GetLocalizedText(talent))

            local talentInput = mainFrame.createNumericInput(card, 44, 18)
            talentInput:SetPoint("TOPRIGHT", -8, cursorYInCard + 2)
            self.uiControls.talents[talent] = talentInput

            cursorYInCard = cursorYInCard - 22
        end

        rowMaxHeight = math.max(rowMaxHeight, cardHeight)
        columnIndex = columnIndex + 1

        local isRowEnd = columnIndex >= columns
        local isLastCard = groupIndex == #self.attributeGroups
        if isRowEnd or isLastCard then
            currentY = currentY - rowMaxHeight - cardSpacingY
            columnIndex = 0
            rowMaxHeight = 0
        end
    end

    content:SetHeight(math.max(math.abs(currentY) + 20, 1))

    frame.SaveButton:SetScript("OnClick", function()
        addon:SaveAttributesUIValues()
    end)
    frame.SaveButton:SetText("Guardar PJ")

    frame.ResetButton:SetScript("OnClick", function()
        addon:ResetAttributesUIValues()
    end)
    frame.ResetButton:SetText("Reiniciar")

    frame.CloseButton:SetScript("OnClick", function()
        frame:Hide()
    end)

    self.uiBuilt = true
    self:SelectMainFrameView()
end
