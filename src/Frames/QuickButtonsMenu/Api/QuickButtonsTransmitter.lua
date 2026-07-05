local _, GAC = ...

GAC.Transmitter:AddEvent(GAC.Enums.Events.ROLL, function(message)
    if not message or message == "" then return end
    local payload = GAC.Enums.Events.ROLL .. ":" .. message
    
    -- Mandar a grupo/banda
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, payload, "INSTANCE_CHAT")
    elseif IsInRaid() then
        C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, payload, "RAID")
    elseif IsInGroup() then
        C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, payload, "PARTY")
    end
    
    -- Mandarlo también por susurro a todos los que nos tienen seleccionados
    if GAC.requestersCache then
        local now = GetTime()
        for requester, timestamp in pairs(GAC.requestersCache) do
            if now - timestamp < 300 then
                C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, payload, "WHISPER", requester)
            else
                GAC.requestersCache[requester] = nil
            end
        end
    end
end)

GAC.Transmitter:AddEvent(GAC.Enums.Events.ARMOR_HIT, function(targetName, zoneId, damageType, totalDamage)
    local payload = GAC.Enums.Events.ARMOR_HIT .. ":" .. tostring(zoneId) .. ":" .. tostring(damageType) .. ":" .. tostring(totalDamage)
    C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX or "GAC_Sync", payload, "WHISPER", targetName)
end)

GAC.Transmitter:AddEvent(GAC.Enums.Events.MSG_ARMOR, function(targetName, msg)
    C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX or "GAC_Sync", GAC.Enums.Events.MSG_ARMOR .. ":" .. msg, "WHISPER", targetName)
end)

GAC.Transmitter:AddEvent(GAC.Enums.Events.MODIFY_LIFE, function(amount)
    if type(amount) ~= "number" or amount == 0 then return end
    if not GAC.playerCharacter then return end
    
    if amount > 0 then
        GAC.playerCharacter:Heal(amount)
    else
        GAC.playerCharacter:TakeDamage(-amount)
    end
    
    -- Forzamos la actualización del marco de jugador
    if PlayerFrameHealthBar then
        UnitFrameHealthBar_Update(PlayerFrameHealthBar, "player")
        if TextStatusBar_UpdateTextString then
            TextStatusBar_UpdateTextString(PlayerFrameHealthBar)
        end
    end
    
    -- Notificar a todos los que nos tengan en target (han hecho REQ en los últimos 5 mins)
    if GAC.Transmitter then
        GAC.Transmitter:Trigger(GAC.Enums.Events.RES, nil, true)
    end
end)

GAC.Transmitter:AddEvent(GAC.Enums.Events.MODIFY_SHIELD, function(amount)
    if type(amount) ~= "number" or amount == 0 then return end
    if not GAC.playerCharacter then return end
    
    local currentShield = GAC.playerCharacter:GetShieldPoints().current
    GAC.playerCharacter:SetShieldPoints(currentShield + amount)
    
    if PlayerFrameHealthBar then
        UnitFrameHealthBar_Update(PlayerFrameHealthBar, "player")
        if TextStatusBar_UpdateTextString then
            TextStatusBar_UpdateTextString(PlayerFrameHealthBar)
        end
    end
    
    if GAC.Transmitter then
        GAC.Transmitter:Trigger(GAC.Enums.Events.RES, nil, true)
    end
end)
