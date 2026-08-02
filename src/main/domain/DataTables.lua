--- @module domain.DataTables
-- Encapsulated pure Lua roleplay data tables and configuration lookups.
-- Isolated from global scope mutations and external dependencies.

local DataTables = {}

DataTables.levelCategories = {
    "noob",
    "normal",
    "elite",
    "boss",
}

DataTables.levelsTable = {
    ["noob"] = {
        [1] = { maxHealth = 10, expToLevel = 10, attPoints = 0, skillPoints = 2, heroicPoints = 1, maxPositiveTraits = 0 },
        [2] = { maxHealth = 11, expToLevel = 12, attPoints = 1, skillPoints = 3, heroicPoints = 1, maxPositiveTraits = 0 },
        [3] = { maxHealth = 13, expToLevel = 14, attPoints = 3, skillPoints = 4, heroicPoints = 1, maxPositiveTraits = 0 },
        [4] = { maxHealth = 16, expToLevel = 16, attPoints = 3, skillPoints = 5, heroicPoints = 1, maxPositiveTraits = 0 },
        [5] = { maxHealth = 20, expToLevel = 20, attPoints = 5, skillPoints = 5, heroicPoints = 1, maxPositiveTraits = 0 },
    },
    ["normal"] = {
        [1] = { maxHealth = 20, expToLevel = 30, attPoints = 5, skillPoints = 5, heroicPoints = 2, maxPositiveTraits = 2 },
        [2] = { maxHealth = 27, expToLevel = 45, attPoints = 5, skillPoints = 6, heroicPoints = 2, maxPositiveTraits = 2 },
        [3] = { maxHealth = 34, expToLevel = 68, attPoints = 6, skillPoints = 6, heroicPoints = 2, maxPositiveTraits = 2 },
        [4] = { maxHealth = 41, expToLevel = 102, attPoints = 7, skillPoints = 7, heroicPoints = 2, maxPositiveTraits = 2 },
        [5] = { maxHealth = 49, expToLevel = 153, attPoints = 7, skillPoints = 7, heroicPoints = 3, maxPositiveTraits = 2 },
        [6] = { maxHealth = 57, expToLevel = 230, attPoints = 8, skillPoints = 8, heroicPoints = 3, maxPositiveTraits = 2 },
        [7] = { maxHealth = 65, expToLevel = 345, attPoints = 9, skillPoints = 8, heroicPoints = 3, maxPositiveTraits = 2 },
        [8] = { maxHealth = 74, expToLevel = 518, attPoints = 9, skillPoints = 9, heroicPoints = 3, maxPositiveTraits = 2 },
        [9] = { maxHealth = 83, expToLevel = 777, attPoints = 10, skillPoints = 9, heroicPoints = 3, maxPositiveTraits = 2 },
        [10] = { maxHealth = 92, expToLevel = 1166, attPoints = 10, skillPoints = 10, heroicPoints = 4, maxPositiveTraits = 3 },
    },
    ["elite"] = {
        [1] = { maxHealth = 40, expToLevel = 1749, attPoints = 10, skillPoints = 10, heroicPoints = 4, maxPositiveTraits = 3 },
        [2] = { maxHealth = 54, expToLevel = 2624, attPoints = 11, skillPoints = 11, heroicPoints = 4, maxPositiveTraits = 3 },
        [3] = { maxHealth = 68, expToLevel = 3936, attPoints = 12, skillPoints = 11, heroicPoints = 4, maxPositiveTraits = 3 },
        [4] = { maxHealth = 82, expToLevel = 5904, attPoints = 13, skillPoints = 12, heroicPoints = 4, maxPositiveTraits = 3 },
        [5] = { maxHealth = 98, expToLevel = 6495, attPoints = 13, skillPoints = 12, heroicPoints = 5, maxPositiveTraits = 3 },
        [6] = { maxHealth = 114, expToLevel = 7145, attPoints = 14, skillPoints = 13, heroicPoints = 5, maxPositiveTraits = 3 },
        [7] = { maxHealth = 130, expToLevel = 7858, attPoints = 14, skillPoints = 13, heroicPoints = 5, maxPositiveTraits = 3 },
        [8] = { maxHealth = 148, expToLevel = 8646, attPoints = 14, skillPoints = 14, heroicPoints = 5, maxPositiveTraits = 3 },
        [9] = { maxHealth = 166, expToLevel = 9511, attPoints = 15, skillPoints = 14, heroicPoints = 5, maxPositiveTraits = 3 },
        [10] = { maxHealth = 184, expToLevel = 10462, attPoints = 15, skillPoints = 15, heroicPoints = 6, maxPositiveTraits = 4 },
    },
    ["boss"] = {
        [1] = { maxHealth = 80, expToLevel = 11508, attPoints = 15, skillPoints = 15, heroicPoints = 6, maxPositiveTraits = 4 },
        [2] = { maxHealth = 108, expToLevel = 12659, attPoints = 16, skillPoints = 16, heroicPoints = 6, maxPositiveTraits = 4 },
        [3] = { maxHealth = 136, expToLevel = 13925, attPoints = 17, skillPoints = 16, heroicPoints = 6, maxPositiveTraits = 4 },
        [4] = { maxHealth = 164, expToLevel = 15318, attPoints = 18, skillPoints = 17, heroicPoints = 6, maxPositiveTraits = 4 },
        [5] = { maxHealth = 196, expToLevel = 16850, attPoints = 18, skillPoints = 17, heroicPoints = 7, maxPositiveTraits = 4 },
        [6] = { maxHealth = 228, expToLevel = 18535, attPoints = 19, skillPoints = 18, heroicPoints = 7, maxPositiveTraits = 4 },
        [7] = { maxHealth = 260, expToLevel = 20389, attPoints = 19, skillPoints = 18, heroicPoints = 7, maxPositiveTraits = 4 },
        [8] = { maxHealth = 296, expToLevel = 22428, attPoints = 19, skillPoints = 19, heroicPoints = 7, maxPositiveTraits = 4 },
        [9] = { maxHealth = 332, expToLevel = 24670, attPoints = 20, skillPoints = 19, heroicPoints = 7, maxPositiveTraits = 4 },
        [10] = { maxHealth = 370, expToLevel = 27137, attPoints = 20, skillPoints = 20, heroicPoints = 8, maxPositiveTraits = 5 },
    }
}

DataTables.attributeGroups = {
    { name = "dexterity", talents = { "precision", "agileCombat", "acrobatics", "stealth", "sleightOfHand", "agileDefense" } },
    { name = "strength", talents = { "twoHandedCombat", "oneHandedCombat", "athletics", "brutality", "sturdyDefense" } },
    { name = "intelligence", talents = { "arcane", "fel", "nature", "shadow", "necromancy" } },
    { name = "willpower", talents = { "magicResistance", "lossOfControlResistance", "faith", "elementalConnection", "chi", "manaRegeneration" } },
    { name = "constitution", talents = { "resilience", "stunResistance", "knockdownResistance", "coldResistance", "heatResistance", "fortitude" } },
    { name = "wisdom", talents = { "animalConnection", "survival", "perception" } },
    { name = "charisma", talents = { "persuasion", "diplomacy", "commerce", "provocation", "seduction", "performance" } },
}

--- Lookup level data entry by category and level.
-- @param category string
-- @param level number
-- @return table|nil Level data object
function DataTables.GetLevelEntry(category, level)
    category = string.lower(type(category) == "string" and category or "normal")
    level = type(level) == "number" and math.max(1, math.floor(level)) or 1
    local catData = DataTables.levelsTable[category] or DataTables.levelsTable["normal"]
    return catData[level] or catData[1]
end

return DataTables
