--- Attributes and Talents Database
--- Transpiled from specs/003-Metadata/attributes-talents-types.ts
local AttributesTalentsDatabase = {}

AttributesTalentsDatabase.Attributes = {
    "strength",
    "dexterity",
    "intelligence",
    "willpower",
    "constitution",
    "wisdom",
    "charisma",
}

AttributesTalentsDatabase.AttributeGroups = {
    {
        name = "strength",
        talents = { "twoHandedCombat", "oneHandedCombat", "athletics", "brutality", "robustDefense" },
    },
    {
        name = "dexterity",
        talents = { "precision", "agileCombat", "acrobatics", "stealth", "sleightOfHand", "agileDefense" },
    },
    {
        name = "intelligence",
        talents = { "arcane", "fel", "nature", "shadow", "necromancy" },
    },
    {
        name = "willpower",
        talents = { "magicResistance", "lossOfControlResistance", "faith", "elementalConnection", "chi", "manaRegeneration" },
    },
    {
        name = "constitution",
        talents = { "resilience", "stunResistance", "knockdownResistance", "coldResistance", "heatResistance", "fortitude" },
    },
    {
        name = "wisdom",
        talents = { "animalConnection", "survival", "perception" },
    },
    {
        name = "charisma",
        talents = { "persuasion", "diplomacy", "commerce", "provocation", "seduction", "performance" },
    },
}

-- Map of talent to parent attribute name for fast lookup
AttributesTalentsDatabase.TalentToAttributeMap = {}
for _, group in ipairs(AttributesTalentsDatabase.AttributeGroups) do
    for _, talent in ipairs(group.talents) do
        AttributesTalentsDatabase.TalentToAttributeMap[talent] = group.name
    end
end

_G.GAC_AttributesTalentsDatabase = AttributesTalentsDatabase
return AttributesTalentsDatabase
