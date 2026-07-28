--- @module Communication.TRP3.TRP3Inventory
-- Inventory and item inspection helpers for TRP3 Extended integration.

local _, GAC = ...

local WEARABLE_SLOT_COUNT = 16
GAC.TRP3 = GAC.TRP3 or {}

local trim = GAC.TRP3.trim
local safeCall = GAC.TRP3.safeCall

local getItemDisplayName

local function parseTRP3Text(rawText, slotInfo)
    if type(rawText) ~= "string" then return nil end
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
    if type(slotInfo) ~= "table" or type(slotInfo.id) ~= "string" then return nil end
    if type(TRP3_API) ~= "table"
        or type(TRP3_API.extended) ~= "table"
        or type(TRP3_API.extended.getClass) ~= "function"
    then
        return nil
    end
    return safeCall(TRP3_API.extended.getClass, slotInfo.id)
end

getItemDisplayName = function(itemData)
    if itemData == nil then return nil end
    if type(itemData) == "string" then
        local clean = trim(itemData)
        return clean or nil
    end
    if type(itemData) ~= "table" then return tostring(itemData) end

    local nameCandidates = {
        itemData.link, itemData.itemLink, itemData.name, itemData.itemName,
        itemData.label, itemData.title, itemData.id, itemData.itemID,
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
                if clean then return clean end
            elseif candidateType == "number" then
                return tostring(candidate)
            end
        end
    end
    return nil
end

local function getItemTooltipFields(slotInfo)
    local BA = nil
    if type(slotInfo) == "table" and type(slotInfo.BA) == "table" then
        BA = slotInfo.BA
    else
        local classData = getItemClassData(slotInfo)
        if type(classData) == "table" and type(classData.BA) == "table" then
            BA = classData.BA
        end
    end
    
    if type(BA) ~= "table" then
        return getItemDisplayName(slotInfo), nil, nil, nil
    end

    local itemName = parseTRP3Text(BA.NA, slotInfo) or getItemDisplayName(slotInfo)
    local tooltipLeft = parseTRP3Text(BA.LE, slotInfo)
    local tooltipRight = parseTRP3Text(BA.RI, slotInfo)
    local itemDescription = parseTRP3Text(BA.DE, slotInfo)

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
                    if rInfo then maxDurability = maxDurability + (rInfo.durability or 0) end
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

    local itemIcon = BA.IC or "INV_Misc_QuestionMark"
    local itemQuality = BA.QA

    return itemName, tooltipLeft, tooltipRight, itemDescription, itemIcon, itemQuality
end
GAC.TRP3.getItemTooltipFields = getItemTooltipFields

local function findFirstTable(candidates)
    for _, candidate in ipairs(candidates) do
        if type(candidate) == "table" then return candidate end
    end
    return nil
end

local function readSlotValue(slotTable, slotID)
    if type(slotTable) ~= "table" then return nil end
    return slotTable[tostring(slotID)]
end
GAC.TRP3.readSlotValue = readSlotValue

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
    if type(TRP3_API) ~= "table" then return nil end
    local extended = TRP3_API.extended
    if type(extended) ~= "table" then return nil end
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
    if type(inventoryData) ~= "table" then return nil end
    if type(inventoryData.content) == "table" then return inventoryData.content end
    return findFirstTable({ inventoryData.equipped, inventoryData.equipment, inventoryData.slots, inventoryData.worn, inventoryData })
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
    if type(TRP3_API) ~= "table" or type(TRP3_API.profile) ~= "table" then return nil end
    local profileData = safeCall(TRP3_API.profile.getData, "player") or safeCall(TRP3_API.profile.getData) or safeCall(TRP3_API.profile.getCurrentProfile)
    if type(profileData) ~= "table" then return nil end
    local extendedData = profileData.extended or profileData.Extended or profileData.EXTENDED
    if type(extendedData) ~= "table" then return nil end
    local inventoryData = extendedData.inventory or extendedData.Inventory
    if type(inventoryData) ~= "table" then return nil end
    if type(inventoryData.content) == "table" then return inventoryData.content end
    return findFirstTable({ inventoryData.equipped, inventoryData.equipment, inventoryData.slots, inventoryData.worn, inventoryData })
end

--- Gets TRP3 Extended variable value for a given slot.
-- @param slotID number|string
-- @param varName string
-- @return any|nil
function GAC:GetTRP3ExtendedItemVariable(slotID, varName)
    local equipped = self:GetTRP3ExtendedEquippedSnapshot()
    local itemData = readSlotValue(equipped, slotID)
    if itemData and itemData.VA then return itemData.VA[varName] end
    return nil
end

--- Sets TRP3 Extended variable value for a given slot.
-- @param slotID number|string
-- @param varName string
-- @param value any
-- @return boolean
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

local targetInventoryCallback = nil
local function onInspectionResponseReceived(response, sender)
    local expected = GAC.inspectedPlayerName and Ambiguate(GAC.inspectedPlayerName, "none") or ""
    local actual = sender and Ambiguate(sender, "none") or ""
    if actual == expected and expected ~= "" and targetInventoryCallback then
        targetInventoryCallback(response.slots or {})
    end
end

--- Requests extended inventory of target player.
-- @param targetName string
-- @param callback function
-- @return void
function GAC:RequestTargetExtendedInventory(targetName, callback)
    if not TRP3_API or not AddOn_TotalRP3 or not AddOn_TotalRP3.Communications then
        if callback then callback({}) end
        return
    end
    if not self.inspectionResponseRegistered then
        AddOn_TotalRP3.Communications.registerSubSystemPrefix("IIRS", onInspectionResponseReceived)
        self.inspectionResponseRegistered = true
    end
    self.inspectedPlayerName = targetName
    targetInventoryCallback = callback
    local reservedMessageID = AddOn_TotalRP3.Communications.getNewMessageToken()
    AddOn_TotalRP3.Communications.sendObject("IIRQ", { reservedMessageID }, targetName, AddOn_TotalRP3.Communications.PRIORITIES.MEDIUM)
end

--- Retrieves snapshot table of equipped items.
-- @return table|nil
function GAC:GetTRP3ExtendedEquippedSnapshot()
    return getExtendedInventoryFromAPI() or getExtendedInventoryFromProfileData()
end

--- Retrieves list of equipped item objects.
-- @return table|nil
function GAC:GetTRP3ExtendedEquippedItems()
    local equipped = self:GetTRP3ExtendedEquippedSnapshot()
    if type(equipped) ~= "table" then return nil end
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

--- Parses single TRP3 Extended item data.
-- @param itemData table|nil
-- @param slotID number
-- @return table|nil
function GAC:ParseTRP3ExtendedItem(itemData, slotID)
    if not itemData then return nil end
    local itemName, tooltipLeft, tooltipRight, itemDescription, itemIcon, itemQuality = getItemTooltipFields(itemData)
    return {
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
