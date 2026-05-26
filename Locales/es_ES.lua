local _, addon = ...

addon.L = {
    -- Atributos
    strength = "Fuerza",
    dexterity = "Destreza",
    intelligence = "Inteligencia",
    willpower = "Voluntad",
    constitution = "Constitución",
    wisdom = "Sabiduría",
    charisma = "Carisma",

    -- Talentos
    precision = "Precisión",
    agileCombat = "Combate Ágil",
    acrobatics = "Acrobacias",
    stealth = "Sigilo",
    sleightOfHand = "Juego de Manos",
    agileDefense = "Defensa Ágil",
    twoHandedCombat = "Combate a 2 manos",
    oneHandedCombat = "Combate a 1 mano",
    athletics = "Atletismo",
    brutality = "Brutalidad",
    robustDefense = "Defensa Robusta",
    arcane = "Arcano",
    fel = "Vil",
    nature = "Naturaleza",
    shadow = "Sombras",
    necromancy = "Nigromancia",
    magicResistance = "Resistencia Mágica",
    controlLossResistance = "Resistencia a la Pérdida de Control",
    faith = "Fe",
    elementalConnection = "Conexión Elemental",
    chi = "Chi",
    manaRegeneration = "Regeneración de Maná",
    resilience = "Resiliencia",
    stunResistance = "Resistencia a Aturdimientos",
    knockdownResistance = "Resistencia a Derribos",
    coldResistance = "Resistencia al Frío",
    heatResistance = "Resistencia al Calor",
    fortitude = "Fortaleza",
    animalHandling = "Conexión con los animales",
    survival = "Supervivencia",
    perception = "Percepción",
    persuasion = "Persuasión",
    diplomacy = "Diplomacia",
    commerce = "Comercio",
    provocation = "Provocación",
    seduction = "Seducción",
    performance = "Interpretación",

    -- Otros
    initiative = "Iniciativa",
    requirements = "Requisitos",
    penalties = "Penalizaciones",
    armor = "Armadura",
    none = "Ninguno",
    others = "Otros",

    -- Tipos de Armadura
    cloth = "Tela",
    leather = "Cuero",
    mail = "Malla",
    plate = "Placa",

    -- Categorías de nivel
    novice = "Novato",
    normal = "Normal",
    elite = "Élite",
    boss = "Jefe",

    -- Secciones de armadura
    armors = "Armaduras",
    pieces = "Piezas",
    reinforcements = "Refuerzos",

    -- Partes del cuerpo
    head = "Cabeza",
    chest = "Pecho",
    hands = "Guantes",
    legs = "Piernas",

    -- Atributos de armadura
    physicalReduction = "Reducción física",
    magicReduction = "Reducción mágica",
    durability = "Durabilidad",
    piercing = "Perforante",
    slashing = "Cortante",
    bludgeoning = "Contundente",
    movement = "Movimiento",
}

addon.ReverseL = {}
for k, v in pairs(addon.L) do
    addon.ReverseL[v:lower()] = k
end

function addon:GetLocalizedText(key)
    return self.L[key] or key
end

function addon:GetInternalKey(text)
    if not text or type(text) ~= "string" then return text end
    local clean = text:match("^%s*(.-)%s*$"):lower()
    return self.ReverseL[clean] or text
end