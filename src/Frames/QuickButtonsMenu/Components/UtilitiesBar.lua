local addonName, GAC = ...

GAC.Components = GAC.Components or {}
GAC.Components.QuickButtonsMenu = GAC.Components.QuickButtonsMenu or {}

function GAC.Components.QuickButtonsMenu:CreateUtilitiesBar(frame)
    local c = GAC.Stores.QuickButtonsMenu.Constants

    -- 1. Vida
    local lifeButton = GAC:CreateQuickButton(frame)
    lifeButton:SetSize(c.BUTTON_SIZE, c.BUTTON_SIZE)
    lifeButton:SetPoint("TOPLEFT", frame, "TOPLEFT", c.BUTTON_X, -8)
    local lifeIcon = lifeButton:CreateTexture(nil, "ARTWORK")
    lifeIcon:SetTexture("Interface\\Icons\\Spell_Holy_Renew")
    lifeIcon:SetPoint("TOPLEFT", 2, -2)
    lifeIcon:SetPoint("BOTTOMRIGHT", -2, 2)
    lifeIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    lifeButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    lifeButton:SetScript("OnClick", function(_, b)
        if IsControlKeyDown() then
            GAC.Components.QuickButtonsMenu:ShowModifyValuePopup("Modificar Vida (Ej: 5 o -5)", function(val)
                if GAC.Transmitter then GAC.Transmitter:Trigger(GAC.Enums.Events.MODIFY_LIFE, val) end
            end)
        else
            if GAC.Transmitter then GAC.Transmitter:Trigger(GAC.Enums.Events.MODIFY_LIFE, b == "RightButton" and -1 or 1) end
        end
    end)
    GAC:SetupQuickTooltip(lifeButton, "Modificar vida ±1", 
        "Clic izquierdo: Añade 1 punto de vida.", 
        {"Clic derecho: Quita 1 punto de vida.", 1, 0.7, 0.7},
        {"Control + Clic: Introducir valor manual", 1, 1, 0.5}
    )

    -- 2. Escudo
    local shieldButton = GAC:CreateQuickButton(frame)
    shieldButton:SetSize(c.BUTTON_SIZE, c.BUTTON_SIZE)
    shieldButton:SetPoint("LEFT", lifeButton, "RIGHT", c.BUTTON_SPACING, 0)
    local shieldIcon = shieldButton:CreateTexture(nil, "ARTWORK")
    shieldIcon:SetTexture("Interface\\Icons\\Spell_Holy_PowerWordShield")
    shieldIcon:SetPoint("TOPLEFT", 2, -2)
    shieldIcon:SetPoint("BOTTOMRIGHT", -2, 2)
    shieldIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    shieldButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    shieldButton:SetScript("OnClick", function(_, b)
        if IsControlKeyDown() then
            GAC.Components.QuickButtonsMenu:ShowModifyValuePopup("Modificar Escudo (Ej: 5 o -5)", function(val)
                if GAC.Transmitter then GAC.Transmitter:Trigger(GAC.Enums.Events.MODIFY_SHIELD, val) end
            end)
        else
            if GAC.Transmitter then GAC.Transmitter:Trigger(GAC.Enums.Events.MODIFY_SHIELD, b == "RightButton" and -1 or 1) end
        end
    end)
    GAC:SetupQuickTooltip(shieldButton, "Modificar escudo ±1", 
        "Clic izquierdo: Añade 1 punto de escudo.", 
        {"Clic derecho: Quita 1 punto de escudo.", 1, 0.7, 0.7},
        {"Control + Clic: Introducir valor manual", 1, 1, 0.5}
    )

    -- 3. Expandir Turnos
    local expandTurnButton = GAC:CreateQuickButton(frame)
    expandTurnButton:SetSize(c.BUTTON_SIZE, c.BUTTON_SIZE)
    expandTurnButton:SetPoint("LEFT", shieldButton, "RIGHT", c.BUTTON_SPACING, 0)
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
    GAC.turnOrderExpandQuickButton = expandTurnButton

    -- 4. Inspect Button (encima del frame)
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
            if GAC.Transmitter then GAC.Transmitter:Trigger(GAC.Enums.Events.INSPECT_REQ, fullName) end
            if GAC.OpenInspectionMenu then
                GAC.inspectedPlayer = {
                    name = fullName, level = 0, category = "normal", race = "-", class = "-", maxHealth = 0, currentShield = 0, attributes = {}, talents = {}
                }
                GAC:OpenInspectionMenu()
            end
        end
    end)
    GAC:SetupQuickTooltip(inspectBtn, "Inspeccionar objetivo", "Muestra la ficha de personaje del objetivo actual")
    inspectBtn:Hide()
    GAC.targetInspectQuickButton = inspectBtn
end
