local addonName, addon = ...

local function toNumberOrZero(text)
    local value = tonumber(text)
    if value == nil then
        return 0
    end

    return math.floor(value)
end

local function createNumericInput(parent, width, height)
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

local function setInputEnabled(input, enabled)
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

function addon:SelectMainFrameView(view)
    local frame = _G.GACAttributesFrame
    if not frame then
        return
    end

    if frame.AttributesPanel then
        frame.AttributesPanel:Show()
    end

    if frame.SaveButton then
        frame.SaveButton:SetShown(not self.attributesUIReadOnly)
    end

    if frame.ResetButton then
        frame.ResetButton:SetShown(not self.attributesUIReadOnly)
    end

    if frame.TitleText then
        frame.TitleText:SetText(self.attributesUITitleText or "Sistema de Atributos y Talentos")
    end
end

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
        header:SetText(group.name)

        local attrInput = createNumericInput(card, 44, 20)
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
            talentLabel:SetText(talent)

            local talentInput = createNumericInput(card, 44, 18)
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

function addon:SetAttributesUIReadOnly(isReadOnly, titleText)
    local frame = _G.GACAttributesFrame
    if not frame then
        return
    end

    self.attributesUIReadOnly = isReadOnly and true or false
    self.attributesUITitleText = titleText or "Sistema de Atributos y Talentos"

    frame.TitleText:SetText(self.attributesUITitleText)
    frame.SaveButton:SetShown(not self.attributesUIReadOnly)
    frame.ResetButton:SetShown(not self.attributesUIReadOnly)

    if not self.uiControls then
        return
    end

    for _, input in pairs(self.uiControls.attributes) do
        setInputEnabled(input, not self.attributesUIReadOnly)
    end

    for _, input in pairs(self.uiControls.talents) do
        setInputEnabled(input, not self.attributesUIReadOnly)
    end

    self:SelectMainFrameView()
end

function addon:FillAttributesUIFromData(data)
    if not self.uiControls then
        return
    end

    local attributes = (type(data) == "table" and data.attributes) or {}
    local talents = (type(data) == "table" and data.talents) or {}

    for attribute, input in pairs(self.uiControls.attributes) do
        input:SetText(tostring(tonumber(attributes[attribute]) or 0))
    end

    for talent, input in pairs(self.uiControls.talents) do
        input:SetText(tostring(tonumber(talents[talent]) or 0))
    end
end

function addon:ShowTargetAttributesUI(targetName, data)
    local frame = _G.GACAttributesFrame
    if not frame then
        print("No se pudo crear la interfaz XML.")
        return
    end

    self:BuildAttributesUI()
    self:FillAttributesUIFromData(data)
    self:SetAttributesUIReadOnly(true, "Atributos y Talentos de " .. (targetName or "Objetivo"))
    frame:Show()
end

function addon:RefreshAttributesUIValues()
    if not self.uiControls then
        return
    end

    if not self.characterData then
        return
    end

    for attribute, input in pairs(self.uiControls.attributes) do
        input:SetText(tostring(self.characterData.attributes[attribute] or 0))
    end

    for talent, input in pairs(self.uiControls.talents) do
        input:SetText(tostring(self.characterData.talents[talent] or 0))
    end
end

function addon:SaveAttributesUIValues()
    if not self.uiControls then
        return
    end

    if not self.characterData then
        return
    end

    for attribute, input in pairs(self.uiControls.attributes) do
        self.characterData.attributes[attribute] = toNumberOrZero(input:GetText())
    end

    for talent, input in pairs(self.uiControls.talents) do
        self.characterData.talents[talent] = toNumberOrZero(input:GetText())
    end

    self:RefreshAttributesUIValues()
    print("|cff00ff00" .. addonName .. "|r valores guardados para este personaje.")
end

function addon:ResetAttributesUIValues()
    if not self.characterData then
        return
    end

    for _, group in ipairs(self.attributeGroups) do
        self.characterData.attributes[group.name] = 0

        for _, talent in ipairs(group.talents) do
            self.characterData.talents[talent] = 0
        end
    end

    self:RefreshAttributesUIValues()
    print("|cffffff00" .. addonName .. "|r valores reiniciados a 0.")
end

function addon:ToggleAttributesUI()
    local frame = _G.GACAttributesFrame
    if not frame then
        print("No se pudo crear la interfaz XML.")
        return
    end

    self:BuildAttributesUI()
    self:SetAttributesUIReadOnly(false, "Sistema de Atributos y Talentos")
    self:RefreshAttributesUIValues()
    self:SelectMainFrameView()

    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end
