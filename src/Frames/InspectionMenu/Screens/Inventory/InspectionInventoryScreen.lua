local addonName, GAC = ...

GAC.Screens = GAC.Screens or {}
GAC.Screens.InspectionMenu = GAC.Screens.InspectionMenu or {}

function GAC.Screens.InspectionMenu:CreateInventoryScreen(parent)
    local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    frame:SetAllPoints()

    local header = GAC:CreateFontString(frame, "Inventario del Objetivo", "GameFontNormalLarge", { "TOPLEFT", 15, -15 }, { 0.25, 0.78, 0.94 })

    local line = frame:CreateTexture(nil, "ARTWORK")
    line:SetPoint("TOPLEFT", 15, -40)
    line:SetPoint("TOPRIGHT", -15, -40)
    line:SetHeight(1)
    line:SetColorTexture(1, 1, 1, 0.1)

    local slots = {
        { id = 1, label = "Cabeza", name="head", icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Head" },
        { id = 5, label = "Pecho", name="chest", icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Chest" },
        { id = 10, label = "Manos", name="hands", icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Hands" },
        { id = 7, label = "Piernas", name="legs", icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Legs" },
    }

    local weaponSlots = {
        { id = 16, label = "Mano diestra", name="mainHand", icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-MainHand" },
        { id = 17, label = "Arma secundaria", name="secondaryHand", icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-SecondaryHand" },
        { id = 18, label = "A distancia", name="ranged", icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Ranged" },
    }

    local slotFrames = {}

    local startX = 30
    local startY = -70
    local yOffset = -60

    for i, slotData in ipairs(slots) do
        local btn = GAC.Components.InspectionMenu:CreateSlotButton(frame, slotData, startX, startY + (i - 1) * yOffset, false)
        table.insert(slotFrames, btn)
    end
    
    local wStartX = 40
    local wStartY = startY + (#slots) * yOffset - 10
    local wXOffset = 100
    
    for i, slotData in ipairs(weaponSlots) do
        local x = wStartX + (i - 1) * wXOffset
        local y = wStartY
        local btn = GAC.Components.InspectionMenu:CreateSlotButton(frame, slotData, x, y, true, wXOffset)
        table.insert(slotFrames, btn)
    end

    local summaryFrame = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    summaryFrame:SetWidth(220)
    summaryFrame:SetPoint("TOPRIGHT", -30, -70)
    summaryFrame:SetPoint("BOTTOMRIGHT", -30, 30)
    summaryFrame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12, insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    summaryFrame:SetBackdropColor(0, 0, 0, 0.5)
    summaryFrame:SetBackdropBorderColor(0.25, 0.78, 0.94, 0.5)
    
    local summaryTitle = GAC:CreateFontString(summaryFrame, "Resumen de Equipo", "GameFontNormal", { "TOP", 0, -10 }, { 0.25, 0.78, 0.94 })
    
    local reqHeader = GAC:CreateFontString(summaryFrame, "Requerimientos Totales", "GameFontHighlight", { "TOPLEFT", 15, -40 }, { 0, 1, 0 })
    local reqText = GAC:CreateFontString(summaryFrame, "", "GameFontHighlightSmall", { "TOPLEFT", reqHeader, "BOTTOMLEFT", 5, -5 }, { 1, 1, 1 })
    reqText:SetJustifyH("LEFT")
    
    local penHeader = GAC:CreateFontString(summaryFrame, "Penalizadores Totales", "GameFontHighlight", { "TOPLEFT", reqHeader, "BOTTOMLEFT", 0, -80 }, { 1, 0, 0 })
    local penText = GAC:CreateFontString(summaryFrame, "", "GameFontHighlightSmall", { "TOPLEFT", penHeader, "BOTTOMLEFT", 5, -5 }, { 1, 1, 1 })
    penText:SetJustifyH("LEFT")
    
    local meetsReqText = GAC:CreateFontString(summaryFrame, "", "GameFontNormalSmall", { "BOTTOM", 0, 15 }, { 1, 0.2, 0.2 })

    local wpnHeader = GAC:CreateFontString(summaryFrame, "Daño de Armas", "GameFontHighlight", { "TOPLEFT", 15, -250 }, { 0.25, 0.78, 0.94 })
    local wpnText = GAC:CreateFontString(summaryFrame, "", "GameFontHighlightSmall", { "TOPLEFT", wpnHeader, "BOTTOMLEFT", 5, -5 }, { 1, 1, 1 })
    wpnText:SetJustifyH("LEFT")

    local function ApplyItemDataToButton(btn, itemDataList)
        btn.itemDataList = itemDataList
        
        if itemDataList and #itemDataList > 0 then
            local item = itemDataList[1]
            local icon = item.itemIcon or "INV_Misc_QuestionMark"
            if type(icon) == "string" and not icon:match("\\") then
                icon = "Interface\\Icons\\" .. icon
            end
            btn.icon:SetTexture(icon)
            btn.icon:SetVertexColor(1, 1, 1)
            
            local r, g, b = 1, 1, 1
            if item.itemQuality and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[item.itemQuality] then
                local color = ITEM_QUALITY_COLORS[item.itemQuality]
                r, g, b = color.r, color.g, color.b
            end
            
            if btn.itemLabel then
                btn.itemLabel:SetText(item.itemName)
                btn.itemLabel:SetTextColor(r, g, b)
            else
                btn.label:SetText(item.itemName)
                btn.label:SetTextColor(r, g, b)
            end
            
            if itemDataList.notAllowed then
                btn.customBorder:SetVertexColor(1, 0, 0)
                btn.icon:SetVertexColor(1, 0, 0)
            else
                btn.customBorder:SetVertexColor(1, 1, 1)
            end
        else
            btn.icon:SetTexture(btn.emptyIcon)
            btn.icon:SetVertexColor(1, 1, 1)
            btn.label:SetText(btn.emptyLabel)
            btn.label:SetTextColor(0.5, 0.5, 0.5)
            if btn.itemLabel then
                btn.itemLabel:SetText("")
            end
            btn.customBorder:SetVertexColor(1, 1, 1)
        end
    end

    frame.Update = function(self)
        if self.isProcessing then return end
        
        for _, btn in ipairs(slotFrames) do
            btn.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
            btn.icon:SetVertexColor(0.5, 0.5, 0.5)
            btn.label:SetText("Solicitando datos...")
            btn.label:SetTextColor(0.5, 0.5, 0.5)
            btn.customBorder:SetVertexColor(1, 1, 1)
            btn.itemDataList = nil
        end
        reqText:SetText("...")
        penText:SetText("...")
        meetsReqText:SetText("")
        
        if not GAC.inspectedPlayer then return end
        
        self.isProcessing = true
        
        local targetID = GAC.inspectedPlayer.name
        if UnitExists("target") and Ambiguate(UnitName("target"), "none") == targetID and TRP3_API and TRP3_API.utils and TRP3_API.utils.str then
            targetID = TRP3_API.utils.str.getUnitID("target") or targetID
        end
        
        GAC:RequestTargetExtendedInventory(targetID, function(equippedData)
            if type(equippedData) ~= "table" then
                for _, btn in ipairs(slotFrames) do
                    ApplyItemDataToButton(btn, nil)
                end
                reqText:SetText("No disponible")
                penText:SetText("No disponible")
                self.isProcessing = false
                return
            end
            
            local groupedBySlot = {}
            local parsedItemsInfo = {}
            local equippedItems = {}
            
            local nextWeaponSlotIdx = 1
            local weaponSlotsIds = {16, 17, 18}
            
            local equippedKeys = {}
            for k, rawItem in pairs(equippedData) do
                table.insert(equippedKeys, k)
                if rawItem.itemVA and rawItem.itemVA.tooltipRight and string.find(string.lower(rawItem.itemVA.tooltipRight), "escudo") then
                    weaponSlotsIds = {16, 18}
                end
            end
            
            local currentIndex = 1
            local function ProcessNextSlot()
                if not self:IsShown() then
                    self.isProcessing = false
                    return
                end
                
                if currentIndex > #equippedKeys then
                    pcall(function() self:FinalizeSummary(groupedBySlot, parsedItemsInfo, equippedItems) end)
                    self.isProcessing = false
                    return
                end
                
                local slotID = equippedKeys[currentIndex]
                local rawItem = equippedData[slotID]
                
                if rawItem then
                    local ok, err = pcall(function()
                        local parsedItem = GAC:ParseTRP3ExtendedItem(rawItem, slotID)
                        if parsedItem then
                            table.insert(equippedItems, parsedItem)
                            
                            local itemTypeStrL, hasReinfL, reinfStrL = GAC:ParseArmorString(parsedItem.tooltipLeft)
                            local itemTypeStrR, hasReinfR, reinfStrR = GAC:ParseArmorString(parsedItem.tooltipRight)
                            
                            local baseKey = GAC:GetArmorKeyByAlias(itemTypeStrL)
                            local slotKey = GAC:GetArmorKeyByAlias(itemTypeStrR)
                            local hasReinforcement = hasReinfL or hasReinfR
                            local reinforcementStr = (hasReinfL and reinfStrL) or (hasReinfR and reinfStrR) or ""
                            
                            if (not baseKey or not GAC:GetArmorTypeInfo(baseKey)) and GAC:GetArmorTypeInfo(GAC:GetArmorKeyByAlias(itemTypeStrR)) then
                                baseKey = GAC:GetArmorKeyByAlias(itemTypeStrR)
                                slotKey = GAC:GetArmorKeyByAlias(itemTypeStrL)
                            end
                            if baseKey and not GAC:GetArmorTypeInfo(baseKey) then baseKey = nil end
                            
                            local weaponKey = GAC:GetWeaponKeyByAlias(parsedItem.tooltipRight)
                            local isShield = false
                            local shieldKey = nil
                            if parsedItem.tooltipRight and string.find(string.lower(parsedItem.tooltipRight), "escudo") then
                                isShield = true
                                shieldKey = GAC:GetShieldKeyByAlias(parsedItem.tooltipRight) or GAC:GetShieldKeyByAlias(parsedItem.tooltipLeft)
                            end
                            
                            local targetSlot = slotKey or tonumber(parsedItem.slotID) or parsedItem.slotID
                            
                            local isValidItem = true
                            if isShield and shieldKey then
                                targetSlot = 17
                            elseif weaponKey then
                                if nextWeaponSlotIdx <= #weaponSlotsIds then
                                    targetSlot = weaponSlotsIds[nextWeaponSlotIdx]
                                    nextWeaponSlotIdx = nextWeaponSlotIdx + 1
                                else
                                    isValidItem = false
                                end
                            else
                                if targetSlot == 16 or targetSlot == 17 or targetSlot == 18 then
                                    isValidItem = false
                                end
                            end
                            
                            if isValidItem then
                                if not groupedBySlot[targetSlot] then groupedBySlot[targetSlot] = {} end
                                table.insert(groupedBySlot[targetSlot], parsedItem)
                                
                                if baseKey then
                                    local info = GAC:GetArmorTypeInfo(baseKey)
                                    if info then
                                        local physRed = info.physicalReduction or 0
                                        local magRed = info.magicalReduction or 0
                                        local maxDurability = info.durability or 0
                                        
                                        local rInfo = nil
                                        if hasReinforcement then
                                            local rKey = GAC:GetArmorKeyByAlias(reinforcementStr)
                                            if rKey then
                                                rInfo = GAC:GetArmorReinforcementInfo(rKey)
                                                if rInfo then
                                                    physRed = physRed + (rInfo.physicalReduction or 0)
                                                    magRed = magRed + (rInfo.magicalReduction or 0)
                                                    maxDurability = maxDurability + (rInfo.durability or 0)
                                                end
                                            end
                                        end
                                        
                                        local reqs = {}
                                        if slotKey and info.requirements and info.requirements[slotKey] then
                                            for stat, val in pairs(info.requirements[slotKey]) do reqs[stat] = (reqs[stat] or 0) + val end
                                        end
                                        if rInfo and rInfo.requirements then
                                            for stat, val in pairs(rInfo.requirements) do reqs[stat] = (reqs[stat] or 0) + val end
                                        end
                                        
                                        local pens = {}
                                        if slotKey and info.disadvantage and info.disadvantage[slotKey] then
                                            for stat, val in pairs(info.disadvantage[slotKey]) do pens[stat] = (pens[stat] or 0) + val end
                                        end
                                        if rInfo and rInfo.disadvantage then
                                            for stat, val in pairs(rInfo.disadvantage) do pens[stat] = (pens[stat] or 0) + val end
                                        end
                                        
                                        parsedItemsInfo[parsedItem.slotID] = {
                                            isArmor = true,
                                            baseKey = baseKey, itemTypeStr = itemTypeStrL .. " - " .. itemTypeStrR, hasReinforcement = hasReinforcement,
                                            reinforcementStr = reinforcementStr, slotKey = slotKey, physRed = physRed,
                                            magRed = magRed, maxDurability = maxDurability, reqs = reqs, pens = pens
                                        }
                                    end
                                elseif isShield and shieldKey then
                                    local info = GAC:GetShieldInfo(shieldKey)
                                    if info then
                                        parsedItemsInfo[parsedItem.slotID] = {
                                            isShield = true,
                                            shieldKey = shieldKey,
                                            itemTypeStr = parsedItem.tooltipRight,
                                            maxDurability = info.durability or 0,
                                            physRed = info.physicalReduction or 0,
                                            magRed = 0,
                                            reqs = info.requirements or {},
                                            pens = info.penalties or {}
                                        }
                                    end
                                elseif weaponKey then
                                    parsedItemsInfo[parsedItem.slotID] = {
                                        isWeapon = true,
                                        weaponKey = weaponKey,
                                        itemTypeStr = parsedItem.tooltipRight,
                                        reqs = {},
                                        pens = {}
                                    }
                                end
                            end
                            
                            for _, btn in ipairs(slotFrames) do
                                if btn.slotName == targetSlot or btn.slotID == targetSlot then
                                    ApplyItemDataToButton(btn, {parsedItem})
                                end
                            end
                        end
                    end)
                end
                
                currentIndex = currentIndex + 1
                C_Timer.After(0.1, ProcessNextSlot)
            end
            
            ProcessNextSlot()
        end)
    end

    frame.FinalizeSummary = function(self, groupedBySlot, parsedItemsInfo, equippedItems)
        for _, btn in ipairs(slotFrames) do
            ApplyItemDataToButton(btn, nil)
        end

        local notAllowedSlots = {}
        for slot, itemsInSlot in pairs(groupedBySlot) do
            if #itemsInSlot > 1 then
                local item1 = itemsInSlot[1]
                local item2 = itemsInSlot[2]
                local p1 = parsedItemsInfo[item1.slotID]
                local p2 = parsedItemsInfo[item2.slotID]
                
                if p1 and p2 then
                    local isNotAllowed = false
                    local reason = nil
                    if p1.hasReinforcement or p2.hasReinforcement then
                        isNotAllowed = true; reason = "No puedes combinar una armadura con refuerzos."
                    else
                        local info1 = GAC:GetArmorTypeInfo(p1.baseKey)
                        if info1 and info1.combinable and info1.combinable[p2.baseKey] then
                            for _, rule in ipairs(info1.combinable[p2.baseKey]) do
                                if rule == "notAllowed" then
                                    isNotAllowed = true; reason = "No puedes equipar dos piezas del mismo tipo."
                                elseif rule == "doubleDisadvantage" then
                                    for s, v in pairs(p1.pens) do p1.pens[s] = v * 2 end
                                    for s, v in pairs(p2.pens) do p2.pens[s] = v * 2 end
                                elseif rule == "doubleRequirements" then
                                    for s, v in pairs(p1.reqs) do p1.reqs[s] = v * 2 end
                                    for s, v in pairs(p2.reqs) do p2.reqs[s] = v * 2 end
                                end
                            end
                        end
                    end
                    if isNotAllowed then notAllowedSlots[slot] = reason or "Combinación no permitida." end
                end
            end
        end
        
        local totalReqs = {}
        for _, item in ipairs(equippedItems) do
            local pInfo = parsedItemsInfo[item.slotID]
            if pInfo and pInfo.reqs then
                for stat, val in pairs(pInfo.reqs) do totalReqs[stat] = (totalReqs[stat] or 0) + val end
            end
        end
        
        local globallyMeetsRequirements = true
        if GAC.inspectedPlayer then
            local attrs = GAC.inspectedPlayer.attributes or {}
            local talents = GAC.inspectedPlayer.talents or {}
            for stat, reqVal in pairs(totalReqs) do
                local playerVal = (attrs[stat] or 0) + (talents[stat] or 0)
                if playerVal < reqVal then
                    globallyMeetsRequirements = false
                    break
                end
            end
        end
        
        local totalPens = {}
        local meetsAll = true
        local hasAnyArmor = false
        local notAllowedErrors = {}
        
        for slot, itemsInSlot in pairs(groupedBySlot) do
            local slotList = { notAllowed = notAllowedSlots[slot] }
            for _, item in ipairs(itemsInSlot) do
                local pInfo = parsedItemsInfo[item.slotID]
                if pInfo then
                    if pInfo.isShield or pInfo.isArmor then
                        hasAnyArmor = true
                        if not globallyMeetsRequirements then
                            if pInfo.pens then
                                for stat, val in pairs(pInfo.pens) do pInfo.pens[stat] = val * 2 end
                            end
                            meetsAll = false
                        end
                    end

                    if pInfo.isShield or pInfo.isWeapon then
                        local damageModifier = 0
                        if item.tooltipLeft then
                            local modVal = string.match(item.tooltipLeft, "%+(%d+)")
                            if modVal then
                                damageModifier = tonumber(modVal) or 0
                            end
                        end
                        
                        item.weaponData = {
                            weaponKey = pInfo.weaponKey or pInfo.shieldKey,
                            baseStr = pInfo.itemTypeStr,
                            damageModifier = damageModifier
                        }
                    end
                    
                    if pInfo.isShield or pInfo.isArmor then
                        local curVal = pInfo.maxDurability or 0
                        if item.itemVA and item.itemVA.durability then
                            local durVal = tonumber(item.itemVA.durability)
                            if durVal then curVal = durVal end
                        end
                        item.armorData = {
                            baseStr = pInfo.itemTypeStr or "Armadura", hasReinforcement = pInfo.hasReinforcement or false,
                            reinforcementStr = pInfo.reinforcementStr, slotStr = item.tooltipRight or "",
                            physRed = pInfo.physRed or 0, magRed = pInfo.magRed or 0, currentDurability = "Durabilidad: " .. tostring(curVal) .. "/" .. tostring(pInfo.maxDurability or 0),
                            requirements = pInfo.reqs or {}, penalties = pInfo.pens or {}, meetsRequirements = globallyMeetsRequirements
                        }
                        if pInfo.pens then
                            for s, v in pairs(pInfo.pens) do totalPens[s] = (totalPens[s] or 0) + v end
                        end
                    end
                end
                table.insert(slotList, item)
            end
            
            for _, btn in ipairs(slotFrames) do
                if btn.slotName == slot or btn.slotID == slot then
                    ApplyItemDataToButton(btn, slotList)
                    if slotList.notAllowed then
                        local n1 = slotList[1].armorData and slotList[1].armorData.baseStr or "Pieza 1"
                        local n2 = slotList[2] and slotList[2].armorData and slotList[2].armorData.baseStr or "Pieza 2"
                        table.insert(notAllowedErrors, btn.emptyLabel .. ": " .. n1 .. " y " .. n2 .. "\n  - " .. tostring(slotList.notAllowed))
                    end
                end
            end
        end
        
        local statNames = { brutality = "Brutalidad", agileDefense = "Defensa Ágil", movement = "Movimiento", perception = "Percepción", stealth = "Sigilo", acrobatics = "Acrobacias", sleightOfHand = "Juego de Manos" }
        
        local rStr = ""
        for stat, val in pairs(totalReqs) do rStr = rStr .. "- " .. (statNames[stat] or stat) .. " " .. val .. "\n" end
        reqText:SetText(rStr == "" and "Ninguno" or rStr)
        
        local pStr = ""
        for stat, val in pairs(totalPens) do pStr = pStr .. "- " .. (statNames[stat] or stat) .. " " .. val .. "\n" end
        penText:SetText(pStr == "" and "Ninguno" or pStr)
        
        local wpnStr = ""
        local function GetWeaponDamageStr(label, slotID)
            local slotList = groupedBySlot[slotID]
            if slotList and #slotList > 0 and slotList[1].weaponData then
                local wInfo = GAC:GetWeaponInfo(slotList[1].weaponData.weaponKey) or GAC:GetShieldInfo(slotList[1].weaponData.weaponKey)
                if wInfo then
                    local playerAttrs = GAC.inspectedPlayer and GAC.inspectedPlayer.attributes or {}
                    local playerTalents = GAC.inspectedPlayer and GAC.inspectedPlayer.talents or {}
                    local wMod = slotList[1].weaponData.damageModifier or 0
                    local dmg = GAC.Utils.InspectionInventory:FormatDamage(wInfo, playerAttrs, playerTalents, wMod)
                    return "- " .. label .. ": " .. dmg .. "\n"
                end
            end
            return ""
        end
        
        wpnStr = wpnStr .. GetWeaponDamageStr("Principal", 16)
        wpnStr = wpnStr .. GetWeaponDamageStr("Secundaria", 17)
        wpnStr = wpnStr .. GetWeaponDamageStr("A distancia", 18)
        
        if wpnStr == "" then wpnStr = "- Desarmado: 1 - 4" end
        wpnText:SetText(wpnStr)
        
        if #notAllowedErrors > 0 then
            meetsReqText:SetText("* Comb. Inválidas:\n" .. table.concat(notAllowedErrors, "\n"))
        elseif hasAnyArmor and not meetsAll then
            meetsReqText:SetText("* El objetivo no cumple con los requisitos *")
        end
    end

    return frame
end
