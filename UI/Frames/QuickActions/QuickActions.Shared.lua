local addonName, addon = ...

addon.quickActions = addon.quickActions or {}
local qa = addon.quickActions

qa.ROLL_CLICK_GUARD_SECONDS = 0.5

qa.ATTACK_TALENT_OPTIONS = {
    { label = "Combate Ágil", key = "Combate Ágil" },
    { label = "Precisión", key = "Precisión" },
    { label = "Brutalidad", key = "Brutalidad" },
    { label = "Acrobacias", key = "Acrobacias" },
    { label = "Combate con armas de 1 mano", key = "Combate a 1 mano" },
    { label = "Combate con armas de 2 manos", key = "Combate a 2 manos" },
    { label = "Arcano", key = "Arcano" },
    { label = "Vil", key = "Vil" },
    { label = "Naturaleza", key = "Naturaleza" },
    { label = "Sombras", key = "Sombras" },
    { label = "Nigromancia", key = "Nigromancia" },
    { label = "Fe", key = "Fe" },
    { label = "Conexión Elemental", key = "Conexión Elemental" },
    { label = "Chi", key = "Chi" },
}

function qa.buildRandomRollPattern()
    local pattern = RANDOM_ROLL_RESULT or "%s rolls %d (%d-%d)"
    pattern = pattern:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
    pattern = pattern:gsub("%%%%s", "(.+)")
    pattern = pattern:gsub("%%%%d", "(%%d+)")
    return "^" .. pattern .. "$"
end

function qa.isPlayerRoll(rollerName)
    if not rollerName then
        return false
    end

    local playerName = UnitName("player")
    if not playerName then
        return false
    end

    if rollerName == playerName then
        return true
    end

    return rollerName:match("^" .. playerName .. "%-") ~= nil
end

function qa.stripColorCodes(text)
    if type(text) ~= "string" then
        return text
    end

    local clean = text:gsub("|c%x%x%x%x%x%x%x%x", "")
    clean = clean:gsub("|r", "")
    return clean
end

function qa.formatRollValue(rollValue)
    if rollValue == 1 then
        return "|cffff4040" .. rollValue .. "|r Pifia"
    end

    if rollValue == 20 then
        return "|cff40ff40" .. rollValue .. "|r Critico"
    end

    return "|cffffffff" .. rollValue .. "|r"
end

function qa.formatInitiativeRollValue(rollValue)
    if rollValue == 1 then
        return "|cffff4040" .. rollValue .. "|r Pifia"
    end

    if rollValue == 100 then
        return "|cff40ff40" .. rollValue .. "|r Crítico"
    end

    return tostring(rollValue)
end

function qa.ensureQuickFramePosition()
    if not addon.characterData or not addon.characterData.ui then
        return
    end

    addon.characterData.ui.quickFrame = addon.characterData.ui.quickFrame or {}

    local position = addon.characterData.ui.quickFrame
    if position.anchor == nil then
        position.anchor = "CENTER"
        position.relativeAnchor = "CENTER"
        position.x = -260
        position.y = -120
    end
end

function qa.canTriggerRoll()
    local now = (GetTimePreciseSec and GetTimePreciseSec()) or GetTime()
    local lastAction = addon.lastRollActionAt or 0

    if (now - lastAction) < qa.ROLL_CLICK_GUARD_SECONDS then
        return false
    end

    addon.lastRollActionAt = now
    return true
end

function qa.normalizeModifierValue(value)
    if type(value) ~= "number" then
        return 0
    end

    return math.floor(value)
end

function qa.buildModifierSegment(hasModifier, modifierValue)
    if not hasModifier then
        return ""
    end

    return " + Mod (" .. modifierValue .. ")"
end

function qa.formatXPBarText(currentXP, maxXP)
    local safeCurrentXP = math.max(tonumber(currentXP) or 0, 0)
    local safeMaxXP = math.max(tonumber(maxXP) or 0, 0)
    local percentage = 0

    if safeMaxXP > 0 then
        percentage = (safeCurrentXP / safeMaxXP) * 100
    end

    return string.format("EXP %d / %d (%.1f%%)", safeCurrentXP, safeMaxXP, percentage)
end

