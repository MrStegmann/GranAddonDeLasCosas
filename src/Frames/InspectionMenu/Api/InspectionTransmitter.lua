local _, GAC = ...

GAC.Transmitter:AddEvent(GAC.Enums.Events.INSPECT_REQ, function(targetName)
    if not targetName or targetName == "" then return end
    
    local targetGUID = UnitGUID("target") or "UNKNOWN"
    local cachedVersion = 0
    if GAC.inspectedPlayersCache and GAC.inspectedPlayersCache[targetGUID] then
        cachedVersion = GAC.inspectedPlayersCache[targetGUID]:GetVersion() or 0
    end
    
    local payload = string.format("%s:%s", tostring(cachedVersion), tostring(targetGUID))
    C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, GAC.Enums.Events.INSPECT_REQ .. ":" .. payload, "WHISPER", targetName)
end)

GAC.Transmitter:AddEvent(GAC.Enums.Events.INSP_INFO, function(targetName, payload)
    C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, GAC.Enums.Events.INSP_INFO .. ":" .. payload, "WHISPER", targetName)
end)

GAC.Transmitter:AddEvent(GAC.Enums.Events.INSP_ATT, function(targetName, payload)
    C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, GAC.Enums.Events.INSP_ATT .. ":" .. payload, "WHISPER", targetName)
end)

GAC.Transmitter:AddEvent(GAC.Enums.Events.INSP_TAL, function(targetName, payload)
    C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, GAC.Enums.Events.INSP_TAL .. ":" .. payload, "WHISPER", targetName)
end)

GAC.Transmitter:AddEvent(GAC.Enums.Events.INSP_ADV, function(targetName, payload)
    C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, GAC.Enums.Events.INSP_ADV .. ":" .. payload, "WHISPER", targetName)
end)

GAC.Transmitter:AddEvent(GAC.Enums.Events.INSP_DIS, function(targetName, payload)
    C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, GAC.Enums.Events.INSP_DIS .. ":" .. payload, "WHISPER", targetName)
end)

GAC.Transmitter:AddEvent(GAC.Enums.Events.INSP_SPC, function(targetName, payload)
    C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, GAC.Enums.Events.INSP_SPC .. ":" .. payload, "WHISPER", targetName)
end)

GAC.Transmitter:AddEvent(GAC.Enums.Events.INSP_RAC, function(targetName, payload)
    C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, GAC.Enums.Events.INSP_RAC .. ":" .. payload, "WHISPER", targetName)
end)

GAC.Transmitter:AddEvent(GAC.Enums.Events.INSP_EQP, function(targetName, payload)
    C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, GAC.Enums.Events.INSP_EQP .. ":" .. payload, "WHISPER", targetName)
end)

GAC.Transmitter:AddEvent(GAC.Enums.Events.INSP_VOL, function(targetName, payload)
    C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, GAC.Enums.Events.INSP_VOL .. ":" .. payload, "WHISPER", targetName)
end)

GAC.Transmitter:AddEvent(GAC.Enums.Events.INSP_END, function(targetName, payload)
    C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, GAC.Enums.Events.INSP_END .. ":" .. payload, "WHISPER", targetName)
end)

function GAC:SendInspectionData(requesterName, requestedVersion)
    if not requesterName or requesterName == "" then return end
    if not self.playerCharacter then return end
    
    local myVersion = self.playerCharacter:GetVersion() or 1
    requestedVersion = tonumber(requestedVersion) or 0
    
    local hp = self.playerCharacter:GetHealthPoints()
    local sp = self.playerCharacter:GetShieldPoints()
    local mp = self.playerCharacter:GetManaPoints()
    local spp = self.playerCharacter:GetSpiritPoints()
    local exp = self.playerCharacter:GetExperience()
    
    local volPayload = string.format("%s:%d:%d:%d:%d:%d", UnitGUID("player") or "UNKNOWN", hp.current, sp and sp.current or 0, mp and mp.current or 0, spp and spp.current or 0, exp and exp.current or 0)
    
    if requestedVersion >= myVersion then
        self.Transmitter:Trigger(GAC.Enums.Events.INSP_VOL, requesterName, volPayload)
        self.Transmitter:Trigger(GAC.Enums.Events.INSP_END, requesterName, tostring(myVersion))
        return
    end
    
    local currentLevel = self.playerCharacter:GetLevel()
    local category = self.playerCharacter:GetCategory()
    local races = self.playerCharacter:GetRace()
    local class = self:GetActiveTRP3ProfileClass() or "Desconocida"
    
    local maxHealth = hp.max
    local maxExp = exp.max
    
    local delay = 0
    local function sendEvent(event, payload)
        C_Timer.After(delay, function()
            self.Transmitter:Trigger(event, requesterName, payload)
        end)
        delay = delay + 0.1
    end

    local infoPayload = string.format("%s:%d:%s:%s:%d:%d:%d", UnitGUID("player") or "UNKNOWN", currentLevel, category, class, maxHealth, maxExp, myVersion)
    sendEvent(GAC.Enums.Events.INSP_INFO, infoPayload)
    
    local attributes = self.playerCharacter:GetAttributes() or {}
    local attStr = ""
    for k, v in pairs(attributes) do
        if tonumber(v) ~= 0 then
            local entry = tostring(k) .. "=" .. tostring(v) .. ";"
            if #attStr + #entry > 200 then
                sendEvent(GAC.Enums.Events.INSP_ATT, attStr)
                attStr = ""
            end
            attStr = attStr .. entry
        end
    end
    if attStr ~= "" then
        sendEvent(GAC.Enums.Events.INSP_ATT, attStr)
    end
    
    local talents = self.playerCharacter:GetTalents() or {}
    local talStr = ""
    for k, v in pairs(talents) do
        if tonumber(v) ~= 0 then
            local entry = tostring(k) .. "=" .. tostring(v) .. ";"
            if #talStr + #entry > 200 then
                sendEvent(GAC.Enums.Events.INSP_TAL, talStr)
                talStr = ""
            end
            talStr = talStr .. entry
        end
    end
    if talStr ~= "" then
        sendEvent(GAC.Enums.Events.INSP_TAL, talStr)
    end
    
    local positiveTraits = self.playerCharacter:GetPositiveTraits() or {}
    local advStr = ""
    for k, v in pairs(positiveTraits) do
        if tonumber(v) ~= 0 then
            local entry = tostring(k) .. "=" .. tostring(v) .. ";"
            if #advStr + #entry > 200 then
                sendEvent(GAC.Enums.Events.INSP_ADV, advStr)
                advStr = ""
            end
            advStr = advStr .. entry
        end
    end
    if advStr ~= "" then
        sendEvent(GAC.Enums.Events.INSP_ADV, advStr)
    end
    
    local negativeTraits = self.playerCharacter:GetNegativeTraits() or {}
    local disStr = ""
    for k, v in pairs(negativeTraits) do
        if tonumber(v) ~= 0 then
            local entry = tostring(k) .. "=" .. tostring(v) .. ";"
            if #disStr + #entry > 200 then
                sendEvent(GAC.Enums.Events.INSP_DIS, disStr)
                disStr = ""
            end
            disStr = disStr .. entry
        end
    end
    if disStr ~= "" then
        sendEvent(GAC.Enums.Events.INSP_DIS, disStr)
    end
    
    local special = self.playerCharacter._data.special or {}
    local spcStr = ""
    for _, v in ipairs(special) do
        local entry = tostring(v) .. ";"
        if #spcStr + #entry > 200 then
            sendEvent(GAC.Enums.Events.INSP_SPC, spcStr)
            spcStr = ""
        end
        spcStr = spcStr .. entry
    end
    if spcStr ~= "" then
        sendEvent(GAC.Enums.Events.INSP_SPC, spcStr)
    end
    
    local r1 = races[1] or "Ninguna"
    local r2 = races[2] or "Ninguna"
    local worgen = self.playerCharacter:GetWorgenCurse() and "1" or "0"
    sendEvent(GAC.Enums.Events.INSP_RAC, string.format("%s:%s:%s", tostring(r1), tostring(r2), worgen))
    
    -- Enviar equipamiento
    local equipped = self.playerCharacter:GetEquippedItems() or {}
    local eqpStr = ""
    for slot, item in pairs(equipped) do
        if type(item) == "table" and item.id then
            local entry = tostring(slot) .. "=" .. tostring(item.id) .. ";"
            if #eqpStr + #entry > 200 then
                sendEvent(GAC.Enums.Events.INSP_EQP, eqpStr)
                eqpStr = ""
            end
            eqpStr = eqpStr .. entry
        end
    end
    if eqpStr ~= "" then
        sendEvent(GAC.Enums.Events.INSP_EQP, eqpStr)
    end
    
    sendEvent(GAC.Enums.Events.INSP_VOL, volPayload)
    sendEvent(GAC.Enums.Events.INSP_END, tostring(myVersion))
end

GAC.Transmitter:AddEvent(GAC.Enums.Events.ADD_EXP, function(targetName, amount)
    if not targetName or targetName == "" then return end
    C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, GAC.Enums.Events.ADD_EXP .. ":" .. tostring(amount), "WHISPER", targetName)
end)
