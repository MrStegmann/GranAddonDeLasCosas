local _, GAC = ...

GAC.ATTACK_TALENT_OPTIONS = {
    { label = "Combate Ágil", key = "agileCombat" },
    { label = "Precisión", key = "precision" },
    { label = "Brutalidad", key = "brutality" },
    { label = "Acrobacias", key = "acrobatics" },
    { label = "Combate con armas de 1 mano", key = "oneHandedCombat" },
    { label = "Combate con armas de 2 manos", key = "twoHandedCombat" },
    { label = "Arcano", key = "arcane" },
    { label = "Vil", key = "fel" },
    { label = "Naturaleza", key = "nature" },
    { label = "Sombras", key = "shadow" },
    { label = "Nigromancia", key = "necromancy" },
    { label = "Fe", key = "faith" },
    { label = "Conexión Elemental", key = "elementalConnection" },
    { label = "Chi", key = "chi" },
}

local ROLL_CLICK_GUARD_SECONDS = 0.5
local lastActionAt = 0

function GAC:CanTriggerRoll()
    local now = (GetTimePreciseSec and GetTimePreciseSec()) or GetTime()
    local lastAction = lastActionAt or 0

    if (now - lastAction) < ROLL_CLICK_GUARD_SECONDS then
        return false
    end
    
    lastActionAt = now
    return true
end

function GAC:BuildRandomRollPattern()
    local pattern = RANDOM_ROLL_RESULT or "%s rolls %d (%d-%d)"
    pattern = pattern:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
    pattern = pattern:gsub("%%%%s", "(.+)")
    pattern = pattern:gsub("%%%%d", "(%%d+)")
    return "^" .. pattern .. "$"
end

function GAC:StripColorCodes(text)
    if type(text) ~= "string" then
        return text
    end

    local clean = text:gsub("|c%x%x%x%x%x%x%x%x", "")
    clean = clean:gsub("|r", "")
    return clean
end


function GAC:IsPlayerRoll(rollerName)
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

function GAC:FormatRollValue(rollValue)
    if rollValue == 1 then
        return "|cffff4040" .. rollValue .. "|r Pifia"
    end

    if rollValue == 20 then
        return "|cff40ff40" .. rollValue .. "|r Critico"
    end

    return "|cffffffff" .. rollValue .. "|r"
end


