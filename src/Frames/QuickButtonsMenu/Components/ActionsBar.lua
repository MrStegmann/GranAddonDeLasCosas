local addonName, GAC = ...

GAC.Components = GAC.Components or {}
GAC.Components.QuickButtonsMenu = GAC.Components.QuickButtonsMenu or {}

function GAC.Components.QuickButtonsMenu:CreateActionsBar(frame)
    local c = GAC.Stores.QuickButtonsMenu.Constants

    -- 1. Dados (Talentos)
    local diceButton = GAC:CreateQuickButton(frame)
    diceButton:SetSize(c.BUTTON_SIZE, c.BUTTON_SIZE)
    diceButton:SetPoint("TOPLEFT", frame, "TOPLEFT", c.BUTTON_X, -35)
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
    GAC:SetupQuickTooltip(diceButton, "Talentos (d20)", "Click para abrir menu de tiradas por talento", {"Click derecho: Repetir última tirada", 0.7, 0.7, 1})

    -- 2. Atributos
    local attrButton = GAC:CreateQuickButton(frame)
    attrButton:SetSize(c.BUTTON_SIZE, c.BUTTON_SIZE)
    attrButton:SetPoint("LEFT", diceButton, "RIGHT", c.BUTTON_SPACING, 0)
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
    GAC:SetupQuickTooltip(attrButton, "Atributos (d20)", "Click para abrir menu de tiradas por atributo", {"Click derecho: Repetir última tirada", 0.7, 0.7, 1})

    -- 3. Iniciativa
    local swordButton = GAC:CreateQuickButton(frame)
    swordButton:SetSize(c.BUTTON_SIZE, c.BUTTON_SIZE)
    swordButton:SetPoint("LEFT", attrButton, "RIGHT", c.BUTTON_SPACING, 0)
    local swordIcon = swordButton:CreateTexture(nil, "ARTWORK")
    swordIcon:SetTexture("Interface\\Icons\\Ability_Rogue_Sprint")
    swordIcon:SetPoint("TOPLEFT", 2, -2)
    swordIcon:SetPoint("BOTTOMRIGHT", -2, 2)
    swordIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    swordButton:SetScript("OnClick", function()
        GAC:StartInitiativeRoll()
        local mod, has = GAC.Utils.QuickButtonsMenu:GetQuickModifierValue()
        if has and GAC.pendingInitiativeRoll then
            GAC.pendingInitiativeRoll.hasModifier = true
            GAC.pendingInitiativeRoll.modifierValue = mod
        end
    end)
    GAC:SetupQuickTooltip(swordButton, "Iniciativa (d100)", "Click para tirar Iniciativa")

    -- 4. Ataque
    local attackButton = GAC:CreateQuickButton(frame)
    attackButton:SetSize(c.BUTTON_SIZE, c.BUTTON_SIZE)
    attackButton:SetPoint("LEFT", swordButton, "RIGHT", c.BUTTON_SPACING, 0)
    local attackIcon = attackButton:CreateTexture(nil, "ARTWORK")
    attackIcon:SetTexture("Interface\\Icons\\Ability_MeleeDamage")
    attackIcon:SetPoint("TOPLEFT", 2, -2)
    attackIcon:SetPoint("BOTTOMRIGHT", -2, 2)
    attackIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    attackButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    attackButton:SetScript("OnClick", function(_, btn)
        if btn == "RightButton" then
            if GAC.lastAttackRolled then
                GAC:StartAttackRoll(GAC.lastAttackRolled.dice, GAC.lastAttackRolled.talentKey, GAC.lastAttackRolled.talentLabel, GAC.lastAttackRolled.targetZone, GAC.lastAttackRolled.targetZoneId, GAC.lastAttackRolled.damageType, GAC.lastAttackRolled.damageLabel)
            else
                print("No has lanzado ningún dado de ataque.")
            end
        else
            if not GAC.attackActionsMenuFrame then GAC.attackActionsMenuFrame = CreateFrame("Frame", "GACAttackActionsMenuFrame", UIParent, "UIDropDownMenuTemplate") end
            EasyMenu(GAC:CreateAttackOptions(), GAC.attackActionsMenuFrame, frame, 0, 0, "MENU", 2)
        end
    end)
    GAC:SetupQuickTooltip(attackButton, "Ataque", "Click para abrir menu de tirada de ataque", {"Click derecho: Repetir última tirada", 0.7, 0.7, 1})

    return attackButton -- Usado como ancla inicial para la WeaponBar
end
