local TraitsDatabase = {}

-- Positive Traits List
TraitsDatabase.PositiveTraits = {
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
    -- Require a specific function for manage dual wield penalties for agile Weapons. At level 1 must anulate the penalty for agile weapons. Each level extra should add a mod only when having dual wield.
    {
        id = "agileAmbidextrous",
        name = "Ambidiestro/a ágil",
        description = "Elimina la penalización al nivel 1 de las armas finas. En el resto de niveles, suma al ataque.",
        type = "mechanical",
        level1 = { { id = "agileAmbidextrous", value = 1 } },
        level2 = { { id = "agileAmbidextrous", value = 2 } },
        level3 = { { id = "agileAmbidextrous", value = 3 } }
    },
    -- Require a specific function for manage dual wield penalties for 1-handed and 2-handed Weapons. At level 1 must reduce to half the penalty for these weapons. At level 2 decrease penalty by 1. At level 3 decrease penalty by 3. This only applies with dual wielding.
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
    -- Should add one combatr actions to the character
    {
        id = "advantaged",
        name = "Aventajado/a",
        description = "Dispone de una acción extra. Se siguen aplicando todas las reglas establecidas para las acciones.",
        type = "mechanical",
        level1 = { { id = "combatActions", value = 1 } }
    },
    -- Have a narrative part that must be showered as a narrative trait. Also, increase the talent seduction.
    {
        id = "beautiful",
        name = "Bello/a",
        description = "Los NPC preferirán tratar contigo antes que cualquier otro. Los NPC se fijarán más en ti. Mejora el talento de Seducción.",
        type = "mechanical",
        level1 = { { id = "seduction", value = 1 } },
        level2 = { { id = "seduction", value = 2 } },
        level3 = { { id = "seduction", value = 3 } }
    },
    -- Need a function that generate automactically a 1D4 roll dice and add the result to the experience gained. Must be triggered when the character with this trait grain any experience.
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
        description = "Mejora el talento de Res. Atur.  Al nivel 3, mejora Res. Derr.",
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
    -- Must apply a movement bonus to the combatstat movement. At level 1 must increase the movement by 5 meters, at level 2 by 7 meters, at level 3 by 10 meters.
    {
        id = "runner",
        name = "Corredor/a",
        description = "Aumenta la distancia normal de Movimiento del personaje. (Metros).",
        type = "mechanical",
        level1 = { { id = "movement", value = 5 } },
        level2 = { { id = "movement", value = 7 } },
        level3 = { { id = "movement", value = 10 } }
    },
    -- Must activate a special selector that allow the user to select any of this three talents: Faith, Chi or Elemental. At level 1 must increase the selected talent by 1, at level 2 by 2, and at level 3 by 3. Also at level 3 reduce the cost of the spells of the same magic school of the selected talent by 1.
    {
        id = "spiritual",
        name = "Espiritual",
        description = "Mejora uno de los siguientes talentos: Fe, C. Elemental o Chi.  Al nivel 3, reduce el coste de espíritu de los hechizos de ese talento.",
        type = "mechanical",
        level1 = { { id = "talent", value = 1 } },
        level2 = { { id = "talent", value = 2 } },
        level3 = { { id = "talent", value = 2 }, { id = "spiritCost", value = -1 } }
    },
    {
        id = "feline",
        name = "Felino/a",
        description = "Mejora el talento de Sigilo.  Al nivel 3, mejora Juego de Manos.",
        type = "talents",
        level1 = { { id = "stealth", value = 1 } },
        level2 = { { id = "stealth", value = 2 } },
        level3 = { { id = "stealth", value = 2 }, { id = "sleightOfHand", value = 1 } }
    },
    -- Must activate a special selector that allow the user to select any INT based magic talent. At level 1 must increase the selected talent by 1, at level 2 by 2, and at level 3 by 3. Also at level 3 reduce the cost of the spells of the same magic school of the selected talent by 1.
    {
        id = "sorcerer",
        name = "Hechicero",
        description = "Mejora un talento de la rama de INT. (Se debe seleccionar)  Al nivel 3, reduce el coste de maná de los hechizos de ese talento.",
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
    -- Physical perception is a 1D20 roll that have a desglose result. The result of the dice is Physical Perception result, but each type of perception could be increase or decrease this result. This trait reduce the result for Perception-Ears.
    -- Perception should have: Ears, Nose, Sight, Touch, Taste.
    {
        id = "sharpEar",
        name = "Oído agudo",
        description = "Mejora el talento de Percepción cuando se realiza utilizando el sentido del oído.",
        type = "mechanical",
        level1 = { { id = "perception-ears", value = 1 } },
        level2 = { { id = "perception-ears", value = 2 } },
        level3 = { { id = "perception-ears", value = 3 } }
    },
    -- This trait required to increase the combatstat initiative.
    {
        id = "prepared",
        name = "Preparado/a",
        description = "Mejora las tiradas de iniciativa.  Al nivel 3, siempre empieza primero.",
        type = "mechanical",
        level1 = { { id = "initiative", value = 25 } },
        level2 = { { id = "initiative", value = 50 } },
        level3 = { { id = "initiative", value = 999 } }
    },
    -- This trait required a function that always should be used has a validation when the character is flanked.
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
    -- This trait should improve the magic perception check.
    {
        id = "magicSensitivity",
        name = "Sensibilidad mágica",
        description = "Mejora las tiradas de percepción mágica.",
        type = "mechanical",
        level1 = { { id = "magicPerception", value = 1 } },
        level2 = { { id = "magicPerception", value = 2 } },
        level3 = { { id = "magicPerception", value = 3 } }
    },
    -- This trait required a function that has to be used has a validation for any critical hit the character scores, allowing it to repeat the same action (attack or heal) against the same target.
    {
        id = "lucky",
        name = "Suertudo",
        description = "Una vez por objetivo, si logras hacer un crítico exitoso, puedes atacar o sanar una segunda vez al mismo objetivo. (Se siguen aplicando todas las reglas establecidas para un ataque normal)",
        type = "mechanical",
        level1 = {}
    },
    -- This trait must be resolve has a first thing in the turn round, so the character has to declarated in which position of the turn order he wants to act.
    {
        id = "tactician",
        name = "Táctico/a",
        description = "En cada turno, te permite elegir en qué momento actúas, independientemente del órden de los turnos. Para usar este rasgo, el personaje no debe haber actuado y debe declarar su intención de actuar antes que cualquier otro lo haga.",
        type = "mechanical",
        level1 = {}
    },
    -- Must activate a special selector that allow the user to select any talent to improve.
    {
        id = "talented",
        name = "Talentoso",
        description = "Mejora un talento de tu elección sin restricciones.",
        type = "mechanical",
        level1 = { { id = "talent", value = 1 } },
        level2 = { { id = "talent", value = 2 } },
        level3 = { { id = "talent", value = 3 } }
    },
    -- This trait required a function that has to be used has a validation for any "grapple" or "immobilized" status effect that the character suffers, preventing it from being affected by it.
    {
        id = "swift",
        name = "Veloz",
        description = "No puedes ser objetivo de agarres ni efectos de enraizado.",
        type = "mechanical",
        level1 = {}
    },
    -- This function should reduced for the user any blind penalty.
    {
        id = "nightVision",
        name = "Visión nocturna",
        description = "Reduce la penalización por Oscuridad.",
        type = "mechanical",
        level1 = { { id = "darknessPenalty", value = -1 } },
        level2 = { { id = "darknessPenalty", value = -2 } },
        level3 = { { id = "darknessPenalty", value = -3 } }
    },
    -- Physical perception is a 1D20 roll that have a desglose result. The result of the dice is Physical Perception result, but each type of perception could be increase or decrease this result. This trait improve the result for Perception-Eyes.
    -- Perception should have: Ears, Nose, Sight, Touch, Taste.
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

-- Negative Traits List
TraitsDatabase.NegativeTraits = {
    -- Have a narrative part that must be showered as a narrative trait. Also, decrease the talent seduction.
    {
        id = "ugly",
        name = "Adefesio",
        description = "Eres tan feo que de pequeño te ponían a dormir con los cerdos. Los NPC preferirán ignorarte antes que tener una conversación contigo. Serás recordado por lo horrible que eres. -3 a seducción.",
        type = "mechanical",
        effect = { { id = "seduction", value = -3 } },
        incompatibility = {}
    },
    -- This trait activates a double cost for all mana consumption. It will be applied when the character spend mana.
    {
        id = "manic_drinker",
        name = "Adicto al maná",
        description = "Cuando gastes más de la mitad de tu maná, dejarás de hacer cualquier cosa y buscarás desesperadamente recuperarlo. Siempre consumirás el doble (Gemas de maná, comida mágica, fuentes de energía, pociones de maná, etc)",
        type = "mechanical",
        effect = {},
        incompatibility = {}
    },
    -- This trait will always triggered for every action the character performs if the character does not drink alcohol in a long period of time. At the moment the character will resolve a dice roll, a warning message must alert charactaer and Master about this trait and the master have the power to apply or not the penalty.
    {
        id = "alcoholic",
        name = "Alcohólico/a",
        description = "Siempre necesitas un trago, sea cual sea la situación, sea cual sea el momento, siempre necesitas beber. Cuando no bebes durante demasiado tiempo, recibes una penalización de -3 a cualquier acción.",
        type = "mechanical",
        effect = { { id = "anyAction", value = -3 } },
        incompatibility = {}
    },
    {
        id = "amnesiac",
        name = "Amnésico",
        description = "Pierdes todos los puntos iniciales de atributo a repartir y no los recuperarás hasta que los recuerdos vuelvan a tu personaje. Esto no ocurrirá por norma general y debería llevar tiempo.",
        type = "narrative",
        effect = {},
        incompatibility = {}
    },
    -- This trait must be manual activated by the master or player whenever the character is in a urban zone.
    {
        id = "wild",
        name = "Asalvajado",
        description = "Penaliza todas las tiradas del personaje en zonas urbanas.",
        type = "mechanical",
        effect = { { id = "anyAction", value = -3 } },
        incompatibility = {}
    },
    -- This trait must be manual activated by the master or player whenever the character is having social moments.
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
        description = "No respetas a ningún símbolo de autoridad ni títulos nobiliarios, contradiciendo las órdenes que te den y devolviendoles su condescendencia.",
        type = "narrative",
        effect = {},
        incompatibility = {}
    },
    -- This trait must be manual activated by the master or player whenever the character is in a urban zone, roads or villages. When triggered, 1D100 roll will be automatically done. If the result is less than 45, the character will suffer an ambush. If the result is greater than 45, the character will not suffer an ambush. If the character is ambushed, 1D4 will be throwed and show the result.
    {
        id = "hunted",
        name = "Buscado",
        description = "Puedes elegir por quién y qué motivos eres buscados sino serán mercenarios que buscan tu cabeza por alguna razón aleatoria. Siempre que se esté en pueblos o caminos, pueden emboscarte aquellos que te buscan. El máster tirará 1D100, acto seguido 1D4 para determinar cuántos son los que te emboscan. (1D100 = <45 sufres una emboscada)",
        type = "mechanical",
        effect = {},
        incompatibility = {}
    },
    -- The character with this trait must select another player to be his beloved one. By that, it should be showed as a narrative trait with the name of the beloved one.
    {
        id = "blinded_by_love",
        name = "Ciego de amor",
        description = "Eliges el objetivo de un amor (otro personaje de jugador). Ese personaje está tan obsesionado que cuando el objeto de su amor sufre daño, el jugador cambiará su objetivo hacia aquel que haya dañado a su amor hasta que muera. Además, si el objeto de su amor está bajo de vida, el personaje abandonará a todos con tal de alejar a su amor del lugar para salvarle la vida.",
        type = "mechanical",
        effect = {},
        incompatibility = { "vengeful" }
    },
    {
        id = "big_mouth",
        name = "Bocazas",
        description = "El personaje tiene dificultades para guardar secretos o medir sus palabras. Cuando obtiene información relevante, escucha un rumor importante o se encuentra bajo presión social, debe superar una tirada de Voluntad + Res. Perd. Control 14 para mantenerse discreto.",
        type = "narrative",
        effect = {},
        incompatibility = {}
    },
    {
        id = "coward",
        name = "Cobarde",
        description = "Cada vez que el jugador se vea superado en número de enemigos o una situación que supera sus capacidades (el máster avisará al jugador), quedará aturdido y será incapaz de actuar. Tirará un dado de Voluntad + Res. Perd. Control en su turno y tendrá que superar 15.",
        type = "narrative",
        effect = {},
        incompatibility = {}
    },
    -- This trait reduces the movement speed of the character.
    {
        id = "lame",
        name = "Cojera",
        description = "Reduce a la mitad el Movimiento base del personaje.",
        type = "mechanical",
        effect = { { id = "movement", value = 0.5 } },
        incompatibility = {}
    },
    -- This trait reduces the perception of the character in situations that involve sight and range attacks.
    {
        id = "short_sighted",
        name = "Corto de miras",
        description = "Penaliza el talento de Percepción siempre que implique el sentido de la vista. Penaliza los ataques a distancia.",
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
    -- This trait should be triggered whenever the character gain experience, reducing it in 50%.
    {
        id = "disastrous",
        name = "Desastroso",
        description = "Recibe la mitad de experiencia total comparado con el resto de personajes.",
        type = "mechanical",
        effect = {},
        incompatibility = {}
    },
    -- This trait reduces the talent perception of the character in situations that involve magic perception.
    {
        id = "absent_minded",
        name = "Despistado",
        description = "Penaliza los talentos de Percepción y Percepción Mágica",
        type = "mechanical",
        effect = { { id = "perception", value = -3 }, { id = "perception-magic", value = -3 } },
        incompatibility = {}
    },
    -- This trait reduces the talent resilience and the amount of health.
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
        description = "Penaliza los talentos de Brutalidad y DR. Si tu oponente tiene más fuerza que tú, te derribará.",
        type = "talents",
        effect = { { id = "brutality", value = -3 }, { id = "robustDefense", value = -2 } },
        incompatibility = {}
    },
    {
        id = "fanatic_religious",
        name = "Fanático religioso",
        description = "Penaliza con 1 todas las tiradas si no se realizan rezos o ritos religiosos. La penalización es acumulativa. Todas las cosas en contra de tu religión te enfurece y te vuelves hostil. Para evitar esto, podrás lanzar un d20 VOL + Resistencia a la Pérdida de Control. Si superas o iguales 15, lo evitas.",
        type = "narrative",
        effect = {},
        incompatibility = {}
    },
    -- This trait activate an unique input field for the character to add his phobia. Whatever, it should be showed has a narrative trait with phobia name.
    {
        id = "phobia",
        name = "Fobia",
        description = "Elige un tipo de fobia para el personaje. Cada vez que te enfrentes a tu fobia, recibirás una penalización a todas tus tiradas.",
        type = "mechanical",
        effect = { { id = "anyAction", value = -3 } },
        incompatibility = {}
    },
    -- Whenever the player is hit by a magical attack, his magical defense (using defensive spells) have always a penalty. Also reduce the talent magicResistance.
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
        description = "Ejecutarás a todos los enemigos sin piedad alguna y sin atender a nada ni nadie. No harás nunca prisioneros ni dejarás a nadie con vida. Para evitar esto, podrás lanzar un d20 VOL + Resistencia a la Pérdida de Control. Si superas o iguales 15 lo evitas.",
        type = "narrative",
        effect = {},
        incompatibility = { "pious" }
    },
    -- This trait activate a special talent selector to choose one talent to reduce in 2 points.
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
        description = "Siempre que alguien obtenga una recompensa, deberá tirar por Voluntad + Rest. Per. Control. Deberá superar 14 si no quiere robar. Siempre que tengas la oportunidad, tratarás de robar algo.",
        type = "narrative",
        effect = {},
        incompatibility = {}
    },
    -- This trait activate a function validator for dual wielding. The character can't use dual wielding.
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
        description = "Eres un fiera, un crack, un máquina der furbito, un mastodonte. Pero te pesa el culo.",
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
    -- This trait reduce combatStat initiative.
    {
        id = "coward",
        name = "Miedica",
        description = "Penaliza las iniciativas.",
        type = "mechanical",
        effect = { { id = "initiative", value = -3 } },
        incompatibility = {}
    },
    -- This trait reduce all magical talents in 3 points (arcane, fel, nature, shadow, necromancy, faith, chi, elementalConnection).
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
        description = "Los recuerdos del pasado te atormentan cada noche al cerrar los ojos, volviendo a ti en forma de vívidas pesadillas. Cada vez que el personaje vaya a dormir, deberá tirar 1d20 Voluntad + Res. Pérdida Control. Si no supera o iguala 15, no podrá dormir y se verá afectado por Fatiga.",
        type = "narrative",
        effect = {},
        incompatibility = {}
    },
    {
        id = "pious",
        name = "Piadoso",
        description = "Te ves incapaz de matar a nadie aunque lo que tengas delante sea un monstruo en vida y hagas más bien que mal matándolo. Pero no lo harás, no matarás a nadie.",
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
        description = "Te deleitas con la energía de otros, lo degustas como si fuera un buen vino. Siempre que sea posible, robarás la energía a la persona más cercana (amigo o enemigo, la verdad es que te da igual) para lanzar tus hechizos.",
        type = "narrative",
        effect = {},
        incompatibility = {}
    },
    -- Whenever the player roll a D20 in perception checks, the perception-ears desglose result suffers -3 penalty.
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
        description = "No es que tengas nada en contra de tus compañeros, es que los otros pagan mejor. Siempre que se te ofrezca una suma importante para tu personaje, no tendrás dudas a la hora de dejarlos de lado. Elige algo por lo que tu personaje aceptaría sin dudar cambiar de bando.",
        type = "narrative",
        effect = {},
        incompatibility = {}
    },
    -- Whenever the player roll a D20 in perception checks, the perception-eyes desglose result suffers -5 penalty and talent precision suffers -5 penalty.
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

return TraitsDatabase
