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

function GAC:InitializeAttributeSystem()
    GranAddonDeLasCosasDB = GranAddonDeLasCosasDB or {}
    GranAddonDeLasCosasDB.debug = GranAddonDeLasCosasDB.debug ~= false

    GranAddonDeLasCosasCharDB = GranAddonDeLasCosasCharDB or {}
    GranAddonDeLasCosasCharDB.attributes = GranAddonDeLasCosasCharDB.attributes or {}
    GranAddonDeLasCosasCharDB.talents = GranAddonDeLasCosasCharDB.talents or {}

    GAC.characterData = GranAddonDeLasCosasCharDB

    local hasMigratedData = next(GranAddonDeLasCosasCharDB.attributes) ~= nil or next(GranAddonDeLasCosasCharDB.talents) ~= nil
    if not hasMigratedData and GranAddonDeLasCosasDB.attributes and GranAddonDeLasCosasDB.talents then
        for key, value in pairs(GranAddonDeLasCosasDB.attributes) do
            GranAddonDeLasCosasCharDB.attributes[GAC:NormalizeAttributeNameThroughtVersions(key)] = value
        end

        for key, value in pairs(GranAddonDeLasCosasDB.talents) do
            GranAddonDeLasCosasCharDB.talents[GAC:NormalizeTalentNameThroughtVersions(key)] = value
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
    print("[GAC]: Atributos y talentos cargados correctamente.")
end