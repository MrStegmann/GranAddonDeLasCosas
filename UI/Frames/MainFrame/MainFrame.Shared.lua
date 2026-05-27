local addonName, addon = ...

addon.mainFrame = addon.mainFrame or {}
local mainFrame = addon.mainFrame

function mainFrame.toNumberOrZero(text)
    local value = tonumber(text)
    if value == nil then
        return 0
    end

    return math.floor(value)
end

function mainFrame.createNumericInput(parent, width, height)
    local input = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    input:SetSize(width, height)
    input:SetAutoFocus(false)
    input:SetNumeric(false)
    input:SetMaxLetters(8)
    input:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    input:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)

    return input
end

function mainFrame.setInputEnabled(input, enabled)
    if not input then
        return
    end

    input:EnableMouse(enabled)
    input:SetEnabled(enabled)

    if enabled then
        input:SetTextColor(1, 1, 1)
    else
        input:SetTextColor(0.85, 0.85, 0.85)
    end
end

local function normalizeInspectProgressData(data)
    local progress = (type(data) == "table" and type(data.progress) == "table") and data.progress or {}
    local category = progress.category or "-"
    local level = tonumber(progress.level) and tostring(math.floor(progress.level)) or "-"
    local currentExperience = tonumber(progress.currentExperience)
    local requiredExperience = progress.requiredExperience

    local expText = "-"
    if currentExperience ~= nil then
        if requiredExperience == nil then
            expText = string.format("%d / MAX", math.max(0, math.floor(currentExperience)))
        else
            expText = string.format("%d / %d", math.max(0, math.floor(currentExperience)), math.max(0, math.floor(requiredExperience)))
        end
    end

    return category, level, expText
end

function mainFrame.updateInspectInfoPanel(frame, data)
    if not frame or not frame.InspectExperiencePanel then
        return
    end

    local category, level, expText = normalizeInspectProgressData(data)
    frame.InspectInfoCategoryValue:SetText(category)
    frame.InspectInfoLevelValue:SetText(level)
    frame.InspectInfoExperienceValue:SetText(expText)

    if frame.InspectGrantInfoText and addon and addon.CanGrantExperienceToInspectedTarget then
        local canGrant = addon:CanGrantExperienceToInspectedTarget()
        frame.InspectGrantInfoText:SetText(canGrant and "Opciones de lider activas" or "Solo lider de grupo/banda")
    end

    if frame.InspectGrantExpInput and addon and addon.CanGrantExperienceToInspectedTarget then
        local canGrant = addon:CanGrantExperienceToInspectedTarget()
        frame.InspectGrantExpInput:SetShown(canGrant)
        if frame.InspectGrantExpLabel then
            frame.InspectGrantExpLabel:SetShown(canGrant)
        end
        if frame.InspectGrantExpButton then
            frame.InspectGrantExpButton:SetShown(canGrant)
        end
    end
end

local function buildCategoryDropdown(frame)
    if not frame or not frame.MainExperienceCategoryDropdown then
        return
    end

    UIDropDownMenu_Initialize(frame.MainExperienceCategoryDropdown, function(_, level)
        if level ~= 1 then
            return
        end

        for _, categoryName in ipairs(addon.levelCategories or {}) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = categoryName
            info.value = categoryName
            info.func = function()
                addon:SetExperienceCategory(categoryName)
                addon:RefreshMainExperiencePanel()
                if addon.UpdateQuickExperienceBar then
                    addon:UpdateQuickExperienceBar()
                end
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
end

local function buildLevelDropdown(frame, category)
    if not frame or not frame.MainExperienceLevelDropdown then
        return
    end

    UIDropDownMenu_Initialize(frame.MainExperienceLevelDropdown, function(_, level)
        if level ~= 1 then
            return
        end

        local maxLevel = addon:GetMaxLevelForCategory(category)
        for levelNumber = 1, maxLevel do
            local info = UIDropDownMenu_CreateInfo()
            info.text = tostring(levelNumber)
            info.value = levelNumber
            info.func = function()
                addon:SetExperienceLevel(levelNumber)
                addon:RefreshMainExperiencePanel()
                if addon.UpdateQuickExperienceBar then
                    addon:UpdateQuickExperienceBar()
                end
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
end

local function setMainNavigationState(frame, activeView)
    if not frame then
        return
    end

    if frame.InspectNavAttributesButton then
        frame.InspectNavAttributesButton:SetEnabled(activeView ~= "attributes")
    end

    if frame.InspectNavExperienceButton then
        frame.InspectNavExperienceButton:SetEnabled(activeView ~= "experience")
    end

    if frame.InspectNavHealthBarButton then
        frame.InspectNavHealthBarButton:SetEnabled(activeView ~= "healthBar")
    end
end

function mainFrame.updateLayout(frame, isInspectMode, activeView)
    if not frame or not frame.AttributesPanel then
        return
    end

    if frame.InspectNavPanel then
        frame.InspectNavPanel:Show()
    end

    if frame.InspectContentPanel then
        frame.InspectContentPanel:Show()
    end

    if frame.InspectExperiencePanel then
        frame.InspectExperiencePanel:SetShown(isInspectMode and activeView == "experience")
    end

    if frame.MainExperiencePanel then
        frame.MainExperiencePanel:SetShown((not isInspectMode) and activeView == "experience")
    end

    if frame.MainHealthBarPanel then
        frame.MainHealthBarPanel:SetShown((not isInspectMode) and activeView == "healthBar")
    end

    if frame.InspectNavHealthBarButton then
        frame.InspectNavHealthBarButton:SetShown(not isInspectMode)
    end

    frame.AttributesPanel:ClearAllPoints()
    if frame.InspectContentPanel then
        frame.AttributesPanel:SetPoint("TOPLEFT", frame.InspectContentPanel, "TOPLEFT", 0, 0)
        frame.AttributesPanel:SetPoint("BOTTOMRIGHT", frame.InspectContentPanel, "BOTTOMRIGHT", 0, 0)
        frame.AttributesPanel:SetShown(activeView == "attributes")
    else
        frame.AttributesPanel:SetPoint("TOPLEFT", frame, "TOPLEFT", 16, -30)
        frame.AttributesPanel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -32, 54)
        frame.AttributesPanel:Show()
    end

    setMainNavigationState(frame, activeView)
end

function addon:SelectMainFrameView(view)
    local frame = _G.GACAttributesFrame
    if not frame then
        return
    end

    local requestedView = view or self.inspectMainView or "attributes"
    if self.attributesUIReadOnly and requestedView == "healthBar" then
        requestedView = "attributes"
    end

    self.inspectMainView = requestedView
    mainFrame.updateLayout(frame, self.attributesUIReadOnly, self.inspectMainView)

    if self.inspectMainView == "experience" then
        if self.attributesUIReadOnly then
            mainFrame.updateInspectInfoPanel(frame, self.currentInspectData)
        else
            self:RefreshMainExperiencePanel()
        end
    elseif self.inspectMainView == "healthBar" then
        if self.RefreshMainHealthConfigPanel then
            self:RefreshMainHealthConfigPanel()
        end
    end

    if frame.SaveButton then
        frame.SaveButton:SetShown((not self.attributesUIReadOnly) and self.inspectMainView == "attributes")
    end

    if frame.ResetButton then
        frame.ResetButton:SetShown((not self.attributesUIReadOnly) and self.inspectMainView == "attributes")
    end

    if frame.TitleText then
        frame.TitleText:SetText(self.attributesUITitleText or "Sistema de Atributos y Talentos")
    end
end

function addon:RefreshMainHealthConfigPanel()
    local frame = _G.GACAttributesFrame
    if not frame or not frame.MainHealthBarPanel then
        return
    end

    local maxModifier = self.GetPlayerHealthMaxModifier and self:GetPlayerHealthMaxModifier() or 0
    local shieldValue = self.GetPlayerHealthShieldValue and self:GetPlayerHealthShieldValue() or 0

    if frame.HealthBarCurrentModifierValue then
        frame.HealthBarCurrentModifierValue:SetText(tostring(maxModifier))
    end

    if frame.HealthBarCurrentShieldValue then
        frame.HealthBarCurrentShieldValue:SetText(tostring(shieldValue))
    end

    if frame.HealthBarAddLifeButton then
        frame.HealthBarAddLifeButton:SetText("Dar vida")
    end

    if frame.HealthBarRemoveLifeButton then
        frame.HealthBarRemoveLifeButton:SetText("Quitar vida")
    end

    if frame.HealthBarAddShieldButton then
        frame.HealthBarAddShieldButton:SetText("Dar escudo")
    end

    if frame.HealthBarRemoveShieldButton then
        frame.HealthBarRemoveShieldButton:SetText("Quitar escudo")
    end

    if frame.HealthBarAddMaxButton then
        frame.HealthBarAddMaxButton:SetText("Añadir a vida maxima")
    end

    if frame.HealthBarRemoveMaxButton then
        frame.HealthBarRemoveMaxButton:SetText("Quitar de vida maxima")
    end
end

function addon:RefreshMainExperiencePanel()
    local frame = _G.GACAttributesFrame
    if not frame or not frame.MainExperiencePanel then
        return
    end

    local snapshot = self:GetExperienceProgressSnapshot()
    local requiredExperienceText = snapshot.requiredExperience and tostring(snapshot.requiredExperience) or "MAX"

    frame.MainExperienceLevelValue:SetText(tostring(snapshot.level))
    frame.MainExperienceCategoryValue:SetText(snapshot.category)
    frame.MainExperienceCurrentInput:SetText(tostring(snapshot.currentExperience))
    frame.MainExperienceRequiredValue:SetText(requiredExperienceText)

    local entry = self.GetLevelEntry and self:GetLevelEntry(snapshot.category, snapshot.level)
    if entry then
        frame.MainExperienceHPValue:SetText(tostring(entry.maxHealth or "-"))
        frame.MainExperienceAttLimitValue:SetText(tostring(entry.attPoints or "-"))
        frame.MainExperienceSkillLimitValue:SetText(tostring(entry.skillPoints or "-"))
        frame.MainExperienceHeroicLimitValue:SetText(tostring(entry.heroicPoints or "-"))
        frame.MainExperienceTraitsLimitValue:SetText(tostring(entry.maxPositiveTraits or "-"))
    else
        frame.MainExperienceHPValue:SetText("-")
    end

    local isPrestigeAvailable = self.IsPrestigeAvailable and self:IsPrestigeAvailable() or false
    if frame.MainExperiencePrestigeMessage then
        frame.MainExperiencePrestigeMessage:SetShown(isPrestigeAvailable)
    end
    if frame.MainExperiencePrestigeButton then
        frame.MainExperiencePrestigeButton:SetShown(isPrestigeAvailable)
    end

    buildCategoryDropdown(frame)
    buildLevelDropdown(frame, snapshot.category)

    UIDropDownMenu_SetText(frame.MainExperienceCategoryDropdown, snapshot.category)
    UIDropDownMenu_SetText(frame.MainExperienceLevelDropdown, tostring(snapshot.level))
end

function addon:ShowMainFrameExperienceUI()
    local frame = _G.GACAttributesFrame
    if not frame then
        print("No se pudo crear la interfaz XML.")
        return
    end

    self:BuildAttributesUI()
    self.currentInspectTargetName = nil
    self.currentInspectData = nil
    self:SetAttributesUIReadOnly(false, "Sistema de Atributos y Talentos")
    self:RefreshAttributesUIValues()
    self:SelectMainFrameView("experience")
    frame:Show()
end

function addon:ToggleMainFrameExperienceUI()
    local frame = _G.GACAttributesFrame
    if not frame then
        print("No se pudo crear la interfaz XML.")
        return
    end

    self:BuildAttributesUI()

    if frame:IsShown() and (not self.attributesUIReadOnly) and self.inspectMainView == "experience" then
        frame:Hide()
        return
    end

    self:ShowMainFrameExperienceUI()
end
