local addonName, GAC = ...

GAC.PositiveTraits = {
    {
        name = "bully",
        label = "Abusón/a",
        description = "Aumenta el rango de los críticos.",
        level1 = function() return { criticalRange = 1 } end,
        level2 = function() return { criticalRange = 2 } end,
        level3 = function() return { criticalRange = 3 } end
    },
    {
        name = "agile",
        label = "Ágil",
        description = "Mejora el talento de Def. Ágil. A nivel 3, mejora Acrobacias",
        level1 = function() return { agileDefense = 1} end,
        level2 = function() return { agileDefense = 2} end,
        level3 = function() return { agileDefense = 2, acrobatics = 1} end
    },
    {
        name = "agileAmbidextrous",
        label = "Ambidiestro/a ágil",
        description = "Elimina la penalización al nivel 1 de las armas finas. En el resto de niveles, suma al ataque.",
        level1 = function() end,
        level2 = function() print("1") end,
        level3 = function() print("2") end
    },
    {
        name = "robustAmbidextrous",
        label = "Ambidiestro/a robusto",
        description = "Al nivel 1 reduce a la mitad la penalización por doble empuñadura de armas de 1 y 2 manos.",
        level1 = function() end,
        level2 = function() print("1") end,
        level3 = function() print("2") end
    },
    {
        name = "athletic",
        label = "Atlético/a",
        description = "Mejora el talento de Atletismo. Al nivel tres, también mejora Acrobacias",
        level1 = function() return { athletics = 1} end,
        level2 = function() return { athletics = 2} end,
        level3 = function() return { athletics = 2, acrobatics = 1} end
    },
    {
        name = "advantaged",
        label = "Aventajado/a",
        description = "Dispone de una acción extra. Se siguen aplicando todas las reglas establecidas para las acciones.",
        level1 = function() return { combatActions = 1} end
    },
    {
        name = "beautiful",
        label = "Bello/a",
        description = "Los NPC preferirán tratar contigo antes que cualquier otro. Los NPC se fijarán más en ti. Mejora el talento de Seducción.",
        level1 = function() return { seduction = 1} end,
        level2 = function() return { seduction = 2} end,
        level3 = function() return { seduction = 3} end
    },
    {
        name = "fastLearner",
        label = "Buen aprendiz",
        description = "Gana el doble de experiencia que el resto de personajes.",
        level1 = function() return random(1,4) end
    },
    {
        name = "stubborn",
        label = "Cabezota",
        description = "Mejora el talento de Res. Atur.  Al nivel 3, mejora Res. Derr.",
        level1 = function() return { stunResistance = 1 } end,
        level2 = function() return { stunResistance = 2 } end,
        level3 = function() return { stunResistance = 2, knockdownResistance = 1 } end
    },
    {
        name = "sentinel",
        label = "Centinela",
        description = "Al beneficiarte de la ventaja por Altura, ganas un bonificador a tus ataques a distancia.",
        level1 = function() return { precision = 1 } end,
        level2 = function() return { precision = 2 } end,
        level3 = function() return { precision = 3 } end
    },
    {
        name = "runner",
        label = "Corredor/a",
        description = "Aumenta la distancia normal de Movimiento del personaje. (Metros).",
        level1 = function() return { movement = 5} end,
        level2 = function() return { movement = 7} end,
        level3 = function() return { movement = 10} end
    },
    {
        name = "spiritual",
        label = "Espiritual",
        description = "Mejora uno de los siguientes talentos: Fe, C. Elemental o Chi.  Al nivel 3, reduce el coste de espíritu de los hechizos de ese talento.",
        level1 = function() return { talent = 1} end,
        level2 = function() return { talent = 2} end,
        level3 = function() return { talent = 2, spiritCost = -1} end
    },
    {
        name = "feline",
        label = "Felino/a",
        description = "Mejora el talento de Sigilo.  Al nivel 3, mejora Juego de Manos.",
        level1 = function() return { stealth = 1} end,
        level2 = function() return { stealth = 2} end,
        level3 = function() return { stealth = 2, sleightOfHand = 1} end
    },
    {
        name = "sorcerer",
        label = "Hechicero",
        description = "Mejora un talento de la rama de INT. (Se debe seleccionar)  Al nivel 3, reduce el coste de maná de los hechizos de ese talento.",
        level1 = function() return { talent = 1} end,
        level2 = function() return { talent = 2} end,
        level3 = function() return { talent = 2, manaCost = -1} end
    },
    {
        name = "unbreakable",
        label = "Inquebrantable",
        description = "Mejora el talento de Res. Pér. Control.",
        level1 = function() return { lossOfControlResistance = 1 } end,
        level2 = function() return { lossOfControlResistance = 2 } end,
        level3 = function() return { lossOfControlResistance = 3 } end
    },
    {
        name = "weaponMaster",
        label = "Maestro de armas",
        description = "Mejora todos los talentos armas cuerpo a cuerpo.",
        level1 = function() return { twoHandedCombat = 1, oneHandedCombat = 1, agileCombat = 1} end,
        level2 = function() return { twoHandedCombat = 2, oneHandedCombat = 2, agileCombat = 2} end,
        level3 = function() return { twoHandedCombat = 3, oneHandedCombat = 3, agileCombat = 3} end
    },
    {
        name = "sharpEar",
        label = "Oído agudo",
        description = "Mejora el talento de Percepción cuando se realiza utilizando el sentido del oído.",
        level1 = function() return { ["perception-ears"] = 1} end,
        level2 = function() return { ["perception-ears"] = 2} end,
        level3 = function() return { ["perception-ears"] = 3} end
    },
    {
        name = "prepared",
        label = "Preparado/a",
        description = "Mejora las tiradas de iniciativa.  Al nivel 3, siempre empieza primero.",
        level1 = function() return { initiative = 25 } end,
        level2 = function() return { initiative = 50 } end,
        level3 = function() return { initiative = 999 } end
    },
    {
        name = "fast",
        label = "Rápido/a",
        description = "Reduce la ventaja de los enemigos por flanqueos.",
        level1 = function() print("Los enemigos que te flanqueen ya no se benefician de tiradas con Ventaja.") end
    },
    {
        name = "resilient",
        label = "Resiliente",
        description = "Mejora el talento de Resiliencia. Al nivel 3, mejora a la Fortaleza.",
        level1 = function() return { resilience = 1} end,
        level2 = function() return { resilience = 2} end,
        level3 = function() return { resilience = 2, fortitude = 1} end
    },
    {
        name = "robust",
        label = "Robusto/a",
        description = "Mejora el talento de DR. Al nivel 3, da un extra de vida.",
        level1 = function() return { sturdyDefense = 1} end,
        level2 = function() return { sturdyDefense = 2} end,
        level3 = function() return { sturdyDefense = 2, health = 5} end
    },
    {
        name = "magicSensitivity",
        label = "Sensibilidad mágica",
        description = "Mejora las tiradas de percepción mágica.",
        level1 = function() return { magicPerception = 1} end,
        level2 = function() return { magicPerception = 2} end,
        level3 = function() return { magicPerception = 3} end
    },
    {
        name = "lucky",
        label = "Suertudo",
        description = "Una vez por objetivo, si logras hacer un crítico exitoso, puedes atacar o sanar una segunda vez al mismo objetivo. (Se siguen aplicando todas las reglas establecidas para un ataque normal)",
        level1 = function() end
    },
    {
        name = "tactician",
        label = "Táctico/a",
        description = "En cada turno, te permite elegir en qué momento actúas, independientemente del órden de los turnos. Para usar este rasgo, el personaje no debe haber actuado y debe declarar su intención de actuar antes que cualquier otro lo haga.",
        level1 = function() end
    },
    {
        name = "talented",
        label = "Talentoso",
        description = "Mejora un talento de tu elección sin restricciones.",
        level1 = function() return { talent = 1} end,
        level2 = function() return { talent = 2} end,
        level3 = function() return { talent = 3} end
    },
    {
        name = "swift",
        label = "Veloz",
        description = "No puedes ser objetivo de agarres ni efectos de enraizado.",
        level1 = function() end
    },
    {
        name = "nightVision",
        label = "Visión nocturna",
        description = "Reduce la penalización por Oscuridad.",
        level1 = function() return { darknessPenalty = -1} end,
        level2 = function() return { darknessPenalty = -2} end,
        level3 = function() return { darknessPenalty = -3} end
    },
    {
        name = "sharpSight",
        label = "Vista aguda",
        description = "Mejora la percepción siempre y cuando se realice usando el sentido de la vista. A nivel 3 mejora Armas Distancia.",
        level1 = function() return { ["perception-eyes"] = 1} end,
        level2 = function() return { ["perception-eyes"] = 2} end,
        level3 = function() return { ["perception-eyes"] = 2, ["precision"] = 1} end
    }
}
