--- Race Database
--- Transpiled from specs/003-Metadata/races-type.ts
local RaceDatabase = {}

RaceDatabase.RaceList = {
    human = {
        advantages = {
            { id = "diplomacy", name = "Diplomacia", value = 2 },
            { id = "stunResistance", name = "Resistencia a Aturdimientos", value = 1 }
        },
        disadvantages = {
            { id = "lossOfControlResistance", name = "Resistencia a Pérdida de Control", value = -2 },
            { id = "resilience", name = "Resiliencia", value = -1 }
        },
        special = { "adaptability" }
    },
    dwarf = {
        advantages = {
            { id = "coldResistance", name = "Resistencia al Frío", value = 1 },
            { id = "brutality", name = "Brutalidad", value = 1 },
            { id = "robustDefense", name = "Defensa Robusta", value = 1 }
        },
        disadvantages = {
            { id = "sleightOfHand", name = "Destreza", value = -1 },
            { id = "diplomacy", name = "Diplomacia", value = -2 }
        }
    },
    kaldorei = {
        advantages = {
            { id = "stealth", name = "Sigilo", value = 1 },
            { id = "agileDefense", name = "Defensa Ágil", value = 1 },
            { id = "athletics", name = "Atlética", value = 1 }
        },
        disadvantages = {
            { id = "arcane", name = "Arcano", value = -1 },
            { id = "commerce", name = "Comercio", value = -2 }
        },
        special = { "nightVision", "superiorHearing" }
    },
    gnome = {
        advantages = {
            { id = "sleightOfHand", name = "Destreza", value = 1 },
            { id = "magicResistance", name = "Resistencia Mágica", value = 2 }
        },
        disadvantages = {
            { id = "health", name = "Salud", value = -2 },
            { id = "resilience", name = "Resiliencia", value = -1 }
        },
        special = { "perfectionism" }
    },
    draenei = {
        advantages = {
            { id = "jewelcraftingProfession", name = "Joyerería", value = 1 },
            { id = "faith", name = "Fe", value = 2 }
        },
        disadvantages = {
            { id = "elementalConnection", name = "Conexión Elemental", value = -2 },
            { id = "stealth", name = "Sigilo", value = -1 }
        }
    },
    queldorei = {
        advantages = {
            { id = "magicResistance", name = "Resistencia Mágica", value = 2 },
            { id = "arcane", name = "Arcano", value = 1 }
        },
        disadvantages = {
            { id = "brutality", name = "Brutalidad", value = -1 },
            { id = "robustDefense", name = "Defensa Robusta", value = -2 }
        },
        special = { "superiorHearing" }
    },
    orc = {
        advantages = {
            { id = "brutality", name = "Brutalidad", value = 1 },
            { id = "elementalConnection", name = "Conexión Elemental", value = 2 }
        },
        disadvantages = {
            { id = "agileDefense", name = "Defensa Ágil", value = -1 },
            { id = "stealth", name = "Sigilo", value = -2 }
        },
        special = { "superStrength" }
    },
    undead = {
        advantages = {
            { id = "lossOfControlResistance", name = "Resistencia a Pérdida de Control", value = 2 },
            { id = "alchemyProfession", name = "Alquimia", value = 1 }
        },
        disadvantages = {
            { id = "diplomacy", name = "Diplomacia", value = -2 },
            { id = "manaRegeneration", name = "Regeneración de Maná", value = -1 }
        },
        special = { "fearAndSleepImmunity", "poisonAndDiseaseImmunity", "limbReplacement" }
    },
    tauren = {
        advantages = {
            { id = "fortitude", name = "Fortaleza", value = 2 },
            { id = "nature", name = "Naturaleza", value = 1 }
        },
        disadvantages = {
            { id = "agileDefense", name = "Defensa Ágil", value = -2 },
            { id = "stealth", name = "Sigilo", value = -1 }
        },
        special = { "superStrength" }
    },
    troll = {
        advantages = {
            { id = "oneHandedCombat", name = "Combate a una Mano", value = 1 },
            { id = "manaRegeneration", name = "Regeneración de Maná", value = 1 },
            { id = "knockdownResistance", name = "Resistencia a Derribos", value = 1 }
        },
        disadvantages = {
            { id = "robustDefense", name = "Defensa Robusta", value = -1 },
            { id = "resilience", name = "Resiliencia", value = -2 }
        },
        special = { "regeneration" }
    },
    goblin = {
        advantages = {
            { id = "commerce", name = "Comercio", value = 2 },
            { id = "sleightOfHand", name = "Destreza", value = 1 }
        },
        disadvantages = {
            { id = "diplomacy", name = "Diplomacia", value = -2 },
            { id = "faith", name = "Fe", value = -1 }
        }
    },
    sindorei = {
        advantages = {
            { id = "fel", name = "Fel", value = 1 },
            { id = "magicResistance", name = "Resistencia Mágica", value = 2 }
        },
        disadvantages = {
            { id = "lossOfControlResistance", name = "Resistencia a Pérdida de Control", value = -1 },
            { id = "robustDefense", name = "Defensa Robusta", value = -2 }
        },
        special = { "superiorHearing" }
    },
    pandaren = {
        advantages = {
            { id = "chi", name = "Chi", value = 2 },
            { id = "lossOfControlResistance", name = "Resistencia a Pérdida de Control", value = 1 }
        },
        disadvantages = {
            { id = "provocation", name = "Provocación", value = -2 },
            { id = "resilience", name = "Resiliencia", value = -1 }
        }
    },
    vrykul = {
        advantages = {
            { id = "brutality", name = "Brutalidad", value = 1 },
            { id = "coldResistance", name = "Resistencia al Frío", value = 1 },
            { id = "fortitude", name = "Fortaleza", value = 1 }
        },
        disadvantages = {
            { id = "lossOfControlResistance", name = "Resistencia a Pérdida de Control", value = -2 },
            { id = "stealth", name = "Sigilo", value = -2 }
        },
        special = { "superStrength" }
    },
    blueDragon = {
        advantages = {
            { id = "fortitude", name = "Fortaleza", value = 3 },
            { id = "magicResistance", name = "Resistencia Mágica", value = 3 },
            { id = "arcane", name = "Arcano", value = 3 }
        },
        disadvantages = {
            { id = "lossOfControlResistance", name = "Resistencia a Pérdida de Control", value = -3 },
            { id = "stealth", name = "Sigilo", value = -5 }
        },
        special = { "innate:Arcane" }
    }
}

RaceDatabase.WorgenCurse = {
    human = {
        advantages = {
            { id = "athletics", name = "Atletismo", value = 1 },
            { id = "brutality", name = "Brutalidad", value = 1 },
            { id = "magicResistance", name = "Resistencia Mágica", value = 1 },
            { id = "perception", name = "Percepción", value = 1 },
            { id = "resilience", name = "Resiliencia", value = 1 }
        },
        disadvantages = {
            { id = "lossOfControlResistance", name = "Resistencia a Pérdida de Control", value = -5 },
            { id = "stealth", name = "Sigilo", value = -3 },
            { id = "sleightOfHand", name = "Destreza", value = -2 }
        },
        special = { "adaptability" }
    },
    worgen = {
        advantages = {
            { id = "athletics", name = "Atletismo", value = 2 },
            { id = "brutality", name = "Brutalidad", value = 2 },
            { id = "magicResistance", name = "Resistencia Mágica", value = 2 },
            { id = "perception", name = "Percepción", value = 2 },
            { id = "resilience", name = "Resiliencia", value = 2 }
        },
        disadvantages = {
            { id = "lossOfControlResistance", name = "Resistencia a Pérdida de Control", value = -5 },
            { id = "stealth", name = "Sigilo", value = -3 },
            { id = "sleightOfHand", name = "Destreza", value = -2 }
        },
        special = { "superStrength", "hughMovility:fourLegs" }
    }
}

_G.GAC_RaceDatabase = RaceDatabase
return RaceDatabase
