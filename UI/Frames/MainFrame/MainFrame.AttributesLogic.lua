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

local function formatValueMap(values)
    if not values or not next(values) then return nil end
    local parts = {}
    for k, v in pairs(values) do
        local localizedKey = addon:GetLocalizedText(k)
        table.insert(parts, localizedKey .. ": " .. tostring(v))
    end
    table.sort(parts)
    return table.concat(parts, ", ")
end

function addon:RefreshMainArmourPanel()
    local frame = _G.GACAttributesFrame
    if not frame then return end

    -- Crear panel de armadura si no existe
    if not frame.MainArmourPanel then
        frame.MainArmourPanel = CreateFrame("Frame", nil, frame.InspectContentPanel or frame)
        frame.MainArmourPanel:SetAllPoints()
        
        local scrollFrame = CreateFrame("ScrollFrame", "$parentArmourScroll", frame.MainArmourPanel, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", 8, -8)
        scrollFrame:SetPoint("BOTTOMRIGHT", -28, 8)
        
        local scrollChild = CreateFrame("Frame", nil, scrollFrame)
        scrollChild:SetSize(scrollFrame:GetWidth() - 10, 1)
        scrollFrame:SetScrollChild(scrollChild)
        frame.MainArmourPanel.scrollChild = scrollChild
        frame.MainArmourPanel.cards = {}
    end

    local scrollChild = frame.MainArmourPanel.scrollChild
    for _, card in ipairs(frame.MainArmourPanel.cards) do card:Hide() end

    local summary = self.GetTRP3ExtendedEquippedArmourSummary and self:GetTRP3ExtendedEquippedArmourSummary()
    if not summary or #summary.pieces == 0 then return end

    local yOffset = 0
    for i, piece in ipairs(summary.pieces) do
        local card = frame.MainArmourPanel.cards[i]
        if not card then
            card = CreateFrame("Frame", nil, scrollChild, "BackdropTemplate")
            card:SetBackdrop({
                bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                tile = true, tileSize = 16, edgeSize = 12,
                insets = { left = 2, right = 2, top = 2, bottom = 2 }
            })
            card:SetBackdropColor(0, 0, 0, 0.4)
            card:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
            
            card.title = card:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            card.title:SetPoint("TOPLEFT", 12, -12)

            -- Botón de quitar durabilidad (Escudo roto)
            card.breakButton = CreateFrame("Button", nil, card, "UIPanelButtonTemplate")
            card.breakButton:SetSize(26, 22)
            card.breakButton:SetPoint("TOPRIGHT", -8, -8)
            local breakIcon = card.breakButton:CreateTexture(nil, "ARTWORK")
            breakIcon:SetTexture("Interface\\Icons\\Ability_Warrior_ShieldBreak")
            breakIcon:SetSize(14, 14)
            breakIcon:SetPoint("CENTER")
            card.breakButton:SetScript("OnClick", function()
                addon:UpdateItemDurability(card.slotID, card.itemID, card.maxDurability, -1)
                addon:RefreshMainArmourPanel()
            end)

            -- Botón de añadir durabilidad (Escudo normal)
            card.normalButton = CreateFrame("Button", nil, card, "UIPanelButtonTemplate")
            card.normalButton:SetSize(26, 22)
            card.normalButton:SetPoint("RIGHT", card.breakButton, "LEFT", -2, 0)
            local normalIcon = card.normalButton:CreateTexture(nil, "ARTWORK")
            normalIcon:SetTexture("Interface\\Icons\\INV_Shield_01")
            normalIcon:SetSize(14, 14)
            normalIcon:SetPoint("CENTER")
            card.normalButton:SetScript("OnClick", function()
                addon:UpdateItemDurability(card.slotID, card.itemID, card.maxDurability, 1)
                addon:RefreshMainArmourPanel()
            end)

            -- Ajustar título
            card.title:SetPoint("RIGHT", card.normalButton, "LEFT", -4, 0)

            card.details = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            card.details:SetPoint("TOPLEFT", card.title, "BOTTOMLEFT", 0, -4)
            card.details:SetWidth(scrollChild:GetWidth() - 24)
            card.details:SetJustifyH("LEFT")
            
            table.insert(frame.MainArmourPanel.cards, card)
        end
        
        card:Show()
        card:SetPoint("TOPLEFT", 0, yOffset)
        card:SetWidth(scrollChild:GetWidth())

        -- Guardar referencias para la lógica de los botones
        card.slotID = piece.slotID
        card.itemID = piece.itemID
        card.maxDurability = piece.attributes.durability or 0

        local pieceName = addon:GetLocalizedText(piece.pieceName)
        local armourType = addon:GetLocalizedText(piece.armourType)
        local reinforcement = addon:GetLocalizedText(piece.reinforcement)
        
        card.title:SetText(pieceName .. " (|cffffd100" .. armourType .. "|r)")
        
        local lines = {}
        table.insert(lines, "|cff808080Item:|r " .. piece.itemName)
        table.insert(lines, "|cff808080Refuerzo:|r " .. reinforcement)
        
        local attr = formatValueMap(piece.attributes)
        if attr then table.insert(lines, "|cff00ff00Atributos:|r " .. attr) end
        local prop = formatValueMap(piece.properties)
        if prop then table.insert(lines, "|cff00ffffPropiedades:|r " .. prop) end
        local req = formatValueMap(piece.requirements)
        if req then table.insert(lines, "|cffff0000Requisitos:|r " .. req) end
        local pen = formatValueMap(piece.penalties)
        if pen then table.insert(lines, "|cffff8000Penalizaciones:|r " .. pen) end
        
        card.details:SetText(table.concat(lines, "\n"))
        local h = card.details:GetStringHeight() + 32
        card:SetHeight(h)
        yOffset = yOffset - (h + 6)
    end
    scrollChild:SetHeight(math.abs(yOffset))
end
