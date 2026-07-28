--- @module Communication.TRP3.TRP3ArmorHook
-- Armor updating logic, durability handlers, and TRP3 event hook registrations.

local _, GAC = ...

local isTRP3Hooked = false

--- Updates equipped armor data based on TRP3 inventory snapshot.
-- @return void
function GAC:UpdateEquippedArmor()
    self.characterData = self.characterData or {}
    self.characterData.inventory = self.characterData.inventory or {}
    self.characterData.inventory.equippedArmor = {}
    
    local equippedItems = self:GetTRP3ExtendedEquippedItems() or {}
    local groupedBySlot = {}
    local parsedItemsInfo = {}
    local nextWeaponSlotIdx = 1
    local weaponSlotsIds = {16, 17, 18}
    
    for _, item in ipairs(equippedItems) do
        if item.tooltipRight and string.find(string.lower(item.tooltipRight), "escudo") then
            weaponSlotsIds = {16, 18}
            break
        end
    end
    
    for _, item in ipairs(equippedItems) do
        local itemTypeStrL, hasReinfL, reinfStrL = self:ParseArmorString(item.tooltipLeft)
        local itemTypeStrR, hasReinfR, reinfStrR = self:ParseArmorString(item.tooltipRight)
        local baseKey = self:GetArmorKeyByAlias(itemTypeStrL)
        local slotKey = self:GetArmorKeyByAlias(itemTypeStrR)
        local hasReinforcement = hasReinfL or hasReinfR
        local reinforcementStr = (hasReinfL and reinfStrL) or (hasReinfR and reinfStrR) or ""
        
        if (not baseKey or not self:GetArmorTypeInfo(baseKey)) and self:GetArmorTypeInfo(self:GetArmorKeyByAlias(itemTypeStrR)) then
            baseKey = self:GetArmorKeyByAlias(itemTypeStrR)
            slotKey = self:GetArmorKeyByAlias(itemTypeStrL)
        end
        if baseKey and not self:GetArmorTypeInfo(baseKey) then baseKey = nil end
        
        local weaponKey = self:GetWeaponKeyByAlias(item.tooltipRight)
        local isShield = false
        local shieldKey = nil
        if item.tooltipRight and string.find(string.lower(item.tooltipRight), "escudo") then
            isShield = true
            shieldKey = GAC:GetShieldKeyByAlias(item.tooltipRight) or GAC:GetShieldKeyByAlias(item.tooltipLeft)
        end
        
        local targetSlot = slotKey or item.slotID
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
            table.insert(groupedBySlot[targetSlot], item)
            
            if baseKey then
                local info = self:GetArmorTypeInfo(baseKey)
                if info then
                    local physRed = info.physicalReduction or 0
                    local magRed = info.magicalReduction or 0
                    local maxDurability = info.durability or 0
                    local rInfo = nil
                    if hasReinforcement then
                        local rKey = self:GetArmorKeyByAlias(reinforcementStr)
                        if rKey then
                            rInfo = self:GetArmorReinforcementInfo(rKey)
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
                    parsedItemsInfo[item.slotID] = {
                        isArmor = true, baseKey = baseKey, slotKey = slotKey, itemTypeStr = itemTypeStrL .. " - " .. itemTypeStrR,
                        hasReinforcement = hasReinforcement, reinforcementStr = reinforcementStr, maxDurability = maxDurability,
                        physRed = physRed, magRed = magRed, reqs = reqs, pens = pens
                    }
                end
            elseif isShield and shieldKey then
                local info = GAC:GetShieldInfo(shieldKey)
                if info then
                    parsedItemsInfo[item.slotID] = {
                        isShield = true, shieldKey = shieldKey, itemTypeStr = item.tooltipRight,
                        maxDurability = info.durability or 0, physRed = info.physicalReduction or 0, magRed = 0,
                        reqs = info.requirements or {}, pens = info.penalties or {}
                    }
                end
            elseif weaponKey then
                parsedItemsInfo[item.slotID] = { isWeapon = true, weaponKey = weaponKey, itemTypeStr = item.tooltipRight }
            end
        end
    end
    
    local notAllowedSlots = {}
    for slot, itemsInSlot in pairs(groupedBySlot) do
        if #itemsInSlot > 1 then
            local item1, item2 = itemsInSlot[1], itemsInSlot[2]
            local p1, p2 = parsedItemsInfo[item1.slotID], parsedItemsInfo[item2.slotID]
            if p1 and p2 then
                local isNotAllowed = false
                local reason = nil
                if p1.hasReinforcement or p2.hasReinforcement then
                    isNotAllowed = true
                    reason = "No puedes combinar una armadura con refuerzos."
                else
                    local info1 = self:GetArmorTypeInfo(p1.baseKey)
                    if info1 and info1.combinable and info1.combinable[p2.baseKey] then
                        for _, rule in ipairs(info1.combinable[p2.baseKey]) do
                            if rule == "notAllowed" then
                                isNotAllowed = true
                                reason = "Combinación no permitida. No puedes equipar dos piezas del mismo tipo."
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
    if self.characterData then
        local attrs = self.characterData.attributes or {}
        local talents = self.characterData.talents or {}
        for stat, totalReqVal in pairs(totalReqs) do
            local playerVal = (attrs[stat] or 0) + (talents[stat] or 0)
            if playerVal < totalReqVal then
                globallyMeetsRequirements = false
                break
            end
        end
    end
    
    for slot, itemsInSlot in pairs(groupedBySlot) do
        local slotList = { notAllowed = notAllowedSlots[slot] }
        for _, item in ipairs(itemsInSlot) do
            local pInfo = parsedItemsInfo[item.slotID]
            if pInfo then
                if (pInfo.isShield or pInfo.isArmor) and not globallyMeetsRequirements then
                    for stat, val in pairs(pInfo.pens) do pInfo.pens[stat] = val * 2 end
                end
                if pInfo.isShield or pInfo.isWeapon then
                    local damageModifier = 0
                    if item.tooltipLeft then
                        local modVal = string.match(item.tooltipLeft, "%+(%d+)")
                        if modVal then damageModifier = tonumber(modVal) or 0 end
                    end
                    item.weaponData = { weaponKey = pInfo.weaponKey or pInfo.shieldKey, baseStr = pInfo.itemTypeStr, damageModifier = damageModifier }
                end
                if pInfo.isShield or pInfo.isArmor then
                    local curVal = pInfo.maxDurability
                    if item.itemVA and item.itemVA.durability then curVal = tonumber(item.itemVA.durability) end
                    item.armorData = {
                        baseKey = pInfo.baseKey, baseStr = pInfo.itemTypeStr, hasReinforcement = pInfo.hasReinforcement or false,
                        reinforcementStr = pInfo.reinforcementStr or "", slotStr = item.tooltipRight or "", physRed = pInfo.physRed,
                        magRed = pInfo.magRed, currentDurability = tostring(curVal) .. "/" .. tostring(pInfo.maxDurability),
                        maxDurability = pInfo.maxDurability, requirements = pInfo.reqs, penalties = pInfo.pens, meetsRequirements = globallyMeetsRequirements
                    }
                end
            end
            table.insert(slotList, item)
        end
        self.characterData.inventory.equippedArmor[slot] = slotList
        
        if self.playerCharacter then
            if #itemsInSlot > 0 then
                local item = itemsInSlot[1]
                local pInfo = parsedItemsInfo[item.slotID]
                local data = {
                    id = item.id or item.slotID or slot, name = item.itemName or "Objeto", icon = item.icon or item.itemIcon,
                    quality = item.itemQuality or 1, description = "", variable = { slotList = slotList }
                }
                if pInfo and (pInfo.isArmor or pInfo.isShield) then
                    data.slot = item.tooltipRight or ""
                    data.material = item.tooltipLeft or ""
                    self.playerCharacter:SetEquippedItem(slot, GAC.Armor:new(data))
                elseif pInfo and pInfo.isWeapon then
                    data.type = item.tooltipRight or ""
                    data.modificator = item.tooltipLeft or ""
                    self.playerCharacter:SetEquippedItem(slot, GAC.Weapon:new(data))
                else
                    self.playerCharacter:SetEquippedItem(slot, GAC.Item:new(data))
                end
            else
                self.playerCharacter:SetEquippedItem(slot, "")
            end
        end
    end
    if self.quickActionsFrame and self.quickActionsFrame.UpdateArmorIcons then self.quickActionsFrame:UpdateArmorIcons() end
    if self.quickActionsFrame and self.quickActionsFrame.UpdateWeaponIcons then self.quickActionsFrame:UpdateWeaponIcons() end
end

--- Calculates total penalty for a given stat across equipped armor.
-- @param statName string
-- @return number
function GAC:GetArmorPenalty(statName)
    if type(statName) ~= "string" then return 0 end
    if not self.characterData or not self.characterData.inventory or type(self.characterData.inventory.equippedArmor) ~= "table" then return 0 end
    local totalPenalty = 0
    for _, slotList in pairs(self.characterData.inventory.equippedArmor) do
        if type(slotList) == "table" then
            for _, item in ipairs(slotList) do
                if item.armorData and type(item.armorData.penalties) == "table" then
                    totalPenalty = totalPenalty + (tonumber(item.armorData.penalties[statName]) or 0)
                end
            end
        end
    end
    return totalPenalty
end

--- Updates durability value of item in specified slot.
-- @param slotName string
-- @param diffAmount number
-- @return void
function GAC:UpdateTRP3ItemDurability(slotName, diffAmount)
    if not self.characterData or not self.characterData.inventory or not self.characterData.inventory.equippedArmor then return end
    local slotList = self.characterData.inventory.equippedArmor[slotName]
    if not slotList or #slotList == 0 then return end
    local item = slotList[1]
    if not item or not item.armorData or not item.itemID then return end
    local tableMax = tonumber(item.armorData.maxDurability)
    if not tableMax then return end
    local equipped = self:GetTRP3ExtendedEquippedSnapshot()
    local itemData = GAC.TRP3.readSlotValue(equipped, item.slotID)
    if not itemData then return end
    local currentVal = tableMax
    if itemData.VA and itemData.VA.durability then currentVal = tonumber(itemData.VA.durability) end
    local newVal = currentVal + diffAmount
    if newVal < 0 then newVal = 0 end
    if newVal > tableMax then newVal = tableMax end
    local amount = math.abs(newVal - currentVal)
    if amount > 0 then
        local qualityColor = "|cFFFFFFFF"
        local q = item.itemQuality or 1
        if type(q) == "number" or tonumber(q) then
            q = tonumber(q)
            if ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[q] and ITEM_QUALITY_COLORS[q].color then
                qualityColor = ITEM_QUALITY_COLORS[q].color:GenerateHexColorMarkup() or ITEM_QUALITY_COLORS[q].hex or "|cFFFFFFFF"
            else
                local _, _, _, hex = GetItemQualityColor(q)
                if hex then qualityColor = "|c" .. hex end
            end
        end
        if not qualityColor:match("^|c") then
            local _, _, _, hex = GetItemQualityColor(q)
            qualityColor = hex and ("|c" .. hex) or "|cFFFFFFFF"
        end
        local coloredName = qualityColor .. "[" .. tostring(item.itemName) .. "]|r"
        if newVal > currentVal then
            print(coloredName .. " recibe " .. amount .. " de durabilidad.")
        elseif newVal < currentVal then
            print(coloredName .. " pierde " .. amount .. " de durabilidad.")
        end
    end
    self:SetTRP3ExtendedItemVariable(item.slotID, "durability", newVal)
    if type(TRP3_API.events) == "table" and type(TRP3_API.events.fireEvent) == "function" and TRP3_API.inventory then
        TRP3_API.events.fireEvent(TRP3_API.inventory.EVENT_REFRESH_BAG)
        if TRP3_API.events.ON_OBJECT_UPDATED then
            TRP3_API.events.fireEvent(TRP3_API.events.ON_OBJECT_UPDATED)
        end
    end
end

--- Hooks TRP3 Extended events for armor tracking and inventory synchronization.
-- @return void
function GAC:InitTRP3ArmorHook()
    if isTRP3Hooked then return end
    if type(TRP3_API) == "table" and type(TRP3_API.events) == "table" and type(TRP3_API.events.listenToEvent) == "function" then
        local function onInventoryUpdate(...)
            GAC:UpdateEquippedArmor()
            if GAC.contentFrames and GAC.contentFrames.inventory and GAC.contentFrames.inventory:IsVisible() then
                GAC.contentFrames.inventory:Update()
            end
            if GAC.quickActionsFrame and GAC.quickActionsFrame.UpdateArmorIcons then GAC.quickActionsFrame:UpdateArmorIcons() end
            if GAC.quickActionsFrame and GAC.quickActionsFrame.UpdateWeaponIcons then GAC.quickActionsFrame:UpdateWeaponIcons() end
        end
        local eventsToHook = {
            TRP3_API.events.WORKFLOW_ON_LOADED, TRP3_API.events.ON_OBJECT_UPDATED,
            TRP3_API.inventory and TRP3_API.inventory.EVENT_REFRESH_BAG,
            TRP3_API.inventory and TRP3_API.inventory.EVENT_ON_SLOT_SWAP,
            TRP3_API.inventory and TRP3_API.inventory.EVENT_ON_SLOT_REMOVE,
            TRP3_API.inventory and TRP3_API.inventory.EVENT_ON_SLOT_USE,
        }
        for _, eventKey in pairs(eventsToHook) do
            if eventKey then TRP3_API.events.listenToEvent(eventKey, onInventoryUpdate) end
        end
        isTRP3Hooked = true
        if AddOn_TotalRP3 and AddOn_TotalRP3.Communications and AddOn_TotalRP3.Communications.sendObject and not GAC.sendObjectHooked then
            local original_sendObject = AddOn_TotalRP3.Communications.sendObject
            AddOn_TotalRP3.Communications.sendObject = function(prefix, data, target, priority, reservedMessageID, ...)
                if prefix == "IIRS" and type(data) == "table" and type(data.slots) == "table" then
                    local playerInventory = TRP3_API.inventory and TRP3_API.inventory.getInventory and TRP3_API.inventory.getInventory()
                    if playerInventory and playerInventory.content then
                        for slotID, slotInfo in pairs(playerInventory.content) do
                            if data.slots[slotID] and slotInfo.VA then
                                data.slots[slotID].VA = slotInfo.VA
                            end
                        end
                    end
                end
                return original_sendObject(prefix, data, target, priority, reservedMessageID, ...)
            end
            GAC.sendObjectHooked = true
        end
    end
    self:UpdateEquippedArmor()
end
