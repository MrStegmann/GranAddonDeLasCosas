local addonName, addon = ...
local qa = addon.quickActions or {}

function addon:UpdateQuickExperienceBar()
    local frame = self.quickActionsFrame
    if not frame or not frame.experienceBar then
        return
    end

    local bar = frame.experienceBar
    local currentXP = 0
    local maxXP = 0

    if self.GetExperienceProgressSnapshot then
        local snapshot = self:GetExperienceProgressSnapshot()
        currentXP = snapshot.currentExperience or 0
        maxXP = snapshot.requiredExperience or 0
    else
        currentXP = UnitXP("player") or 0
        maxXP = UnitXPMax("player") or 0
    end

    bar.currentXP = currentXP
    bar.maxXP = maxXP

    local effectiveMaxXP = maxXP
    if effectiveMaxXP <= 0 then
        effectiveMaxXP = 1
    end

    local percentage = 0
    if maxXP > 0 then
        percentage = currentXP / maxXP
    end

    bar:SetMinMaxValues(0, effectiveMaxXP)
    bar:SetValue(math.min(currentXP, effectiveMaxXP))

    local fillR = 0.12 + (0.18 * percentage)
    local fillG = 0.26 + (0.40 * percentage)
    local fillB = 0.52 + (0.46 * percentage)
    bar:SetStatusBarColor(fillR, fillG, fillB)

    if bar.spark then
        local barWidth = bar:GetWidth() - 4
        local xOffset = (barWidth * percentage) - (barWidth / 2)

        bar.spark:ClearAllPoints()
        bar.spark:SetPoint("CENTER", bar, "CENTER", xOffset, 0)
        bar.spark:SetShown(maxXP > 0 and percentage > 0 and percentage < 1)
    end

    if bar.valueText then
        bar.valueText:SetText(qa.formatXPBarText(currentXP, maxXP))
    end
end

function addon:CanShowTargetInspectButton()
    return UnitExists("target") and UnitIsPlayer("target") and not UnitIsUnit("target", "player")
end

function addon:UpdateTargetInspectButtonVisibility()
    if not self.targetInspectQuickButton then
        return
    end

    self.targetInspectQuickButton:SetShown(self:CanShowTargetInspectButton())
end


function addon:CreateQuickActionsFrame()
    if self.quickActionsFrame then
        return
    end


    -- Anclar el frame de dados al lado derecho de la barra de acción principal
    local frame = CreateFrame("Frame", "GACQuickActionsFrame", UIParent, "BackdropTemplate")
    frame:SetHeight(34)
    frame:SetMovable(false)
    frame:EnableMouse(false)
    frame:SetClampedToScreen(true)
    frame:SetFrameStrata("MEDIUM")

    frame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 8,
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    frame:SetBackdropColor(0.05, 0.06, 0.08, 0.78)
    frame:SetBackdropBorderColor(0.25, 0.78, 0.94, 0.75)

    local function anchorDiceFrameToMainActionBar()
        local minWidth = 340
        local maxWidth = 480
        local padding = 8
        if MainMenuBarArtFrame then
            local actionBarWidth = MainMenuBarArtFrame:GetWidth()
            if not actionBarWidth or actionBarWidth <= 0 then
                actionBarWidth = 1024
            end
            local diceFrameWidth = math.max(minWidth, math.min(actionBarWidth * 0.48, maxWidth))
            frame:ClearAllPoints()
            frame:SetWidth(diceFrameWidth)
            frame:SetPoint("BOTTOMRIGHT", MainMenuBarArtFrame, "TOPRIGHT", -padding, 44)
        elseif MainMenuBar then
            frame:ClearAllPoints()
            frame:SetWidth(minWidth)
            frame:SetPoint("BOTTOMRIGHT", MainMenuBar, "TOPRIGHT", -padding, 2)
        else
            frame:ClearAllPoints()
            frame:SetWidth(minWidth)
            frame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -200, 180)
        end
    end

    anchorDiceFrameToMainActionBar()

    if MainMenuBarArtFrame and not self.mainActionBarDiceHooked then
        self.mainActionBarDiceHooked = true
        MainMenuBarArtFrame:HookScript("OnSizeChanged", function()
            if addon.quickActionsFrame then
                anchorDiceFrameToMainActionBar()
            end
        end)
        MainMenuBarArtFrame:HookScript("OnShow", function()
            if addon.quickActionsFrame then
                anchorDiceFrameToMainActionBar()
            end
        end)
    end

    -- Botones en una sola fila, alineados horizontalmente
    local buttonY = -2
    local buttonX = 8
    local buttonSpacing = 1

    local diceButton = CreateFrame("Button", "GACQuickDiceButton", frame, "UIPanelButtonTemplate")
    diceButton:SetSize(28, 22)
    diceButton:SetPoint("LEFT", frame, "LEFT", buttonX, buttonY)

    local diceIcon = diceButton:CreateTexture(nil, "ARTWORK")
    diceIcon:SetTexture("Interface\\Icons\\INV_Misc_Dice_01")
    diceIcon:SetPoint("CENTER")
    diceIcon:SetSize(15, 15)

    diceButton:SetScript("OnClick", function(self)
        addon.quickActionsMenu = addon:GetTalentRollMenu()
        if not addon.quickActionsMenuFrame then
            addon.quickActionsMenuFrame = CreateFrame("Frame", "GACQuickActionsMenuFrame", UIParent, "UIDropDownMenuTemplate")
        end
        -- Anclar el menú: bottom del menú con el top del frame de botones
        EasyMenu(addon.quickActionsMenu, addon.quickActionsMenuFrame, frame, 0, 0, "MENU", 2)
    end)

    diceButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Dado (d20)")
        GameTooltip:AddLine("Click para abrir menu de tiradas por talento", 1, 1, 1)
        GameTooltip:Show()
    end)

    diceButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    local attributeButton = CreateFrame("Button", "GACQuickAttributeButton", frame, "UIPanelButtonTemplate")
    attributeButton:SetSize(28, 22)
    attributeButton:SetPoint("LEFT", diceButton, "RIGHT", buttonSpacing, 0)

    local attributeIcon = attributeButton:CreateTexture(nil, "ARTWORK")
    attributeIcon:SetTexture("Interface\\Icons\\INV_Misc_Book_11")
    attributeIcon:SetPoint("CENTER")
    attributeIcon:SetSize(15, 15)

    attributeButton:SetScript("OnClick", function(self)
        addon.attributeActionsMenu = addon:GetAttributeRollMenu()
        if not addon.attributeActionsMenuFrame then
            addon.attributeActionsMenuFrame = CreateFrame("Frame", "GACAttributeActionsMenuFrame", UIParent, "UIDropDownMenuTemplate")
        end
        EasyMenu(addon.attributeActionsMenu, addon.attributeActionsMenuFrame, frame, 0, 0, "MENU", 2)
    end)

    attributeButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Atributos (d20)")
        GameTooltip:AddLine("Click para abrir menu de tiradas por atributo", 1, 1, 1)
        GameTooltip:Show()
    end)

    attributeButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    local addLifeQuickButton = CreateFrame("Button", "GACQuickAddLifeButton", frame, "UIPanelButtonTemplate")
    addLifeQuickButton:SetSize(28, 22)
    addLifeQuickButton:SetPoint("BOTTOMLEFT", diceButton, "TOPLEFT", 0, 1)

    local addLifeIcon = addLifeQuickButton:CreateTexture(nil, "ARTWORK")
    addLifeIcon:SetTexture("Interface\\Icons\\Spell_Holy_Renew")
    addLifeIcon:SetPoint("CENTER")
    addLifeIcon:SetSize(15, 15)

    addLifeQuickButton:SetScript("OnClick", function()
        if addon.ModifyPlayerLife then
            addon:ModifyPlayerLife(1)
        end
    end)

    addLifeQuickButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Dar 1 de vida")
        GameTooltip:AddLine("Te añade 1 punto de vida.", 1, 1, 1)
        GameTooltip:Show()
    end)

    addLifeQuickButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    local removeLifeQuickButton = CreateFrame("Button", "GACQuickRemoveLifeButton", frame, "UIPanelButtonTemplate")
    removeLifeQuickButton:SetSize(28, 22)
    removeLifeQuickButton:SetPoint("LEFT", addLifeQuickButton, "RIGHT", buttonSpacing, 0)

    local removeLifeIcon = removeLifeQuickButton:CreateTexture(nil, "ARTWORK")
    removeLifeIcon:SetTexture("Interface\\Icons\\Spell_Shadow_DeathCoil")
    removeLifeIcon:SetPoint("CENTER")
    removeLifeIcon:SetSize(15, 15)

    removeLifeQuickButton:SetScript("OnClick", function()
        if addon.ModifyPlayerLife then
            addon:ModifyPlayerLife(-1)
        end
    end)

    removeLifeQuickButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Quitar 1 de vida")
        GameTooltip:AddLine("Te quita 1 punto de vida.", 1, 1, 1)
        GameTooltip:Show()
    end)

    removeLifeQuickButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    local addShieldQuickButton = CreateFrame("Button", "GACQuickAddShieldButton", frame, "UIPanelButtonTemplate")
    addShieldQuickButton:SetSize(28, 22)
    addShieldQuickButton:SetPoint("LEFT", removeLifeQuickButton, "RIGHT", buttonSpacing, 0)

    local addShieldIcon = addShieldQuickButton:CreateTexture(nil, "ARTWORK")
    addShieldIcon:SetTexture("Interface\\Icons\\Spell_Holy_PowerWordShield")
    addShieldIcon:SetPoint("CENTER")
    addShieldIcon:SetSize(15, 15)

    addShieldQuickButton:SetScript("OnClick", function()
        if addon.ModifyPlayerShield then
            addon:ModifyPlayerShield(1)
        end
    end)

    addShieldQuickButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Dar 1 de escudo")
        GameTooltip:AddLine("Te añade 1 punto de escudo.", 1, 1, 1)
        GameTooltip:Show()
    end)

    addShieldQuickButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    local removeShieldQuickButton = CreateFrame("Button", "GACQuickRemoveShieldButton", frame, "UIPanelButtonTemplate")
    removeShieldQuickButton:SetSize(28, 22)
    removeShieldQuickButton:SetPoint("LEFT", addShieldQuickButton, "RIGHT", buttonSpacing, 0)

    local removeShieldIcon = removeShieldQuickButton:CreateTexture(nil, "ARTWORK")
    removeShieldIcon:SetTexture("Interface\\Icons\\Ability_Warrior_ShieldBreak")
    removeShieldIcon:SetPoint("CENTER")
    removeShieldIcon:SetSize(15, 15)

    removeShieldQuickButton:SetScript("OnClick", function()
        if addon.ModifyPlayerShield then
            addon:ModifyPlayerShield(-1)
        end
    end)

    removeShieldQuickButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Quitar 1 de escudo")
        GameTooltip:AddLine("Te quita 1 punto de escudo.", 1, 1, 1)
        GameTooltip:Show()
    end)

    removeShieldQuickButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    local swordButton = CreateFrame("Button", "GACQuickSwordButton", frame, "UIPanelButtonTemplate")
    swordButton:SetSize(28, 22)
    swordButton:SetPoint("LEFT", attributeButton, "RIGHT", buttonSpacing, 0)

    local swordIcon = swordButton:CreateTexture(nil, "ARTWORK")
    swordIcon:SetTexture("Interface\\Icons\\Ability_Rogue_Sprint")
    swordIcon:SetPoint("CENTER")
    swordIcon:SetSize(15, 15)

    swordButton:SetScript("OnClick", function()
        if not qa.canTriggerRoll() then
            return
        end

        local modifierValue, hasModifier = addon:GetActiveRollModifier()

        addon.pendingInitiativeRoll = {
            min = 1,
            max = 100,
            modifierValue = modifierValue,
            hasModifier = hasModifier,
        }

        addon.randomRollPattern = addon.randomRollPattern or qa.buildRandomRollPattern()

        RandomRoll(1, 100)
    end)

    swordButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Iniciativa (d100)")
        GameTooltip:AddLine("Click para tirar Iniciativa", 1, 1, 1)
        GameTooltip:Show()
    end)

    swordButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    local attackButton = CreateFrame("Button", "GACQuickAttackButton", frame, "UIPanelButtonTemplate")
    attackButton:SetSize(28, 22)
    attackButton:SetPoint("LEFT", swordButton, "RIGHT", buttonSpacing, 0)

    local attackIcon = attackButton:CreateTexture(nil, "ARTWORK")
    attackIcon:SetTexture("Interface\\Icons\\Ability_MeleeDamage")
    attackIcon:SetPoint("CENTER")
    attackIcon:SetSize(15, 15)

    attackButton:SetScript("OnClick", function(self)
        addon.attackActionsMenu = addon:GetAttackRollMenu()
        if not addon.attackActionsMenuFrame then
            addon.attackActionsMenuFrame = CreateFrame("Frame", "GACAttackActionsMenuFrame", UIParent, "UIDropDownMenuTemplate")
        end
        EasyMenu(addon.attackActionsMenu, addon.attackActionsMenuFrame, frame, 0, 0, "MENU", 2)
    end)

    attackButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Ataque")
        GameTooltip:AddLine("Click para abrir menu de tirada de ataque", 1, 1, 1)
        GameTooltip:Show()
    end)

    attackButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    local modifierLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    modifierLabel:SetText("Mod")
    modifierLabel:SetPoint("LEFT", attackButton, "RIGHT", 4, 0)

    local modifierInput = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    modifierInput:SetSize(26, 18)
    modifierInput:SetPoint("LEFT", modifierLabel, "RIGHT", 10, 0)
    modifierInput:SetAutoFocus(false)
    modifierInput:SetNumeric(false)
    modifierInput:SetMaxLetters(5)
    modifierInput:SetText("")
    modifierInput:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    modifierInput:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)

    -- Inputs de dado custom alineados a la derecha del frame
    local dadoLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    dadoLabel:SetText("Dado ")
    dadoLabel:SetPoint("LEFT", modifierInput, "RIGHT", 12, 0)

    local quantityInput = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    quantityInput:SetSize(22, 18)
    quantityInput:SetAutoFocus(false)
    quantityInput:SetNumeric(true)
    quantityInput:SetMaxLetters(2)
    quantityInput:SetText("1")
    quantityInput:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    quantityInput:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)
    quantityInput:SetPoint("LEFT", dadoLabel, "RIGHT", 8, 0)

    local separator = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    separator:SetText("d")
    separator:SetPoint("LEFT", quantityInput, "RIGHT", 5, 0)

    local facesInput = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    facesInput:SetSize(28, 18)
    facesInput:SetAutoFocus(false)
    facesInput:SetNumeric(true)
    facesInput:SetMaxLetters(4)
    facesInput:SetText("20")
    facesInput:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    facesInput:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)
    facesInput:SetPoint("LEFT", separator, "RIGHT", 2, 0)

    local customRollButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    customRollButton:SetSize(28, 22)
    customRollButton:SetText("")
    customRollButton:SetPoint("LEFT", facesInput, "RIGHT", 1, 0)

    local customRollIcon = customRollButton:CreateTexture(nil, "ARTWORK")
    customRollIcon:SetTexture("Interface\\Icons\\INV_Misc_Dice_02")
    customRollIcon:SetPoint("CENTER")
    customRollIcon:SetSize(15, 15)

    customRollButton:SetScript("OnClick", function()
        addon:StartCustomDiceRoll(quantityInput:GetText(), facesInput:GetText())
    end)

    local experienceBar = CreateFrame("StatusBar", "GACExperienceBar", UIParent)
    experienceBar:SetFrameStrata("LOW")
    experienceBar:SetFrameLevel(5)

    local function anchorExperienceBarToMainActionBar()
        if MainMenuBarArtFrame then
            local actionBarWidth = MainMenuBarArtFrame:GetWidth()
            if not actionBarWidth or actionBarWidth <= 0 then
                actionBarWidth = 1024
            end

            experienceBar:ClearAllPoints()
            experienceBar:SetSize(actionBarWidth, 10)
            experienceBar:SetPoint("BOTTOM", MainMenuBarArtFrame, "TOP", 0, -16)
            return
        end

        if MainMenuExpBar then
            experienceBar:ClearAllPoints()
            experienceBar:SetAllPoints(MainMenuExpBar)
            return
        end

        if StatusTrackingBarManager then
            experienceBar:ClearAllPoints()
            experienceBar:SetPoint("TOPLEFT", StatusTrackingBarManager, "TOPLEFT", 0, 0)
            experienceBar:SetPoint("BOTTOMRIGHT", StatusTrackingBarManager, "BOTTOMRIGHT", 0, 0)
            return
        end

        if MainMenuBar then
            experienceBar:ClearAllPoints()
            experienceBar:SetSize(512, 10)
            experienceBar:SetPoint("BOTTOM", MainMenuBar, "TOP", 0, 2)
            return
        end

        experienceBar:ClearAllPoints()
        experienceBar:SetSize(512, 12)
        experienceBar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 2)
    end

    anchorExperienceBarToMainActionBar()

    if MainMenuBarArtFrame and not self.mainActionBarAnchorHooked then
        self.mainActionBarAnchorHooked = true
        MainMenuBarArtFrame:HookScript("OnSizeChanged", function()
            if addon.quickActionsFrame and addon.quickActionsFrame.experienceBar then
                anchorExperienceBarToMainActionBar()
            end
        end)
        MainMenuBarArtFrame:HookScript("OnShow", function()
            if addon.quickActionsFrame and addon.quickActionsFrame.experienceBar then
                anchorExperienceBarToMainActionBar()
            end
        end)
    elseif MainMenuExpBar then
        experienceBar:ClearAllPoints()
        experienceBar:SetAllPoints(MainMenuExpBar)
    end
    experienceBar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
    experienceBar:SetMinMaxValues(0, 1)
    experienceBar:SetValue(0)
    experienceBar:SetStatusBarColor(0.12, 0.26, 0.52)
    experienceBar:EnableMouse(true)

    local statusTexture = experienceBar:GetStatusBarTexture()
    if statusTexture and statusTexture.SetGradientAlpha then
        statusTexture:SetGradientAlpha("HORIZONTAL", 0.08, 0.20, 0.45, 0.95, 0.42, 0.78, 1.00, 0.98)
    end

    local expBackground = experienceBar:CreateTexture(nil, "BACKGROUND")
    expBackground:SetAllPoints()
    expBackground:SetColorTexture(0.01, 0.03, 0.07, 0.72)

    local expOverlay = experienceBar:CreateTexture(nil, "OVERLAY")
    expOverlay:SetPoint("TOPLEFT", 1, -1)
    expOverlay:SetPoint("TOPRIGHT", -1, -1)
    expOverlay:SetHeight(3)
    expOverlay:SetColorTexture(0.72, 0.88, 1.00, 0.26)

    local expBorderTop = experienceBar:CreateTexture(nil, "BORDER")
    expBorderTop:SetPoint("TOPLEFT", -1, 1)
    expBorderTop:SetPoint("TOPRIGHT", 1, 1)
    expBorderTop:SetHeight(1)
    expBorderTop:SetColorTexture(0.22, 0.44, 0.72, 0.9)

    local expBorderBottom = experienceBar:CreateTexture(nil, "BORDER")
    expBorderBottom:SetPoint("BOTTOMLEFT", -1, -1)
    expBorderBottom:SetPoint("BOTTOMRIGHT", 1, -1)
    expBorderBottom:SetHeight(1)
    expBorderBottom:SetColorTexture(0.02, 0.08, 0.18, 0.95)

    local expBorderLeft = experienceBar:CreateTexture(nil, "BORDER")
    expBorderLeft:SetPoint("TOPLEFT", -1, 1)
    expBorderLeft:SetPoint("BOTTOMLEFT", -1, -1)
    expBorderLeft:SetWidth(1)
    expBorderLeft:SetColorTexture(0.18, 0.36, 0.62, 0.9)

    local expBorderRight = experienceBar:CreateTexture(nil, "BORDER")
    expBorderRight:SetPoint("TOPRIGHT", 1, 1)
    expBorderRight:SetPoint("BOTTOMRIGHT", 1, -1)
    expBorderRight:SetWidth(1)
    expBorderRight:SetColorTexture(0.02, 0.07, 0.16, 0.95)

    local expSpark = experienceBar:CreateTexture(nil, "ARTWORK")
    expSpark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
    expSpark:SetSize(10, 12)
    expSpark:SetBlendMode("ADD")
    expSpark:SetVertexColor(0.62, 0.86, 1.00, 0.95)
    expSpark:SetPoint("CENTER", experienceBar, "LEFT", 0, 0)
    experienceBar.spark = expSpark

    local expValueText = experienceBar:CreateFontString(nil, "OVERLAY", "GameFontNormalTiny")
    expValueText:SetPoint("CENTER", experienceBar, "CENTER", 0, 0)
    expValueText:SetTextColor(1, 0.95, 0.82)
    expValueText:SetShadowOffset(1, -1)
    expValueText:SetShadowColor(0, 0, 0, 0.9)
    expValueText:SetText("EXP 0 / 0 (0.0%)")
    expValueText:Hide()
    experienceBar.valueText = expValueText

    experienceBar:SetScript("OnEnter", function(self)
        if self.valueText then
            self.valueText:Show()
        end
    end)

    experienceBar:SetScript("OnLeave", function(self)
        if self.valueText then
            self.valueText:Hide()
        end
    end)

    local expandTurnOrderButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    expandTurnOrderButton:SetSize(96, 20)
    expandTurnOrderButton:SetPoint("LEFT", removeShieldQuickButton, "RIGHT", 8, 0)
    expandTurnOrderButton:SetText("Orden Turnos")
    expandTurnOrderButton:SetShown(false)
    expandTurnOrderButton:SetScript("OnClick", function()
        if addon.SetTurnOrderMinimized then
            addon:SetTurnOrderMinimized(false)
        end

        if addon.UpdateTurnOrderFrameVisibility then
            addon:UpdateTurnOrderFrameVisibility()
        end
    end)

    expandTurnOrderButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Mostrar orden de turnos")
        GameTooltip:AddLine("Expande el panel de orden de turnos minimizado.", 1, 1, 1)
        GameTooltip:Show()
    end)

    expandTurnOrderButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    local inspectTargetButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    inspectTargetButton:SetSize(24, 24)
    inspectTargetButton:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -8, -1)
    inspectTargetButton:SetShown(false)

    local inspectTargetIcon = inspectTargetButton:CreateTexture(nil, "ARTWORK")
    inspectTargetIcon:SetTexture("Interface\\Icons\\INV_Misc_Spyglass_03")
    inspectTargetIcon:SetPoint("CENTER")
    inspectTargetIcon:SetSize(16, 16)

    inspectTargetButton:SetScript("OnClick", function()
        if addon.OpenTargetAttributesFromUnit then
            addon:OpenTargetAttributesFromUnit("target")
        end
    end)

    inspectTargetButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Inspeccionar objetivo")
        GameTooltip:AddLine("Muestra atributos y talentos del objetivo si usa este addon.", 1, 1, 1)
        GameTooltip:Show()
    end)

    inspectTargetButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- Eliminar los antiguos inputs de dado custom (ahora están alineados en la fila principal)

    frame.quantityInput = quantityInput
    frame.facesInput = facesInput
    frame.modifierInput = modifierInput
    frame.customRollButton = customRollButton
    frame.experienceBar = experienceBar

    self.turnOrderExpandQuickButton = expandTurnOrderButton
    self.targetInspectQuickButton = inspectTargetButton

    self.quickActionsFrame = frame

    if self.UpdateTurnOrderExpandButtonVisibility then
        self:UpdateTurnOrderExpandButtonVisibility()
    end

    self:UpdateTargetInspectButtonVisibility()
    self:UpdateQuickExperienceBar()
end
