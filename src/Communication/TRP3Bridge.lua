local _, GAC = ...

local function trim(text)
    if type(text) ~= "string" then
        return nil
    end

    local cleaned = text:match("^%s*(.-)%s*$")
    if cleaned == "" then
        return nil
    end

    return cleaned
end

local function normalizeHexColor(value)
    if type(value) ~= "string" then
        return nil
    end

    local color = value:lower():gsub("#", "")
    color = color:gsub("|c", "")
    color = color:gsub("|r", "")

    if color:match("^ff%x%x%x%x%x%x$") then
        return color:sub(3)
    end

    if color:match("^%x%x%x%x%x%x$") then
        return color
    end

    return nil
end

local function safeCall(fn, ...)
    if type(fn) ~= "function" then
        return nil
    end

    local ok, result = pcall(fn, ...)
    if not ok then
        return nil
    end

    return result
end

local function firstTrimmed(...)
    for i = 1, select("#", ...) do
        local value = trim(select(i, ...))
        if value then
            return value
        end
    end

    return nil
end

local function firstNormalizedColor(...)
    for i = 1, select("#", ...) do
        local value = normalizeHexColor(select(i, ...))
        if value then
            return value
        end
    end

    return nil
end

local function getProfileNameFromData(profileData)
    if type(profileData) ~= "table" then
        return nil
    end

    local directName = firstTrimmed(profileData.profileName, profileData.name, profileData.fullname)
    if directName then
        return directName
    end

    local characteristics = profileData.characteristics
    if type(characteristics) == "table" then
        local firstName = firstTrimmed(characteristics.FN, characteristics.fn)
        local lastName = firstTrimmed(characteristics.LN, characteristics.ln)

        if firstName and lastName then
            return firstName .. " " .. lastName
        end

        if firstName then
            return firstName
        end
    end

    return nil
end

local function getProfileColorFromData(profileData)
    if type(profileData) ~= "table" then
        return nil
    end

    local directColor = firstNormalizedColor(
        profileData.color,
        profileData.profileColor,
        profileData.chatColor
    )
    if directColor then
        return directColor
    end

    local characteristics = profileData.characteristics
    if type(characteristics) ~= "table" then
        return nil
    end

    return firstNormalizedColor(
        characteristics.CH,
        characteristics.ch,
        characteristics.CO,
        characteristics.co,
        characteristics.color
    )
end

local function getCurrentProfileData(api)
    if type(api) ~= "table" then
        return nil
    end

    return safeCall(api.getData, "player")
        or safeCall(api.getData)
        or safeCall(api.getPlayerCurrentProfile)
        or safeCall(api.getCurrentProfile)
end

local function getFromTRP3ProfileAPI(api, extractor)
    if type(api) ~= "table" then
        return nil
    end

    return extractor(getCurrentProfileData(api))
end

local function getFromTRP3RegisterAPI(api, extractor)
    if type(api) ~= "table" then
        return nil
    end

    local unitID = safeCall(api.getUnitID, "player") or "player"

    local directUnit = safeCall(api.getUnit, unitID) or safeCall(api.getUnitData, unitID)
    local directValue = extractor(directUnit)
    if directValue then
        return directValue
    end

    local profileID = safeCall(api.getUnitIDCurrentProfile, unitID)
        or safeCall(api.getUnitCurrentProfile, unitID)
        or safeCall(api.getUnitProfileID, unitID)

    if not profileID then
        return nil
    end

    local profileData = safeCall(api.getProfile, profileID)
    return extractor(profileData)
end

local function getProfileRaceFromData(profileData)
    if type(profileData) ~= "table" then return nil end
    local characteristics = profileData.characteristics
    if type(characteristics) == "table" then
        return firstTrimmed(characteristics.RA, characteristics.ra, characteristics.race)
    end
    return nil
end

local function getProfileClassFromData(profileData)
    if type(profileData) ~= "table" then return nil end
    local characteristics = profileData.characteristics
    if type(characteristics) == "table" then
        return firstTrimmed(characteristics.CL, characteristics.cl, characteristics.class)
    end
    return nil
end

local function getActiveTRP3ProfileValue(extractor)
    if type(TRP3_API) ~= "table" then
        return nil
    end

    local byProfile = getFromTRP3ProfileAPI(TRP3_API.profile, extractor)
    if byProfile then
        return byProfile
    end

    local byRegister = getFromTRP3RegisterAPI(TRP3_API.register, extractor)
    if byRegister then
        return byRegister
    end

    return nil
end

function GAC:GetActiveTRP3ProfileName()
    return getActiveTRP3ProfileValue(getProfileNameFromData)
end

function GAC:GetActiveTRP3ProfileColor()
    return getActiveTRP3ProfileValue(getProfileColorFromData)
end

function GAC:GetActiveTRP3ProfileRace()
    return getActiveTRP3ProfileValue(getProfileRaceFromData) or UnitRace("player")
end

function GAC:GetActiveTRP3ProfileClass()
    return getActiveTRP3ProfileValue(getProfileClassFromData) or UnitClass("player")
end

function GAC:GetRollDisplayName()
    return self:GetActiveTRP3ProfileName() or UnitName("player") or self.name
end

function GAC:GetRollDisplayNameWithColor()
    local name = self:GetRollDisplayName()
    local color = self:GetActiveTRP3ProfileColor()

    if not color then
        return name
    end

    return "|cff" .. color .. name .. "|r"
end

local function getTargetTRP3ProfileValue(extractor)
    if type(TRP3_API) ~= "table" then
        return nil
    end

    local api = TRP3_API.register
    if type(api) ~= "table" then
        return nil
    end

    local unitStr = "target"
    local unitID = safeCall(api.getUnitID, unitStr) or unitStr

    local directUnit = safeCall(api.getUnit, unitID) or safeCall(api.getUnitData, unitID)
    local directValue = extractor(directUnit)
    if directValue then
        return directValue
    end

    local profileID = safeCall(api.getUnitIDCurrentProfile, unitID)
        or safeCall(api.getUnitCurrentProfile, unitID)
        or safeCall(api.getUnitProfileID, unitID)

    if not profileID then
        return nil
    end

    local profileData = safeCall(api.getProfile, profileID)
    return extractor(profileData)
end

function GAC:GetTargetTRP3ProfileName()
    return getTargetTRP3ProfileValue(getProfileNameFromData) or UnitName("target")
end

function GAC:GetTargetTRP3ProfileRace()
    return getTargetTRP3ProfileValue(getProfileRaceFromData) or UnitRace("target")
end

function GAC:GetTargetTRP3ProfileClass()
    return getTargetTRP3ProfileValue(getProfileClassFromData) or UnitClass("target")
end

local WEARABLE_SLOT_COUNT = 16
local getItemDisplayName
local function parseTRP3Text(rawText, slotInfo)
    if type(rawText) ~= "string" then
        return nil
    end

    local parsed = rawText
    if type(TRP3_API) == "table"
        and type(TRP3_API.script) == "table"
        and type(TRP3_API.script.parseArgs) == "function"
    then
        parsed = safeCall(TRP3_API.script.parseArgs, rawText, { object = slotInfo }) or rawText
    end

    return trim(parsed)
end

local function getItemClassData(slotInfo)
    if type(slotInfo) ~= "table" or type(slotInfo.id) ~= "string" then
        return nil
    end

    if type(TRP3_API) ~= "table"
        or type(TRP3_API.extended) ~= "table"
        or type(TRP3_API.extended.getClass) ~= "function"
    then
        return nil
    end

    return safeCall(TRP3_API.extended.getClass, slotInfo.id)
end

local function getItemTooltipFields(slotInfo)
    local classData = getItemClassData(slotInfo)
    if type(classData) ~= "table" or type(classData.BA) ~= "table" then
        return getItemDisplayName(slotInfo), nil, nil, nil
    end

    local itemName = parseTRP3Text(classData.BA.NA, slotInfo) or getItemDisplayName(slotInfo)
    local tooltipLeft = parseTRP3Text(classData.BA.LE, slotInfo)
    local tooltipRight = parseTRP3Text(classData.BA.RI, slotInfo)
    
    local itemDescription = parseTRP3Text(classData.BA.DE, slotInfo)

    -- Extraemos la durabilidad dinámicamente de la tabla base en vez de la descripción
    local itemTypeStrL, hasReinfL, reinfStrL = GAC:ParseArmorString(tooltipLeft)
    local itemTypeStrR, hasReinfR, reinfStrR = GAC:ParseArmorString(tooltipRight)
    
    local baseKey = GAC:GetArmorKeyByAlias(itemTypeStrL)
    local slotKey = GAC:GetArmorKeyByAlias(itemTypeStrR)
    
    local hasReinforcement = hasReinfL or hasReinfR
    local reinforcementStr = (hasReinfL and reinfStrL) or (hasReinfR and reinfStrR) or ""
    
    if (not baseKey or not GAC:GetArmorTypeInfo(baseKey)) and GAC:GetArmorTypeInfo(GAC:GetArmorKeyByAlias(itemTypeStrR)) then
        baseKey = GAC:GetArmorKeyByAlias(itemTypeStrR)
        slotKey = GAC:GetArmorKeyByAlias(itemTypeStrL)
    end
    
    local maxDurability = nil
    if baseKey then
        local info = GAC:GetArmorTypeInfo(baseKey)
        if info then
            maxDurability = info.durability or 0
            if hasReinforcement then
                local rKey = GAC:GetArmorKeyByAlias(reinforcementStr)
                if rKey then
                    local rInfo = GAC:GetArmorReinforcementInfo(rKey)
                    if rInfo then
                        maxDurability = maxDurability + (rInfo.durability or 0)
                    end
                end
            end
        end
    end
    
    if maxDurability then
        local curDur = maxDurability
        if slotInfo and slotInfo.VA and slotInfo.VA.durability then
            curDur = tonumber(slotInfo.VA.durability)
        end
        
        local durStr = "\n\nDurabilidad: " .. tostring(curDur) .. "/" .. tostring(maxDurability)
        
        if type(itemDescription) == "string" and itemDescription ~= "" then
            itemDescription = itemDescription .. durStr
        else
            itemDescription = "Durabilidad: " .. tostring(curDur) .. "/" .. tostring(maxDurability)
        end
    end

    local itemIcon = classData.BA.IC or "INV_Misc_QuestionMark"
    local itemQuality = classData.BA.QA

    return itemName, tooltipLeft, tooltipRight, itemDescription, itemIcon, itemQuality
end

local function findFirstTable(candidates)
    for _, candidate in ipairs(candidates) do
        if type(candidate) == "table" then
            return candidate
        end
    end

    return nil
end

getItemDisplayName = function(itemData)
    if itemData == nil then
        return nil
    end

    if type(itemData) == "string" then
        local clean = trim(itemData)
        if clean then
            return clean
        end
        return nil
    end

    if type(itemData) ~= "table" then
        return tostring(itemData)
    end

    local nameCandidates = {
        itemData.link,
        itemData.itemLink,
        itemData.name,
        itemData.itemName,
        itemData.label,
        itemData.title,
        itemData.id,
        itemData.itemID,
    }

    if type(itemData.id) == "string"
        and type(TRP3_API) == "table"
        and type(TRP3_API.inventory) == "table"
        and type(TRP3_API.extended) == "table"
        and type(TRP3_API.extended.getClass) == "function"
        and type(TRP3_API.inventory.getItemLink) == "function"
    then
        local classData = safeCall(TRP3_API.extended.getClass, itemData.id)
        local itemLink = safeCall(TRP3_API.inventory.getItemLink, classData, itemData.id)
        if type(itemLink) == "string" and itemLink ~= "" then
            table.insert(nameCandidates, 1, itemLink)
        end
    end

    for _, candidate in ipairs(nameCandidates) do
        if candidate ~= nil then
            local candidateType = type(candidate)
            if candidateType == "string" then
                local clean = trim(candidate)
                if clean then
                    return clean
                end
            elseif candidateType == "number" then
                return tostring(candidate)
            end
        end
    end

    return nil
end

local function readSlotValue(slotTable, slotID)
    if type(slotTable) ~= "table" then
        return nil
    end

    return slotTable[tostring(slotID)]
end

local function getExtendedInventoryFromAPI()
    if type(TRP3_API) == "table"
        and type(TRP3_API.inventory) == "table"
        and type(TRP3_API.inventory.getInventory) == "function"
    then
        local playerInventory = safeCall(TRP3_API.inventory.getInventory)
        if type(playerInventory) == "table" and type(playerInventory.content) == "table" then
            return playerInventory.content
        end
    end

    if type(TRP3_API) ~= "table" then
        return nil
    end

    local extended = TRP3_API.extended
    if type(extended) ~= "table" then
        return nil
    end

    local inventoryModule = extended.inventory
    local itemsModule = extended.items

    local inventoryCandidates = {
        safeCall(extended.getPlayerInventory, "player"),
        safeCall(extended.getPlayerInventory),
        safeCall(extended.getInventoryForUnit, "player"),
        safeCall(extended.getInventory, "player"),
        safeCall(inventoryModule and inventoryModule.getPlayerInventory, "player"),
        safeCall(inventoryModule and inventoryModule.getPlayerInventory),
        safeCall(inventoryModule and inventoryModule.getInventoryForUnit, "player"),
        safeCall(inventoryModule and inventoryModule.getInventory, "player"),
        safeCall(itemsModule and itemsModule.getPlayerInventory, "player"),
        safeCall(itemsModule and itemsModule.getInventoryForUnit, "player"),
    }

    local inventoryData = findFirstTable(inventoryCandidates)
    if type(inventoryData) ~= "table" then
        return nil
    end

    if type(inventoryData.content) == "table" then
        return inventoryData.content
    end

    local equippedCandidates = {
        inventoryData.equipped,
        inventoryData.equipment,
        inventoryData.slots,
        inventoryData.worn,
        inventoryData,
    }

    return findFirstTable(equippedCandidates)
end

local function getExtendedInventoryFromProfileData()
    if type(TRP3_API) == "table"
        and type(TRP3_API.profile) == "table"
        and type(TRP3_API.profile.getPlayerCurrentProfile) == "function"
    then
        local profileData = safeCall(TRP3_API.profile.getPlayerCurrentProfile)
        if type(profileData) == "table"
            and type(profileData.inventory) == "table"
            and type(profileData.inventory.content) == "table"
        then
            return profileData.inventory.content
        end
    end

    if type(TRP3_API) ~= "table" or type(TRP3_API.profile) ~= "table" then
        return nil
    end

    local profileData = safeCall(TRP3_API.profile.getData, "player")
        or safeCall(TRP3_API.profile.getData)
        or safeCall(TRP3_API.profile.getCurrentProfile)

    if type(profileData) ~= "table" then
        return nil
    end

    local extendedData = profileData.extended or profileData.Extended or profileData.EXTENDED
    if type(extendedData) ~= "table" then
        return nil
    end

    local inventoryData = extendedData.inventory or extendedData.Inventory
    if type(inventoryData) ~= "table" then
        return nil
    end

    if type(inventoryData.content) == "table" then
        return inventoryData.content
    end

    local equippedCandidates = {
        inventoryData.equipped,
        inventoryData.equipment,
        inventoryData.slots,
        inventoryData.worn,
        inventoryData,
    }

    return findFirstTable(equippedCandidates)
end

function GAC:GetTRP3ExtendedItemVariable(slotID, varName)
    local equipped = self:GetTRP3ExtendedEquippedSnapshot()
    local itemData = readSlotValue(equipped, slotID)
    if itemData and itemData.VA then
        return itemData.VA[varName]
    end
    return nil
end

function GAC:SetTRP3ExtendedItemVariable(slotID, varName, value)
    local equipped = self:GetTRP3ExtendedEquippedSnapshot()
    local itemData = readSlotValue(equipped, slotID)
    if itemData then
        itemData.VA = itemData.VA or {}
        itemData.VA[varName] = value
        return true
    end
    return false
end

function GAC:GetTRP3ExtendedEquippedSnapshot()
    return getExtendedInventoryFromAPI() or getExtendedInventoryFromProfileData()
end

function GAC:GetTRP3ExtendedEquippedItems()
    local equipped = self:GetTRP3ExtendedEquippedSnapshot()
    if type(equipped) ~= "table" then
        return nil
    end

    local items = {}

    for slotID = 1, WEARABLE_SLOT_COUNT do
        local itemData = readSlotValue(equipped, slotID)
        if itemData then
            local itemName, tooltipLeft, tooltipRight, itemDescription, itemIcon, itemQuality = getItemTooltipFields(itemData)
            items[#items + 1] = {
                slotID = slotID,
                itemID = itemData.id,
                itemName = itemName,
                tooltipLeft = tooltipLeft,
                tooltipRight = tooltipRight,
                itemDescription = itemDescription,
                itemIcon = itemIcon,
                itemQuality = itemQuality,
                itemVA = itemData.VA or {},
            }
        end
    end

    return items
end

local isTRP3Hooked = false

function GAC:UpdateEquippedArmor()
    self.characterData = self.characterData or {}
    self.characterData.inventory = self.characterData.inventory or {}
    self.characterData.inventory.equippedArmor = {}
    
    local equippedItems = self:GetTRP3ExtendedEquippedItems() or {}
    
    local groupedBySlot = {}
    local parsedItemsInfo = {}
    
    -- PASO 1: Parseo individual de cada pieza y agrupación por ranura
    for _, item in ipairs(equippedItems) do
        local itemTypeStrL, hasReinfL, reinfStrL = self:ParseArmorString(item.tooltipLeft)
        local itemTypeStrR, hasReinfR, reinfStrR = self:ParseArmorString(item.tooltipRight)
        
        local baseKey = self:GetArmorKeyByAlias(itemTypeStrL)
        local slotKey = self:GetArmorKeyByAlias(itemTypeStrR)
        
        local hasReinforcement = hasReinfL or hasReinfR
        local reinforcementStr = (hasReinfL and reinfStrL) or (hasReinfR and reinfStrR) or ""
        
        -- Si están invertidos (Ej: "Cabeza" a la izquierda, "Placas" a la derecha)
        if (not baseKey or not self:GetArmorTypeInfo(baseKey)) and self:GetArmorTypeInfo(self:GetArmorKeyByAlias(itemTypeStrR)) then
            baseKey = self:GetArmorKeyByAlias(itemTypeStrR)
            slotKey = self:GetArmorKeyByAlias(itemTypeStrL)
        end
        
        -- Si la base Key se detectó pero es un slot (Ej: "Cabeza"), descartarlo como base
        if baseKey and not self:GetArmorTypeInfo(baseKey) then
            baseKey = nil
        end
        
        local targetSlot = slotKey or item.slotID
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
                    for stat, val in pairs(info.requirements[slotKey]) do
                        reqs[stat] = (reqs[stat] or 0) + val
                    end
                end
                if rInfo and rInfo.requirements then
                    for stat, val in pairs(rInfo.requirements) do
                        reqs[stat] = (reqs[stat] or 0) + val
                    end
                end
                
                local pens = {}
                if slotKey and info.disadvantage and info.disadvantage[slotKey] then
                    for stat, val in pairs(info.disadvantage[slotKey]) do
                        pens[stat] = (pens[stat] or 0) + val
                    end
                end
                if rInfo and rInfo.disadvantage then
                    for stat, val in pairs(rInfo.disadvantage) do
                        pens[stat] = (pens[stat] or 0) + val
                    end
                end
                
                parsedItemsInfo[item.slotID] = {
                    baseKey = baseKey,
                    itemTypeStr = itemTypeStrL,
                    hasReinforcement = hasReinforcement,
                    reinforcementStr = reinforcementStr,
                    slotKey = slotKey,
                    physRed = physRed,
                    magRed = magRed,
                    maxDurability = maxDurability,
                    reqs = reqs,
                    pens = pens
                }
            end
        end
    end
    
    -- PASO 2: Lógica de Combinación por Slot
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
                    isNotAllowed = true
                    reason = "No puedes combinar una armadura con refuerzos."
                else
                    local info1 = self:GetArmorTypeInfo(p1.baseKey)
                    if info1 and info1.combinable and info1.combinable[p2.baseKey] then
                        local rules = info1.combinable[p2.baseKey]
                        for _, rule in ipairs(rules) do
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
                if isNotAllowed then
                    notAllowedSlots[slot] = reason or "Combinación no permitida."
                end
            end
        end
    end
    
    -- PASO 3: Calcular la suma total de requerimientos post-combinación
    local totalReqs = {}
    for _, item in ipairs(equippedItems) do
        local pInfo = parsedItemsInfo[item.slotID]
        if pInfo and pInfo.reqs then
            for stat, val in pairs(pInfo.reqs) do
                totalReqs[stat] = (totalReqs[stat] or 0) + val
            end
        end
    end
    
    -- PASO 4: Comprobar el total contra los atributos del jugador
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
    
    -- PASO 5: Asignar data y penalizaciones finales (y empaquetar por slot)
    for slot, itemsInSlot in pairs(groupedBySlot) do
        local slotList = { notAllowed = notAllowedSlots[slot] }
        for _, item in ipairs(itemsInSlot) do
            local pInfo = parsedItemsInfo[item.slotID]
            if pInfo then
                if not globallyMeetsRequirements then
                    for stat, val in pairs(pInfo.pens) do
                        pInfo.pens[stat] = val * 2
                    end
                end
                
                local curVal = pInfo.maxDurability
                if item.itemVA and item.itemVA.durability then
                    curVal = tonumber(item.itemVA.durability)
                end
                
                item.armorData = {
                    baseStr = pInfo.itemTypeStr,
                    hasReinforcement = pInfo.hasReinforcement,
                    reinforcementStr = pInfo.reinforcementStr,
                    slotStr = item.tooltipRight or "",
                    physRed = pInfo.physRed,
                    magRed = pInfo.magRed,
                    currentDurability = tostring(curVal) .. "/" .. tostring(pInfo.maxDurability),
                    maxDurability = pInfo.maxDurability,
                    requirements = pInfo.reqs,
                    penalties = pInfo.pens,
                    meetsRequirements = globallyMeetsRequirements
                }
            end
            table.insert(slotList, item)
        end
        self.characterData.inventory.equippedArmor[slot] = slotList
    end
    
    if self.quickActionsFrame and self.quickActionsFrame.UpdateArmorIcons then
        self.quickActionsFrame:UpdateArmorIcons()
    end
end

function GAC:GetArmorPenalty(statName)
    if type(statName) ~= "string" then return 0 end
    if not self.characterData or not self.characterData.inventory or type(self.characterData.inventory.equippedArmor) ~= "table" then
        return 0
    end
    
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

function GAC:UpdateTRP3ItemDurability(slotName, diffAmount)
    if not self.characterData or not self.characterData.inventory or not self.characterData.inventory.equippedArmor then return end
    
    local slotList = self.characterData.inventory.equippedArmor[slotName]
    if not slotList or #slotList == 0 then return end
    
    local item = slotList[1]
    if not item or not item.armorData or not item.itemID then return end
    
    local tableMax = tonumber(item.armorData.maxDurability)
    if not tableMax then return end
    
    local equipped = self:GetTRP3ExtendedEquippedSnapshot()
    local itemData = readSlotValue(equipped, item.slotID)
    if not itemData then return end
    
    local currentVal = tableMax
    if itemData.VA and itemData.VA.durability then
        currentVal = tonumber(itemData.VA.durability)
    end
    
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
                if hex then
                    qualityColor = "|c" .. hex
                end
            end
        end
        
        -- Fallback si ITEM_QUALITY_COLORS[q].hex no existe en esta versión de WoW (Epsilon usa 9.2 o similar)
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
    
    if type(TRP3_API.events) == "table" and type(TRP3_API.events.fireEvent) == "function" then
        TRP3_API.events.fireEvent("EXTENDED_INVENTORY_UPDATE")
    end
    
    self:UpdateEquippedArmor()
    
    if self.quickActionsFrame and self.quickActionsFrame.UpdateArmorIcons then
        self.quickActionsFrame:UpdateArmorIcons()
    end
    
    if self.contentFrames and self.contentFrames.inventory and self.contentFrames.inventory:IsShown() then
        self.contentFrames.inventory:Update()
    end
end

function GAC:InitTRP3ArmorHook()
    if isTRP3Hooked then return end
    
    if type(TRP3_API) == "table" and type(TRP3_API.events) == "table" and type(TRP3_API.events.listenToEvent) == "function" then
        local function onInventoryUpdate()
            GAC:UpdateEquippedArmor()
            if GAC.contentFrames and GAC.contentFrames.inventory and GAC.contentFrames.inventory:IsVisible() then
                GAC.contentFrames.inventory:Update()
            end
        end
        
        local eventsToHook = {
            "WORKFLOW_ON_LOADED",
            "EXTENDED_INVENTORY_UPDATE",
            "EXTENDED_WEARABLE_UPDATE"
        }
        
        for _, eventName in ipairs(eventsToHook) do
            if TRP3_API.events[eventName] then
                TRP3_API.events.listenToEvent(TRP3_API.events[eventName], onInventoryUpdate)
            else
                TRP3_API.events.listenToEvent(eventName, onInventoryUpdate)
            end
        end
        isTRP3Hooked = true
    end
    
    -- Primera carga manual
    self:UpdateEquippedArmor()
end