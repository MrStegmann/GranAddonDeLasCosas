local addonName, GAC = ...

GAC.shields = {
    light = {
        durability = 10,
        physicalReduction = 1,
        talent = "brutality",
        damage = 4,
        diceNumber = 1,
        damageType = "crushing"
    },
    medium = {
        durability = 15,
        physicalReduction = 2,
        talent = "brutality",
        damage = 6,
        diceNumber = 1,
        damageType = "crushing",
        requirements = {
            brutality = 1
        },
        penalties = {
            agileDefense = -1,
            acrobatics = -1
        }
    },
    heavy = {
        durability = 20,
        physicalReduction = 3,
        talent = "brutality",
        damage = 8,
        diceNumber = 1,
        damageType = "slashing",
        requirements = {
            brutality = 2
        },
        penalties = {
            agileDefense = -4,
            acrobatics = -4,
            movement = -2
        }
    }
}

GAC.shields.alias = {
    light = "Ligero",
    medium = "Medio",
    heavy = "Pesado"
}

function GAC:GetShieldKeyByAlias(aliasString)
    if type(aliasString) ~= "string" then return nil end
    local cleanString = string.gsub(aliasString, "|c%x%x%x%x%x%x%x%x", "")
    cleanString = string.gsub(cleanString, "|r", "")
    local lowerClean = string.lower(cleanString)
    for key, value in pairs(GAC.shields.alias) do
        if string.find(lowerClean, string.lower(value), 1, true) then
            return key
        end
    end
    
    return nil
end

function GAC:GetShieldInfo(shieldKey)
    if type(shieldKey) ~= "string" then return nil end
    
    return GAC.shields[shieldKey] or nil
end