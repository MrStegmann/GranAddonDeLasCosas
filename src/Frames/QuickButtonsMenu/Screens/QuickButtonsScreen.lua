local addonName, GAC = ...

GAC.Screens = GAC.Screens or {}
GAC.Screens.QuickButtonsMenu = {}

function GAC.Screens.QuickButtonsMenu:CreateMainFrame()
    GAC.Utils.QuickButtonsMenu:EnsureQuickFramePosition()
    local pos = GAC.characterData and GAC.characterData.ui and GAC.characterData.ui.quickFrame
    local c = GAC.Stores.QuickButtonsMenu.Constants
    local anchor, relAnchor, x, y = c.DEFAULT_ANCHOR, c.DEFAULT_REL_ANCHOR, c.DEFAULT_X, c.DEFAULT_Y
    if pos then
        anchor, relAnchor = pos.anchor or anchor, pos.relativeAnchor or relAnchor
        x, y = tonumber(pos.x) or x, tonumber(pos.y) or y
    end

    local frame = CreateFrame("Frame", "GACQuickActionsFrame", UIParent, "BackdropTemplate")
    frame:SetPoint(anchor, UIParent, relAnchor, x, y)
    frame:SetSize(c.FRAME_WIDTH, c.FRAME_HEIGHT)
    frame:SetMovable(true)
    GAC:SetClampedWithVisiblePixels(frame, 20)
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
    frame:SetBackdropColor(c.BACKGROUND_COLOR.r, c.BACKGROUND_COLOR.g, c.BACKGROUND_COLOR.b, c.BACKGROUND_COLOR.a)
    frame:SetBackdropBorderColor(c.BORDER_COLOR.r, c.BORDER_COLOR.g, c.BORDER_COLOR.b, c.BORDER_COLOR.a)

    frame:SetScript("OnDragStart", function(s) s:StartMoving() end)
    frame:SetScript("OnDragStop", function(s)
        s:StopMovingOrSizing()
        GAC.Utils.QuickButtonsMenu:SaveFramePosition(s)
    end)

    -- Crear subcomponentes
    GAC.Components.QuickButtonsMenu:CreateUtilitiesBar(frame)
    local attackBtnAnchor = GAC.Components.QuickButtonsMenu:CreateActionsBar(frame)
    GAC.Components.QuickButtonsMenu:CreateWeaponBar(frame, attackBtnAnchor)
    GAC.Components.QuickButtonsMenu:CreateCustomDiceBar(frame)
    GAC.Components.QuickButtonsMenu:CreateArmorBar(frame)

    -- Métodos de actualización de iconos dinámicos
    frame.UpdateArmorIcons = function(self)
        local equippedArmor = GAC.characterData and GAC.characterData.inventory and GAC.characterData.inventory.equippedArmor
        for _, btn in ipairs(self.armorButtons) do
            local itemData = equippedArmor and (equippedArmor[btn.slotID] or equippedArmor[btn.numId] or equippedArmor[tostring(btn.numId)])
            btn:Show()
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
                                        r = (1 - ratio) * 2; g = 1
                                    else
                                        r = 1; g = ratio * 2
                                    end
                                    b = 0
                                    r = r * 0.6 + 0.4; g = g * 0.6 + 0.4; b = b * 0.6 + 0.4
                                end
                            end
                        end
                    end
                    btn.icon:SetVertexColor(r, g, b)
                end
            else
                btn:SetAlpha(0.2)
                btn.icon:SetTexture(btn.emptyIconPath)
                btn.icon:SetVertexColor(1, 1, 1)
            end
        end
    end

    frame.UpdateWeaponIcons = function(self)
        local equippedArmor = GAC.characterData and GAC.characterData.inventory and GAC.characterData.inventory.equippedArmor
        local currentLast = attackBtnAnchor
        for _, btn in ipairs(self.weaponButtons) do
            local itemData = equippedArmor and (equippedArmor[btn.slotID] or equippedArmor[tostring(btn.slotID)])
            if itemData and #itemData > 0 and itemData[1].weaponData then
                btn:Show()
                btn.weaponKey = itemData[1].weaponData.weaponKey
                btn.weaponName = itemData[1].itemName
                btn.damageModifier = itemData[1].weaponData.damageModifier or 0
                
                local iconPath = itemData[1].itemIcon or "INV_Misc_QuestionMark"
                if type(iconPath) == "string" and not iconPath:match("\\") then
                    iconPath = "Interface\\Icons\\" .. iconPath
                end
                btn.icon:SetTexture(iconPath)
                
                btn:ClearAllPoints()
                btn:SetPoint("LEFT", currentLast, "RIGHT", c.BUTTON_SPACING + 2, 0)
                currentLast = btn
                
                GAC:SetupQuickTooltip(btn, "Atacar con " .. itemData[1].itemName, "Click para tirar daño del arma", {"Este es tu " .. btn.slotLabel .. ".", 0.7, 0.7, 1})
            else
                if btn.slotID == 16 or btn.slotID == 17 then
                    btn:Show()
                    btn.weaponKey = nil
                    btn.weaponName = "Desarmado"
                    btn.damageModifier = 0
                    
                    local iconPath = (btn.slotID == 16) and "Interface\\Icons\\INV_Gauntlets_04" or "Interface\\Icons\\INV_Gauntlets_05"
                    btn.icon:SetTexture(iconPath)
                    
                    btn:ClearAllPoints()
                    btn:SetPoint("LEFT", currentLast, "RIGHT", c.BUTTON_SPACING + 2, 0)
                    currentLast = btn
                    
                    GAC:SetupQuickTooltip(btn, "Ataque Desarmado (" .. btn.slotLabel .. ")", "Click para tirar daño desarmado", {"Golpe sin armas: 1d4 + MAX(Acrobacia, Brutalidad)", 0.7, 0.7, 1})
                else
                    btn:Hide()
                    btn.weaponKey = nil
                    btn.weaponName = nil
                end
            end
        end
    end

    return frame
end
