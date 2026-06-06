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


function GAC:FormatRollValue(rollValue, maxFaces)
    maxFaces = tonumber(maxFaces) or 20
    rollValue = tonumber(rollValue)

    if rollValue == 1 then
        return "|cffff4040" .. rollValue .. "|r Pifia"
    end

    local isCritical = false
    if maxFaces == 20 then
        local criticalThreshold = 20
        if self.characterData and self.characterData.positiveTraits and self.characterData.positiveTraits["bully"] then
            local bullyLvl = self.characterData.positiveTraits["bully"].level or 0
            if bullyLvl > 0 then
                criticalThreshold = 20 - bullyLvl
            end
        end
        if rollValue >= criticalThreshold then
            isCritical = true
        end
    else
        if rollValue == maxFaces then
            isCritical = true
        end
    end

    if isCritical then
        return "|cff40ff40" .. rollValue .. "|r Critico"
    end

    return "|cffffffff" .. rollValue .. "|r"
end

function GAC:GetCharacterRaceString()
    if not self.characterData or not self.characterData.race1 then
        return self.GetActiveTRP3ProfileRace and self:GetActiveTRP3ProfileRace() or "Desconocida"
    end
    
    local r1 = self:_(self.characterData.race1) or self.characterData.race1
    if self.characterData.race2 then
        local r2 = self:_(self.characterData.race2) or self.characterData.race2
        return "Mestizo (" .. r1 .. " - " .. r2 .. ")"
    end
    
    return r1
end

function GAC:UpdateTraitLevel(traitName, newLevel, selectedTalent)
    if not self.characterData then return end
    
    local def = nil
    for _, t in ipairs(self.PositiveTraits or {}) do
        if t.name == traitName then def = t; break end
    end
    if not def then return end

    self.characterData.positiveTraits = self.characterData.positiveTraits or {}
    local oldData = self.characterData.positiveTraits[traitName]
    local oldLevel = oldData and oldData.level or 0
    local oldTalent = oldData and oldData.selectedTalent

    -- Revert old modifiers
    if oldLevel > 0 and def.modifiers and def.modifiers[oldLevel] then
        for k, v in pairs(def.modifiers[oldLevel]) do
            local key = (k == "_selected") and oldTalent or k
            if key then
                self.characterData.talents[key] = (self.characterData.talents[key] or 0) - v
            end
        end
    end

    -- Apply new modifiers
    if newLevel > 0 and def.modifiers and def.modifiers[newLevel] then
        for k, v in pairs(def.modifiers[newLevel]) do
            local key = (k == "_selected") and selectedTalent or k
            if key then
                self.characterData.talents[key] = (self.characterData.talents[key] or 0) + v
            end
        end
    end

    -- Save new data
    if newLevel == 0 then
        self.characterData.positiveTraits[traitName] = nil
    else
        self.characterData.positiveTraits[traitName] = {
            level = newLevel,
            selectedTalent = selectedTalent
        }
    end
end
