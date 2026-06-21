local addonName, GAC = ...

GAC.Utils = GAC.Utils or {}
GAC.Utils.InspectionInventory = GAC.Utils.InspectionInventory or {}

function GAC.Utils.InspectionInventory:FormatDamage(info, playerAttrs, playerTalents, damageModifier, isTwoHanded)
    local baseMinDmg = info.diceNumber
    local baseMaxDmg = info.diceNumber * info.damage
    
    local talentVal = 0
    if type(info.talent) == "table" then
        for _, t in ipairs(info.talent) do
            local val = (playerAttrs[t] or 0) + (playerTalents[t] or 0)
            if val > talentVal then talentVal = val end
        end
    elseif type(info.talent) == "string" then
        talentVal = (playerAttrs[info.talent] or 0) + (playerTalents[info.talent] or 0)
    end
    
    local minDmg = baseMinDmg + talentVal + (damageModifier or 0)
    local maxDmg = baseMaxDmg + talentVal + (damageModifier or 0)
    
    local str = minDmg .. " - " .. maxDmg
    if isTwoHanded then str = "(" .. str .. ")" end
    return str
end

function GAC.Utils.InspectionInventory:FormatDice(info, isTwoHanded)
    local str = info.diceNumber .. "D" .. info.damage
    if isTwoHanded then str = "(" .. str .. ")" end
    return str
end

function GAC.Utils.InspectionInventory:DrawTooltip(tooltipFrame, itemData, isNotAllowed)
    tooltipFrame:ClearLines()
    local r, g, b = 1, 1, 1
    if itemData.itemQuality and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[itemData.itemQuality] then
        local color = ITEM_QUALITY_COLORS[itemData.itemQuality]
        r, g, b = color.r, color.g, color.b
    end
    
    tooltipFrame:AddLine(itemData.itemName, r, g, b)
    
    if itemData.armorData then
        local data = itemData.armorData
        local leftText = data.baseStr
        if data.hasReinforcement then
            leftText = leftText .. ": Reforzado con " .. data.reinforcementStr
        end
        tooltipFrame:AddDoubleLine(leftText, data.slotStr, 1, 1, 1, 1, 1, 1)
        
        tooltipFrame:AddLine("Reducción física: " .. data.physRed, 1, 1, 1)
        tooltipFrame:AddLine("Reducción mágica: " .. data.magRed, 1, 1, 1)
        
        local statNames = {
            brutality = "Brutalidad", agileDefense = "Defensa Ágil", movement = "Movimiento",
            perception = "Percepción", stealth = "Sigilo", acrobatics = "Acrobacias", sleightOfHand = "Juego de Manos"
        }
        
        local hasReqs = false
        for stat, val in pairs(data.requirements) do
            if not hasReqs then
                tooltipFrame:AddLine(" ")
                hasReqs = true
            end
            tooltipFrame:AddLine((statNames[stat] or stat) .. " " .. val, 0, 1, 0)
        end
        
        local hasPens = false
        for stat, val in pairs(data.penalties) do
            if not hasPens then
                if not hasReqs then tooltipFrame:AddLine(" ") end
                hasPens = true
            end
            tooltipFrame:AddLine((statNames[stat] or stat) .. " " .. val, 1, 0, 0)
        end
        
        tooltipFrame:AddLine(" ")
        tooltipFrame:AddLine(data.currentDurability, 1, 1, 1)
        
        if isNotAllowed then
            tooltipFrame:AddLine(" ")
            tooltipFrame:AddLine("* " .. string.upper(tostring(isNotAllowed)) .. " *", 1, 0, 0, true)
        elseif data.meetsRequirements == false then
            tooltipFrame:AddLine(" ")
            tooltipFrame:AddLine("* No cumple con los requisitos *", 1, 0.2, 0.2)
        end
    elseif itemData.weaponData then
        local data = itemData.weaponData
        local wInfo = GAC:GetWeaponInfo(data.weaponKey) or GAC:GetShieldInfo(data.weaponKey)
        
        tooltipFrame:AddDoubleLine(data.baseStr, "Arma", 1, 1, 1, 1, 1, 1)
        
        if wInfo then
            local dmgTypeES = { piercing = "Perforante", crushing = "Contundente", slashing = "Cortante" }
            
            local playerAttrs = GAC.inspectedPlayer and GAC.inspectedPlayer.attributes or {}
            local playerTalents = GAC.inspectedPlayer and GAC.inspectedPlayer.talents or {}
            
            local dmgLine = "Daño: " .. self:FormatDamage(wInfo, playerAttrs, playerTalents, data.damageModifier)
            local diceLine = self:FormatDice(wInfo)
            if wInfo.twoHanded then
                dmgLine = dmgLine .. " " .. self:FormatDamage(wInfo.twoHanded, playerAttrs, playerTalents, data.damageModifier, true)
                diceLine = diceLine .. " " .. self:FormatDice(wInfo.twoHanded, true)
            end
            
            tooltipFrame:AddLine(" ")
            tooltipFrame:AddLine(dmgLine, 1, 1, 1)
            tooltipFrame:AddLine(diceLine, 1, 0.82, 0)
            
            if itemData.tooltipLeft and itemData.tooltipLeft ~= "" then
                tooltipFrame:AddLine("Mejora: " .. itemData.tooltipLeft, 0, 1, 0)
            end
            
            local typeLine = "Tipo de daño: " .. (dmgTypeES[wInfo.damageType] or wInfo.damageType)
            if wInfo.twoHanded and wInfo.twoHanded.damageType and wInfo.twoHanded.damageType ~= wInfo.damageType then
                typeLine = typeLine .. " (" .. (dmgTypeES[wInfo.twoHanded.damageType] or wInfo.twoHanded.damageType) .. ")"
            end
            tooltipFrame:AddLine(typeLine, 1, 1, 1)
            
            if wInfo.throwable then
                tooltipFrame:AddLine(" ")
                tooltipFrame:AddLine("Arrojadiza:", 0, 1, 0)
                local thr = wInfo.throwable
                tooltipFrame:AddLine("Daño: " .. self:FormatDamage(thr, playerAttrs, playerTalents, data.damageModifier), 1, 1, 1)
                tooltipFrame:AddLine(self:FormatDice(thr), 1, 0.82, 0)
                tooltipFrame:AddLine("Tipo de daño: " .. (dmgTypeES[thr.damageType] or thr.damageType), 1, 1, 1)
            end
            
            if wInfo.twoHanded then
                tooltipFrame:AddLine(" ")
                tooltipFrame:AddLine("* Los valores entre paréntesis son empuñando el arma a dos manos.", 0.5, 0.5, 0.5)
            end
        end
        
        if itemData.itemDescription and itemData.itemDescription ~= "" then
            tooltipFrame:AddLine(" ")
            tooltipFrame:AddLine(itemData.itemDescription, 1, 0.82, 0, true)
        end
    else
        if itemData.itemDescription and itemData.itemDescription ~= "" then
            tooltipFrame:AddLine(itemData.itemDescription, 1, 0.82, 0, true)
        end
    end
    
    if isNotAllowed and tooltipFrame.SetBackdropBorderColor then
        tooltipFrame.originalBorderR, tooltipFrame.originalBorderG, tooltipFrame.originalBorderB, tooltipFrame.originalBorderA = tooltipFrame:GetBackdropBorderColor()
        tooltipFrame:SetBackdropBorderColor(1, 0, 0, 1)
    end
    
    tooltipFrame:Show()
end
