local addonName, GAC = ...


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
    
    local canShow = false
    local currentTarget = UnitName("target")
    if currentTarget and UnitExists("target") and UnitIsPlayer("target") and not UnitIsUnit("target", "player") then
        local targetClean = Ambiguate(currentTarget, "none")
        if self.targetDataCache and self.targetDataCache[targetClean] then
            canShow = true
        end
    end
    -- GAC:SetupQuickTooltip(self.targetInspectQuickButton, "Inspeccionar a " .. currentTarget, "Muestra la ficha de personaje del objetivo actual")
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
    frame:SetSize(360, 65)
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
        ra = ra or a
        GAC.characterData.ui.quickFrame.anchor = a
        GAC.characterData.ui.quickFrame.relativeAnchor = ra
        GAC.characterData.ui.quickFrame.x = math.floor(ox + 0.5)
        GAC.characterData.ui.quickFrame.y = math.floor(oy + 0.5)
    end)

    -- Botones
    local buttonX, buttonSpacing, buttonRowSpacing = 10, 0, 0

    local function ShowModifyValuePopup(title, callback)
        if not GAC.modifyValuePopup then
            local f = CreateFrame("Frame", "GACModifyValuePopup", UIParent, "BackdropTemplate")
            f:SetSize(220, 110)
            f:SetPoint("CENTER")
            f:SetFrameStrata("DIALOG")
            f:SetBackdrop({
                bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                tile = true, tileSize = 32, edgeSize = 32,
                insets = { left = 11, right = 12, top = 12, bottom = 11 },
            })
            
            local text = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            text:SetPoint("TOP", 0, -20)
            f.text = text
            
            local editBox = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
            editBox:SetSize(80, 20)
            editBox:SetPoint("CENTER", 0, 0)
            editBox:SetAutoFocus(true)
            -- No usamos SetNumeric porque necesitamos aceptar números negativos como "-5"
            f.editBox = editBox
            
            local btn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
            btn:SetSize(80, 22)
            btn:SetPoint("BOTTOM", 0, 15)
            btn:SetText("Aceptar")
            f.btn = btn
            
            local closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
            closeBtn:SetPoint("TOPRIGHT", -5, -5)
            
            local function submit()
                local val = tonumber(f.editBox:GetText())
                if val then
                    if f.callback then f.callback(val) end
                end
                f:Hide()
            end
            
            btn:SetScript("OnClick", submit)
            editBox:SetScript("OnEnterPressed", submit)
            editBox:SetScript("OnEscapePressed", function() f:Hide() end)
            
            GAC.modifyValuePopup = f
        end
        
        GAC.modifyValuePopup.text:SetText(title)
        GAC.modifyValuePopup.editBox:SetText("")
        GAC.modifyValuePopup.callback = callback
        GAC.modifyValuePopup:Show()
        GAC.modifyValuePopup.editBox:SetFocus()
    end

    -- ================= ROW 1 (Utilities) =================
    -- 3. Vida
    local lifeButton = GAC:CreateQuickButton(frame)
    lifeButton:SetSize(25, 25)
    lifeButton:SetPoint("TOPLEFT", frame, "TOPLEFT", buttonX, -8)
    local lifeIcon = lifeButton:CreateTexture(nil, "ARTWORK")
    lifeIcon:SetTexture("Interface\\Icons\\Spell_Holy_Renew")
    lifeIcon:SetPoint("TOPLEFT", 2, -2)
    lifeIcon:SetPoint("BOTTOMRIGHT", -2, 2)
    lifeIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    lifeButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    lifeButton:SetScript("OnClick", function(_, b)
        if IsControlKeyDown() then
            ShowModifyValuePopup("Modificar Vida (Ej: 5 o -5)", function(val)
                if GAC.ModifyPlayerLife then GAC:ModifyPlayerLife(val) end
            end)
        else
            if GAC.ModifyPlayerLife then GAC:ModifyPlayerLife(b == "RightButton" and -1 or 1) end
        end
    end)
    GAC:SetupQuickTooltip(lifeButton, "Modificar vida ±1", 
        "Clic izquierdo: Añade 1 punto de vida.", 
        {"Clic derecho: Quita 1 punto de vida.", 1, 0.7, 0.7},
        {"Control + Clic: Introducir valor manual", 1, 1, 0.5}
    )

    -- 4. Escudo
    local shieldButton = GAC:CreateQuickButton(frame)
    shieldButton:SetSize(25, 25)
    shieldButton:SetPoint("LEFT", lifeButton, "RIGHT", buttonSpacing, 0)
    local shieldIcon = shieldButton:CreateTexture(nil, "ARTWORK")
    shieldIcon:SetTexture("Interface\\Icons\\Spell_Holy_PowerWordShield")
    shieldIcon:SetPoint("TOPLEFT", 2, -2)
    shieldIcon:SetPoint("BOTTOMRIGHT", -2, 2)
    shieldIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    shieldButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    shieldButton:SetScript("OnClick", function(_, b)
        if IsControlKeyDown() then
            ShowModifyValuePopup("Modificar Escudo (Ej: 5 o -5)", function(val)
                if GAC.ModifyPlayerShield then GAC:ModifyPlayerShield(val) end
            end)
        else
            if GAC.ModifyPlayerShield then GAC:ModifyPlayerShield(b == "RightButton" and -1 or 1) end
        end
    end)
    GAC:SetupQuickTooltip(shieldButton, "Modificar escudo ±1", 
        "Clic izquierdo: Añade 1 punto de escudo.", 
        {"Clic derecho: Quita 1 punto de escudo.", 1, 0.7, 0.7},
        {"Control + Clic: Introducir valor manual", 1, 1, 0.5}
    )

    -- 7. Expandir Turnos
    local expandTurnButton = GAC:CreateQuickButton(frame)
    expandTurnButton:SetSize(25, 25)
    expandTurnButton:SetPoint("LEFT", shieldButton, "RIGHT", buttonSpacing, 0)
    local expandIcon = expandTurnButton:CreateTexture(nil, "ARTWORK")
    expandIcon:SetTexture("Interface\\Icons\\INV_Misc_Map_01")
    expandIcon:SetPoint("TOPLEFT", 2, -2)
    expandIcon:SetPoint("BOTTOMRIGHT", -2, 2)
    expandIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    expandTurnButton:SetScript("OnClick", function()
        if GAC.SetTurnOrderMinimized then GAC:SetTurnOrderMinimized(false) end
        if GAC.UpdateTurnOrderFrameVisibility then GAC:UpdateTurnOrderFrameVisibility() end
    end)
    GAC:SetupQuickTooltip(expandTurnButton, "Maximizar Orden de Turnos", 
        "Haz clic para mostrar el panel de orden de turnos si está minimizado.",
        {"Permite expandir el panel de gestión de turnos del grupo.", 0.8, 0.95, 1}
    )
    expandTurnButton:Hide()

    -- Inspect Button (encima del frame)
    local inspectBtn = GAC:CreateQuickButton(frame)
    inspectBtn:SetSize(20, 20)
    inspectBtn:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -8, -1)
    local inspectIcon = inspectBtn:CreateTexture(nil, "ARTWORK")
    inspectIcon:SetTexture("Interface\\Icons\\INV_Misc_Spyglass_03")
    inspectIcon:SetPoint("TOPLEFT", 2, -2)
    inspectIcon:SetPoint("BOTTOMRIGHT", -2, 2)
    inspectIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    inspectBtn:SetScript("OnClick", function()
        local fullName = GetUnitName("target", true)
        if fullName then
            fullName = Ambiguate(fullName, "none")
            if GAC.RequestInspection then
                GAC:RequestInspection(fullName)
            end
            if GAC.OpenInspectionMenu then
                GAC.inspectedPlayer = {
                    name = fullName,
                    level = 0,
                    category = "normal",
                    race = "-",
                    class = "-",
                    maxHealth = 0,
                    currentShield = 0,
                    attributes = {},
                    talents = {}
                }
                GAC:OpenInspectionMenu()
            end
        end
    end)
    GAC:SetupQuickTooltip(inspectBtn, "Inspeccionar objetivo", "Muestra la ficha de personaje del objetivo actual")
    inspectBtn:Hide()

    -- Modificador UI
    local modLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    modLabel:SetText("Mod")
    modLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 215, -13)

    local modInput = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    modInput:SetSize(26, 18)
    modInput:SetPoint("LEFT", modLabel, "RIGHT", 10, 0)
    modInput:SetAutoFocus(false)
    modInput:SetMaxLetters(5)

    -- ================= ROW 2 (Actions) =================
    -- 1. Dados (Talentos)
    local diceButton = GAC:CreateQuickButton(frame)
    diceButton:SetSize(25, 25)
    diceButton:SetPoint("TOPLEFT", frame, "TOPLEFT", buttonX, -35)
    local diceIcon = diceButton:CreateTexture(nil, "ARTWORK")
    diceIcon:SetTexture("Interface\\Icons\\INV_Misc_Dice_01")
    diceIcon:SetPoint("TOPLEFT", 2, -2)
    diceIcon:SetPoint("BOTTOMRIGHT", -2, 2)
    diceIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    diceButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    diceButton:SetScript("OnClick", function(_, btn)
        if btn == "RightButton" then
            if GAC.lastTalentRolled then
                GAC:StartTalentRoll(GAC.lastTalentRolled.attributeName, GAC.lastTalentRolled.talentName)
            else
                print("No has lanzado ningún dado de talento.")
            end
        else
            if not GAC.quickActionsMenuFrame then GAC.quickActionsMenuFrame = CreateFrame("Frame", "GACQuickActionsMenuFrame", UIParent, "UIDropDownMenuTemplate") end
            EasyMenu(GAC:CreateTalentsOptions(), GAC.quickActionsMenuFrame, frame, 0, 0, "MENU", 2)
        end
    end)
    GAC:SetupQuickTooltip(diceButton, "Talentos (d20)", 
        "Click para abrir menu de tiradas por talento",
        {"Click derecho: Repetir última tirada", 0.7, 0.7, 1}
    )

    -- 2. Atributos
    local attrButton = GAC:CreateQuickButton(frame)
    attrButton:SetSize(25, 25)
    attrButton:SetPoint("LEFT", diceButton, "RIGHT", buttonSpacing, 0)
    local attrIcon = attrButton:CreateTexture(nil, "ARTWORK")
    attrIcon:SetTexture("Interface\\Icons\\INV_Misc_Book_11")
    attrIcon:SetPoint("TOPLEFT", 2, -2)
    attrIcon:SetPoint("BOTTOMRIGHT", -2, 2)
    attrIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    attrButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    attrButton:SetScript("OnClick", function(_, btn)
        if btn == "RightButton" then
            if GAC.lastAttributeRolled then
                GAC:StartAttributeRoll(GAC.lastAttributeRolled.attributeName)
            else
                print("No has lanzado ningún dado de atributo.")
            end
        else
            if not GAC.attributeActionsMenuFrame then GAC.attributeActionsMenuFrame = CreateFrame("Frame", "GACAttributeActionsMenuFrame", UIParent, "UIDropDownMenuTemplate") end
            EasyMenu(GAC:CreateAttributesOptions(), GAC.attributeActionsMenuFrame, frame, 0, 0, "MENU", 2)
        end
    end)
    GAC:SetupQuickTooltip(attrButton, "Atributos (d20)", 
        "Click para abrir menu de tiradas por atributo",
        {"Click derecho: Repetir última tirada", 0.7, 0.7, 1}
    )

    -- 5. Iniciativa
    local swordButton = GAC:CreateQuickButton(frame)
    swordButton:SetSize(25, 25)
    swordButton:SetPoint("LEFT", attrButton, "RIGHT", buttonSpacing, 0)
    local swordIcon = swordButton:CreateTexture(nil, "ARTWORK")
    swordIcon:SetTexture("Interface\\Icons\\Ability_Rogue_Sprint")
    swordIcon:SetPoint("TOPLEFT", 2, -2)
    swordIcon:SetPoint("BOTTOMRIGHT", -2, 2)
    swordIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    swordButton:SetScript("OnClick", function()
        GAC:StartInitiativeRoll()
        local mod, has = GAC:GetQuickModifierValue()
        if has and GAC.pendingInitiativeRoll then
            GAC.pendingInitiativeRoll.hasModifier = true
            GAC.pendingInitiativeRoll.modifierValue = mod
        end
    end)
    GAC:SetupQuickTooltip(swordButton, "Iniciativa (d100)", "Click para tirar Iniciativa")

    -- 6. Ataque
    local attackButton = GAC:CreateQuickButton(frame)
    attackButton:SetSize(25, 25)
    attackButton:SetPoint("LEFT", swordButton, "RIGHT", buttonSpacing, 0)
    local attackIcon = attackButton:CreateTexture(nil, "ARTWORK")
    attackIcon:SetTexture("Interface\\Icons\\Ability_MeleeDamage")
    attackIcon:SetPoint("TOPLEFT", 2, -2)
    attackIcon:SetPoint("BOTTOMRIGHT", -2, 2)
    attackIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    attackButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    attackButton:SetScript("OnClick", function(_, btn)
        if btn == "RightButton" then
            if GAC.lastAttackRolled then
                GAC:StartAttackRoll(GAC.lastAttackRolled.dice, GAC.lastAttackRolled.talentKey, GAC.lastAttackRolled.talentLabel)
            else
                print("No has lanzado ningún dado de ataque.")
            end
        else
            if not GAC.attackActionsMenuFrame then GAC.attackActionsMenuFrame = CreateFrame("Frame", "GACAttackActionsMenuFrame", UIParent, "UIDropDownMenuTemplate") end
            EasyMenu(GAC:CreateAttackOptions(), GAC.attackActionsMenuFrame, frame, 0, 0, "MENU", 2)
        end
    end)
    GAC:SetupQuickTooltip(attackButton, "Ataque", 
        "Click para abrir menu de tirada de ataque",
        {"Click derecho: Repetir última tirada", 0.7, 0.7, 1}
    )

    -- Dynamic Weapon Buttons
    frame.weaponButtons = {}
    local weaponSlotsData = {
        { id = 16, label = "Arma Principal" },
        { id = 17, label = "Arma Secundaria" },
        { id = 18, label = "Arma A Distancia" }
    }
    
    local lastWpnBtn = attackButton
    for i, wData in ipairs(weaponSlotsData) do
        local btn = GAC:CreateQuickButton(frame)
        btn:SetSize(25, 25)
        btn:SetPoint("LEFT", lastWpnBtn, "RIGHT", buttonSpacing + 2, 0)
        local icon = btn:CreateTexture(nil, "ARTWORK")
        icon:SetPoint("TOPLEFT", 2, -2)
        icon:SetPoint("BOTTOMRIGHT", -2, 2)
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        btn.icon = icon
        btn.slotID = wData.id
        btn.slotLabel = wData.label
        
        btn:RegisterForClicks("LeftButtonUp")
        btn:SetScript("OnClick", function(self, buttonClicked)
            if self.weaponKey then
                local wInfo = GAC:GetWeaponInfo(self.weaponKey)
                if not wInfo then return end
                
                local hasTwoHanded = wInfo.twoHanded ~= nil
                local hasThrowable = wInfo.throwable ~= nil
                
                if hasTwoHanded or hasThrowable then
                    if not GAC.weaponActionsMenuFrame then GAC.weaponActionsMenuFrame = CreateFrame("Frame", "GACWeaponActionsMenuFrame", UIParent, "UIDropDownMenuTemplate") end
                    
                    local menuOptions = {}
                    table.insert(menuOptions, { text = "Daño " .. self.slotLabel, isTitle = true, notCheckable = true })
                    table.insert(menuOptions, { text = "Ataque Normal", func = function() GAC:StartWeaponDamageRoll(self.weaponKey, "normal", self.weaponName) end, notCheckable = true })
                    if hasTwoHanded then
                        table.insert(menuOptions, { text = "Ataque a Dos Manos", func = function() GAC:StartWeaponDamageRoll(self.weaponKey, "twoHanded", self.weaponName) end, notCheckable = true })
                    end
                    if hasThrowable then
                        table.insert(menuOptions, { text = "Lanzar Arma", func = function() GAC:StartWeaponDamageRoll(self.weaponKey, "throwable", self.weaponName) end, notCheckable = true })
                    end
                    table.insert(menuOptions, { text = "Cancelar", notCheckable = true })
                    
                    EasyMenu(menuOptions, GAC.weaponActionsMenuFrame, self, 0, 0, "MENU", 2)
                else
                    GAC:StartWeaponDamageRoll(self.weaponKey, "normal", self.weaponName)
                end
            end
        end)
        btn:Hide()
        table.insert(frame.weaponButtons, btn)
        lastWpnBtn = btn
    end

    -- Custom Dice UI
    local dadoLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    dadoLabel:SetText("Dado")
    dadoLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 215, -41)

    local qtyInput = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    qtyInput:SetSize(22, 18)
    qtyInput:SetPoint("LEFT", dadoLabel, "RIGHT", 8, 0)
    qtyInput:SetAutoFocus(false)
    qtyInput:SetNumeric(true)
    qtyInput:SetText("1")

    local sep = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sep:SetText("d")
    sep:SetPoint("LEFT", qtyInput, "RIGHT", 3, 0)

    local faceInput = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    faceInput:SetSize(28, 18)
    faceInput:SetPoint("LEFT", sep, "RIGHT", 3, 0)
    faceInput:SetAutoFocus(false)
    faceInput:SetNumeric(true)
    faceInput:SetText("20")

    local customRollBtn = GAC:CreateQuickButton(frame)
    customRollBtn:SetSize(25, 25)
    customRollBtn:SetPoint("LEFT", faceInput, "RIGHT", 5, 0)
    local customIcon = customRollBtn:CreateTexture(nil, "ARTWORK")
    customIcon:SetTexture("Interface\\Icons\\INV_Misc_Dice_02")
    customIcon:SetPoint("TOPLEFT", 2, -2)
    customIcon:SetPoint("BOTTOMRIGHT", -2, 2)
    customIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    customRollBtn:SetScript("OnClick", function()
        GAC:StartCustomDiceRoll(qtyInput:GetText(), faceInput:GetText())
    end)
    GAC:SetupQuickTooltip(customRollBtn, "Tirada Personalizada", "Lanza la cantidad y caras de dados indicadas.")

    -- Asignaciones al objeto GAC
    frame.modifierInput = modInput
    self.quickActionsFrame = frame
    self.turnOrderExpandQuickButton = expandTurnButton
    self.targetInspectQuickButton = inspectBtn
    
    self:UpdateTargetInspectButtonVisibility()

    -- Registro de eventos para visibilidad
    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    eventFrame:SetScript("OnEvent", function() GAC:UpdateTargetInspectButtonVisibility() end)
    
    -- Crear marco de telemetría eliminado
    
    -- ================= ROW 3 (Armor Slots) =================
    local armorIconSize = 25
    local armorSpacing = 5
    frame.armorButtons = {}
    local armorSlots = {
        { id = "head", numId = 1, icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Head", label = "Cabeza" },
        { id = "chest", numId = 5, icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Chest", label = "Pecho" },
        { id = "hands", numId = 10, icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Hands", label = "Manos" },
        { id = "legs", numId = 7, icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Legs", label = "Piernas" }
    }
    for i, slotData in ipairs(armorSlots) do
        local btn = GAC:CreateQuickButton(frame)
        btn:SetSize(armorIconSize, armorIconSize)
        
        -- Formato 2x2 a la izquierda del marco principal
        local col = (i - 1) % 2
        local row = math.floor((i - 1) / 2)
        -- La columna 1 está más cerca del frame (-5), la columna 0 está más a la izquierda
        local xOffset = -5 - ((1 - col) * (armorIconSize + armorSpacing))
        local yOffset = -5 - (row * (armorIconSize + armorSpacing))
        btn:SetPoint("TOPRIGHT", frame, "TOPLEFT", xOffset, yOffset)
        
        local icon = btn:CreateTexture(nil, "ARTWORK")
        icon:SetTexture(slotData.icon)
        icon:SetPoint("TOPLEFT", 2, -2)
        icon:SetPoint("BOTTOMRIGHT", -2, 2)
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        btn.icon = icon
        btn.slotID = slotData.id
        btn.numId = slotData.numId
        btn.emptyIconPath = slotData.icon
        
        btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        btn:SetScript("OnClick", function(_, buttonClicked)
            local correctKey = nil
            local equippedArmor = GAC.characterData and GAC.characterData.inventory and GAC.characterData.inventory.equippedArmor
            if equippedArmor then
                if equippedArmor[slotData.id] then correctKey = slotData.id
                elseif equippedArmor[slotData.numId] then correctKey = slotData.numId
                elseif equippedArmor[tostring(slotData.numId)] then correctKey = tostring(slotData.numId) end
            end
            if not correctKey then return end
            if buttonClicked == "LeftButton" then
                if GAC.UpdateTRP3ItemDurability then GAC:UpdateTRP3ItemDurability(correctKey, 1) end
            elseif buttonClicked == "RightButton" then
                if GAC.UpdateTRP3ItemDurability then GAC:UpdateTRP3ItemDurability(correctKey, -1) end
            end
            
            -- Refrescar el tooltip si tenemos el ratón encima
            if GameTooltip:IsOwned(self) then
                local onEnter = self:GetScript("OnEnter")
                if onEnter then onEnter(self) end
            end
        end)
        btn:SetScript("OnEnter", function(self)
            local itemData = GAC.characterData and GAC.characterData.inventory and GAC.characterData.inventory.equippedArmor and (GAC.characterData.inventory.equippedArmor[slotData.id] or GAC.characterData.inventory.equippedArmor[slotData.numId] or GAC.characterData.inventory.equippedArmor[tostring(slotData.numId)])
            if not itemData or #itemData == 0 then return end
            local item = itemData[1]
            if not item or not item.armorData then return end
            
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            
            local totalPhys = 0
            local totalMag = 0
            for _, it in ipairs(itemData) do
                if it.armorData then
                    totalPhys = totalPhys + (tonumber(it.armorData.physRed) or 0)
                    totalMag = totalMag + (tonumber(it.armorData.magRed) or 0)
                end
            end
            
            GameTooltip:AddLine(item.itemName, 1, 1, 1)
            GameTooltip:AddLine("Reducción Física Total: " .. totalPhys, 1, 1, 1)
            GameTooltip:AddLine("Reducción Mágica Total: " .. totalMag, 1, 1, 1)
            
            local curDur = item.armorData.currentDurability or ""
            if not string.match(string.lower(curDur), "durabilidad") then
                curDur = "Durabilidad: " .. curDur
            end
            GameTooltip:AddLine(curDur, 1, 1, 1)
            
            if itemData.notAllowed then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("* COMBINACIÓN NO PERMITIDA *", 1, 0, 0)
            end
            
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Clic izquierdo: Añadir durabilidad", 0.5, 1, 0.5)
            GameTooltip:AddLine("Clic derecho: Quitar durabilidad", 1, 0.5, 0.5)
            
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
        table.insert(frame.armorButtons, btn)
    end
    
    frame.UpdateArmorIcons = function(self)
        local equippedArmor = GAC.characterData and GAC.characterData.inventory and GAC.characterData.inventory.equippedArmor
        for _, btn in ipairs(self.armorButtons) do
            local itemData = equippedArmor and (equippedArmor[btn.slotID] or equippedArmor[btn.numId] or equippedArmor[tostring(btn.numId)])
            
            btn:Show() -- Siempre visible
            
            if itemData and #itemData > 0 then
                btn:SetAlpha(1)
                local iconPath = itemData[1].itemIcon or "INV_Misc_QuestionMark"
                if type(iconPath) == "string" and not iconPath:match("\\") then
                    iconPath = "Interface\\Icons\\" .. iconPath
                end
                btn.icon:SetTexture(iconPath)
                if itemData.notAllowed then
                    btn.icon:SetVertexColor(1, 0, 0)
                else
                    local r, g, b = 1, 1, 1
                    if itemData[1].armorData and itemData[1].armorData.maxDurability and itemData[1].armorData.currentDurability then
                        local curStr = itemData[1].armorData.currentDurability
                        local curVal = string.match(curStr, "(%d+)")
                        if curVal then
                            curVal = tonumber(curVal)
                            local maxVal = tonumber(itemData[1].armorData.maxDurability)
                            if maxVal and maxVal > 0 then
                                local ratio = curVal / maxVal
                                if ratio > 1 then ratio = 1 end
                                if ratio < 0 then ratio = 0 end
                                
                                if curVal == 0 then
                                    btn.icon:SetDesaturated(true)
                                    r, g, b = 1, 0, 0
                                else
                                    btn.icon:SetDesaturated(false)
                                    if ratio > 0.5 then
                                        r = (1 - ratio) * 2
                                        g = 1
                                    else
                                        r = 1
                                        g = ratio * 2
                                    end
                                    b = 0
                                    
                                    -- Mezclamos un poco con blanco para no saturar excesivamente el icono original
                                    r = r * 0.6 + 0.4
                                    g = g * 0.6 + 0.4
                                    b = b * 0.6 + 0.4
                                end
                            end
                        end
                    end
                    btn.icon:SetVertexColor(r, g, b)
                end
            else
                btn:SetAlpha(0.2) -- Transparente si está vacío
                btn.icon:SetTexture(btn.emptyIconPath) -- Usamos la textura por defecto
                btn.icon:SetVertexColor(1, 1, 1)
            end
        end
    end
    frame.UpdateWeaponIcons = function(self)
        local equippedArmor = GAC.characterData and GAC.characterData.inventory and GAC.characterData.inventory.equippedArmor
        
        local currentLast = attackButton
        for _, btn in ipairs(self.weaponButtons) do
            local itemData = equippedArmor and (equippedArmor[btn.slotID] or equippedArmor[tostring(btn.slotID)])
            if itemData and #itemData > 0 and itemData[1].weaponData then
                btn:Show()
                btn.weaponKey = itemData[1].weaponData.weaponKey
                btn.weaponName = itemData[1].itemName
                
                local iconPath = itemData[1].itemIcon or "INV_Misc_QuestionMark"
                if type(iconPath) == "string" and not iconPath:match("\\") then
                    iconPath = "Interface\\Icons\\" .. iconPath
                end
                btn.icon:SetTexture(iconPath)
                
                btn:ClearAllPoints()
                btn:SetPoint("LEFT", currentLast, "RIGHT", buttonSpacing + 2, 0)
                currentLast = btn
                
                GAC:SetupQuickTooltip(btn, "Atacar con " .. itemData[1].itemName, "Click para tirar daño del arma", {"Este es tu " .. btn.slotLabel .. ".", 0.7, 0.7, 1})
            else
                btn:Hide()
                btn.weaponKey = nil
                btn.weaponName = nil
            end
        end
    end
    
    frame:UpdateArmorIcons()
    frame:UpdateWeaponIcons()
end


