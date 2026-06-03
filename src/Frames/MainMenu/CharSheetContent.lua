local _, GAC = ...
local WLVX = WLV_Extends

if not WLVX then
    return
end

local DEFAULT_LEVEL = 1
local DEFAULT_STAT_VALUE = 0

local ATTRIBUTE_LABELS = {
    dexterity = "Destreza",
    strength = "Fuerza",
    intelligence = "Inteligencia",
    willpower = "Voluntad",
    constitution = "Constitucion",
    wisdom = "Sabiduria",
    charisma = "Carisma",
}

local TALENT_LABELS = {
    precision = "Precision",
    agileCombat = "Combate agil",
    acrobatics = "Acrobacias",
    stealth = "Sigilo",
    sleightOfHand = "Juego de manos",
    agileDefense = "Defensa agil",
    twoHandedCombat = "Combate a 2 manos",
    oneHandedCombat = "Combate a 1 mano",
    athletics = "Atletismo",
    brutality = "Brutalidad",
    sturdyDefense = "Defensa robusta",
    arcane = "Arcano",
    fel = "Vil",
    nature = "Naturaleza",
    shadow = "Sombras",
    necromancy = "Nigromancia",
    magicResistance = "Resistencia magica",
    lossOfControlResistance = "Resistencia perdida control",
    faith = "Fe",
    elementalConnection = "Conexion elemental",
    chi = "Chi",
    manaRegeneration = "Regeneracion de mana",
    resilience = "Resiliencia",
    stunResistance = "Resistencia aturdimientos",
    knockdownResistance = "Resistencia derribos",
    coldResistance = "Resistencia frio",
    heatResistance = "Resistencia calor",
    fortitude = "Fortaleza",
    animalConnection = "Conexion animal",
    survival = "Supervivencia",
    perception = "Percepcion",
    persuasion = "Persuasion",
    diplomacy = "Diplomacia",
    commerce = "Comercio",
    provocation = "Provocacion",
    seduction = "Seduccion",
    performance = "Interpretacion",
}

-- Convierte cualquier entrada de texto en un entero estable para guardar en la ficha.
local function toInteger(value, fallback)
    local numberValue = tonumber(value)
    if not numberValue then
        return fallback or DEFAULT_STAT_VALUE
    end

    return math.floor(numberValue)
end

-- Devuelve la etiqueta visible para una clave interna de atributo.
local function getAttributeLabel(attributeName)
    return ATTRIBUTE_LABELS[attributeName] or attributeName
end

-- Devuelve la etiqueta visible para una clave interna de talento.
local function getTalentLabel(talentName)
    return TALENT_LABELS[talentName] or talentName
end

-- Asegura que las SavedVariables y las tablas internas existen antes de crear controles.
local function ensureCharacterData()
    if GAC.InitializeAttributeSystem and (not GAC.characterData or not GAC.characterData.attributes or not GAC.characterData.talents) then
        GAC:InitializeAttributeSystem()
    end

    GAC.characterData = GAC.characterData or {}
    GAC.characterData.attributes = GAC.characterData.attributes or {}
    GAC.characterData.talents = GAC.characterData.talents or {}
    GAC.characterData.level = math.max(DEFAULT_LEVEL, toInteger(GAC.characterData.level, DEFAULT_LEVEL))

    for _, group in ipairs(GAC.attributeGroups or {}) do
        if GAC.characterData.attributes[group.name] == nil then
            GAC.characterData.attributes[group.name] = DEFAULT_STAT_VALUE
        end

        for _, talentName in ipairs(group.talents or {}) do
            if GAC.characterData.talents[talentName] == nil then
                GAC.characterData.talents[talentName] = DEFAULT_STAT_VALUE
            end
        end
    end

    return GAC.characterData
end

-- Aplica el estilo visual de panel usado por la ficha.
local function applyPanelBackdrop(frame, alpha)
    frame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 8,
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    frame:SetBackdropColor(0.04, 0.07, 0.12, alpha or 0.72)
    frame:SetBackdropBorderColor(0.20, 0.45, 0.82, 0.85)
end

-- Crea una etiqueta de WoW con ancho, alineacion y plantilla configurables.
local function createText(parent, template, text, width, justify)
    local label = parent:CreateFontString(nil, "OVERLAY", template or "GameFontHighlightSmall")
    label:SetText(text or "")
    if width then
        label:SetWidth(width)
    end
    label:SetJustifyH(justify or "LEFT")
    return label
end

-- Crea un input numerico con comportamiento comun de Enter/Escape.
local function createNumericInput(parent, width, height, value, onCommit)
    local input = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    local res = WLVX:resolveDimensions(width or 32, height or 32, parent)
    input:SetSize(res.x, res.y)
    input:SetAutoFocus(false)
    input:SetNumeric(true)
    input:SetMaxLetters(6)
    input:SetText(tostring(toInteger(value, DEFAULT_STAT_VALUE)))
    input:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    input:SetScript("OnEnterPressed", function(self)
        if onCommit then
            onCommit(self:GetText())
        end
        self:ClearFocus()
    end)
    input:SetScript("OnEditFocusLost", function(self)
        if onCommit then
            onCommit(self:GetText())
        end
    end)
    return input
end

-- Guarda el valor del nivel de personaje.
local function saveLevel(value)
    ensureCharacterData().level = math.max(DEFAULT_LEVEL, toInteger(value, DEFAULT_LEVEL))
end

-- Guarda el valor de un atributo concreto.
local function saveAttribute(attributeName, value)
    ensureCharacterData().attributes[attributeName] = toInteger(value, DEFAULT_STAT_VALUE)
end

-- Guarda el valor de un talento concreto.
local function saveTalent(talentName, value)
    ensureCharacterData().talents[talentName] = toInteger(value, DEFAULT_STAT_VALUE)
end

-- Lee todos los inputs visibles y los vuelca a characterData.
local function saveAllControls()
    local controls = GAC.charSheetControls
    if not controls then
        return
    end

    if controls.level then
        saveLevel(controls.level:GetText())
    end

    for attributeName, input in pairs(controls.attributes or {}) do
        saveAttribute(attributeName, input:GetText())
    end

    for talentName, input in pairs(controls.talents or {}) do
        saveTalent(talentName, input:GetText())
    end

    print("[GAC]: Ficha de personaje guardada.")
end

-- Refresca los inputs desde characterData despues de cambios programaticos.
local function refreshControls()
    local characterData = ensureCharacterData()
    local controls = GAC.charSheetControls
    if not controls then
        return
    end

    if controls.level then
        controls.level:SetText(tostring(characterData.level))
    end

    for attributeName, input in pairs(controls.attributes or {}) do
        input:SetText(tostring(characterData.attributes[attributeName] or DEFAULT_STAT_VALUE))
    end

    for talentName, input in pairs(controls.talents or {}) do
        input:SetText(tostring(characterData.talents[talentName] or DEFAULT_STAT_VALUE))
    end
end

-- Reinicia nivel, atributos y talentos a los valores base.
local function resetValues()
    local characterData = ensureCharacterData()
    characterData.level = DEFAULT_LEVEL

    for _, group in ipairs(GAC.attributeGroups or {}) do
        characterData.attributes[group.name] = DEFAULT_STAT_VALUE
        for _, talentName in ipairs(group.talents or {}) do
            characterData.talents[talentName] = DEFAULT_STAT_VALUE
        end
    end

    refreshControls()
    print("[GAC]: Ficha de personaje reiniciada.")
end

-- Crea el bloque superior con titulo, descripcion y nivel.
local function buildHeader(parent, charSheetId)
    local characterData = ensureCharacterData()

    WLVX:AddHeader(parent, charSheetId .. "_Title", "Ficha de personaje", "100%", 28)
    WLVX:AddLabel(parent, charSheetId .. "_Description", "Atributos y talentos usados por las tiradas.", "100%", 18)

    WLVX:AddRow(parent, charSheetId .. "_LevelRow", "100%", 32, function(row)
        local label = createText(row, "GameFontNormal", "Nivel", 80, "LEFT")
        label:SetPoint("LEFT", row, "LEFT", 4, 0)

        GAC.charSheetControls.level = createNumericInput(row, 54, 20, characterData.level, saveLevel)
        GAC.charSheetControls.level:SetPoint("LEFT", label, "RIGHT", 8, 0)
    end)
end

-- Crea el ScrollFrame que contiene las tarjetas de atributos.
local function createAttributesScroll(parent, charSheetId)
    local panel = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    panel:SetAllPoints(parent)
    applyPanelBackdrop(panel, 0.65)

    local scrollFrame = CreateFrame("ScrollFrame", charSheetId .. "_ScrollFrame", panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -10)
    scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -28, 10)

    local scrollChild = CreateFrame("Frame", charSheetId .. "_ScrollChild", scrollFrame)
    scrollChild:SetSize(1, 1)
    scrollFrame:SetScrollChild(scrollChild)

    return scrollChild
end

-- Aplica el estilo de tarjeta usado para cada atributo.
local function styleAttributeCard(card)
    local background = card:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints()
    background:SetColorTexture(0.08, 0.10, 0.13, 0.92)

    local accent = card:CreateTexture(nil, "ARTWORK")
    accent:SetPoint("TOPLEFT", 0, 0)
    accent:SetPoint("TOPRIGHT", 0, 0)
    accent:SetHeight(3)
    accent:SetColorTexture(0.20, 0.68, 1, 0.65)

    local borderTop = card:CreateTexture(nil, "BORDER")
    borderTop:SetPoint("TOPLEFT", 0, 0)
    borderTop:SetPoint("TOPRIGHT", 0, 0)
    borderTop:SetHeight(1)
    borderTop:SetColorTexture(1, 1, 1, 0.20)

    local borderBottom = card:CreateTexture(nil, "BORDER")
    borderBottom:SetPoint("BOTTOMLEFT", 0, 0)
    borderBottom:SetPoint("BOTTOMRIGHT", 0, 0)
    borderBottom:SetHeight(1)
    borderBottom:SetColorTexture(1, 1, 1, 0.20)

    local borderLeft = card:CreateTexture(nil, "BORDER")
    borderLeft:SetPoint("TOPLEFT", 0, 0)
    borderLeft:SetPoint("BOTTOMLEFT", 0, 0)
    borderLeft:SetWidth(1)
    borderLeft:SetColorTexture(1, 1, 1, 0.20)

    local borderRight = card:CreateTexture(nil, "BORDER")
    borderRight:SetPoint("TOPRIGHT", 0, 0)
    borderRight:SetPoint("BOTTOMRIGHT", 0, 0)
    borderRight:SetWidth(1)
    borderRight:SetColorTexture(1, 1, 1, 0.20)
end

-- Construye una tarjeta de atributo con su input y los talentos asociados.
local function buildAttributeCard(parent, group, yOffset, cardWidth)
    local characterData = ensureCharacterData()
    local cardHeight = 48 + (#(group.talents or {}) * 22)
    local card = CreateFrame("Frame", nil, parent)
    local res = WLVX:resolveDimensions(cardWidth or 32, cardHeight, parent)
    card:SetSize(res.x, cardHeight)
    card:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, yOffset)
    styleAttributeCard(card)

    local header = createText(card, "GameFontNormal", getAttributeLabel(group.name), cardWidth - 70, "LEFT")
    header:SetPoint("TOPLEFT", card, "TOPLEFT", 8, -8)

    local attributeInput = createNumericInput(card, 44, 20, characterData.attributes[group.name], function(value)
        saveAttribute(group.name, value)
    end)
    attributeInput:SetPoint("TOPRIGHT", card, "TOPRIGHT", -8, -6)
    GAC.charSheetControls.attributes[group.name] = attributeInput

    local divider = card:CreateTexture(nil, "ARTWORK")
    divider:SetColorTexture(1, 1, 1, 0.13)
    divider:SetPoint("TOPLEFT", card, "TOPLEFT", 8, -30)
    divider:SetPoint("TOPRIGHT", card, "TOPRIGHT", -8, -30)
    divider:SetHeight(1)

    local talentY = -39
    for _, talentName in ipairs(group.talents or {}) do
        local talentLabel = createText(card, "GameFontHighlightSmall", getTalentLabel(talentName), cardWidth - 66, "LEFT")
        talentLabel:SetPoint("TOPLEFT", card, "TOPLEFT", 8, talentY)

        local talentInput = createNumericInput(card, 44, 18, characterData.talents[talentName], function(value)
            saveTalent(talentName, value)
        end)
        talentInput:SetPoint("TOPRIGHT", card, "TOPRIGHT", -8, talentY + 2)
        GAC.charSheetControls.talents[talentName] = talentInput

        talentY = talentY - 22
    end

    return cardHeight
end

-- Construye todas las tarjetas de atributos usando la estructura de AttributesAndTalents.lua.
local function buildAttributeCards(parent)
    local cardWidth = 365
    local cardSpacing = 14
    local currentY = -12

    for _, group in ipairs(GAC.attributeGroups or {}) do
        local cardHeight = buildAttributeCard(parent, group, currentY, cardWidth)
        currentY = currentY - cardHeight - cardSpacing
    end

    parent:SetSize(cardWidth, math.max(math.abs(currentY) + 20, 1))
end

-- Construye la fila de acciones de la ficha con botones nativos de WoW.
local function buildActions(parent, charSheetId)
    local actions = CreateFrame("Frame", charSheetId .. "_Actions", parent)
    actions:SetAllPoints(parent)
    actions:SetHeight(32)

    local saveButton = CreateFrame("Button", nil, actions, "UIPanelButtonTemplate")
    saveButton:SetSize(120, 26)
    saveButton:SetPoint("LEFT", actions, "LEFT", 6, 0)
    saveButton:SetText("Guardar")
    saveButton:SetScript("OnClick", saveAllControls)

    local resetButton = CreateFrame("Button", nil, actions, "UIPanelButtonTemplate")
    resetButton:SetSize(120, 26)
    resetButton:SetPoint("LEFT", saveButton, "RIGHT", 8, 0)
    resetButton:SetText("Reiniciar")
    resetButton:SetScript("OnClick", resetValues)
end

-- Construye el apartado de personaje del menu principal.
function GAC:buildCharSheetContent(parentId, charSheetId, parentFrame)
    ensureCharacterData()

    self.charSheetControls = {
        attributes = {},
        talents = {},
    }

    local sheetContent = WLVX:AddColumn(parentFrame, parentId .. charSheetId, "100%", "100%", function(content)
        WLVX:SetMargin(content, 2, 5) -- Márgenes reducidos para dar más espacio al contenido real
        WLVX:SetGap(content, 6)

        buildHeader(content, charSheetId)

        WLVX:AddRow(content, charSheetId .. "_ScrollRow", "100%", 450, function(row)
            local scrollChild = createAttributesScroll(row, charSheetId)
            buildAttributeCards(scrollChild)
        end)

        WLVX:AddRow(content, charSheetId .. "_ActionsRow", "100%", 32, function(row)
            buildActions(row, charSheetId)
        end)
    end)

    self.contentFrames = self.contentFrames or {}
    self.contentFrames[charSheetId] = sheetContent
end
