local _, GAC = ...

GAC.Races = {
    alliance = {
        human = {
            advantages = {
                adaptability = 1, -- Mejora el talento más bajo que tengas antes de aplicar el resto de ventajas y desventajas. No se tienen en cuenta valores 0.
                diplomacy = 1,
                stunResistance = 1
            },
            disadvantages = {
                lossOfControlResistance = -2,
                resilience = -1
            }
        },
        dwarf = {
            advantages = {
                coldResistance = 1,
                brutality = 1,
                sturdyDefense = 1
            },
            disadvantages = {
                sleightOfHand = -1,
                diplomacy = -2
            }
        },
        kaldorei = {
            advantages = {
                stealth = 1,
                agileDefense = 1,
                athletics = 1
            },
            disadvantages = {
                arcane = -1,
                commerce = -2
            },
            special = {
                "nightVision",
                "superiorHearing"
            }
        },
        gnome = {
            advantages = {
                perfectionism = 1, -- Mejora el talento más alto que tengas antes de aplicar el resto de ventajas y desventajas.
                sleightOfHand = 1,
                magicResistance = 1
            },
            disadvantages = {
                health = -2,
                resilience = -1
            }
        },
        draenei = {
            advantages = {
                jewelcraftingProfession = 1,
                faith = 2
            },
            disadvantages = {
                elementalConnection = -2,
                stealth = -1
            }
        },
        queldorei = {
            advantages = {
                magicResistance = 2,
                arcane = 1
            },
            disadvantages = {
                brutality = -1,
                sturdyDefense = -2
            },
            special = {
                "superiorHearing"
            }
        }
    },
    horde = {
        orc = {
            advantages = {
                brutality = 1,
                elementalConnection = 2
            },
            disadvantages = {
                agileDefense = -1,
                stealth = -2
            },
            special = {
                "superStrength"
            }
        },
        undead = {
            advantages = {
                lossOfControlResistance = 2,
                alchemyProfession = 1
            },
            disadvantages = {
                diplomacy = -2,
                manaRegeneration = -1
            },
            special = {
                "fearAndSleepImmunity",
                "poisonAndDiseaseImmunity",
                "limbReplacement"
            }
        },
        tauren = {
            advantages = {
                fortitude = 2,
                nature = 1
            },
            disadvantages = {
                agileDefense = -2,
                stealth = -1
            },
            special = {
                "superStrength"
            }
        },
        troll = {
            advantages = {
                oneHandedCombat = 1,
                manaRegeneration = 1,
                knockdownResistance = 1
            },
            disadvantages = {
                sturdyDefense = -1,
                resilience = -2
            },
            special = {
                "regeneration"
            }
        },
        goblin = {
            advantages = {
                commerce = 2,
                sleightOfHand = 1
            },
            disadvantages = {
                diplomacy = -2,
                faith = -1
            }
        },
        sindorei = {
            advantages = {
                fel = 1,
                magicResistance = 2
            },
            disadvantages = {
                lossOfControlResistance = -1,
                sturdyDefense = -2
            },
            special = {
                "superiorHearing"
            }
        }
    },
    otherRaces = {
        pandaren = {
            advantages = {
                chi = 2,
                lossOfControlResistance = 1
            },
            disadvantages = {
                provocation = -2,
                resilience = -1
            }
        },
        vrykul = {
            advantages = {
                brutality = 1,
                coldResistance = 1,
                fortitude = 1
            },
            disadvantages = {
                lossOfControlResistance = -2,
                stealth = -2
            },
            special = {
                "superStrength"
            }
        },
        blueDragon = {
            advantages = {
                fortitude = 3,
                magicResistance = 3,
                arcane = 3
            },
            disadvantages = {
                lossOfControlResistance = -3,
                stealth = -5
            },
            special = {
                "innate:Arcane"
            }
        }
    }
}
--- Mestizos ---
-- Los mestizos pueden elegir las ventajas y desventajas de ambas razas hasta tener un máximo de +3 en ventajas y -3 en desventajas.
-- Todos los mestizos heredan el apartado especial de cada raza del que es mestizo.

--- Special characteristics ---
--- Superfuerza:
---- Aumenta el daño de las armas finas, armas 1 mano, armas 2 manos en +2
---- Los objetivos que se defiende con Defensa Robusta o reciben el golpe y NO tienen Superfuerza, lanzarán 1D20 Constitución + Res. Derribos con dificultad 10 + Brutalidad.
---- No puede quedar agarrado por alguien que no tenga Superfuerza.
---- Pueden portar objetos muy pesados con ventaja.
--- Audición superior:
---- Duplica el rango de percepción auditiva.
---- Tiene ventaja en las tiradas de percepción auditiva.
---- Los sonidos fuertes cercanos aturden durante algunos turnos (a interpretación del máster)
--- Visión noctura:
---- No recibe penalización por Oscuridad.
---- Esto no se aplica a penalizadores por reducida visibilidad (niebla o humo)
--- Prestidigitador
---- Permite lanzar dos hechizos Truco en un solo ataque.
--- Reemplazo de miembros
---- Permite reemplazar miembros del cuerpo tras haberlos perdido.
--- Gran movilidad
---- Pueden moverse el doble de metros que otras razas.
--- Regeneración
---- Puede recuperar puntos de vida en un tiempo determinado o al final de cada ronda
--- Innato: Magia
---- Indica que el personaje nace con el dominio de la magia en concreto de forma natural, por lo que se considera que conoce TODOS los hechizos de dicha escuela de magia.
---- Tiene ventajas para la percepción mágica sobre dicha magia.

function GAC:GetFlatRaces()
    local list = {}
    if not self.Races then
        return list
    end
    local success, err = pcall(function()
        for groupName, races in pairs(self.Races) do
            for raceName, data in pairs(races) do
                if data.advantages or data.disadvantages then
                    table.insert(list, raceName)
                else
                    for subName, subData in pairs(data) do
                        table.insert(list, raceName .. " (" .. subName .. ")")
                    end
                end
            end
        end
        table.sort(list)
    end)
    return list
end

function GAC:GetRaceData(targetRaceName)
    if not self.Races then
        return nil
    end
    local targetData = nil
    local success, err = pcall(function()
        for groupName, races in pairs(self.Races) do
            for raceName, data in pairs(races) do
                if data.advantages or data.disadvantages then
                    if raceName == targetRaceName then targetData = data end
                else
                    for subName, subData in pairs(data) do
                        if (raceName .. " (" .. subName .. ")") == targetRaceName then targetData = subData end
                    end
                end
            end
        end
    end)
    return targetData
end
