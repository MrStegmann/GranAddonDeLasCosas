local _, addon = ...

local ARMOUR_TYPE_ALIASES = {
    ["tela"] = "cloth",
    ["telas"] = "cloth",
    ["cuero"] = "leather",
    ["cueros"] = "leather",
    ["malla"] = "mail",
    ["mallas"] = "mail",
    ["placa"] = "plate",
    ["placas"] = "plate",
}

local ARMOUR_PIECE_ALIASES = {
    ["cabeza"] = "head",
    ["pecho"] = "chest",
    ["guantes"] = "hands",
    ["piernas"] = "legs",
}

local ARMOUR_PIECE_TYPE_FALLBACK_KEYS = {
    cloth = { "cloth" },
    leather = { "leather" },
    mail = { "mail" },
    plate = { "plate" },
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

    -- Primero intentamos usar el mapeo interno (localizado a interno)
    local internalKey = addon:GetInternalKey(clean)
    if internalKey and data[internalKey] ~= nil then
        return internalKey
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

    local armours = data.armors
    local pieces = data.pieces
    local reinforcements = data.reinforcements

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
    ["requirements"] = true,
    ["penalties"] = true,
}

local function addNamedValue(total, name, value)
    local numericValue = tonumber(value)
    local internalKey = addon:GetInternalKey(name)
    if type(total) == "table" and type(internalKey) == "string" and numericValue then
        total[internalKey] = (total[internalKey] or 0) + numericValue
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

    addNamedValuesFromEntries(totals.requirements, data.requirements)
    addNamedValuesFromEntries(totals.penalties, data.penalties)
end

local function addArmourAttributes(totals, data)
    if type(totals) ~= "table" or type(data) ~= "table" then
        return
    end

    for name, value in pairs(data) do
        local internalKey = addon:GetInternalKey(name)
        if not SUMMED_ARMOUR_ATTRIBUTE_EXCLUSIONS[internalKey] and type(value) ~= "table" then
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
            
            local durMax = tonumber(self:GetTRP3ExtendedItemVariable(item.slotID, "dur_max")) or tonumber(pieceTotals.attributes.durability) or 0
            local durCur = tonumber(self:GetTRP3ExtendedItemVariable(item.slotID, "dur_cur"))
            if durCur == nil then durCur = durMax end

            local pieceEntry = {
                slotID = item.slotID,
                itemID = item.itemID,
                itemName = item.itemName or "Desconocido",
                pieceName = armourInfo.pieceKey or armourInfo.pieceName or "unknown",
                armourType = armourInfo.armourKey or armourInfo.armourType or "unknown",
                reinforcement = armourInfo.reinforcementKey or armourInfo.reinforcementType or "none",
                durabilityCurrent = durCur,
                durabilityMax = durMax,
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

--[[
    Actualiza la durabilidad de un objeto en su descripción de TRP3 Extended.
    slotID: Slot del objeto.
    itemID: ID de la clase del objeto.
    maxDurability: El valor máximo calculado (Atributos + Pieza + Refuerzos).
    delta: Cantidad a sumar o restar.
]]
function addon:UpdateItemDurability(slotID, itemID, maxDurability, delta)
    if not slotID or not itemID or not maxDurability or maxDurability <= 0 then return end

    -- Obtener valores de las variables temporales (VA) para persistencia por instancia.
    local currentVal = tonumber(self:GetTRP3ExtendedItemVariable(slotID, "dur_cur"))
    local maxVal = tonumber(maxDurability)
    
    -- Si no existe el valor temporal, inicializar al máximo calculado.
    if not currentVal then
        currentVal = maxVal
    end

    -- Calcular nuevo valor con límites (clamping)
    local newVal = currentVal + delta
    if newVal < 0 then newVal = 0 end
    if newVal > maxVal then newVal = maxVal end

    -- Guardar en las variables temporales del objeto en el slot
    self:SetTRP3ExtendedItemVariable(slotID, "dur_cur", newVal)
    self:SetTRP3ExtendedItemVariable(slotID, "dur_max", maxVal)

    -- Obtener el texto de la descripción (BA.DE) para modificarla visualmente
    local _, _, _, currentDescription = self:GetTRP3ExtendedItemTooltipFields(itemID)
    currentDescription = currentDescription or ""

    local durabilityLabel = self:GetLocalizedText("durability")
    local pattern = durabilityLabel .. ":%s*%d+/%d+"
    local newDurabilityText = string.format("%s: %d/%d", durabilityLabel, newVal, maxVal)
    local finalDescription

    if currentDescription:match(pattern) then
        finalDescription = currentDescription:gsub(pattern, newDurabilityText)
    else
        finalDescription = (currentDescription ~= "" and (currentDescription .. "\n") or "") .. newDurabilityText
    end

    -- Actualizar el campo BA.DE (Tooltip Description) de la clase del objeto
    self:SetTRP3ExtendedItemTooltipDescription(itemID, finalDescription)

    -- Actualizar el muñeco de durabilidad en el HUD
    if self.UpdateQuickDurabilityDoll then
        self:UpdateQuickDurabilityDoll()
    end

    -- Mostrar mensaje por chat sobre la modificación de durabilidad
    local itemName = self:GetTRP3ExtendedItemTooltipFields(itemID) or "Armadura"
    local action = (delta > 0) and "gana" or "pierde"
    print(string.format("%s %s 1 de Durabilidad. Estado actual %d/%d", itemName, action, newVal, maxVal))
end
