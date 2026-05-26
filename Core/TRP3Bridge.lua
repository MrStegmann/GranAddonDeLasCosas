local _, addon = ...

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
        return getItemDisplayName(slotInfo), nil, nil
    end

    local itemName = parseTRP3Text(classData.BA.NA, slotInfo) or getItemDisplayName(slotInfo)
    local tooltipLeft = parseTRP3Text(classData.BA.LE, slotInfo)
    local tooltipRight = parseTRP3Text(classData.BA.RI, slotInfo)

    return itemName, tooltipLeft, tooltipRight
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

function addon:GetTRP3ExtendedEquippedSnapshot()
    return getExtendedInventoryFromAPI() or getExtendedInventoryFromProfileData()
end

function addon:GetTRP3ExtendedEquippedItems()
    local equipped = self:GetTRP3ExtendedEquippedSnapshot()
    if type(equipped) ~= "table" then
        return nil
    end

    local items = {}

    for slotID = 1, WEARABLE_SLOT_COUNT do
        local itemData = readSlotValue(equipped, slotID)
        if itemData then
            local itemName, tooltipLeft, tooltipRight = getItemTooltipFields(itemData)
            items[#items + 1] = {
                slotID = slotID,
                itemName = itemName,
                tooltipLeft = tooltipLeft,
                tooltipRight = tooltipRight,
            }
        end
    end

    return items
end

local function getProfileNameFromData(profileData)
    if type(profileData) ~= "table" then
        return nil
    end

    local directName = trim(profileData.profileName) or trim(profileData.name) or trim(profileData.fullname)
    if directName then
        return directName
    end

    local characteristics = profileData.characteristics
    if type(characteristics) == "table" then
        local firstName = trim(characteristics.FN) or trim(characteristics.fn)
        local lastName = trim(characteristics.LN) or trim(characteristics.ln)

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

    local directCandidates = {
        profileData.color,
        profileData.profileColor,
        profileData.chatColor,
    }

    for _, candidate in ipairs(directCandidates) do
        local normalized = normalizeHexColor(candidate)
        if normalized then
            return normalized
        end
    end

    local characteristics = profileData.characteristics
    if type(characteristics) ~= "table" then
        return nil
    end

    local characteristicCandidates = {
        characteristics.CH,
        characteristics.ch,
        characteristics.CO,
        characteristics.co,
        characteristics.color,
    }

    for _, candidate in ipairs(characteristicCandidates) do
        local normalized = normalizeHexColor(candidate)
        if normalized then
            return normalized
        end
    end

    return nil
end

local function getFromTRP3ProfileAPI(api)
    if type(api) ~= "table" then
        return nil
    end

    local data = safeCall(api.getData, "player")
        or safeCall(api.getData)
        or safeCall(api.getPlayerCurrentProfile)
        or safeCall(api.getCurrentProfile)

    return getProfileNameFromData(data)
end

local function getColorFromTRP3ProfileAPI(api)
    if type(api) ~= "table" then
        return nil
    end

    local data = safeCall(api.getData, "player")
        or safeCall(api.getData)
        or safeCall(api.getPlayerCurrentProfile)
        or safeCall(api.getCurrentProfile)

    return getProfileColorFromData(data)
end

local function getFromTRP3RegisterAPI(api)
    if type(api) ~= "table" then
        return nil
    end

    local unitID = safeCall(api.getUnitID, "player") or "player"

    local directUnit = safeCall(api.getUnit, unitID) or safeCall(api.getUnitData, unitID)
    local directName = getProfileNameFromData(directUnit)
    if directName then
        return directName
    end

    local profileID = safeCall(api.getUnitIDCurrentProfile, unitID)
        or safeCall(api.getUnitCurrentProfile, unitID)
        or safeCall(api.getUnitProfileID, unitID)

    if not profileID then
        return nil
    end

    local profileData = safeCall(api.getProfile, profileID)
    return getProfileNameFromData(profileData)
end

local function getColorFromTRP3RegisterAPI(api)
    if type(api) ~= "table" then
        return nil
    end

    local unitID = safeCall(api.getUnitID, "player") or "player"

    local directUnit = safeCall(api.getUnit, unitID) or safeCall(api.getUnitData, unitID)
    local directColor = getProfileColorFromData(directUnit)
    if directColor then
        return directColor
    end

    local profileID = safeCall(api.getUnitIDCurrentProfile, unitID)
        or safeCall(api.getUnitCurrentProfile, unitID)
        or safeCall(api.getUnitProfileID, unitID)

    if not profileID then
        return nil
    end

    local profileData = safeCall(api.getProfile, profileID)
    return getProfileColorFromData(profileData)
end

function addon:GetActiveTRP3ProfileName()
    if type(TRP3_API) ~= "table" then
        return nil
    end

    local byProfile = getFromTRP3ProfileAPI(TRP3_API.profile)
    if byProfile then
        return byProfile
    end

    local byRegister = getFromTRP3RegisterAPI(TRP3_API.register)
    if byRegister then
        return byRegister
    end

    return nil
end

function addon:GetActiveTRP3ProfileColor()
    if type(TRP3_API) ~= "table" then
        return nil
    end

    local byProfile = getColorFromTRP3ProfileAPI(TRP3_API.profile)
    if byProfile then
        return byProfile
    end

    local byRegister = getColorFromTRP3RegisterAPI(TRP3_API.register)
    if byRegister then
        return byRegister
    end

    return nil
end

