local addonName, GAC = ...

local races = {
    human = {
        talents = {
            adaptability = 1, -- Mejora el talento más bajo sin contar los talentos que estén a 0. Este efecto solo se aplica una vez y se elige un talento según su prioridad de importancia. Una vez asignado y guardados los talentos, se aplica esta mejora. Primero se aplica esta mejora luego el resto.
            diplomacy = 1,
            lossOfControlResistance = -2,
            knockdownResistance = 1,
            resilience = -1
        }
    },
    dwarf = {
        talents = {
            coldResistance = 1,
            brutality = 1,
            robustDefense = 1,
            sleightOfHand = -1,
            diplomacy = -2
        }
    },
    gnome = {   
        talents = {
            perfection = 1, -- Mejora el talento más alto. Este efecto solo se aplica una vez y se elige un talento según su prioridad de importancia. Una vez asignado y guardados los talentos, se aplica esta mejora. Primero se aplica esta mejora luego el resto.
            magicResistance = 1,
            sleightOfHand = 1,
            vitality = -2,
            resilience = -1
        }
    },
    kaldorei = {
        talents = {
            stealth = 1,
            agileDefense = 1,
            arcane = -1,
            commerce = -2
        },
        others = {
            movementDistance = 5,
        },
        special = {

        }
    },
    draenei = {
        talents = {
            faith = 2,
            elementalResistance = -2,
            stealth = -1
        },
        special = {}
    },
    quelDorei = {
        talents = {
            magicResistance = 2,
            arcane = 1,
            brutality = -1,
            robustDefense = -2
        },
        special = {

        }
     },
    forsaken = {
        talents = {
            lossOfControlResistance = 2,
            shadow = 1,
            manaRegeneration = -1,
            diplomacy = -2
        },
        special = {
            "superResilience",
            "memberReplacement"
        }
        
    },
    orcs = {
        talents = {
            brutality = 1,
            elementalConnection = 1,
            stealth = -2,
            agileDefense = -1
        },
        special = {
            "superStrength"
        }
    },
    tauren = {
        talents = {
            fortitude = 2,
            nature = 1,
            agileDefense = -2,
            stealth = -1
        },
        special = {
            "superStrength"
        }
    },
    goblins = {
        talents = {
            commerce = 2,
            sleightOfHand = 1,
            diplomacy = -2,
            faith = -1
        },
        special = {

        }
    },
    sindorei = {
        talents = {
            magicResistance = 2,
            fel = 1,
            lossOfControlResistance = -1,
            robustDefense = -2
        },
        special = {
            "superHearing"
        }
    },
}