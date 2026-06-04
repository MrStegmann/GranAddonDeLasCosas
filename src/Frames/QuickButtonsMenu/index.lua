local addonName, GAC = ...

-- Namespace local para utilidades de acciones rápidas
GAC.quickActions = GAC.quickActions or {}
local qa = GAC.quickActions

qa.setupTooltip = function(button, title, ...)
    local lines = {...}
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(title)
        for _, line in ipairs(lines) do
            if type(line) == "table" then GameTooltip:AddLine(unpack(line)) else GameTooltip:AddLine(line, 1, 1, 1) end
        end
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

qa.createQuickButton = function(parent)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    btn:SetBackdropColor(0, 0, 0, 0.6)
    btn:SetBackdropBorderColor(0.25, 0.78, 0.94, 0.5)

    btn:HookScript("OnEnter", function(self)
        self:SetBackdropColor(0.25, 0.78, 0.94, 0.3)
    end)
    btn:HookScript("OnLeave", function(self)
        self:SetBackdropColor(0, 0, 0, 0.6)
    end)
    return btn
end

local function injectModifier(pendingTable)
    if not pendingTable then return end
    local mod, has = GAC:GetQuickModifierValue()
    if has then
        pendingTable.hasModifier = true
        pendingTable.modifierValue = mod
    end
end

function GAC:GetQuickModifierValue()
    if not self.quickActionsFrame or not self.quickActionsFrame.modifierInput then
        return 0, false
    end
    local text = self.quickActionsFrame.modifierInput:GetText()
    if text == "" then return 0, false end
    local val = tonumber(text)
    return val or 0, true
end

function GAC:UpdateTargetInspectButtonVisibility()
    if not self.targetInspectQuickButton then return end
    local canShow = UnitExists("target") and UnitIsPlayer("target") and not UnitIsUnit("target", "player")
    self.targetInspectQuickButton:SetShown(canShow)
end

local function ensureQuickFramePosition()
    if not GAC.characterData or not GAC.characterData.ui then return end
    GAC.characterData.ui.quickFrame = GAC.characterData.ui.quickFrame or {}
    local pos = GAC.characterData.ui.quickFrame
    if pos.anchor == nil then
        pos.anchor, pos.relativeAnchor, pos.x, pos.y = "CENTER", "CENTER", -260, -120
    end
end

function GAC:StartCustomDiceRoll(quantity, faces)
    local q = tonumber(quantity) or 1
    local f = tonumber(faces) or 20
    local mod, has = self:GetQuickModifierValue()
    
    -- Dado que no hay un evento de "custom", usamos un mensaje simple o extendemos el sistema
    -- Por ahora disparamos el RandomRoll de WoW
    RandomRoll(1, f)
    -- Aquí se podría añadir lógica de captura similar a las otras si fuera necesario
end

function GAC:CreateQuickActionsFrame()
    if self.quickActionsFrame then return end

    ensureQuickFramePosition()
    local pos = self.characterData and self.characterData.ui and self.characterData.ui.quickFrame
    local anchor, relAnchor, x, y = "CENTER", "CENTER", -260, -120
    if pos then
        anchor, relAnchor = pos.anchor or anchor, pos.relativeAnchor or relAnchor
        x, y = tonumber(pos.x) or x, tonumber(pos.y) or y
    end

    local frame = CreateFrame("Frame", "GACQuickActionsFrame", UIParent, "BackdropTemplate")
    frame:SetPoint(anchor, UIParent, relAnchor, x, y)
    frame:SetSize(340, 60) -- Altura dinámica luego
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetClampedToScreen(true)
    frame:SetFrameStrata("MEDIUM")
    frame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 8, edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    frame:SetBackdropColor(0.05, 0.06, 0.08, 0.78)
    frame:SetBackdropBorderColor(0.25, 0.78, 0.94, 0.75)

    frame:SetScript("OnDragStart", function(s) s:StartMoving() end)
    frame:SetScript("OnDragStop", function(s)
        s:StopMovingOrSizing()
        local a, _, ra, ox, oy = s:GetPoint(1)
        if not GAC.characterData.ui.quickFrame then GAC.characterData.ui.quickFrame = {} end
        GAC.characterData.ui.quickFrame.anchor = a
        GAC.characterData.ui.quickFrame.relativeAnchor = ra
        GAC.characterData.ui.quickFrame.x = math.floor(ox + 0.5)
        GAC.characterData.ui.quickFrame.y = math.floor(oy + 0.5)
    end)

    -- Botones
    local buttonX, buttonSpacing, buttonRowSpacing = 8, 1, 1

    -- 1. Dados (Talentos)
    local diceButton = qa.createQuickButton(frame)
    diceButton:SetSize(33, 27)
    diceButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", buttonX, 0)
    local diceIcon = diceButton:CreateTexture(nil, "ARTWORK")
    diceIcon:SetTexture("Interface\\Icons\\INV_Misc_Dice_01")
    diceIcon:SetSize(15, 15)
    diceIcon:SetPoint("CENTER")
    diceButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    diceButton:SetScript("OnClick", function(_, btn)
        if btn == "RightButton" then
            if GAC.lastTalentRolled then
                GAC:StartTalentRoll(GAC.lastTalentRolled.attributeName, GAC.lastTalentRolled.talentName)
                injectModifier(GAC.pendingTalentRoll)
            else
                print("No has lanzado ningún dado de talento.")
            end
        else
            if not GAC.quickActionsMenuFrame then GAC.quickActionsMenuFrame = CreateFrame("Frame", "GACQuickActionsMenuFrame", UIParent, "UIDropDownMenuTemplate") end
            EasyMenu(GAC:CreateTalentsOptions(), GAC.quickActionsMenuFrame, frame, 0, 0, "MENU", 2)
        end
    end)
    qa.setupTooltip(diceButton, "Dado (d20)", 
        "Click para abrir menu de tiradas por talento",
        {"Click derecho: Repetir última tirada", 0.7, 0.7, 1}
    )

    -- 2. Atributos
    local attrButton = qa.createQuickButton(frame)
    attrButton:SetSize(33, 27)
    attrButton:SetPoint("LEFT", diceButton, "RIGHT", buttonSpacing, 0)
    local attrIcon = attrButton:CreateTexture(nil, "ARTWORK")
    attrIcon:SetTexture("Interface\\Icons\\INV_Misc_Book_11")
    attrIcon:SetSize(15, 15)
    attrIcon:SetPoint("CENTER")
    attrButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    attrButton:SetScript("OnClick", function(_, btn)
        if btn == "RightButton" then
            if GAC.lastAttributeRolled then
                GAC:StartAttributeRoll(GAC.lastAttributeRolled.attributeName)
                injectModifier(GAC.pendingAttributeRoll)
            else
                print("No has lanzado ningún dado de atributo.")
            end
        else
            if not GAC.attributeActionsMenuFrame then GAC.attributeActionsMenuFrame = CreateFrame("Frame", "GACAttributeActionsMenuFrame", UIParent, "UIDropDownMenuTemplate") end
            EasyMenu(GAC:CreateAttributesOptions(), GAC.attributeActionsMenuFrame, frame, 0, 0, "MENU", 2)
        end
    end)
    qa.setupTooltip(attrButton, "Atributos (d20)", 
        "Click para abrir menu de tiradas por atributo",
        {"Click derecho: Repetir última tirada", 0.7, 0.7, 1}
    )

    -- 3. Vida
    local lifeButton = qa.createQuickButton(frame)
    lifeButton:SetSize(33, 27)
    lifeButton:SetPoint("BOTTOMLEFT", diceButton, "TOPLEFT", 0, buttonRowSpacing)
    local lifeIcon = lifeButton:CreateTexture(nil, "ARTWORK")
    lifeIcon:SetTexture("Interface\\Icons\\Spell_Holy_Renew")
    lifeIcon:SetSize(15, 15)
    lifeIcon:SetPoint("CENTER")
    lifeButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    lifeButton:SetScript("OnClick", function(_, b)
        if GAC.ModifyPlayerLife then GAC:ModifyPlayerLife(b == "RightButton" and -1 or 1) end
    end)
    qa.setupTooltip(lifeButton, "Modificar vida ±1", 
        "Clic izquierdo: Añade 1 punto de vida.", 
        {"Clic derecho: Quita 1 punto de vida.", 1, 0.7, 0.7}
    )

    -- 4. Escudo
    local shieldButton = qa.createQuickButton(frame)
    shieldButton:SetSize(33, 27)
    shieldButton:SetPoint("LEFT", lifeButton, "RIGHT", buttonSpacing, 0)
    local shieldIcon = shieldButton:CreateTexture(nil, "ARTWORK")
    shieldIcon:SetTexture("Interface\\Icons\\Spell_Holy_PowerWordShield")
    shieldIcon:SetSize(15, 15)
    shieldIcon:SetPoint("CENTER")
    shieldButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    shieldButton:SetScript("OnClick", function(_, b)
        if GAC.ModifyPlayerShield then GAC:ModifyPlayerShield(b == "RightButton" and -1 or 1) end
    end)
    qa.setupTooltip(shieldButton, "Modificar escudo ±1", 
        "Clic izquierdo: Añade 1 punto de escudo.", 
        {"Clic derecho: Quita 1 punto de escudo.", 1, 0.7, 0.7}
    )

    -- 5. Iniciativa
    local swordButton = qa.createQuickButton(frame)
    swordButton:SetSize(33, 27)
    swordButton:SetPoint("LEFT", attrButton, "RIGHT", buttonSpacing, 0)
    local swordIcon = swordButton:CreateTexture(nil, "ARTWORK")
    swordIcon:SetTexture("Interface\\Icons\\Ability_Rogue_Sprint")
    swordIcon:SetSize(15, 15)
    swordIcon:SetPoint("CENTER")
    swordButton:SetScript("OnClick", function()
        GAC:StartInitiativeRoll()
        local mod, has = GAC:GetQuickModifierValue()
        if has and GAC.pendingInitiativeRoll then
            GAC.pendingInitiativeRoll.hasModifier = true
            GAC.pendingInitiativeRoll.modifierValue = mod
        end
    end)
    qa.setupTooltip(swordButton, "Iniciativa (d100)", "Click para tirar Iniciativa")

    -- 6. Ataque
    local attackButton = qa.createQuickButton(frame)
    attackButton:SetSize(33, 27)
    attackButton:SetPoint("LEFT", swordButton, "RIGHT", buttonSpacing, 0)
    local attackIcon = attackButton:CreateTexture(nil, "ARTWORK")
    attackIcon:SetTexture("Interface\\Icons\\Ability_MeleeDamage")
    attackIcon:SetSize(15, 15)
    attackIcon:SetPoint("CENTER")
    attackButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    attackButton:SetScript("OnClick", function(_, btn)
        if btn == "RightButton" then
            if GAC.lastAttackRolled then
                GAC:StartAttackRoll(GAC.lastAttackRolled.dice, GAC.lastAttackRolled.talentKey, GAC.lastAttackRolled.talentLabel)
                injectModifier(GAC.pendingAttackRoll)
            else
                print("No has lanzado ningún dado de ataque.")
            end
        else
            if not GAC.attackActionsMenuFrame then GAC.attackActionsMenuFrame = CreateFrame("Frame", "GACAttackActionsMenuFrame", UIParent, "UIDropDownMenuTemplate") end
            EasyMenu(GAC:CreateAttackOptions(), GAC.attackActionsMenuFrame, frame, 0, 0, "MENU", 2)
        end
    end)
    qa.setupTooltip(attackButton, "Ataque", 
        "Click para abrir menu de tirada de ataque",
        {"Click derecho: Repetir última tirada", 0.7, 0.7, 1}
    )

    -- 7. Expandir Turnos
    local expandTurnButton = qa.createQuickButton(frame)
    expandTurnButton:SetSize(33, 27)
    expandTurnButton:SetPoint("LEFT", shieldButton, "RIGHT", buttonSpacing, 0)
    local expandIcon = expandTurnButton:CreateTexture(nil, "ARTWORK")
    expandIcon:SetTexture("Interface\\Icons\\INV_Misc_Map_01")
    expandIcon:SetSize(15, 15)
    expandIcon:SetPoint("CENTER")
    expandTurnButton:SetScript("OnClick", function()
        if GAC.SetTurnOrderMinimized then GAC:SetTurnOrderMinimized(false) end
        if GAC.UpdateTurnOrderFrameVisibility then GAC:UpdateTurnOrderFrameVisibility() end
    end)
    qa.setupTooltip(expandTurnButton, "Maximizar Orden de Turnos", 
        "Haz clic para mostrar el panel de orden de turnos si está minimizado.",
        {"Permite expandir el panel de gestión de turnos del grupo.", 0.8, 0.95, 1}
    )
    expandTurnButton:Hide()

    -- Modificador UI
    local modLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    modLabel:SetText("Mod")
    modLabel:SetPoint("LEFT", attackButton, "RIGHT", 4, 0)

    local modInput = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    modInput:SetSize(26, 18)
    modInput:SetPoint("LEFT", modLabel, "RIGHT", 10, 0)
    modInput:SetAutoFocus(false)
    modInput:SetMaxLetters(5)

    -- Custom Dice UI
    local dadoLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    dadoLabel:SetText("Dado")
    dadoLabel:SetPoint("LEFT", modInput, "RIGHT", 12, 0)

    local qtyInput = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    qtyInput:SetSize(22, 18)
    qtyInput:SetPoint("LEFT", dadoLabel, "RIGHT", 8, 0)
    qtyInput:SetAutoFocus(false)
    qtyInput:SetNumeric(true)
    qtyInput:SetText("1")

    local sep = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sep:SetText("d")
    sep:SetPoint("LEFT", qtyInput, "RIGHT", 5, 0)

    local faceInput = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    faceInput:SetSize(28, 18)
    faceInput:SetPoint("LEFT", sep, "RIGHT", 2, 0)
    faceInput:SetAutoFocus(false)
    faceInput:SetNumeric(true)
    faceInput:SetText("20")

    local customRollBtn = qa.createQuickButton(frame)
    customRollBtn:SetSize(33, 27)
    customRollBtn:SetPoint("LEFT", faceInput, "RIGHT", 1, 0)
    local customIcon = customRollBtn:CreateTexture(nil, "ARTWORK")
    customIcon:SetTexture("Interface\\Icons\\INV_Misc_Dice_02")
    customIcon:SetSize(15, 15)
    customIcon:SetPoint("CENTER")
    customRollBtn:SetScript("OnClick", function()
        GAC:StartCustomDiceRoll(qtyInput:GetText(), faceInput:GetText())
    end)
    qa.setupTooltip(customRollBtn, "Tirada Personalizada", "Lanza la cantidad y caras de dados indicadas.")

    -- Inspect Button (encima del frame)
    local inspectBtn = qa.createQuickButton(frame)
    inspectBtn:SetSize(29, 29)
    inspectBtn:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -8, -1)
    local inspectIcon = inspectBtn:CreateTexture(nil, "ARTWORK")
    inspectIcon:SetTexture("Interface\\Icons\\INV_Misc_Spyglass_03")
    inspectIcon:SetSize(16, 16)
    inspectIcon:SetPoint("CENTER")
    inspectBtn:SetScript("OnClick", function()
        if GAC.OpenTargetAttributesFromUnit then GAC:OpenTargetAttributesFromUnit("target") end
    end)
    qa.setupTooltip(inspectBtn, "Inspeccionar objetivo", "Muestra atributos y talentos del objetivo si usa este addon.")
    inspectBtn:Hide()

    -- Asignaciones al objeto GAC
    frame.modifierInput = modInput
    self.quickActionsFrame = frame
    self.turnOrderExpandQuickButton = expandTurnButton
    self.targetInspectQuickButton = inspectBtn

    frame:SetHeight(lifeButton:GetHeight() + diceButton:GetHeight() + buttonRowSpacing + 4)
    
    self:UpdateTargetInspectButtonVisibility()

    -- Registro de eventos para visibilidad
    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    eventFrame:SetScript("OnEvent", function() GAC:UpdateTargetInspectButtonVisibility() end)
end

-- Inicialización
C_Timer.After(1, function()
    GAC:CreateQuickActionsFrame()
end)
