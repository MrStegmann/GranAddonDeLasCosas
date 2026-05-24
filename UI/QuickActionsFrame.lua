local addonName, addon = ...
local ROLL_CLICK_GUARD_SECONDS = 0.5

local ATTACK_TALENT_OPTIONS = {
    { label = "Combate Ágil", key = "Combate Ágil" },
    { label = "Precisión", key = "Precisión" },
    { label = "Brutalidad", key = "Brutalidad" },
    { label = "Acrobacias", key = "Acrobacias" },
    { label = "Combate con armas de 1 mano", key = "Combate a 1 mano" },
    { label = "Combate con armas de 2 manos", key = "Combate a 2 manos" },
    { label = "Arcano", key = "Arcano" },
    { label = "Vil", key = "Vil" },
    { label = "Naturaleza", key = "Naturaleza" },
    { label = "Sombras", key = "Sombras" },
    { label = "Nigromancia", key = "Nigromancia" },
    { label = "Fe", key = "Fe" },
    { label = "Conexión Elemental", key = "Conexión Elemental" },
    { label = "Chi", key = "Chi" },
}

local function buildRandomRollPattern()
    local pattern = RANDOM_ROLL_RESULT or "%s rolls %d (%d-%d)"
    pattern = pattern:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
    pattern = pattern:gsub("%%%%s", "(.+)")
    pattern = pattern:gsub("%%%%d", "(%%d+)")
    return "^" .. pattern .. "$"
end

local function isPlayerRoll(rollerName)
    if not rollerName then
        return false
    end

    local playerName = UnitName("player")
    if not playerName then
        return false
    end

    if rollerName == playerName then
        return true
    end

    return rollerName:match("^" .. playerName .. "%-") ~= nil
end

local function stripColorCodes(text)
    if type(text) ~= "string" then
        return text
    end

    local clean = text:gsub("|c%x%x%x%x%x%x%x%x", "")
    clean = clean:gsub("|r", "")
    return clean
end

local function formatRollValue(rollValue)
    if rollValue == 1 then
        return "|cffff4040" .. rollValue .. "|r Pifia"
    end

    if rollValue == 20 then
        return "|cff40ff40" .. rollValue .. "|r Critico"
    end

    return "|cffffffff" .. rollValue .. "|r"
end

local function formatInitiativeRollValue(rollValue)
    if rollValue == 1 then
        return "|cffff4040" .. rollValue .. "|r Pifia"
    end

    if rollValue == 100 then
        return "|cff40ff40" .. rollValue .. "|r Crítico"
    end

    return tostring(rollValue)
end

local function ensureQuickFramePosition()
    if not addon.characterData or not addon.characterData.ui then
        return
    end

    addon.characterData.ui.quickFrame = addon.characterData.ui.quickFrame or {}

    local position = addon.characterData.ui.quickFrame
    if position.anchor == nil then
        position.anchor = "CENTER"
        position.relativeAnchor = "CENTER"
        position.x = -260
        position.y = -120
    end
end

local function canTriggerRoll()
    local now = (GetTimePreciseSec and GetTimePreciseSec()) or GetTime()
    local lastAction = addon.lastRollActionAt or 0

    if (now - lastAction) < ROLL_CLICK_GUARD_SECONDS then
        return false
    end

    addon.lastRollActionAt = now
    return true
end

local function normalizeModifierValue(value)
    if type(value) ~= "number" then
        return 0
    end

    return math.floor(value)
end

local function buildModifierSegment(hasModifier, modifierValue)
    if not hasModifier then
        return ""
    end

    return " + Mod (" .. modifierValue .. ")"
end

local function formatXPBarText(currentXP, maxXP)
    local safeCurrentXP = math.max(tonumber(currentXP) or 0, 0)
    local safeMaxXP = math.max(tonumber(maxXP) or 0, 0)
    local percentage = 0

    if safeMaxXP > 0 then
        percentage = (safeCurrentXP / safeMaxXP) * 100
    end

    return string.format("EXP %d / %d (%.1f%%)", safeCurrentXP, safeMaxXP, percentage)
end

function addon:GetActiveRollModifier()
    local frame = self.quickActionsFrame
    if not frame or not frame.modifierInput then
        return 0, false
    end

    local rawValue = (frame.modifierInput:GetText() or ""):match("^%s*(.-)%s*$")
    if rawValue == "" then
        return 0, false
    end

    local numericValue = tonumber(rawValue)
    if not numericValue then
        return 0, false
    end

    return normalizeModifierValue(numericValue), true
end

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
        bar.valueText:SetText(formatXPBarText(currentXP, maxXP))
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

function addon:GetTalentRollMenu()
    local menu = {
        {
            text = "Tirada de Talentos",
            isTitle = true,
            notCheckable = true,
        },
    }

    for _, group in ipairs(self.attributeGroups or {}) do
        local subMenu = {}

        for _, talent in ipairs(group.talents or {}) do
            subMenu[#subMenu + 1] = {
                text = talent,
                notCheckable = true,
                func = function()
                    addon:StartTalentRoll(group.name, talent)
                end,
            }
        end

        menu[#menu + 1] = {
            text = group.name,
            notCheckable = true,
            hasArrow = true,
            menuList = subMenu,
        }
    end

    return menu
end

function addon:GetAttributeRollMenu()
    local menu = {
        {
            text = "Tirada de Atributos",
            isTitle = true,
            notCheckable = true,
        },
    }

    for _, group in ipairs(self.attributeGroups or {}) do
        menu[#menu + 1] = {
            text = group.name,
            notCheckable = true,
            func = function()
                addon:StartAttributeRoll(group.name)
            end,
        }
    end

    return menu
end

function addon:GetAttackRollMenu()
    local menu = {
        {
            text = "Tirada de Ataque",
            isTitle = true,
            notCheckable = true,
        },
    }

    for _, sides in ipairs({ 4, 6, 8, 10, 12 }) do
        local diceSides = sides
        local talentSubmenu = {}

        for _, option in ipairs(ATTACK_TALENT_OPTIONS) do
            local currentOption = option
            talentSubmenu[#talentSubmenu + 1] = {
                text = currentOption.label,
                notCheckable = true,
                func = function()
                    addon:StartAttackRoll(diceSides, currentOption.key, currentOption.label)
                end,
            }
        end

        menu[#menu + 1] = {
            text = "1D" .. diceSides,
            notCheckable = true,
            hasArrow = true,
            menuList = talentSubmenu,
        }
    end

    return menu
end

function addon:StartTalentRoll(attributeName, talentName)
    if not self.characterData then
        return
    end

    if not canTriggerRoll() then
        return
    end

    local attributeValue = tonumber(self.characterData.attributes[attributeName]) or 0
    local talentValue = tonumber(self.characterData.talents[talentName]) or 0
    local modifierValue, hasModifier = self:GetActiveRollModifier()

    self.pendingTalentRoll = {
        attributeName = attributeName,
        talentName = talentName,
        attributeValue = attributeValue,
        talentValue = talentValue,
        modifierValue = modifierValue,
        hasModifier = hasModifier,
        min = 1,
        max = 20,
    }

    self.randomRollPattern = self.randomRollPattern or buildRandomRollPattern()

    RandomRoll(1, 20)
end

function addon:StartAttributeRoll(attributeName)
    if not self.characterData then
        return
    end

    if not canTriggerRoll() then
        return
    end

    local attributeValue = tonumber(self.characterData.attributes[attributeName]) or 0
    local modifierValue, hasModifier = self:GetActiveRollModifier()

    self.pendingAttributeRoll = {
        attributeName = attributeName,
        attributeValue = attributeValue,
        modifierValue = modifierValue,
        hasModifier = hasModifier,
        min = 1,
        max = 20,
    }

    self.randomRollPattern = self.randomRollPattern or buildRandomRollPattern()

    RandomRoll(1, 20)
end

function addon:StartAttackRoll(diceSides, talentKey, talentLabel)
    if not self.characterData then
        return
    end

    if not canTriggerRoll() then
        return
    end

    local talentValue = tonumber(self.characterData.talents[talentKey]) or 0
    local modifierValue, hasModifier = self:GetActiveRollModifier()

    self.pendingAttackRoll = {
        diceSides = diceSides,
        talentKey = talentKey,
        talentLabel = talentLabel,
        talentValue = talentValue,
        modifierValue = modifierValue,
        hasModifier = hasModifier,
        min = 1,
        max = diceSides,
    }

    self.randomRollPattern = self.randomRollPattern or buildRandomRollPattern()

    RandomRoll(1, diceSides)
end

function addon:StartCustomDiceRoll(quantity, faces)
    if not canTriggerRoll() then
        return
    end

    local diceCount = tonumber(quantity) or 0
    local diceFaces = tonumber(faces) or 0

    if diceCount < 1 or diceFaces < 2 then
        print("Introduce valores validos: cantidad >= 1 y caras >= 2.")
        return
    end

    diceCount = math.min(math.floor(diceCount), 20)
    diceFaces = math.min(math.floor(diceFaces), 1000)

    local modifierValue, hasModifier = self:GetActiveRollModifier()

    local total = 0
    local rollParts = {}
    for _ = 1, diceCount do
        local value = random(1, diceFaces)
        total = total + value
        rollParts[#rollParts + 1] = tostring(value)
    end

    if hasModifier then
        total = total + modifierValue
    end

    local displayName = self.GetRollDisplayNameWithColor and self:GetRollDisplayNameWithColor()
        or (self.GetRollDisplayName and self:GetRollDisplayName())
        or addonName

    local finalMessage = displayName .. " tira " .. diceCount .. "D" .. diceFaces
        .. " (" .. table.concat(rollParts, "+") .. ")"
        .. buildModifierSegment(hasModifier, modifierValue)
        .. " = " .. total

    print(finalMessage)

    if self.BroadcastRollMessage then
        self:BroadcastRollMessage(finalMessage)
    end
end

function addon:CHAT_MSG_SYSTEM(message)
    if self.CaptureRaidRollForTurnOrder then
        self:CaptureRaidRollForTurnOrder(message)
    end

    if not self.pendingTalentRoll and not self.pendingAttributeRoll and not self.pendingAttackRoll and not self.pendingInitiativeRoll then
        return
    end

    local plainMessage = stripColorCodes(message)
    local roller, roll, low, high = plainMessage:match(self.randomRollPattern)
    if not roller or not isPlayerRoll(roller) then
        return
    end

    local rollValue = tonumber(roll)
    local lowValue = tonumber(low)
    local highValue = tonumber(high)
    if self.pendingTalentRoll and (lowValue == self.pendingTalentRoll.min and highValue == self.pendingTalentRoll.max) then
        local total = rollValue + self.pendingTalentRoll.attributeValue + self.pendingTalentRoll.talentValue
        if self.pendingTalentRoll.hasModifier then
            total = total + self.pendingTalentRoll.modifierValue
        end
        local displayName = self.GetRollDisplayNameWithColor and self:GetRollDisplayNameWithColor()
            or (self.GetRollDisplayName and self:GetRollDisplayName())
            or addonName
        local formattedRoll = formatRollValue(rollValue)
        local finalMessage = displayName .. " tira "
            .. " 1D20 (" .. formattedRoll .. ") + "
            .. self.pendingTalentRoll.attributeName .. " (" .. self.pendingTalentRoll.attributeValue .. ") + "
            .. self.pendingTalentRoll.talentName .. " (" .. self.pendingTalentRoll.talentValue .. ")"
            .. buildModifierSegment(self.pendingTalentRoll.hasModifier, self.pendingTalentRoll.modifierValue)
            .. " = " .. total

        print(finalMessage)

        if self.BroadcastRollMessage then
            self:BroadcastRollMessage(finalMessage)
        end

        self.pendingTalentRoll = nil
    elseif self.pendingAttributeRoll and (lowValue == self.pendingAttributeRoll.min and highValue == self.pendingAttributeRoll.max) then
        local total = rollValue + self.pendingAttributeRoll.attributeValue
        if self.pendingAttributeRoll.hasModifier then
            total = total + self.pendingAttributeRoll.modifierValue
        end
        local displayName = self.GetRollDisplayNameWithColor and self:GetRollDisplayNameWithColor()
            or (self.GetRollDisplayName and self:GetRollDisplayName())
            or addonName
        local formattedRoll = formatRollValue(rollValue)
        local finalMessage = displayName .. " tira "
            .. self.pendingAttributeRoll.attributeName
            .. " 1D20 (" .. formattedRoll .. ") + "
            .. self.pendingAttributeRoll.attributeName .. " (" .. self.pendingAttributeRoll.attributeValue .. ")"
            .. buildModifierSegment(self.pendingAttributeRoll.hasModifier, self.pendingAttributeRoll.modifierValue)
            .. " = " .. total

        print(finalMessage)

        if self.BroadcastRollMessage then
            self:BroadcastRollMessage(finalMessage)
        end

        self.pendingAttributeRoll = nil
    elseif self.pendingAttackRoll and (lowValue == self.pendingAttackRoll.min and highValue == self.pendingAttackRoll.max) then
        local total = rollValue + self.pendingAttackRoll.talentValue
        if self.pendingAttackRoll.hasModifier then
            total = total + self.pendingAttackRoll.modifierValue
        end
        local displayName = self.GetRollDisplayNameWithColor and self:GetRollDisplayNameWithColor()
            or (self.GetRollDisplayName and self:GetRollDisplayName())
            or addonName
        local formattedRoll = formatRollValue(rollValue)
        local finalMessage = displayName .. " tira 1D" .. self.pendingAttackRoll.diceSides
            .. " (" .. formattedRoll .. ") + "
            .. self.pendingAttackRoll.talentLabel .. " (" .. self.pendingAttackRoll.talentValue .. ")"
            .. buildModifierSegment(self.pendingAttackRoll.hasModifier, self.pendingAttackRoll.modifierValue)
            .. " = " .. total

        print(finalMessage)

        if self.BroadcastRollMessage then
            self:BroadcastRollMessage(finalMessage)
        end

        self.pendingAttackRoll = nil
    elseif self.pendingInitiativeRoll and (lowValue == self.pendingInitiativeRoll.min and highValue == self.pendingInitiativeRoll.max) then
        local plainDisplayName = self.GetRollDisplayName and self:GetRollDisplayName() or addonName
        local displayName = self.GetRollDisplayNameWithColor and self:GetRollDisplayNameWithColor()
            or plainDisplayName
            or addonName
        local formattedRoll = formatInitiativeRollValue(rollValue)
        local modifierValue = self.pendingInitiativeRoll.modifierValue or 0
        local hasModifier = self.pendingInitiativeRoll.hasModifier
        local finalMessage
        if hasModifier then
            local total = rollValue + modifierValue
            finalMessage = displayName .. " tira por Iniciativa: " .. formattedRoll
                .. buildModifierSegment(true, modifierValue)
                .. " = " .. total
        else
            finalMessage = displayName .. " tira por Iniciativa: " .. formattedRoll
        end

        print(finalMessage)

        if self.BroadcastRollMessage then
            self:BroadcastRollMessage(finalMessage)
        end

        self.pendingInitiativeRoll = nil
    else
        return
    end
end

function addon:CreateQuickActionsFrame()
    if self.quickActionsFrame then
        return
    end

    ensureQuickFramePosition()

    local frame = CreateFrame("Frame", "GACQuickActionsFrame", UIParent, "BackdropTemplate")
    frame:SetSize(220, 64)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
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

    local position = self.characterData.ui.quickFrame
    frame:SetPoint(position.anchor, UIParent, position.relativeAnchor, position.x, position.y)

    frame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)

    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()

        local anchor, _, relativeAnchor, x, y = self:GetPoint(1)
        addon.characterData.ui.quickFrame.anchor = anchor
        addon.characterData.ui.quickFrame.relativeAnchor = relativeAnchor
        addon.characterData.ui.quickFrame.x = math.floor(x + 0.5)
        addon.characterData.ui.quickFrame.y = math.floor(y + 0.5)
    end)

    local diceButton = CreateFrame("Button", "GACQuickDiceButton", frame, "UIPanelButtonTemplate")
    diceButton:SetSize(30, 24)
    diceButton:SetPoint("TOPLEFT", 5, -4)

    local diceIcon = diceButton:CreateTexture(nil, "ARTWORK")
    diceIcon:SetTexture("Interface\\Icons\\INV_Misc_Dice_01")
    diceIcon:SetPoint("CENTER")
    diceIcon:SetSize(15, 15)

    diceButton:SetScript("OnClick", function()
        addon.quickActionsMenu = addon:GetTalentRollMenu()
        if not addon.quickActionsMenuFrame then
            addon.quickActionsMenuFrame = CreateFrame("Frame", "GACQuickActionsMenuFrame", UIParent, "UIDropDownMenuTemplate")
        end

        EasyMenu(addon.quickActionsMenu, addon.quickActionsMenuFrame, "cursor", 0, 0, "MENU", 2)
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
    attributeButton:SetSize(30, 24)
    attributeButton:SetPoint("LEFT", diceButton, "RIGHT", 2, 0)

    local attributeIcon = attributeButton:CreateTexture(nil, "ARTWORK")
    attributeIcon:SetTexture("Interface\\Icons\\INV_Misc_Book_11")
    attributeIcon:SetPoint("CENTER")
    attributeIcon:SetSize(15, 15)

    attributeButton:SetScript("OnClick", function()
        addon.attributeActionsMenu = addon:GetAttributeRollMenu()
        if not addon.attributeActionsMenuFrame then
            addon.attributeActionsMenuFrame = CreateFrame("Frame", "GACAttributeActionsMenuFrame", UIParent, "UIDropDownMenuTemplate")
        end

        EasyMenu(addon.attributeActionsMenu, addon.attributeActionsMenuFrame, "cursor", 0, 0, "MENU", 2)
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

    local swordButton = CreateFrame("Button", "GACQuickSwordButton", frame, "UIPanelButtonTemplate")
    swordButton:SetSize(30, 24)
    swordButton:SetPoint("LEFT", attributeButton, "RIGHT", 2, 0)

    local swordIcon = swordButton:CreateTexture(nil, "ARTWORK")
    swordIcon:SetTexture("Interface\\Icons\\Ability_Rogue_Sprint")
    swordIcon:SetPoint("CENTER")
    swordIcon:SetSize(15, 15)

    swordButton:SetScript("OnClick", function()
        if not canTriggerRoll() then
            return
        end

        local modifierValue, hasModifier = addon:GetActiveRollModifier()

        addon.pendingInitiativeRoll = {
            min = 1,
            max = 100,
            modifierValue = modifierValue,
            hasModifier = hasModifier,
        }

        addon.randomRollPattern = addon.randomRollPattern or buildRandomRollPattern()

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
    attackButton:SetSize(30, 24)
    attackButton:SetPoint("LEFT", swordButton, "RIGHT", 2, 0)

    local attackIcon = attackButton:CreateTexture(nil, "ARTWORK")
    attackIcon:SetTexture("Interface\\Icons\\Ability_MeleeDamage")
    attackIcon:SetPoint("CENTER")
    attackIcon:SetSize(15, 15)

    attackButton:SetScript("OnClick", function()
        addon.attackActionsMenu = addon:GetAttackRollMenu()
        if not addon.attackActionsMenuFrame then
            addon.attackActionsMenuFrame = CreateFrame("Frame", "GACAttackActionsMenuFrame", UIParent, "UIDropDownMenuTemplate")
        end

        EasyMenu(addon.attackActionsMenu, addon.attackActionsMenuFrame, "cursor", 0, 0, "MENU", 2)
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
    modifierLabel:SetPoint("LEFT", attackButton, "RIGHT", 6, 0)
    modifierLabel:SetText("Mod")

    local modifierInput = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    modifierInput:SetSize(30, 18)
    modifierInput:SetPoint("LEFT", modifierLabel, "RIGHT", 4, 0)
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
    expandTurnOrderButton:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 8, -1)
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

    local quantityInput = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    quantityInput:SetSize(30, 18)
    quantityInput:SetPoint("BOTTOMLEFT", 8, 8)
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

    local separator = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    separator:SetPoint("LEFT", quantityInput, "RIGHT", 4, 0)
    separator:SetText("d")

    local facesInput = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    facesInput:SetSize(34, 18)
    facesInput:SetPoint("LEFT", separator, "RIGHT", 4, 0)
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

    local customRollButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    customRollButton:SetSize(44, 18)
    customRollButton:SetPoint("BOTTOMRIGHT", -8, 8)
    customRollButton:SetText("Tirar")
    customRollButton:SetScript("OnClick", function()
        addon:StartCustomDiceRoll(quantityInput:GetText(), facesInput:GetText())
    end)

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
