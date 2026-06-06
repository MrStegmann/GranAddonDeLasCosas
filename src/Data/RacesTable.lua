local addonName, GAC = ...

GAC.racesTable = {
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
    pandaren = {
        talents = {
            chi = 2,
            resilience = -1,
            lossOfControlResistance = 1,
            provocation = -2
        },
        special = {
        }
    },
    vrykul = {
        talents = {
            brutality = 1,
            coldResistance = 1,
            fortitude = 1,
            stealth = -2,
            lossOfControlResistance = -1
        },
        special = {
            "superStrength",
        }
    }
}

-- Construye y devuelve un mapa de prioridad de talentos basado en el orden de attributeGroups
function GAC:GetTalentPriority()
    if self._talentPriority then return self._talentPriority end
    self._talentPriority = {}
    local priority = 1
    if self.attributeGroups then
        for _, group in ipairs(self.attributeGroups) do
            if group.talents then
                for _, talent in ipairs(group.talents) do
                    self._talentPriority[talent] = priority
                    priority = priority + 1
                end
            end
        end
    end
    return self._talentPriority
end

-- Aplica las mejoras especiales de raza (Adaptability, Perfection) a los talentos actuales del personaje
function GAC:ApplyRaceSpecialUpgrades()
    if not self.characterData or not self.characterData.talents then return end
    
    local talents = self.characterData.talents
    local priorityMap = self:GetTalentPriority()

    local function IsValidTalent(k)
        return priorityMap[k] ~= nil
    end

    -- Perfection: Mejora el talento más alto
    if talents.perfection and talents.perfection > 0 then
        local maxVal = -math.huge
        local bestTalent = nil
        
        for k, v in pairs(talents) do
            if IsValidTalent(k) then
                if v > maxVal then
                    maxVal = v
                    bestTalent = k
                elseif v == maxVal then
                    -- Desempate por prioridad (menor número = mayor prioridad)
                    if bestTalent == nil or priorityMap[k] < priorityMap[bestTalent] then
                        bestTalent = k
                    end
                end
            end
        end
        
        if bestTalent then
            talents[bestTalent] = talents[bestTalent] + 1
            print("|cFF40C7EBGAC:|r Perfección (Gnomo) aplicada: +1 a " .. tostring(bestTalent))
        end
        -- Consumir el efecto para que no se vuelva a aplicar
        talents.perfection = nil
    end

    -- Adaptability: Mejora el talento más bajo sin contar los que estén a 0
    if talents.adaptability and talents.adaptability > 0 then
        local minVal = math.huge
        local bestTalent = nil
        
        for k, v in pairs(talents) do
            if IsValidTalent(k) and v > 0 then
                if v < minVal then
                    minVal = v
                    bestTalent = k
                elseif v == minVal then
                    if bestTalent == nil or priorityMap[k] < priorityMap[bestTalent] then
                        bestTalent = k
                    end
                end
            end
        end
        
        if bestTalent then
            talents[bestTalent] = talents[bestTalent] + 1
            print("|cFF40C7EBGAC:|r Adaptabilidad (Humano) aplicada: +1 a " .. tostring(bestTalent))
        end
        -- Consumir el efecto para que no se vuelva a aplicar
        talents.adaptability = nil
    end
end
