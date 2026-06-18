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
    
    GAC.characterData.progress = GAC.characterData.progress or { category = "normal", level = 1 }
    if type(GAC.characterData.progress.level) ~= "number" or GAC.characterData.progress.level < 1 then
        GAC.characterData.progress.level = 1
    end

    local hasMigratedData = next(GranAddonDeLasCosasCharDB.attributes) ~= nil or next(GranAddonDeLasCosasCharDB.talents) ~= nil
    if not hasMigratedData and GranAddonDeLasCosasDB.attributes and GranAddonDeLasCosasDB.talents then
        for key, value in pairs(GranAddonDeLasCosasDB.attributes) do
            GranAddonDeLasCosasCharDB.attributes[GAC:NormalizeAttributeNameThroughtVersions(key)] = value
        end

        for key, value in pairs(GranAddonDeLasCosasDB.talents) do
            GranAddonDeLasCosasCharDB.talents[GAC:NormalizeTalentNameThroughtVersions(key)] = value
        end
    end

    -- In-place cleanup of old localized names in character DB
    local oldAttrKeys = {}
    for key, value in pairs(GranAddonDeLasCosasCharDB.attributes) do
        local normalizedKey = GAC:NormalizeAttributeNameThroughtVersions(key)
        if normalizedKey ~= key then
            oldAttrKeys[key] = normalizedKey
        end
    end
    for oldKey, newKey in pairs(oldAttrKeys) do
        -- Solo sobrescribimos si no existe un valor nuevo pre-existente o combinamos (aquí nos quedamos con el antiguo si migra por primera vez)
        GranAddonDeLasCosasCharDB.attributes[newKey] = GranAddonDeLasCosasCharDB.attributes[newKey] or GranAddonDeLasCosasCharDB.attributes[oldKey]
        GranAddonDeLasCosasCharDB.attributes[oldKey] = nil
    end

    local oldTalentKeys = {}
    for key, value in pairs(GranAddonDeLasCosasCharDB.talents) do
        local normalizedKey = GAC:NormalizeTalentNameThroughtVersions(key)
        if normalizedKey ~= key then
            oldTalentKeys[key] = normalizedKey
        end
    end
    for oldKey, newKey in pairs(oldTalentKeys) do
        GranAddonDeLasCosasCharDB.talents[newKey] = GranAddonDeLasCosasCharDB.talents[newKey] or GranAddonDeLasCosasCharDB.talents[oldKey]
        GranAddonDeLasCosasCharDB.talents[oldKey] = nil
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
