local addonName, GAC = ...

function GAC:NormalizeAttributeNameThroughtVersions(attributeName)
    local normalizationMap = {
        ["Destreza"] = "dexterity",
        ["Fuerza"] = "strength",
        ["Inteligencia"] = "intelligence",
        ["Voluntad"] = "willpower",
        ["Constitución"] = "constitution",
        ["Sabiduría"] = "wisdom",
        ["Carisma"] = "charisma",
    }
    return normalizationMap[attributeName] or attributeName
end

function GAC:NormalizeTalentNameThroughtVersions(talentName)
    local normalizationMap = {
        ["Precisión"] = "precision",
        ["Combate Ágil"] = "agileCombat",
        ["Acrobacias"] = "acrobatics",
        ["Sigilo"] = "stealth",
        ["Juego de Manos"] = "sleightOfHand",
        ["Defensa Ágil"] = "agileDefense",

        ["Combate a 2 manos"] = "twoHandedCombat",
        ["Combate a 1 mano"] = "oneHandedCombat",
        ["Atletismo"] = "athletics",
        ["Brutalidad"] = "brutality",
        ["Defensa Robusta"] = "sturdyDefense",
        
        ["Arcano"] = "arcane",
        ["Vil"] = "fel",
        ["Naturaleza"] = "nature",
        ["Sombras"] = "shadow",
        ["Nigromancia"] = "necromancy",
        
        ["Resistencia Mágica"] = "magicResistance",
        ["Resistencia a la Pérdida de Control"] = "lossOfControlResistance",
        ["Fe"] = "faith",
        ["Conexión Elemental"] = "elementalConnection",
        ["Chi"] = "chi",
        ["Regeneración de Maná"] = "manaRegeneration",

        ["Resiliencia"] = "resilience",
        ["Resistencia a Aturdimientos"] = "stunResistance",
        ["Resistencia a Derribos"] = "knockdownResistance",
        ["Resistencia al Frío"] = "coldResistance",
        ["Resistencia al Calor"] = "heatResistance",
        ["Fortaleza"] = "fortitude",

        ["Conexión con los animales"] = "animalConnection",
        ["Supervivencia"] = "survival",
        ["Percepción"] = "perception",

        ["Persuasión"] = "persuasion",
        ["Diplomacia"] = "diplomacy",
        ["Comercio"] = "commerce",
        ["Provocación"] = "provocation",
        ["Seducción"] = "seduction",
        ["Interpretación"] = "performance",
    }
    return normalizationMap[talentName] or talentName
end