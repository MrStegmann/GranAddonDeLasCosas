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

function GAC:GetRacialTalentModifier(talentKey)
    if not self.characterData or not self.characterData.characteristics then return 0 end
    local chars = self.characterData.characteristics
    local mod = 0
    
    if chars.activeAdvantages and chars.activeAdvantages[talentKey] then
        mod = mod + chars.activeAdvantages[talentKey]
    end
    if chars.activeDisadvantages and chars.activeDisadvantages[talentKey] then
        mod = mod + chars.activeDisadvantages[talentKey]
    end
    
    if chars.adaptLocked and chars.adaptTarget == talentKey and chars.activeAdvantages and chars.activeAdvantages["adaptability"] then
        mod = mod + chars.activeAdvantages["adaptability"]
    end
    if chars.perfLocked and chars.perfTarget == talentKey and chars.activeAdvantages and chars.activeAdvantages["perfectionism"] then
        mod = mod + chars.activeAdvantages["perfectionism"]
    end
    
    return mod
end

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

function GAC:ErrorHandler(errorMessage)
    local file, line, msg = string.match(tostring(errorMessage), "(.-):(%d+):%s*(.*)")
    
    if file and line then
        local filename = string.match(file, "[^/\\]+$") or file
        print(string.format("|cffff0000[GAC]|r |cffff8000Error detectado:|r Archivo |cffffff00%s|r, línea |cffffff00%s|r.", filename, line))
        if msg then
            print("|cffff0000[GAC]|r Detalle: " .. msg)
        end
    else
        print("|cffff0000[GAC]|r |cffff8000Error detectado:|r " .. tostring(errorMessage))
    end
    
    -- Pass the error to the standard UI error handler (e.g. BugSack, Swatter, or default WoW error frame)
    local handler = geterrorhandler()
    if handler then
        handler(errorMessage)
    end
end

function GAC:SafeCall(func, ...)
    if type(func) ~= "function" then return end
    return xpcall(func, function(err) GAC:ErrorHandler(err) end, ...)
end

function GAC:SetClampedWithVisiblePixels(frame, visiblePixels)
    visiblePixels = visiblePixels or 20
    frame:SetClampedToScreen(true)
    frame:HookScript("OnSizeChanged", function(self, width, height)
        if width > 0 and height > 0 then
            self:SetClampRectInsets(width - visiblePixels, -(width - visiblePixels), -(height - visiblePixels), height - visiblePixels)
        end
    end)
    local w, h = frame:GetSize()
    if w and h and w > 0 and h > 0 then
        frame:SetClampRectInsets(w - visiblePixels, -(w - visiblePixels), -(h - visiblePixels), h - visiblePixels)
    end
end
