--- @module Data.AttributesAndTalents
-- Attribute groups definitions and attribute data initialization.

local _, GAC = ...

GAC.attributeGroups = {
    {
        name = "dexterity",
        talents = {
            "precision",
            "agileCombat",
            "acrobatics",
            "stealth",
            "sleightOfHand",
            "agileDefense",
        },
    },
    {
        name = "strength",
        talents = {
            "twoHandedCombat",
            "oneHandedCombat",
            "athletics",
            "brutality",
            "sturdyDefense",
        },
    },
    {
        name = "intelligence",
        talents = {
            "arcane",
            "fel",
            "nature",
            "shadow",
            "necromancy",
        },
    },
    {
        name = "willpower",
        talents = {
            "magicResistance",
            "lossOfControlResistance",
            "faith",
            "elementalConnection",
            "chi",
            "manaRegeneration",
        },
    },
    {
        name = "constitution",
        talents = {
            "resilience",
            "stunResistance",
            "knockdownResistance",
            "coldResistance",
            "heatResistance",
            "fortitude",
        },
    },
    {
        name = "wisdom",
        talents = {
            "animalConnection",
            "survival",
            "perception",
        },
    },
    {
        name = "charisma",
        talents = {
            "persuasion",
            "diplomacy",
            "commerce",
            "provocation",
            "seduction",
            "performance",
        },
    },
}

--- Initializes default attribute and talent values within character state.
-- @return void
function GAC:InitializeAttributeSystemData()
    if not self.characterData then return end

    self.characterData.attributes = self.characterData.attributes or {}
    self.characterData.talents = self.characterData.talents or {}

    for _, group in ipairs(self.attributeGroups) do
        if self.characterData.attributes[group.name] == nil then
            self.characterData.attributes[group.name] = 0
        end

        for _, talent in ipairs(group.talents) do
            if self.characterData.talents[talent] == nil then
                self.characterData.talents[talent] = 0
            end
        end
    end
end

--- Backward compatibility alias.
-- @return void
function GAC:InitializeAttributeSystem()
    self:InitializeAttributeSystemData()
end