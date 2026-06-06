local addonName, GAC = ...

GAC.PositiveTraits = {
  {
    name = "bully",
    label = "Abusón/a",
    description = "Aumenta el rango de los críticos.",
    levelOne = "1",
    levelTwo = "2.0",
    levelThree = "3",
  },
  {
    name = "agile",
    label = "Ágil",
    description = "Mejora el talento de Def. Ágil.\nA nivel 3, mejora Acrobacias",
    levelOne = "1",
    levelTwo = "2.0",
    levelThree = "Def. Ágil +2\nAcrobacias +1",
    modifiers = {
        [1] = { agileDefense = 1 },
        [2] = { agileDefense = 2 },
        [3] = { agileDefense = 2, acrobatics = 1 }
    }
  },
  {
    name = "agileAmbidextrous",
    label = "Ambidiestro/a ágil",
    description = "Elimina la penalización al nivel 1 de las armas finas. En el resto de niveles, suma al ataque.",
    levelOne = "",
    levelTwo = "1.0",
    levelThree = "2",
  },
  {
    name = "robustAmbidextrous",
    label = "Ambidiestro/a robusto",
    description = "Al nivel 1 reduce a la mitad la penalización por doble empuñadura de armas de 1 y 2 manos.",
    levelOne = "",
    levelTwo = "1.0",
    levelThree = "2",
  },
  {
    name = "athletic",
    label = "Atlético/a",
    description = "Mejora el talento de Atletismo. Al nivel tres, también mejora Acrobacias",
    levelOne = "1",
    levelTwo = "2.0",
    levelThree = "At+2\nAc+1",
    modifiers = {
        [1] = { athletics = 1 },
        [2] = { athletics = 2 },
        [3] = { athletics = 2, acrobatics = 1 }
    }
  },
  {
    name = "gifted",
    label = "Aventajado/a",
    description = "Dispone de una acción extra.\nSe siguen aplicando todas las reglas establecidas para las acciones.",
    levelOne = "",
    levelTwo = "",
    levelThree = "",
  },
  {
    name = "beautiful",
    label = "Bello/a",
    description = "Los NPC preferirán tratar contigo antes que cualquier otro.\nLos NPC se fijarán más en ti.\nMejora el talento de Seducción.",
    levelOne = "1",
    levelTwo = "2.0",
    levelThree = "3",
    modifiers = {
        [1] = { seduction = 1 },
        [2] = { seduction = 2 },
        [3] = { seduction = 3 }
    }
  },
  {
    name = "fastLearner",
    label = "Buen aprendiz",
    description = "Gana el doble de experiencia que el resto de personajes.",
    levelOne = "",
    levelTwo = "",
    levelThree = "",
  },
  {
    name = "stubborn",
    label = "Cabezota",
    description = "Mejora el talento de Resistencia al Aturdimiento.\nAl nivel 3, mejora Resistencia al Derribo.",
    levelOne = "1",
    levelTwo = "2.0",
    levelThree = "Resistencia al Aturdimiento +2\nResistencia al Derribo +1",
    modifiers = {
        [1] = { stunResistance = 1 },
        [2] = { stunResistance = 2 },
        [3] = { stunResistance = 2, knockdownResistance = 1 }
    }
  },
  {
    name = "sentinel",
    label = "Centinela",
    description = "Al beneficiarte de la ventaja por Altura, ganas un bonificador a tus ataques a distancia.",
    levelOne = "1",
    levelTwo = "2.0",
    levelThree = "3",
  },
  {
    name = "runner",
    label = "Corredor/a",
    description = "Aumenta la distancia normal de Movimiento del personaje. (Metros).",
    levelOne = "5",
    levelTwo = "7.0",
    levelThree = "10",
  },
  {
    name = "spiritual",
    label = "Espiritual",
    description = "Mejora uno de los siguientes talentos: Fe, Conexión Elemental o Chi.\nAl nivel 3, reduce el coste de espíritu de los hechizos de ese talento.",
    levelOne = "1",
    levelTwo = "2.0",
    levelThree = "Talento +2\nEspíritu-1",
    requiresTalentSelection = true,
    talentOptions = { "faith", "elementalConnection", "chi" },
    modifiers = {
        [1] = { _selected = 1 },
        [2] = { _selected = 2 },
        [3] = { _selected = 2 }
    }
  },
  {
    name = "feline",
    label = "Felino/a",
    description = "Mejora el talento de Sigilo.\nAl nivel 3, mejora Juego de Manos.",
    levelOne = "1",
    levelTwo = "2.0",
    levelThree = "Sigilo +2\nJuego de Manos +1",
    modifiers = {
        [1] = { stealth = 1 },
        [2] = { stealth = 2 },
        [3] = { stealth = 2, sleightOfHand = 1 }
    }
  },
  {
    name = "sorcerer",
    label = "Hechicero",
    description = "Mejora un talento de la rama de Inteligencia. (Se debe seleccionar)\nAl nivel 3, reduce el coste de maná de los hechizos de ese talento.",
    levelOne = "1",
    levelTwo = "2.0",
    levelThree = "Talento +2\nManá -1",
    requiresTalentSelection = true,
    talentGroup = "intelligence",
    modifiers = {
        [1] = { _selected = 1 },
        [2] = { _selected = 2 },
        [3] = { _selected = 2 }
    }
  },
  {
    name = "unbreakable",
    label = "Inquebrantable",
    description = "Mejora el talento de Resistencia a la Pérdida de Control.",
    levelOne = "1",
    levelTwo = "2.0",
    levelThree = "3",
    modifiers = {
        [1] = { lossOfControlResistance = 1 },
        [2] = { lossOfControlResistance = 2 },
        [3] = { lossOfControlResistance = 3 }
    }
  },
  {
    name = "weaponMaster",
    label = "Maestro de armas",
    description = "Mejora todos los talentos armas cuerpo a cuerpo.",
    levelOne = "1",
    levelTwo = "2.0",
    levelThree = "3",
    modifiers = {
        [1] = { oneHandedCombat = 1, twoHandedCombat = 1 },
        [2] = { oneHandedCombat = 2, twoHandedCombat = 2 },
        [3] = { oneHandedCombat = 3, twoHandedCombat = 3 }
    }
  },
  {
    name = "runeMaster",
    label = "Maestro rúnico",
    description = "Aumenta el talento de Inscripción (Sabiduría).",
    levelOne = "1",
    levelTwo = "2.0",
    levelThree = "3",
    modifiers = {
        [1] = { inscription = 1 },
        [2] = { inscription = 2 },
        [3] = { inscription = 3 }
    }
  },
  {
    name = "keenHearing",
    label = "Oído agudo",
    description = "Mejora el talento de Percepción cuando se realiza utilizando el sentido del oído.",
    levelOne = "1",
    levelTwo = "2.0",
    levelThree = "3",
  },
  {
    name = "prepared",
    label = "Preparado/a",
    description = "Mejora las tiradas de iniciativa.\nAl nivel 3, siempre empieza primero.",
    levelOne = "25",
    levelTwo = "50.0",
    levelThree = "∞",
  },
  {
    name = "quick",
    label = "Rápido/a",
    description = "Reduce la ventaja de los enemigos por flanqueos.",
    levelOne = "Los enemigos que te flanqueen ya no se benefician de tiradas con Ventaja.",
    levelTwo = "",
    levelThree = "",
  },
  {
    name = "resilient",
    label = "Resiliente",
    description = "Mejora el talento de Resiliencia. Al nivel 3, mejora a la Fortaleza.",
    levelOne = "1",
    levelTwo = "2.0",
    levelThree = "Resiliencia +2\nFortaleza +1",
    modifiers = {
        [1] = { resilience = 1 },
        [2] = { resilience = 2 },
        [3] = { resilience = 2, fortitude = 1 }
    }
  },
  {
    name = "robust",
    label = "Robusto/a",
    description = "Mejora el talento de Defensa Robusta. Al nivel 3, da un extra de vida.",
    levelOne = "1",
    levelTwo = "2.0",
    levelThree = "Defensa Robusta +2\nPuntos de Vida +5",
    modifiers = {
        [1] = { sturdyDefense = 1 },
        [2] = { sturdyDefense = 2 },
        [3] = { sturdyDefense = 2 }
    }
  },
  {
    name = "magicSensitivity",
    label = "Sensibilidad mágica",
    description = "Mejora las tiradas de percepción mágica.",
    levelOne = "1",
    levelTwo = "2.0",
    levelThree = "3",
  },
  {
    name = "lucky",
    label = "Suertudo",
    description = "Una vez por objetivo, si logras hacer un crítico exitoso, puedes atacar o sanar una segunda vez al mismo objetivo. (Se siguen aplicando todas las reglas establecidas para un ataque normal)",
    levelOne = "",
    levelTwo = "",
    levelThree = "",
  },
  {
    name = "tactical",
    label = "Táctico/a",
    description = "En cada turno, te permite elegir en qué momento actúas, independientemente del órden de los turnos. Para usar este rasgo, el personaje no debe haber actuado y debe declarar su intención de actuar antes que cualquier otro lo haga.",
    levelOne = "",
    levelTwo = "",
    levelThree = "",
  },
  {
    name = "talented",
    label = "Talentoso",
    description = "Mejora un talento de tu elección sin restricciones.",
    levelOne = "1",
    levelTwo = "2.0",
    levelThree = "3",
    requiresTalentSelection = true,
    modifiers = {
        [1] = { _selected = 1 },
        [2] = { _selected = 2 },
        [3] = { _selected = 3 }
    }
  },
  {
    name = "swift",
    label = "Veloz",
    description = "No puedes ser objetivo de agarres ni efectos de enraizado.",
    levelOne = "",
    levelTwo = "",
    levelThree = "",
  },
  {
    name = "nightVision",
    label = "Visión nocturna",
    description = "Reduce la penalización por Oscuridad.",
    levelOne = "1",
    levelTwo = "3.0",
    levelThree = "5",
  },
  {
    name = "keenSight",
    label = "Vista aguda",
    description = "Mejora la percepción siempre y cuando se realice usando el sentido de la vista. A nivel 3 mejora Armas Distancia.",
    levelOne = "1",
    levelTwo = "2.0",
    levelThree = "Percepción +2\nArmas Distancia +1",
  },
}