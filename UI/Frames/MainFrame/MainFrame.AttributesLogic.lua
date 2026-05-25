local addonName, addon = ...
local mainFrame = addon.mainFrame or {}

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
        mainFrame.setInputEnabled(input, not self.attributesUIReadOnly)
    end

    for _, input in pairs(self.uiControls.talents) do
        mainFrame.setInputEnabled(input, not self.attributesUIReadOnly)
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

function addon:RefreshTargetInspectUI(targetName, data)
    local frame = _G.GACAttributesFrame
    if not frame then
        return
    end

    self:BuildAttributesUI()
    self:FillAttributesUIFromData(data)
    mainFrame.updateInspectInfoPanel(frame, data)

    self.currentInspectTargetName = targetName
    self.currentInspectData = data

    if frame:IsShown() and self.attributesUIReadOnly then
        frame.TitleText:SetText("Atributos y Talentos de " .. (targetName or "Objetivo"))
    end
end

function addon:ShowTargetAttributesUI(targetName, data)
    local frame = _G.GACAttributesFrame
    if not frame then
        print("No se pudo crear la interfaz XML.")
        return
    end

    self:RefreshTargetInspectUI(targetName, data)
    self.inspectMainView = "attributes"
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
        self.characterData.attributes[attribute] = mainFrame.toNumberOrZero(input:GetText())
    end

    for talent, input in pairs(self.uiControls.talents) do
        self.characterData.talents[talent] = mainFrame.toNumberOrZero(input:GetText())
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
    self.inspectMainView = "attributes"
    self.currentInspectTargetName = nil
    self.currentInspectData = nil
    self:SetAttributesUIReadOnly(false, "Sistema de Atributos y Talentos")
    self:RefreshAttributesUIValues()
    self:SelectMainFrameView()

    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end
