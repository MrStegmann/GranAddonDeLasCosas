local addonName, GAC = ...

GAC.weapons = {
    dagger = {
        talent = {"agileCombat"},
        damage = 4,
        diceNumber = 1,
        damageType = "piercing",
        throwable = {
            talent = "precision",
            damage = 4,
            diceNumber = 1,
            damageType = "piercing",
        },

    },
    whip = {
        talent = {"agileCombat"},
        damage = 4,
        diceNumber = 1,
        damageType = "slashing",
    },
    handAxe = {
        talent = {"agileCombat", "oneHandedCombat"},
        damage = 6,
        diceNumber = 1,
        damageType = "slashing",
        throwable = {
            talent = "precision",
            damage = 6,
            diceNumber = 1,
            damageType = "slashing",
        },
    },
    staff = {
        talent = {"agileCombat"},
        damage = 6,
        diceNumber = 1,
        damageType = "crushing",
    },
    sickle = {
        talent = {"agileCombat"},
        damage = 4,
        diceNumber = 1,
        damageType = "slashing",
    },
    spear = {
        talent = {"agileCombat"},
        damage = 6,
        diceNumber = 1,
        damageType = "piercing",
        throwable = {
            talent = "precision",
            damage = 6,
            diceNumber = 1,
            damageType = "piercing",
        },
        twoHanded = {
            talent = {"twoHandedCombat"},
            damage = 8,
            diceNumber = 1,
            damageType = "piercing",
        },
    },
    rapier = {
        talent = {"agileCombat"},
        damage = 8,
        diceNumber = 1,
        damageType = "piercing",
        throwable = {
            talent = "precision",
            damage = 4,
            diceNumber = 1,
            damageType = "piercing",
        },

    },
    scimitar = {
        talent = {"agileCombat"},
        damage = 6,
        diceNumber = 1,
        damageType = "piercing",
    },
    shortSword = {
        talent = {"agileCombat", "oneHandedCombat"},
        damage = 6,
        diceNumber = 1,
        damageType = "slashing",
    },
    javelin = {
        talent = {"precision"},
        damage = 6,
        diceNumber = 1,
        damageType = "piercing",
    },
    lightCrossbow = {
        talent = {"precision"},
        damage = 8,
        diceNumber = 1,
        damageType = "piercing",
    },
    shortBow = {
        talent = {"precision"},
        damage = 6,
        diceNumber = 1,
        damageType = "piercing",
    },
    handCrossbow = {
        talent = {"precision"},
        damage = 6,
        diceNumber = 1,
        damageType = "piercing",
    },
    longBow = {
        talent = {"precision"},
        damage = 8,
        diceNumber = 1,
        damageType = "piercing",
    },
    heavyCrossbow = {
        talent = {"precision"},
        damage = 10,
        diceNumber = 1,
        damageType = "piercing",
    },
    pistol = {
        talent = {"precision"},
        damage = 6,
        diceNumber = 1,
        damageType = "piercing",
    },
    rifle = {
        talent = {"precision"},
        damage = 8,
        diceNumber = 1,
        damageType = "piercing",
    },
    shotgun = {
        talent = {"precision"},
        damage = 12,
        diceNumber= 1,
        damageType = "piercing",
    },
    rocketLauncher = {
        talent = {"precision"},
        damage = 8,
        diceNumber = 2,
        damageType = "crushing",
    },
    club = {
        talent = {"oneHandedCombat"},
        damage = 8,
        diceNumber = 1,
        damageType = "crushing",
    },
    lightMace = {
        talent = {"oneHandedCombat"},
        damage = 4,
        diceNumber = 1,
        damageType = "crushing",
    },
    mace = {
        talent = {"oneHandedCombat"},
        damage = 6,
        diceNumber = 1,
        damageType = "crushing",
    },
    warAxe = {
        talent = {"oneHandedCombat"},
        damage = 8,
        diceNumber = 1,
        damageType = "slashing",
        twoHanded = {
            talent = {"twoHandedCombat"},
            damage = 10,
            diceNumber = 1,
            damageType = "slashing",
        },
    },
    mayal = {
       talent = {"oneHandedCombat"},
        damage = 8,
        diceNumber = 1,
        damageType = "crushing", 
    },
    longSword = {
        talent = {"oneHandedCombat"},
        damage = 8,
        diceNumber = 1,
        damageType = "slashing",
        twoHanded = {
            talent = {"twoHandedCombat"},
            damage = 10,
            diceNumber = 1,
            damageType = "slashing",
        },
    },
    morningStar = {
        talent = {"oneHandedCombat"},
        damage = 8,
        diceNumber = 1,
        damageType = "crushing", 
    },
    trident = {
        talent = {"oneHandedCombat"},
        damage = 6,
        diceNumber = 1,
        damageType = "piercing",
        twoHanded = {
            talent = {"twoHandedCombat"},
            damage = 8,
            diceNumber = 1,
            damageType = "piercing",
        },
    },
    warHammer = {
        talent = {"oneHandedCombat"},
        damage = 8,
        diceNumber = 1,
        damageType = "crushing",
        twoHanded = {
            talent = {"twoHandedCombat"},
            damage = 10,
            diceNumber = 1,
            damageType = "crushing",
        },
    },
    warPick = {
        talent = {"oneHandedCombat"},
        damage = 8,
        diceNumber = 1,
        damageType = "piercing",
    },
    greatClub = {
        talent = {"twoHandedCombat"},
        damage = 12,
        diceNumber = 1,
        damageType = "crushing",
    },
    glaive = {
        talent = {"twoHandedCombat"},
        damage = 10,
        diceNumber = 1,
        damageType = "slashing",
    },
    heavyAxe = {
        talent = {"twoHandedCombat"},
        damage = 12,
        diceNumber = 1,
        damageType = "slashing",
    },
    greatSword = {
        talent = {"twoHandedCombat"},
        damage = 12,
        diceNumber = 1,
        damageType = "slashing",
    },
    halberd = {
        talent = {"twoHandedCombat"},
        damage = 10,
        diceNumber = 1,
        damageType = "slashing",
    },
    greatMace = {
        talent = {"twoHandedCombat"},
        damage = 12,
        diceNumber = 1,
        damageType = "crushing",
    },
    pike = {
        talent = {"twoHandedCombat"},
        damage = 10,
        diceNumber = 1,
        damageType = "piercing",
    },
}

GAC.weapons.alias = {
    dagger = "Daga",
    whip = "Látigo",
    handAxe = "Hacha de mano",
    staff = "Bastón",
    sickle = "Hoz",
    spear = "Lanza",
    rapier = "Estoque",
    scimitar = "Cimitarra",
    shortSword = "Espada corta",
    javelin = "Jabalina",
    lightCrossbow = "Ballesta ligera",
    shortBow = "Arco corto",
    handCrossbow = "Ballesta de mano",
    longBow = "Arco largo",
    heavyCrossbow = "Ballesta pesada",
    pistol = "Pistola",
    rifle = "Rifle",
    shotgun = "Escopeta",
    rocketLauncher = "Lanzacohetes",
    club = "Mazo",
    lightMace = "Maza ligera",
    mace = "Maza",
    warAxe = "Hacha de guerra",
    mayal = "Mangual",
    longSword = "Espada larga",
    morningStar = "Estrella de la mañana",
    trident = "Tridente",
    warHammer = "Martillo de guerra",
    warPick = "Pica de guerra",
    greatClub = "Gran mazo",
    glaive = "Guja",
    heavyAxe = "Hacha pesada",
    greatSword = "Espadón",
    halberd = "Alabarda",
    greatMace = "Gran maza",
    pike = "Pica",
}


function GAC:GetWeaponKeyByAlias(aliasString)
    if type(aliasString) ~= "string" then return nil end
    
    local cleanString = string.gsub(aliasString, "|c%x%x%x%x%x%x%x%x", "")
    cleanString = string.gsub(cleanString, "|r", "")
    cleanString = string.match(cleanString, "^%s*(.-)%s*$") or cleanString
    local lowerClean = string.lower(cleanString)
    
    for key, value in pairs(GAC.weapons.alias) do
        if string.lower(value) == lowerClean then
            return key
        end
    end
    return nil
end

function GAC:GetWeaponInfo(weaponKey)
    if type(weaponKey) ~= "string" then return nil end
    return GAC.weapons[weaponKey]
end