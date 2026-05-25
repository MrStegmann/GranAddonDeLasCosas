local addonName, addon = ...

local function buildCategoryDropdown(frame)
    UIDropDownMenu_Initialize(frame.categoryDropdown, function(dropdown, level)
        if level ~= 1 then
            return
        end

        for _, categoryName in ipairs(addon.levelCategories or {}) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = categoryName
            info.value = categoryName
            info.func = function()
                addon:SetExperienceCategory(categoryName)
                addon:RefreshExperienceConfigFrame()
                if addon.UpdateQuickExperienceBar then
                    addon:UpdateQuickExperienceBar()
                end
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
end

local function buildLevelDropdown(frame, category)
    UIDropDownMenu_Initialize(frame.levelDropdown, function(dropdown, level)
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
                addon:RefreshExperienceConfigFrame()
                if addon.UpdateQuickExperienceBar then
                    addon:UpdateQuickExperienceBar()
                end
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
end

function addon:RefreshExperienceConfigFrame()
    local frame = self.experienceConfigFrame
    if not frame then
        return
    end

    local snapshot = self:GetExperienceProgressSnapshot()
    local requiredExperienceText = snapshot.requiredExperience and tostring(snapshot.requiredExperience) or "MAX"

    frame.levelValue:SetText(tostring(snapshot.level))
    frame.categoryValue:SetText(snapshot.category)
    frame.currentExperienceInput:SetText(tostring(snapshot.currentExperience))
    frame.requiredExperienceValue:SetText(requiredExperienceText)

    local isPrestigeAvailable = self.IsPrestigeAvailable and self:IsPrestigeAvailable() or false
    if frame.prestigeMessageText then
        frame.prestigeMessageText:SetShown(isPrestigeAvailable)
    end
    if frame.prestigeButton then
        frame.prestigeButton:SetShown(isPrestigeAvailable)
    end

    buildCategoryDropdown(frame)
    buildLevelDropdown(frame, snapshot.category)

    UIDropDownMenu_SetText(frame.categoryDropdown, snapshot.category)
    UIDropDownMenu_SetText(frame.levelDropdown, tostring(snapshot.level))
end

function addon:CreateExperienceConfigFrame()
    if self.experienceConfigFrame then
        return
    end

    local frame = CreateFrame("Frame", "GACExperienceConfigFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(340, 280)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetFrameStrata("DIALOG")
    frame:Hide()

    frame.TitleText:SetText("Configuracion de EXP")

    local categoryLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    categoryLabel:SetPoint("TOPLEFT", 18, -36)
    categoryLabel:SetText("Categoria")

    local categoryValue = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    categoryValue:SetPoint("LEFT", categoryLabel, "RIGHT", 8, 0)
    categoryValue:SetText("-")

    local categoryDropdown = CreateFrame("Frame", "GACExperienceCategoryDropdown", frame, "UIDropDownMenuTemplate")
    categoryDropdown:SetPoint("TOPLEFT", categoryLabel, "BOTTOMLEFT", -16, -6)
    UIDropDownMenu_SetWidth(categoryDropdown, 150)

    local levelLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    levelLabel:SetPoint("TOPRIGHT", -92, -36)
    levelLabel:SetText("Nivel")

    local levelValue = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    levelValue:SetPoint("LEFT", levelLabel, "RIGHT", 8, 0)
    levelValue:SetText("1")

    local levelDropdown = CreateFrame("Frame", "GACExperienceLevelDropdown", frame, "UIDropDownMenuTemplate")
    levelDropdown:SetPoint("TOPLEFT", levelLabel, "BOTTOMLEFT", -16, -6)
    UIDropDownMenu_SetWidth(levelDropdown, 90)

    local currentExperienceLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    currentExperienceLabel:SetPoint("TOPLEFT", categoryDropdown, "BOTTOMLEFT", 16, -16)
    currentExperienceLabel:SetText("EXP actual")

    local currentExperienceInput = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    currentExperienceInput:SetSize(100, 20)
    currentExperienceInput:SetPoint("LEFT", currentExperienceLabel, "RIGHT", 10, 0)
    currentExperienceInput:SetAutoFocus(false)
    currentExperienceInput:SetNumeric(true)
    currentExperienceInput:SetMaxLetters(8)
    currentExperienceInput:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
        addon:RefreshExperienceConfigFrame()
    end)
    currentExperienceInput:SetScript("OnEnterPressed", function(self)
        addon:SetCurrentExperience(self:GetText())
        addon:RefreshExperienceConfigFrame()
        if addon.UpdateQuickExperienceBar then
            addon:UpdateQuickExperienceBar()
        end
        self:ClearFocus()
    end)

    local requiredExperienceLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    requiredExperienceLabel:SetPoint("TOPLEFT", currentExperienceLabel, "BOTTOMLEFT", 0, -22)
    requiredExperienceLabel:SetText("EXP necesaria")

    local requiredExperienceValue = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    requiredExperienceValue:SetPoint("LEFT", requiredExperienceLabel, "RIGHT", 10, 0)
    requiredExperienceValue:SetText("-")

    local applyButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    applyButton:SetSize(120, 24)
    applyButton:SetPoint("BOTTOM", frame, "BOTTOM", 0, 14)
    applyButton:SetText("Aplicar")
    applyButton:SetScript("OnClick", function()
        addon:SetCurrentExperience(currentExperienceInput:GetText())
        addon:RefreshExperienceConfigFrame()
        if addon.UpdateQuickExperienceBar then
            addon:UpdateQuickExperienceBar()
        end
        currentExperienceInput:ClearFocus()
    end)

    local helpText = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    helpText:SetPoint("BOTTOM", applyButton, "TOP", 0, 6)
    helpText:SetText("Usa Enter o el boton Aplicar para confirmar EXP.")

    local prestigeMessageText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    prestigeMessageText:SetPoint("TOPLEFT", requiredExperienceLabel, "BOTTOMLEFT", 0, -20)
    prestigeMessageText:SetPoint("RIGHT", frame, "RIGHT", -20, 0)
    prestigeMessageText:SetJustifyH("LEFT")
    prestigeMessageText:SetText("Prestigio disponible. Reiniciarás tus atributos y talentos y volverás al nivel 1 de la siguiente categoría.")
    prestigeMessageText:Hide()

    local prestigeButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    prestigeButton:SetSize(120, 24)
    prestigeButton:SetPoint("TOPLEFT", prestigeMessageText, "BOTTOMLEFT", 0, -8)
    prestigeButton:SetText("Prestigiar")
    prestigeButton:SetScript("OnClick", function()
        if addon.PrestigeToNextCategory and addon:PrestigeToNextCategory() then
            addon:RefreshExperienceConfigFrame()
            if addon.RefreshAttributesUIValues then
                addon:RefreshAttributesUIValues()
            end
            if addon.UpdateQuickExperienceBar then
                addon:UpdateQuickExperienceBar()
            end
        end
    end)
    prestigeButton:Hide()

    frame.categoryDropdown = categoryDropdown
    frame.levelDropdown = levelDropdown
    frame.levelValue = levelValue
    frame.categoryValue = categoryValue
    frame.currentExperienceInput = currentExperienceInput
    frame.requiredExperienceValue = requiredExperienceValue
    frame.applyButton = applyButton
    frame.prestigeMessageText = prestigeMessageText
    frame.prestigeButton = prestigeButton

    self.experienceConfigFrame = frame
    self:RefreshExperienceConfigFrame()
end

function addon:ToggleExperienceConfigUI()
    if self.ToggleMainFrameExperienceUI then
        self:ToggleMainFrameExperienceUI()
        return
    end

    if not self.experienceConfigFrame then
        self:CreateExperienceConfigFrame()
    end

    if self.experienceConfigFrame:IsShown() then
        self.experienceConfigFrame:Hide()
        return
    end

    self:RefreshExperienceConfigFrame()
    self.experienceConfigFrame:Show()
end
