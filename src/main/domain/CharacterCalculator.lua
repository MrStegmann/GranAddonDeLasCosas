--- @module domain.CharacterCalculator
-- Pure Lua calculation engine for character stats, health caps, and attributes.
-- Completely isolated from World of Warcraft API dependencies.

local CharacterCalculator = {}

-- Base health categories fallback table
local DEFAULT_HEALTH_TABLE = {
    noob = { [1] = 10, [2] = 11, [3] = 13, [4] = 16, [5] = 20 },
    normal = { [1] = 20, [2] = 27, [3] = 34, [4] = 41, [5] = 49, [6] = 57, [7] = 65, [8] = 74, [9] = 83, [10] = 92 },
    elite = { [1] = 40, [2] = 54, [3] = 68, [4] = 82, [5] = 98, [6] = 114, [7] = 130, [8] = 148, [9] = 166, [10] = 184 },
    boss = { [1] = 80, [2] = 108, [3] = 136, [4] = 164, [5] = 196, [6] = 228, [7] = 260, [8] = 296, [9] = 332, [10] = 370 }
}

--- Calculates max health deterministically from category, level, and constitution attribute.
-- @param category string Character category ("noob", "normal", "elite", "boss")
-- @param level number Character level (1-10)
-- @param constitution number Constitution stat modifier
-- @param customTable table|nil Optional level table override
-- @return number Max health value
function CharacterCalculator.CalculateMaxHealth(category, level, constitution, customTable)
    category = (type(category) == "string" and category) or "normal"
    level = (type(level) == "number" and math.max(1, math.floor(level))) or 1
    constitution = (type(constitution) == "number" and constitution) or 0

    local tableRef = customTable or DEFAULT_HEALTH_TABLE
    local catData = tableRef[category] or tableRef["normal"]
    local baseHealth = catData[level] or catData[1] or 10
    if type(baseHealth) == "table" then
        baseHealth = baseHealth.maxHealth or 10
    end

    return math.max(1, baseHealth + constitution)
end

--- Clamps health within 0 and maxHealth bounds.
-- @param current number Current health
-- @param maxHealth number Max health
-- @return number Clamped current health
function CharacterCalculator.ClampHealth(current, maxHealth)
    maxHealth = (type(maxHealth) == "number" and maxHealth >= 1) and maxHealth or 10
    current = (type(current) == "number") and current or maxHealth
    return math.min(math.max(0, current), maxHealth)
end

--- Clamps resource points (mana, spirit, shield) within valid range.
-- @param current number Current resource value
-- @param maxVal number Maximum allowed resource value
-- @return number Clamped resource value
function CharacterCalculator.ClampResource(current, maxVal)
    maxVal = (type(maxVal) == "number" and maxVal >= 0) and maxVal or 0
    current = (type(current) == "number") and current or 0
    if maxVal > 0 then
        return math.min(math.max(0, current), maxVal)
    end
    return math.max(0, current)
end

--- Sums total attribute value from attributes map.
-- @param attributes table Map of attribute names to numeric values
-- @param attrName string Attribute key to lookup
-- @return number Attribute value
function CharacterCalculator.GetAttributeValue(attributes, attrName)
    if type(attributes) ~= "table" or type(attrName) ~= "string" then
        return 0
    end
    return type(attributes[attrName]) == "number" and attributes[attrName] or 0
end

--- Sums total talent value from talents map.
-- @param talents table Map of talent names to numeric values
-- @param talentName string Talent key to lookup
-- @return number Talent value
function CharacterCalculator.GetTalentValue(talents, talentName)
    if type(talents) ~= "table" or type(talentName) ~= "string" then
        return 0
    end
    return type(talents[talentName]) == "number" and talents[talentName] or 0
end

return CharacterCalculator
