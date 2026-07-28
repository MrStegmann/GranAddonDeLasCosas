--- @module Communication.TRP3.TRP3Utils
-- String normalization, safety wrappers, and profile extraction utilities for TRP3 integration.

local _, GAC = ...

GAC.TRP3 = GAC.TRP3 or {}

--- Trims whitespace from string.
-- @param text string|nil
-- @return string|nil
local function trim(text)
    if type(text) ~= "string" then return nil end
    local cleaned = text:match("^%s*(.-)%s*$")
    return (cleaned ~= "") and cleaned or nil
end
GAC.TRP3.trim = trim

--- Normalizes hex color string to 6-digit hex.
-- @param value string|nil
-- @return string|nil
local function normalizeHexColor(value)
    if type(value) ~= "string" then return nil end
    local color = value:lower():gsub("#", ""):gsub("|c", ""):gsub("|r", "")
    if color:match("^ff%x%x%x%x%x%x$") then return color:sub(3) end
    if color:match("^%x%x%x%x%x%x$") then return color end
    return nil
end
GAC.TRP3.normalizeHexColor = normalizeHexColor

--- Safely executes function via pcall.
-- @param fn function
-- @param ... vararg
-- @return any|nil
local function safeCall(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, result = pcall(fn, ...)
    return ok and result or nil
end
GAC.TRP3.safeCall = safeCall

--- Returns first non-nil trimmed string.
-- @param ... vararg
-- @return string|nil
local function firstTrimmed(...)
    for i = 1, select("#", ...) do
        local value = trim(select(i, ...))
        if value then return value end
    end
    return nil
end
GAC.TRP3.firstTrimmed = firstTrimmed

--- Returns first valid normalized color.
-- @param ... vararg
-- @return string|nil
local function firstNormalizedColor(...)
    for i = 1, select("#", ...) do
        local value = normalizeHexColor(select(i, ...))
        if value then return value end
    end
    return nil
end
GAC.TRP3.firstNormalizedColor = firstNormalizedColor

--- Extracts profile name from profile table.
-- @param profileData table|nil
-- @return string|nil
local function getProfileNameFromData(profileData)
    if type(profileData) ~= "table" then return nil end
    local directName = firstTrimmed(profileData.profileName, profileData.name, profileData.fullname)
    if directName then return directName end
    local characteristics = profileData.characteristics
    if type(characteristics) == "table" then
        local firstName = firstTrimmed(characteristics.FN, characteristics.fn)
        local lastName = firstTrimmed(characteristics.LN, characteristics.ln)
        if firstName and lastName then return firstName .. " " .. lastName end
        if firstName then return firstName end
    end
    return nil
end
GAC.TRP3.getProfileNameFromData = getProfileNameFromData

--- Extracts profile color from profile table.
-- @param profileData table|nil
-- @return string|nil
local function getProfileColorFromData(profileData)
    if type(profileData) ~= "table" then return nil end
    local directColor = firstNormalizedColor(profileData.color, profileData.profileColor, profileData.chatColor)
    if directColor then return directColor end
    local characteristics = profileData.characteristics
    if type(characteristics) ~= "table" then return nil end
    return firstNormalizedColor(characteristics.CH, characteristics.ch, characteristics.CO, characteristics.co, characteristics.color)
end
GAC.TRP3.getProfileColorFromData = getProfileColorFromData

--- Extracts race string from profile data.
-- @param profileData table|nil
-- @return string|nil
local function getProfileRaceFromData(profileData)
    if type(profileData) ~= "table" then return nil end
    local characteristics = profileData.characteristics
    if type(characteristics) == "table" then
        return firstTrimmed(characteristics.RA, characteristics.ra, characteristics.race)
    end
    return nil
end
GAC.TRP3.getProfileRaceFromData = getProfileRaceFromData

--- Extracts class string from profile data.
-- @param profileData table|nil
-- @return string|nil
local function getProfileClassFromData(profileData)
    if type(profileData) ~= "table" then return nil end
    local characteristics = profileData.characteristics
    if type(characteristics) == "table" then
        return firstTrimmed(characteristics.CL, characteristics.cl, characteristics.class)
    end
    return nil
end
GAC.TRP3.getProfileClassFromData = getProfileClassFromData

--- Fetches current player profile data from TRP3 profile API.
-- @param api table|nil
-- @return table|nil
local function getCurrentProfileData(api)
    if type(api) ~= "table" then return nil end
    return safeCall(api.getData, "player")
        or safeCall(api.getData)
        or safeCall(api.getPlayerCurrentProfile)
        or safeCall(api.getCurrentProfile)
end

--- Retrieves extracted profile value from TRP3 Profile API.
-- @param api table|nil
-- @param extractor function
-- @return any|nil
local function getFromTRP3ProfileAPI(api, extractor)
    if type(api) ~= "table" then return nil end
    return extractor(getCurrentProfileData(api))
end

--- Retrieves extracted profile value from TRP3 Register API.
-- @param api table|nil
-- @param extractor function
-- @return any|nil
local function getFromTRP3RegisterAPI(api, extractor)
    if type(api) ~= "table" then return nil end
    local unitID = safeCall(api.getUnitID, "player") or "player"
    local directUnit = safeCall(api.getUnit, unitID) or safeCall(api.getUnitData, unitID)
    local directValue = extractor(directUnit)
    if directValue then return directValue end
    local profileID = safeCall(api.getUnitIDCurrentProfile, unitID)
        or safeCall(api.getUnitCurrentProfile, unitID)
        or safeCall(api.getUnitProfileID, unitID)
    if not profileID then return nil end
    local profileData = safeCall(api.getProfile, profileID)
    return extractor(profileData)
end

--- Helper for evaluating active TRP3 profile fields.
-- @param extractor function
-- @return any|nil
local function getActiveTRP3ProfileValue(extractor)
    if type(TRP3_API) ~= "table" then return nil end
    local byProfile = getFromTRP3ProfileAPI(TRP3_API.profile, extractor)
    if byProfile then return byProfile end
    return getFromTRP3RegisterAPI(TRP3_API.register, extractor)
end
GAC.TRP3.getActiveTRP3ProfileValue = getActiveTRP3ProfileValue

--- Gets target TRP3 profile field.
-- @param extractor function
-- @return any|nil
local function getTargetTRP3ProfileValue(extractor)
    if type(TRP3_API) ~= "table" then return nil end
    local api = TRP3_API.register
    if type(api) ~= "table" then return nil end
    local unitStr = "target"
    local unitID = safeCall(api.getUnitID, unitStr) or unitStr
    local directUnit = safeCall(api.getUnit, unitID) or safeCall(api.getUnitData, unitID)
    local directValue = extractor(directUnit)
    if directValue then return directValue end
    local profileID = safeCall(api.getUnitIDCurrentProfile, unitID)
        or safeCall(api.getUnitCurrentProfile, unitID)
        or safeCall(api.getUnitProfileID, unitID)
    if not profileID then return nil end
    local profileData = safeCall(api.getProfile, profileID)
    return extractor(profileData)
end
GAC.TRP3.getTargetTRP3ProfileValue = getTargetTRP3ProfileValue

--- Returns active player TRP3 profile name.
-- @return string|nil
function GAC:GetActiveTRP3ProfileName()
    return getActiveTRP3ProfileValue(getProfileNameFromData)
end

--- Returns active player TRP3 profile color.
-- @return string|nil
function GAC:GetActiveTRP3ProfileColor()
    return getActiveTRP3ProfileValue(getProfileColorFromData)
end

--- Returns active player TRP3 profile race.
-- @return string
function GAC:GetActiveTRP3ProfileRace()
    return getActiveTRP3ProfileValue(getProfileRaceFromData) or UnitRace("player")
end

--- Returns active player TRP3 profile class.
-- @return string
function GAC:GetActiveTRP3ProfileClass()
    return getActiveTRP3ProfileValue(getProfileClassFromData) or UnitClass("player")
end

--- Returns target TRP3 profile name.
-- @return string
function GAC:GetTargetTRP3ProfileName()
    return getTargetTRP3ProfileValue(getProfileNameFromData) or UnitName("target")
end

--- Returns target TRP3 profile race.
-- @return string
function GAC:GetTargetTRP3ProfileRace()
    return getTargetTRP3ProfileValue(getProfileRaceFromData) or UnitRace("target")
end

--- Returns target TRP3 profile class.
-- @return string
function GAC:GetTargetTRP3ProfileClass()
    return getTargetTRP3ProfileValue(getProfileClassFromData) or UnitClass("target")
end

--- Returns roll display name for player.
-- @return string
function GAC:GetRollDisplayName()
    return self:GetActiveTRP3ProfileName() or UnitName("player") or self.name
end

--- Returns roll display name formatted with hex color markup.
-- @return string
function GAC:GetRollDisplayNameWithColor()
    local name = self:GetRollDisplayName()
    local color = self:GetActiveTRP3ProfileColor()
    if not color then return name end
    return "|cff" .. color .. name .. "|r"
end
