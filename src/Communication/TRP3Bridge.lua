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

-- ============================================================================
-- TRP3 Extended: Equipped Items & Events
-- ============================================================================

-- Devuelve una tabla con los objetos equipados en el inventario de TRP3 Extended
function GAC:GetTRP3ExtendedEquippedItems()
    if type(TRP3_API) ~= "table" or type(TRP3_API.inventory) ~= "table" then
        return {}
    end

    local equippedItems = {}
    
    -- Intentamos usar getWearables que es comúnmente usado en TRP3 Extended
    if type(TRP3_API.inventory.getWearables) == "function" then
        local wearables = safeCall(TRP3_API.inventory.getWearables)
        if type(wearables) == "table" then
            for slot, itemData in pairs(wearables) do
                table.insert(equippedItems, {
                    slot = slot,
                    data = itemData
                })
            end
            return equippedItems
        end
    end

    -- Alternativamente, intentamos iterar sobre el inventario buscando objetos con flag de equipado
    if type(TRP3_API.inventory.getInventoryList) == "function" then
        local invList = safeCall(TRP3_API.inventory.getInventoryList, "player")
        if type(invList) == "table" then
            for _, itemData in pairs(invList) do
                if itemData.isWearable or itemData.isEquipped then
                    table.insert(equippedItems, {
                        data = itemData
                    })
                end
            end
            return equippedItems
        end
    end

    return equippedItems
end

-- Evento para detectar cuando el jugador se equipa/desequipa algo en TRP3 Extended
local trp3EquipmentCallbacks = {}

function GAC:RegisterTRP3EquipmentCallback(callbackFn)
    if type(callbackFn) == "function" then
        table.insert(trp3EquipmentCallbacks, callbackFn)
    end
end

-- Función interna para notificar a nuestros callbacks
local function FireTRP3EquipmentChanged()
    local equippedItems = GAC:GetTRP3ExtendedEquippedItems()
    for _, callbackFn in ipairs(trp3EquipmentCallbacks) do
        safeCall(callbackFn, equippedItems)
    end
end

-- Inicializador de eventos para TRP3 Extended
function GAC:InitTRP3ExtendedEvents()
    if type(TRP3_API) ~= "table" then return end

    -- Registramos un callback nativo de TRP3. Los eventos exactos de TRP3 Extended 
    -- pueden variar, pero comúnmente son de este tipo:
    local eventsToWatch = {
        "TRP3_INVENTORY_CHANGED",
        "TRP3_WEARABLES_CHANGED",
        "TRP3_ITEM_EQUIPPED",
        "TRP3_ITEM_UNEQUIPPED",
        (TRP3_API.inventory and TRP3_API.inventory.EVENTS and TRP3_API.inventory.EVENTS.INVENTORY_CHANGED)
    }

    for _, eventName in ipairs(eventsToWatch) do
        if type(eventName) == "string" and type(TRP3_API.RegisterCallback) == "function" then
            TRP3_API.RegisterCallback("GAC_TRP3_BRIDGE", eventName, function()
                FireTRP3EquipmentChanged()
            end)
        end
    end

    -- Además, si queremos monitorear el OnEvent de WoW para eventos de TRP3 que se envían globalmente
    local f = CreateFrame("Frame")
    f:RegisterEvent("USER_DATA_SAVED") -- A veces TRP3 guarda después de un cambio de inventario
    f:SetScript("OnEvent", function(self, event, ...)
        -- Solo disparamos si sospechamos que cambió el equipo
        FireTRP3EquipmentChanged()
    end)
end
