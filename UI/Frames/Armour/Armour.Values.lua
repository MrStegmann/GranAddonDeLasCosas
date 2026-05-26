local _, addon = ...

local ARMOUR_TYPE_ALIASES = {
    ["tela"] = "Tela",
    ["telas"] = "Tela",
    ["cuero"] = "Cuero",
    ["cueros"] = "Cuero",
    ["malla"] = "Malla",
    ["mallas"] = "Malla",
    ["placa"] = "Placa",
    ["placas"] = "Placa",
}

local ARMOUR_PIECE_ALIASES = {
    ["cabeza"] = "Cabeza",
    ["pecho"] = "Pecho",
    ["guantes"] = "Guantes",
    ["piernas"] = "Piernas",
}

local ARMOUR_PIECE_TYPE_FALLBACK_KEYS = {
    Tela = { "Telas" },
    Cuero = { "Cueros" },
    Malla = { "Mallas" },
    Placa = { "Placas" },
}

local function trim(text)
    if type(text) ~= "string" then
        return nil
    end

    local cleaned = text:match("^%s*(.-)%s*$")
    if cleaned == "" then
        return nil
    end

    return cleaned
end

local function parseArmourTooltipLeft(tooltipLeft)
    local clean = trim(tooltipLeft)
    if not clean then
        return nil, nil
    end

    local armourType, suffix = clean:match("^(.-)%s*:%s*(.+)$")
    if not armourType then
        return clean, nil
    end

    armourType = trim(armourType)
    suffix = trim(suffix)
    if not suffix then
        return armourType, nil
    end
    local section, reinforcementType = suffix:match("^(.-)%s*%-%s*(.+)$")
    section = trim(section)
    reinforcementType = trim(reinforcementType)

    if section and section:lower() == "refuerzos" then
        return armourType, reinforcementType
    end

    return armourType, nil
end

local function resolveDataKey(data, value, aliases)
    local clean = trim(value)
    if type(data) ~= "table" or not clean then
        return nil
    end

    local candidates = {}
    local alias = aliases and aliases[clean:lower()] or nil
    if alias then
        candidates[#candidates + 1] = alias
    end
    candidates[#candidates + 1] = clean

    for _, candidate in ipairs(candidates) do
        if candidate and data[candidate] ~= nil then
            return candidate
        end
    end

    local cleanLower = clean:lower()
    for key in pairs(data) do
        if type(key) == "string" and key:lower() == cleanLower then
            return key
        end
    end

    return nil
end

local function resolvePieceArmourKey(pieceData, armourKey)
    if type(pieceData) ~= "table" or not armourKey then
        return nil
    end

    if pieceData[armourKey] ~= nil then
        return armourKey
    end

    local singularLower = armourKey:lower()
    for key in pairs(pieceData) do
        if type(key) == "string" and key:lower() == singularLower then
            return key
        end
    end

    for _, fallbackKey in ipairs(ARMOUR_PIECE_TYPE_FALLBACK_KEYS[armourKey] or {}) do
        if pieceData[fallbackKey] ~= nil then
            return fallbackKey
        end

        local fallbackLower = fallbackKey:lower()
        for key in pairs(pieceData) do
            if type(key) == "string" and key:lower() == fallbackLower then
                return key
            end
        end
    end

    return nil
end

function addon:GetArmourInfoFromTooltips(tooltipLeft, tooltipRight)
    local armourType, reinforcementType = parseArmourTooltipLeft(tooltipLeft)
    local pieceName = trim(tooltipRight)
    local data = self.armourData

    local info = {
        armourType = armourType,
        reinforcementType = reinforcementType,
        pieceName = pieceName,
    }

    if type(data) ~= "table" then
        return info
    end

    local armours = data["Armaduras"]
    local pieces = data["Piezas"]
    local reinforcements = data["Refuerzos"]

    info.armourKey = resolveDataKey(armours, armourType, ARMOUR_TYPE_ALIASES)
    info.armourData = info.armourKey and armours[info.armourKey] or nil

    info.pieceKey = resolveDataKey(pieces, pieceName, ARMOUR_PIECE_ALIASES)
    local pieceData = info.pieceKey and pieces[info.pieceKey] or nil
    info.pieceArmourKey = resolvePieceArmourKey(pieceData, info.armourKey)
    info.pieceData = info.pieceArmourKey and pieceData[info.pieceArmourKey] or nil

    info.reinforcementKey = resolveDataKey(reinforcements, reinforcementType, ARMOUR_TYPE_ALIASES)
    info.reinforcementData = info.reinforcementKey and reinforcements[info.reinforcementKey] or nil

    return info
end

local SUMMED_ARMOUR_ATTRIBUTE_EXCLUSIONS = {
    ["Requisitos"] = true,
    ["Penalizaciones"] = true,
}

local function addNamedValue(total, name, value)
    local numericValue = tonumber(value)
    local cleanName = trim(name) or name
    if type(total) == "table" and type(cleanName) == "string" and numericValue then
        total[cleanName] = (total[cleanName] or 0) + numericValue
    end
end

local function addPropertyValue(properties, name, value)
    local cleanName = trim(name) or name
    if type(properties) ~= "table" or type(cleanName) ~= "string" or value == nil then
        return
    end

    local valueText = tostring(value)
    if valueText == "" then
        return
    end

    if not properties[cleanName] then
        properties[cleanName] = valueText
        return
    end

    for existingValue in string.gmatch(properties[cleanName] .. "/", "([^/]+)/") do
        if existingValue == valueText then
            return
        end
    end

    properties[cleanName] = properties[cleanName] .. "/" .. valueText
end

local function addNamedValuesFromEntry(total, entry)
    if type(total) ~= "table" or type(entry) ~= "table" then
        return
    end

    for name, value in pairs(entry) do
        addNamedValue(total, name, value)
    end
end

local function addNamedValuesFromEntries(total, entries)
    if type(total) ~= "table" or type(entries) ~= "table" then
        return
    end

    if #entries > 0 then
        for _, entry in ipairs(entries) do
            addNamedValuesFromEntry(total, entry)
        end
        return
    end

    addNamedValuesFromEntry(total, entries)
end

local function addArmourRequirementsAndPenalties(totals, data)
    if type(totals) ~= "table" or type(data) ~= "table" then
        return
    end

    addNamedValuesFromEntries(totals.requirements, data["Requisitos"])
    addNamedValuesFromEntries(totals.penalties, data["Penalizaciones"])
end

local function addArmourAttributes(totals, data)
    if type(totals) ~= "table" or type(data) ~= "table" then
        return
    end

    for name, value in pairs(data) do
        if not SUMMED_ARMOUR_ATTRIBUTE_EXCLUSIONS[name] and type(value) ~= "table" then
            if tonumber(value) then
                addNamedValue(totals.attributes, name, value)
            else
                addPropertyValue(totals.properties, name, value)
            end
        end
    end
end

local function addNamedMap(target, source)
    if type(target) ~= "table" or type(source) ~= "table" then
        return
    end

    for name, value in pairs(source) do
        local numericValue = tonumber(value)
        if type(name) == "string" and numericValue then
            target[name] = (target[name] or 0) + numericValue
        end
    end
end

function addon:BuildArmourPieceTotals(armourInfo)
    local totals = {
        attributes = {},
        properties = {},
        requirements = {},
        penalties = {},
    }

    if type(armourInfo) ~= "table" then
        return totals
    end

    addArmourAttributes(totals, armourInfo.armourData)
    addArmourAttributes(totals, armourInfo.pieceData)
    addArmourRequirementsAndPenalties(totals, armourInfo.pieceData)

    if type(armourInfo.reinforcementData) == "table" then
        addArmourAttributes(totals, armourInfo.reinforcementData)
        addArmourRequirementsAndPenalties(totals, armourInfo.reinforcementData)
    end

    return totals
end

function addon:IsKnownArmourPiece(armourInfo)
    return type(armourInfo) == "table"
        and type(armourInfo.armourData) == "table"
        and (armourInfo.pieceKey ~= nil or armourInfo.pieceName ~= nil)
end

function addon:GetTRP3ExtendedEquippedArmourItems()
    if type(self.GetTRP3ExtendedEquippedItems) ~= "function" then
        return nil
    end

    local items = self:GetTRP3ExtendedEquippedItems()
    if type(items) ~= "table" then
        return nil
    end

    for _, item in ipairs(items) do
        item.armourInfo = self:GetArmourInfoFromTooltips(item.tooltipLeft, item.tooltipRight)
    end

    return items
end

function addon:GetTRP3ExtendedEquippedArmourSummary()
    local items = self:GetTRP3ExtendedEquippedArmourItems()
    if type(items) ~= "table" then
        return nil
    end

    local summary = {
        pieces = {},
        totalRequirements = {},
        totalPenalties = {},
    }

    for _, item in ipairs(items) do
        local armourInfo = item.armourInfo or {}
        if self:IsKnownArmourPiece(armourInfo) then
            local pieceTotals = self:BuildArmourPieceTotals(armourInfo)
            
            local pieceEntry = {
                slotID = item.slotID,
                itemName = item.itemName or "Desconocido",
                pieceName = armourInfo.pieceKey or armourInfo.pieceName or "Desconocida",
                armourType = armourInfo.armourKey or armourInfo.armourType or "Desconocida",
                reinforcement = armourInfo.reinforcementKey or armourInfo.reinforcementType or "Ninguno",
                attributes = pieceTotals.attributes,
                properties = pieceTotals.properties,
                requirements = pieceTotals.requirements,
                penalties = pieceTotals.penalties,
            }

            table.insert(summary.pieces, pieceEntry)
            addNamedMap(summary.totalRequirements, pieceTotals.requirements)
            addNamedMap(summary.totalPenalties, pieceTotals.penalties)
        end
    end

    return summary
end

function addon:CheckArmourRequirementsMet()
    local summary = self:GetTRP3ExtendedEquippedArmourSummary()
    -- Si no hay resumen o no hay requisitos, técnicamente se cumplen
    if not summary or not summary.totalRequirements then
        return true
    end

    -- Obtenemos los atributos actuales del personaje (cargados en characterData)
    local charTalents = (self.characterData and self.characterData.talents) or {}
    for talName, requiredValue in pairs(summary.totalRequirements) do
        local currentValue = tonumber(charTalents[talName]) or 0
        if currentValue < requiredValue then
            return false -- No cumple con este requisito específico
        end
    end
    return true -- Cumple todos los requisitos sumados
end

function addon:GetArmourTotalPenalties()
    local summary = self:GetTRP3ExtendedEquippedArmourSummary()
    if not summary or not summary.totalPenalties then
        return {}
    end

    return summary.totalPenalties
end
