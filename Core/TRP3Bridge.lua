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

function addon:GetRollDisplayName()
    return self:GetActiveTRP3ProfileName() or UnitName("player") or self.name
end

function addon:GetRollDisplayNameWithColor()
    local name = self:GetRollDisplayName()
    local color = self:GetActiveTRP3ProfileColor()

    if not color then
        return name
    end

    return "|cff" .. color .. name .. "|r"
end
