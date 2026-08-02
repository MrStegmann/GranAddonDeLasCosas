--- Traits Database
--- Transpiled from specs/003-Metadata/traits-types.ts
local TraitsDatabase = {}

TraitsDatabase.PositiveTraitList = {
    {
        id = "bully",
        name = "Abusón/a",
        description = "Aumenta el rango de los críticos.",
        type = "mechanical",
        level1 = { { id = "criticalRange", value = 1 } },
        level2 = { { id = "criticalRange", value = 2 } },
        level3 = { { id = "criticalRange", value = 3 } }
    },
    {
        id = "agile",
        name = "Ágil",
        description = "Mejora el talento de Def. Ágil. A nivel 3, mejora Acrobacias",
        type = "talents",
        level1 = { { id = "agileDefense", value = 1 } },
        level2 = { { id = "agileDefense", value = 2 } },
        level3 = { { id = "agileDefense", value = 2 }, { id = "acrobatics", value = 1 } }
    },
    {
        id = "agileAmbidextrous",
        name = "Ambidiestro/a ágil",
        description = "Elimina la penalización al nivel 1 de las armas finas. En el resto de niveles, suma al ataque.",
        type = "mechanical",
        level1 = { { id = "agileAmbidextrous", value = 1 } },
        level2 = { { id = "agileAmbidextrous", value = 2 } },
        level3 = { { id = "agileAmbidextrous", value = 3 } }
    },
    {
        id = "strongAmbidextrous",
        name = "Ambidiestro/a robusto",
        description = "Al nivel 1 reduce a la mitad la penalización por doble empuñadura de armas de 1 y 2 manos.",
        type = "mechanical",
        level1 = { { id = "strongAmbidextrous", value = 1 } },
        level2 = { { id = "strongAmbidextrous", value = 2 } },
        level3 = { { id = "strongAmbidextrous", value = 3 } }
    },
    {
        id = "athletic",
        name = "Atlético/a",
        description = "Mejora el talento de Atletismo. Al nivel tres, también mejora Acrobacias",
        type = "talents",
        level1 = { { id = "athletics", value = 1 } },
        level2 = { { id = "athletics", value = 2 } },
        level3 = { { id = "athletics", value = 2 }, { id = "acrobatics", value = 1 } }
    },
    {
        id = "advantaged",
        name = "Aventajado/a",
        description = "Dispone de una acción extra. Se siguen aplicando todas las reglas establecidas para las acciones.",
        type = "mechanical",
        level1 = { { id = "combatActions", value = 1 } }
    },
    {
        id = "beautiful",
        name = "Bello/a",
        description = "Los NPC preferirán tratar contigo antes que cualquier otro. Los NPC se fijarán más en ti. Mejora el talento de Seducción.",
        type = "mechanical",
        level1 = { { id = "seduction", value = 1 } },
        level2 = { { id = "seduction", value = 2 } },
        level3 = { { id = "seduction", value = 3 } }
    },
    {
        id = "fastLearner",
        name = "Buen aprendiz",
        description = "Gana el doble de experiencia que el resto de personajes.",
        type = "mechanical",
        level1 = { { id = "experienceGain", value = 1 } }
    },
    {
        id = "stubborn",
        name = "Cabezota",
        description = "Mejora el talento de Res. Atur. Al nivel 3, mejora Res. Derr.",
        type = "talents",
        level1 = { { id = "stunResistance", value = 1 } },
        level2 = { { id = "stunResistance", value = 2 } },
        level3 = { { id = "stunResistance", value = 2 }, { id = "knockdownResistance", value = 1 } }
    },
    {
        id = "sentinel",
        name = "Centinela",
        description = "Al beneficiarte de la ventaja por Altura, ganas un bonificador a tus ataques a distancia.",
        type = "talents",
        level1 = { { id = "precision", value = 1 } },
        level2 = { { id = "precision", value = 2 } },
        level3 = { { id = "precision", value = 3 } }
    },
    {
        id = "runner",
        name = "Corredor/a",
        description = "Aumenta la distancia normal de Movimiento del personaje. (Metros).",
        type = "mechanical",
        level1 = { { id = "movement", value = 5 } },
        level2 = { { id = "movement", value = 7 } },
        level3 = { { id = "movement", value = 10 } }
    },
    {
        id = "spiritual",
        name = "Espiritual",
        description = "Mejora uno de los siguientes talentos: Fe, C. Elemental o Chi. Al nivel 3, reduce el coste de espíritu de los hechizos de ese talento.",
        type = "mechanical",
        level1 = { { id = "talent", value = 1 } },
        level2 = { { id = "talent", value = 2 } },
        level3 = { { id = "talent", value = 2 }, { id = "spiritCost", value = -1 } }
    },
    {
        id = "feline",
        name = "Felino/a",
        description = "Mejora el talento de Sigilo. Al nivel 3, mejora Juego de Manos.",
        type = "talents",
        level1 = { { id = "stealth", value = 1 } },
        level2 = { { id = "stealth", value = 2 } },
        level3 = { { id = "stealth", value = 2 }, { id = "sleightOfHand", value = 1 } }
    },
    {
        id = "sorcerer",
        name = "Hechicero",
        description = "Mejora un talento de la rama de INT. (Se debe seleccionar) Al nivel 3, reduce el coste de maná de los hechizos de ese talento.",
        type = "mechanical",
        level1 = { { id = "talent", value = 1 } },
        level2 = { { id = "talent", value = 2 } },
        level3 = { { id = "talent", value = 2 }, { id = "manaCost", value = -1 } }
    },
    {
        id = "unbreakable",
        name = "Inquebrantable",
        description = "Mejora el talento de Res. Pér. Control.",
        type = "talents",
        level1 = { { id = "lossOfControlResistance", value = 1 } },
        level2 = { { id = "lossOfControlResistance", value = 2 } },
        level3 = { { id = "lossOfControlResistance", value = 3 } }
    },
    {
        id = "weaponMaster",
        name = "Maestro de armas",
        description = "Mejora todos los talentos armas cuerpo a cuerpo.",
        type = "talents",
        level1 = { { id = "twoHandedCombat", value = 1 }, { id = "oneHandedCombat", value = 1 }, { id = "agileCombat", value = 1 } },
        level2 = { { id = "twoHandedCombat", value = 2 }, { id = "oneHandedCombat", value = 2 }, { id = "agileCombat", value = 2 } },
        level3 = { { id = "twoHandedCombat", value = 3 }, { id = "oneHandedCombat", value = 3 }, { id = "agileCombat", value = 3 } }
    },
    {
        id = "sharpEar",
        name = "Oído agudo",
        description = "Mejora el talento de Percepción cuando se realiza utilizando el sentido del oído.",
        type = "mechanical",
        level1 = { { id = "perception-ears", value = 1 } },
        level2 = { { id = "perception-ears", value = 2 } },
        level3 = { { id = "perception-ears", value = 3 } }
    },
    {
        id = "prepared",
        name = "Preparado/a",
        description = "Mejora las tiradas de iniciativa. Al nivel 3, siempre empieza primero.",
        type = "mechanical",
        level1 = { { id = "initiative", value = 25 } },
        level2 = { { id = "initiative", value = 50 } },
        level3 = { { id = "initiative", value = 999 } }
    },
    {
        id = "fast",
        name = "Rápido/a",
        description = "No sufres desventaja por flanqueo.",
        type = "mechanical",
        level1 = {}
    },
    {
        id = "resilient",
        name = "Resiliente",
        description = "Mejora el talento de Resiliencia. Al nivel 3, mejora a la Fortaleza.",
        type = "talents",
        level1 = { { id = "resilience", value = 1 } },
        level2 = { { id = "resilience", value = 2 } },
        level3 = { { id = "resilience", value = 2 }, { id = "fortitude", value = 1 } }
    },
    {
        id = "robust",
        name = "Robusto/a",
        description = "Mejora el talento de DR. Al nivel 3, da un extra de vida.",
        type = "talents",
        level1 = { { id = "robustDefense", value = 1 } },
        level2 = { { id = "robustDefense", value = 2 } },
        level3 = { { id = "robustDefense", value = 2 }, { id = "health", value = 5 } }
    },
    {
        id = "magicSensitivity",
        name = "Sensibilidad mágica",
        description = "Mejora las tiradas de percepción mágica.",
        type = "mechanical",
        level1 = { { id = "magicPerception", value = 1 } },
        level2 = { { id = "magicPerception", value = 2 } },
        level3 = { { id = "magicPerception", value = 3 } }
    },
    {
        id = "lucky",
        name = "Suertudo",
        description = "Una vez por objetivo, si logras hacer un crítico exitoso, puedes atacar o sanar una segunda vez al mismo objetivo.",
        type = "mechanical",
        level1 = {}
    },
    {
        id = "tactician",
        name = "Táctico/a",
        description = "En cada turno, te permite elegir en qué momento actúas, independientemente del órden de los turnos.",
        type = "mechanical",
        level1 = {}
    },
    {
        id = "talented",
        name = "Talentoso",
        description = "Mejora un talento de tu elección sin restricciones.",
        type = "mechanical",
        level1 = { { id = "talent", value = 1 } },
        level2 = { { id = "talent", value = 2 } },
        level3 = { { id = "talent", value = 3 } }
    },
    {
        id = "swift",
        name = "Veloz",
        description = "No puedes ser objetivo de agarres ni efectos de enraizado.",
        type = "mechanical",
        level1 = {}
    },
    {
        id = "nightVision",
        name = "Visión nocturna",
        description = "Reduce la penalización por Oscuridad.",
        type = "mechanical",
        level1 = { { id = "darknessPenalty", value = -1 } },
        level2 = { { id = "darknessPenalty", value = -2 } },
        level3 = { { id = "darknessPenalty", value = -3 } }
    },
    {
        id = "sharpSight",
        name = "Vista aguda",
        description = "Mejora la percepción siempre y cuando se realice usando el sentido de la vista. A nivel 3 mejora Armas Distancia.",
        type = "mechanical",
        level1 = { { id = "perception-eyes", value = 1 } },
        level2 = { { id = "perception-eyes", value = 2 } },
        level3 = { { id = "perception-eyes", value = 2 }, { id = "precision", value = 1 } }
    }
}

TraitsDatabase.NegativeTraitList = {
    {
        id = "ugly",
        name = "Adefesio",
        description = "Eres tan feo que de pequeño te ponían a dormir con los cerdos. -3 a seducción.",
        type = "mechanical",
        effect = { { id = "seduction", value = -3 } },
        incompatibility = {}
    },
    {
        id = "manic_drinker",
        name = "Adicto al maná",
        description = "Cuando gastes más de la mitad de tu maná, consumes el doble.",
        type = "mechanical",
        effect = {},
        incompatibility = {}
    },
    {
        id = "alcoholic",
        name = "Alcohólico/a",
        description = "Cuando no bebes durante demasiado tiempo, recibes una penalización de -3 a cualquier acción.",
        type = "mechanical",
        effect = { { id = "anyAction", value = -3 } },
        incompatibility = {}
    },
    {
        id = "amnesiac",
        name = "Amnésico",
        description = "Pierdes todos los puntos iniciales de atributo a repartir y no los recuperarás hasta que los recuerdos vuelvan.",
        type = "narrative",
        effect = {},
        incompatibility = {}
    },
    {
        id = "wild",
        name = "Asalvajado",
        description = "Penaliza todas las tiradas del personaje en zonas urbanas.",
        type = "mechanical",
        effect = { { id = "anyAction", value = -3 } },
        incompatibility = {}
    },
    {
        id = "asocial",
        name = "Asocial",
        description = "Penaliza todas las tiradas de Carisma",
        type = "mechanical",
        effect = { { id = "charisma", value = -3 } },
        incompatibility = {}
    },
    {
        id = "jester",
        name = "Bufón",
        description = "No respetas a ningún símbolo de autoridad ni títulos nobiliarios.",
        type = "narrative",
        effect = {},
        incompatibility = {}
    },
    {
        id = "hunted",
        name = "Buscado",
        description = "Siempre que se esté en pueblos o caminos, pueden emboscarte aquellos que te buscan.",
        type = "mechanical",
        effect = {},
        incompatibility = {}
    },
    {
        id = "blinded_by_love",
        name = "Ciego de amor",
        description = "Eliges el objetivo de un amor (otro personaje de jugador).",
        type = "mechanical",
        effect = {},
        incompatibility = { "vengeful" }
    },
    {
        id = "big_mouth",
        name = "Bocazas",
        description = "El personaje tiene dificultades para guardar secretos o medir sus palabras.",
        type = "narrative",
        effect = {},
        incompatibility = {}
    },
    {
        id = "coward",
        name = "Cobarde",
        description = "Cada vez que el jugador se vea superado en número de enemigos, quedará aturdido.",
        type = "narrative",
        effect = {},
        incompatibility = {}
    },
    {
        id = "lame",
        name = "Cojera",
        description = "Reduce a la mitad el Movimiento base del personaje.",
        type = "mechanical",
        effect = { { id = "movement", value = 0.5 } },
        incompatibility = {}
    },
    {
        id = "short_sighted",
        name = "Corto de miras",
        description = "Penaliza el talento de Percepción siempre que implique la vista. Penaliza los ataques a distancia.",
        type = "mechanical",
        effect = { { id = "perception-eyes", value = -2 }, { id = "rangedAttack", value = -2 } },
        incompatibility = {}
    },
    {
        id = "weak",
        name = "Débil",
        description = "Penaliza los talentos de Fortaleza y Def. Robusta",
        type = "talents",
        effect = { { id = "fortitude", value = -2 }, { id = "robustDefense", value = -1 } },
        incompatibility = {}
    },
    {
        id = "disastrous",
        name = "Desastroso",
        description = "Recibe la mitad de experiencia total comparado con el resto de personajes.",
        type = "mechanical",
        effect = {},
        incompatibility = {}
    },
    {
        id = "absent_minded",
        name = "Despistado",
        description = "Penaliza los talentos de Percepción y Percepción Mágica",
        type = "mechanical",
        effect = { { id = "perception", value = -3 }, { id = "perception-magic", value = -3 } },
        incompatibility = {}
    },
    {
        id = "sickly",
        name = "Enfermizo/a",
        description = "Penaliza la resiliencia y la cantidad de vida.",
        type = "mechanical",
        effect = { { id = "resilience", value = -2 }, { id = "health", value = -5 } },
        incompatibility = {}
    },
    {
        id = "berserker",
        name = "Ensañamiento",
        description = "Cuando mates a un enemigo, permanecerás un turno más atacando al cadáver.",
        type = "narrative",
        effect = {},
        incompatibility = {}
    },
    {
        id = "emaciated",
        name = "Escuálido/a",
        description = "Penaliza los talentos de Brutalidad y DR.",
        type = "talents",
        effect = { { id = "brutality", value = -3 }, { id = "robustDefense", value = -2 } },
        incompatibility = {}
    },
    {
        id = "fanatic_religious",
        name = "Fanático religioso",
        description = "Penaliza con 1 todas las tiradas si no se realizan rezos o ritos religiosos.",
        type = "narrative",
        effect = {},
        incompatibility = {}
    },
    {
        id = "phobia",
        name = "Fobia",
        description = "Elige un tipo de fobia para el personaje.",
        type = "mechanical",
        effect = { { id = "anyAction", value = -3 } },
        incompatibility = {}
    },
    {
        id = "fragile",
        name = "Frágil",
        description = "Penaliza el talento de Resistencia Mágica y la efectividad de cualquier defensa mágica.",
        type = "mechanical",
        effect = { { id = "magicResistance", value = -2 }, { id = "magicDefense", value = -1 } },
        incompatibility = {}
    },
    {
        id = "indecisive",
        name = "Indeciso",
        description = "No puede atacar o curar al mismo objetivo dos turnos seguidos",
        type = "narrative",
        effect = {},
        incompatibility = {}
    },
    {
        id = "merciless",
        name = "Inmisericorde",
        description = "Ejecutarás a todos los enemigos sin piedad alguna.",
        type = "narrative",
        effect = {},
        incompatibility = { "pious" }
    },
    {
        id = "useless",
        name = "Inútil",
        description = "Penaliza un talento de tu elección sin restricciones.",
        type = "mechanical",
        effect = { { id = "anyTalent", value = -2 } },
        incompatibility = {}
    },
    {
        id = "thief",
        name = "Ladrón",
        description = "Siempre que alguien obtenga una recompensa, deberá tirar por Voluntad + Rest. Per. Control.",
        type = "narrative",
        effect = {},
        incompatibility = {}
    },
    {
        id = "cripple",
        name = "Manco",
        description = "Le falta una mano o un brazo.",
        type = "mechanical",
        effect = {},
        incompatibility = {}
    },
    {
        id = "mastodon",
        name = "Mastodonte",
        description = "Eres un fiera, un crack, un máquina. Pero te pesa el culo.",
        type = "talents",
        effect = { { id = "agileDefense", value = -2 }, { id = "acrobatics", value = -3 } },
        incompatibility = {}
    },
    {
        id = "mentally_fragile",
        name = "Mentalidad frágil",
        description = "Penaliza el talento de Res. Pérdida de control",
        type = "talents",
        effect = { { id = "lossOfControlResistance", value = -3 } },
        incompatibility = {}
    },
    {
        id = "coward",
        name = "Miedica",
        description = "Penaliza las iniciativas.",
        type = "mechanical",
        effect = { { id = "initiative", value = -3 } },
        incompatibility = {}
    },
    {
        id = "muggle",
        name = "Muggle",
        description = "Penaliza todas las tiradas mágicas.",
        type = "mechanical",
        effect = { { id = "anyMagic", value = -3 } },
        incompatibility = {}
    },
    {
        id = "nightmares",
        name = "Pesadillas",
        description = "Los recuerdos del pasado te atormentan cada noche al cerrar los ojos.",
        type = "narrative",
        effect = {},
        incompatibility = {}
    },
    {
        id = "pious",
        name = "Piadoso",
        description = "Te ves incapaz de matar a nadie.",
        type = "narrative",
        effect = {},
        incompatibility = { "merciless" }
    },
    {
        id = "noisy",
        name = "Ruidoso",
        description = "Penaliza el talento de sigilo.",
        type = "talents",
        effect = { { id = "stealth", value = -3 } },
        incompatibility = {}
    },
    {
        id = "mana_leech",
        name = "Sanguijuela de maná",
        description = "Te deleitas con la energía de otros.",
        type = "narrative",
        effect = {},
        incompatibility = {}
    },
    {
        id = "deafness",
        name = "Sordera",
        description = "Penaliza el talento de Percepción siempre que implique el sentido del oído.",
        type = "mechanical",
        effect = { { id = "perception-ears", value = -3 } },
        incompatibility = {}
    },
    {
        id = "clumsy",
        name = "Torpe",
        description = "Penaliza los talentos de Juego de manos y todas los de Armas al intentar impactar.",
        type = "talents",
        effect = { { id = "sleightOfHand", value = -2 }, { id = "agileCombat", value = -2 }, { id = "oneHandedCombat", value = -2 }, { id = "twoHandedCombat", value = -2 } },
        incompatibility = {}
    },
    {
        id = "traitor",
        name = "Traidor",
        description = "Siempre que se te ofrezca una suma importante para tu personaje, los dejarás de lado.",
        type = "narrative",
        effect = {},
        incompatibility = {}
    },
    {
        id = "one_eyed",
        name = "Tuerto",
        description = "Te falta un ojo.",
        type = "mechanical",
        effect = { { id = "perception-eyes", value = -5 }, { id = "precision", value = -5 } },
        incompatibility = {}
    },
    {
        id = "vengeful",
        name = "Vengativo",
        description = "Hasta que muera el primer enemigo que te ataque, sólo atacarás a ese enemigo.",
        type = "narrative",
        effect = {},
        incompatibility = { "love_blind" }
    },
    {
        id = "dopey",
        name = "Zopenco",
        description = "Penaliza los talentos de Res. Derribos y Aturdimientos",
        type = "talents",
        effect = { { id = "stunResistance", value = -2 }, { id = "knockdownResistance", value = -2 } },
        incompatibility = {}
    }
}

_G.GAC_TraitsDatabase = TraitsDatabase
return TraitsDatabase
