local addonName, GAC = ...

GAC.Utils = GAC.Utils or {}
GAC.Utils.QuickButtonsMenu = {}

function GAC.Utils.QuickButtonsMenu:EnsureQuickFramePosition()
    if not GAC.characterData or not GAC.characterData.ui then return end
    GAC.characterData.ui.quickFrame = GAC.characterData.ui.quickFrame or {}
    local pos = GAC.characterData.ui.quickFrame
    local c = GAC.Stores.QuickButtonsMenu.Constants
    if pos.anchor == nil then
        pos.anchor, pos.relativeAnchor, pos.x, pos.y = c.DEFAULT_ANCHOR, c.DEFAULT_REL_ANCHOR, c.DEFAULT_X, c.DEFAULT_Y
    end
end

function GAC.Utils.QuickButtonsMenu:GetQuickModifierValue()
    if not GAC.quickActionsFrame or not GAC.quickActionsFrame.modifierInput then
        return 0, false
    end
    local text = GAC.quickActionsFrame.modifierInput:GetText()
    if text == "" then return 0, false end
    local val = tonumber(text)
    return val or 0, true
end

function GAC.Utils.QuickButtonsMenu:UpdateTargetInspectButtonVisibility()
    if not GAC.targetInspectQuickButton then return end
    
    local canShow = false
    local currentTarget = UnitName("target")
    if currentTarget and UnitExists("target") and UnitIsPlayer("target") and not UnitIsUnit("target", "player") then
        local targetGUID = UnitGUID("target")
        if GAC.targetDataCache and GAC.targetDataCache[targetGUID] then
            canShow = true
        end
    end
    GAC.targetInspectQuickButton:SetShown(canShow)
end

function GAC.Utils.QuickButtonsMenu:SaveFramePosition(frame)
    local a, _, ra, ox, oy = frame:GetPoint(1)
    if not GAC.characterData.ui.quickFrame then GAC.characterData.ui.quickFrame = {} end
    ra = ra or a
    GAC.characterData.ui.quickFrame.anchor = a
    GAC.characterData.ui.quickFrame.relativeAnchor = ra
    GAC.characterData.ui.quickFrame.x = math.floor(ox + 0.5)
    GAC.characterData.ui.quickFrame.y = math.floor(oy + 0.5)
end

function GAC.Utils.QuickButtonsMenu:DrawArmorTooltip(btn, slotData)
    local equippedItems = GAC.playerCharacter and GAC.playerCharacter:GetEquippedItems()
    if not equippedItems then return end
    local itemInstance = equippedItems[slotData.id] or equippedItems[slotData.numId] or equippedItems[tostring(slotData.numId)]
    local itemData = itemInstance and type(itemInstance) == "table" and itemInstance.GetVariable and itemInstance:GetVariable().slotList
    
    if not itemData or #itemData == 0 then return end
    local item = itemData[1]
    if not item or not item.armorData then return end
    
    GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
    
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
end

function GAC.Utils.QuickButtonsMenu:HandleArmorClick(buttonClicked, slotData)
    local correctKey = nil
    local equippedItems = GAC.playerCharacter and GAC.playerCharacter:GetEquippedItems()
    if equippedItems then
        if equippedItems[slotData.id] then correctKey = slotData.id
        elseif equippedItems[slotData.numId] then correctKey = slotData.numId
        elseif equippedItems[tostring(slotData.numId)] then correctKey = tostring(slotData.numId) end
    end
    if not correctKey then return end
    if buttonClicked == "LeftButton" then
        if GAC.UpdateTRP3ItemDurability then GAC:UpdateTRP3ItemDurability(correctKey, 1) end
    elseif buttonClicked == "RightButton" then
        if GAC.UpdateTRP3ItemDurability then GAC:UpdateTRP3ItemDurability(correctKey, -1) end
    end
end
