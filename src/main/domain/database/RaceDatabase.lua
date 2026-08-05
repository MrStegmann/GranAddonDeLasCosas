local RaceDatabase = {
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
    nightElf = {
        advantages = {
            { id = "stealth", name = "Sigilo", value = 2 },
            { id = "nature", name = "Naturaleza / Elune", value = 1 }
        },
        disadvantages = {
            { id = "fireResistance", name = "Resistencia al Fuego", value = -2 },
            { id = "resilience", name = "Resiliencia", value = -1 }
        },
        special = { "shadowmeld" }
    },
    gnome = {
        advantages = {
            { id = "engineering", name = "Ingeniería / Arcana", value = 2 },
            { id = "sleightOfHand", name = "Destreza", value = 1 }
        },
        disadvantages = {
            { id = "brutality", name = "Brutalidad", value = -2 },
            { id = "athletics", name = "Atletismo", value = -1 }
        },
        special = { "escapeArtist" }
    },
    orc = {
        advantages = {
            { id = "brutality", name = "Brutalidad", value = 2 },
            { id = "stunResistance", name = "Resistencia a Aturdimientos", value = 1 }
        },
        disadvantages = {
            { id = "diplomacy", name = "Diplomacia", value = -2 },
            { id = "lossOfControlResistance", name = "Resistencia a Pérdida de Control", value = -1 }
        },
        special = { "bloodFury" }
    },
    undead = {
        advantages = {
            { id = "shadowResistance", name = "Resistencia a las Sombras / Necromancia", value = 2 },
            { id = "lossOfControlResistance", name = "Resistencia a Pérdida de Control", value = 1 }
        },
        disadvantages = {
            { id = "holyLightResistance", name = "Resistencia a la Luz Sagrada", value = -2 },
            { id = "resilience", name = "Resiliencia", value = -1 }
        },
        special = { "willOfTheForsaken" }
    },
    tauren = {
        advantages = {
            { id = "health", name = "Salud Máxima", value = 2 },
            { id = "nature", name = "Naturaleza / C. Elemental", value = 1 }
        },
        disadvantages = {
            { id = "sleightOfHand", name = "Destreza", value = -2 },
            { id = "agileDefense", name = "Defensa Ágil", value = -1 }
        },
        special = { "warStomp" }
    },
    troll = {
        advantages = {
            { id = "regeneration", name = "Regeneración", value = 2 },
            { id = "precision", name = "Precisión", value = 1 }
        },
        disadvantages = {
            { id = "robustDefense", name = "Defensa Robusta", value = -2 },
            { id = "diplomacy", name = "Diplomacia", value = -1 }
        },
        special = { "berserking" }
    },
    bloodElf = {
        advantages = {
            { id = "arcane", name = "Magia Arcana / Fel", value = 2 },
            { id = "magicResistance", name = "Resistencia Mágica", value = 1 }
        },
        disadvantages = {
            { id = "resilience", name = "Resiliencia", value = -2 },
            { id = "brutality", name = "Brutalidad", value = -1 }
        },
        special = { "arcaneTorrent" }
    },
    goblin = {
        advantages = {
            { id = "sleightOfHand", name = "Destreza", value = 2 },
            { id = "alchemy", name = "Alquimia / Ingeniería", value = 1 }
        },
        disadvantages = {
            { id = "diplomacy", name = "Diplomacia", value = -2 },
            { id = "resilience", name = "Resiliencia", value = -1 }
        },
        special = { "rocketJump" }
    },
    draenei = {
        advantages = {
            { id = "holyLight", name = "Luz Sagrada", value = 2 },
            { id = "shadowResistance", name = "Resistencia a las Sombras", value = 1 }
        },
        disadvantages = {
            { id = "felResistance", name = "Resistencia a la Magia Fel", value = -2 },
            { id = "stealth", name = "Sigilo", value = -1 }
        },
        special = { "giftOfTheNaaru" }
    },
    worgen = {
        advantages = {
            { id = "precision", name = "Precisión", value = 2 },
            { id = "shadowResistance", name = "Resistencia a las Sombras", value = 1 }
        },
        disadvantages = {
            { id = "lossOfControlResistance", name = "Resistencia a Pérdida de Control", value = -2 },
            { id = "diplomacy", name = "Diplomacia", value = -1 }
        },
        special = { "darkflight" }
    },
    pandaren = {
        advantages = {
            { id = "chi", name = "Chi / Filosofía", value = 2 },
            { id = "resilience", name = "Resiliencia", value = 1 }
        },
        disadvantages = {
            { id = "movement", name = "Movimiento", value = -1 },
            { id = "sleightOfHand", name = "Destreza", value = -1 }
        },
        special = { "quakingPalm" }
    }
}

return RaceDatabase
