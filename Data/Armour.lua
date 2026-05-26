local _, addon = ...

addon.armourData = {
    armors = {
        cloth = {
            physicalReduction = 0,
            magicReduction = 4,
            durability = 2,
            piercing = "Vulnerable",
            slashing = "Vulnerable",
            bludgeoning = "Vulnerable",
        },
        leather = {
            physicalReduction = 2,
            magicReduction = 1,
            durability = 4,
            piercing = "Vulnerable",
            slashing = "Débil",
            bludgeoning = "Normal",
        },
        mail = {
            physicalReduction = 4,
            magicReduction = 0,
            durability = 3,
            piercing = "Vulnerable",
            slashing = "Resistente",
            bludgeoning = "Débil",
        },
        plate = {
            physicalReduction = 6,
            magicReduction = 0,
            durability = 5,
            piercing = "Resistente",
            slashing = "Muy Resistente",
            bludgeoning = "Vulnerable",
        },
    },
    pieces = {
        head = {
            plate = {
                requirements = {
                    { brutality = 1 },
                },
                penalties = {
                    { perception = -1 },
                    { acrobatics = -1 },
                    { agileDefense = -1 },
                },
            },
        },
        chest = {
            mail = {
                requirements = {
                    { brutality = 1 },
                },
                penalties = {
                    { movement = -1 },
                    { acrobatics = -1 },
                    { agileDefense = -1 },
                },
            },
            plate = {
                requirements = {
                    { brutality = 2 },
                },
                penalties = {
                    { movement = -5 },
                    { acrobatics = -2 },
                    { agileDefense = -2 },
                    { stealth = -4 },
                },
            },
        },
        hands = {
            mail = {
                penalties = {
                    { sleightOfHand = -1 },
                },
            },
            plate = {
                requirements = {
                    { brutality = 1 },
                },
                penalties = {
                    { sleightOfHand = -2 },
                    { acrobatics = -1 },
                },
            },
        },
        legs = {
            mail = {
                requirements = {
                    { brutality = 1 },
                },
                penalties = {
                    { movement = -1 },
                    { acrobatics = -1 },
                    { agileDefense = -1 },
                },
            },
            plate = {
                requirements = {
                    { brutality = 2 },
                },
                penalties = {
                    { movement = -5 },
                    { acrobatics = -2 },
                    { agileDefense = -2 },
                    { stealth = -4 },
                },
            },
        },
    },
    reinforcements = {
        leather = {
            physicalReduction = 1,
            magicReduction = 0,
            durability = 1,
        },
        mail = {
            physicalReduction = 2,
            magicReduction = 0,
            durability = 2,
            penalties = {
                { agileDefense = -1 },
            },
        },
        plate = {
            physicalReduction = 3,
            magicReduction = 0,
            durability = 3,
            requirements = {
                { brutality = 1 },
            },
            penalties = {
                { movement = -1 },
                { agileDefense = -2 },
            },
        },
    },
}
