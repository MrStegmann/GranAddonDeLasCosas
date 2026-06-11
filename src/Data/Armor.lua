local addonName, GAC = ...

GAC.armor = {
    slots = {
        "head",
        "chest",
        "hands",
        "legs",
    },
    types = {
        clothes = {
            physicalReduction = 0,
            magicalReduction = 4,
            durability = 2,
            piercingDamage = -2,
            slashingDamage = -2,
            crushingDamage = -2,
            combinable = {
                clothes = {"notAllowed"},
                leather = {},
                mail = {},
                plate = {},
            },
        },
        leather = {
            physicalReduction = 2,
            magicalReduction = 1,
            durability = 4,
            piercingDamage = -2,
            slashingDamage = -1,
            crushingDamage = 0,
            combinable = {
                clothes = {},
                leather = {"notAllowed"},
                mail = {"doubleDisadvantage"},
                plate = {"doubleDisadvantage"},
            },
        },
        mail = {
            physicalReduction = 4,
            magicalReduction = 0,
            durability = 6,
            piercingDamage = -2,
            slashingDamage = 1,
            crushingDamage = -1,
            combinable = {
                clothes = {},
                leather = {"doubleDisadvantage"},
                mail = {"notAllowed"},
                plate = {"doubleDisadvantage", "doubleRequirements"},
            },
            requirements = {
                chest = {
                    brutality = 1,
                },
                legs = {
                    brutality = 1,
                }
            },
            disadvantage = {
                chest = {
                    movement = -1,
                    acrobatics = -1,
                    agileDefense = -1
                },
                hands = {
                    sleightOfHand = -1,
                },
                legs = {
                    movement = -1,
                    acrobatics = -1,
                    agileDefense = -1
                }
            }
        },
        plate = {
            physicalReduction = 6,
            magicalReduction = 0,
            durability = 8,
            piercingDamage = 1,
            slashingDamage = 2,
            crushingDamage = -2,
            combinable = {
                clothes = {},
                leather = {"doubleDisadvantage"},
                mail = {"doubleDisadvantage", "doubleRequirements"},
                plate = {"notAllowed"},
            },
            requirements = {
                head = {
                    brutality = 1,
                },
                chest = {
                    brutality = 2,
                },
                hands = {
                    brutality = 1,
                },
                legs = {
                    brutality = 2,
                }
            },
            disadvantage = {
                head = {
                    perception = -1,
                    acrobatics = -1,
                    agileDefense = -1
                },
                chest = {
                    movement = -5,
                    acrobatics = -2,
                    agileDefense = -4,
                    stealth = -4
                },
                hands = {
                    sleightOfHand = -2,
                    acrobatics = -1
                },
                legs = {
                    movement = -5,
                    acrobatics = -2,
                    agileDefense = -4,
                    stealth = -4
                }
            }
        }
    },
    reinforcements = {
        leather = {
            physicalReduction = 1,
            magicalReduction = 0,
            durability = 1,
        },
        mail = {
            physicalReduction = 2,
            magicalReduction = 0,
            durability = 2,
            disadvantage = {
                agileDefense = -1,
                
            }
        },
        plate = {
            physicalReduction = 3,
            magicalReduction = 0,
            durability = 3,
            disadvantage = {
                agileDefense = -2,
                movement = -2,
            },
            requirements = {
                brutality = 1,
            }
        }
    }
}

GAC.armor.alias = {
    head = "Cabeza",
    chest = "Pecho",
    hands = "Manos",
    legs = "Piernas",
    clothes = "Tela",
    leather = "Cuero",
    mail = "Malla",
    plate = "Placas",
    reinforcements = "Refuerzos"
}
-- Daño fisico:
-- Daño perforante, cortante, contundente
-- Vulnerable (-2): Reducción física anulada. La durabilidad de la armadura se reduce el doble por golpe.
-- Débil (-1): Reducción física tiene la mitad de eficacia.
-- Normal (0): Reducción física normal.
-- Resistente (1): Reducción física tiene el doble de eficacia.
-- Muy Resistente (2): El daño del arma es siempre 0 y no reduce la durabilidad

function GAC:ParseArmorString(armorString)
    if type(armorString) ~= "string" then return "", false, "" end
    
    -- Limpiamos códigos de color de WoW
    local cleanString = string.gsub(armorString, "|c%x%x%x%x%x%x%x%x", "")
    cleanString = string.gsub(cleanString, "|r", "")
    cleanString = string.match(cleanString, "^%s*(.-)%s*$") or cleanString
    
    -- Buscamos el patrón "Base:Refuerzos-Refuerzo" o "Base: Refuerzado con Refuerzo"
    local base, reinforcement = string.match(cleanString, "^([^:]+)%s*:%s*Refuerzos%s*%-%s*(.+)$")
    
    if not base then
        base, reinforcement = string.match(cleanString, "^([^:]+)%s*:%s*[Rr]efuerzad[oa] con%s+(.+)$")
    end
    
    if base and reinforcement then
        base = string.match(base, "^%s*(.-)%s*$") or base
        reinforcement = string.match(reinforcement, "^%s*(.-)%s*$") or reinforcement
        return base, true, reinforcement
    end
    
    -- Si no tiene refuerzos, devolvemos la base (limpia de colores y espacios), false, y un string vacío
    return cleanString, false, ""
end

function GAC:GetArmorKeyByAlias(aliasString)
    if type(aliasString) ~= "string" then return nil end
    
    local cleanString = string.gsub(aliasString, "|c%x%x%x%x%x%x%x%x", "")
    cleanString = string.gsub(cleanString, "|r", "")
    cleanString = string.match(cleanString, "^%s*(.-)%s*$") or cleanString
    local lowerClean = string.lower(cleanString)
    
    -- Corrección de typo común: Placa -> Placas
    if lowerClean == "placa" then lowerClean = "placas" end
    
    for key, value in pairs(GAC.armor.alias) do
        if string.lower(value) == lowerClean then
            return key
        end
    end
    
    return nil
end

function GAC:GetArmorTypeInfo(typeKey)
    if type(typeKey) ~= "string" then return nil end
    
    return GAC.armor.types[typeKey]
end

function GAC:GetArmorReinforcementInfo(typeKey)
    if type(typeKey) ~= "string" then return nil end
    
    return GAC.armor.reinforcements[typeKey]
end