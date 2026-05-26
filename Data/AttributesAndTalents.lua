local _, addon = ...

addon.attributeGroups = {
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
            "robustDefense",
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
            "controlLossResistance",
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
            "animalHandling",
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

function addon:InitializeAttributeSystem()
    GranAddonDeLasCosasDB = GranAddonDeLasCosasDB or {}
    GranAddonDeLasCosasDB.debug = GranAddonDeLasCosasDB.debug ~= false

    GranAddonDeLasCosasCharDB = GranAddonDeLasCosasCharDB or {}
    GranAddonDeLasCosasCharDB.attributes = GranAddonDeLasCosasCharDB.attributes or {}
    GranAddonDeLasCosasCharDB.talents = GranAddonDeLasCosasCharDB.talents or {}
    GranAddonDeLasCosasCharDB.ui = GranAddonDeLasCosasCharDB.ui or {}
    if GranAddonDeLasCosasCharDB.ui.minimapAngle == nil then
        GranAddonDeLasCosasCharDB.ui.minimapAngle = 220
    end
    GranAddonDeLasCosasCharDB.ui.quickFrame = GranAddonDeLasCosasCharDB.ui.quickFrame or {
        anchor = "CENTER",
        relativeAnchor = "CENTER",
        x = -260,
        y = -120,
    }
    GranAddonDeLasCosasCharDB.turnOrder = GranAddonDeLasCosasCharDB.turnOrder or {
        byGroup = {},
        sequence = 0,
    }
    GranAddonDeLasCosasCharDB.progress = GranAddonDeLasCosasCharDB.progress or {
        category = "Normal",
        level = 1,
        currentExperience = 0,
    }
    GranAddonDeLasCosasCharDB.healthConfig = GranAddonDeLasCosasCharDB.healthConfig or {
        maxHealthModifier = 0,
        lifeDelta = 0,
        shield = 0,
    }

    addon.characterData = GranAddonDeLasCosasCharDB

    local hasMigratedData = next(GranAddonDeLasCosasCharDB.attributes) ~= nil or next(GranAddonDeLasCosasCharDB.talents) ~= nil
    if not hasMigratedData and GranAddonDeLasCosasDB.attributes and GranAddonDeLasCosasDB.talents then
        for key, value in pairs(GranAddonDeLasCosasDB.attributes) do
            GranAddonDeLasCosasCharDB.attributes[key] = value
        end

        for key, value in pairs(GranAddonDeLasCosasDB.talents) do
            GranAddonDeLasCosasCharDB.talents[key] = value
        end
    end

    for _, group in ipairs(self.attributeGroups) do
        if GranAddonDeLasCosasCharDB.attributes[group.name] == nil then
            GranAddonDeLasCosasCharDB.attributes[group.name] = 0
        end

        for _, talent in ipairs(group.talents) do
            if GranAddonDeLasCosasCharDB.talents[talent] == nil then
                GranAddonDeLasCosasCharDB.talents[talent] = 0
            end
        end
    end

    if self.NormalizeExperienceProgressData then
        self:NormalizeExperienceProgressData()
    end
end
