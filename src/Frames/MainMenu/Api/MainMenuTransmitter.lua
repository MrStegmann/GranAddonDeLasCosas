local _, GAC = ...

GAC.Transmitter:AddEvent(GAC.Enums.Events.REQ, function(targetName, isGroup)
    if isGroup then
        if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
            C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, GAC.Enums.Events.REQ, "INSTANCE_CHAT")
        elseif IsInRaid() then
            C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, GAC.Enums.Events.REQ, "RAID")
        elseif IsInGroup() then
            C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, GAC.Enums.Events.REQ, "PARTY")
        end
    else
        if not targetName or targetName == "" then return end
        C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, GAC.Enums.Events.REQ, "WHISPER", targetName)
    end
end)

GAC.Transmitter:AddEvent(GAC.Enums.Events.RES, function(targetName, isBroadcast)
    if not GAC.playerCharacter then return end
    
    local currentLevel = GAC.playerCharacter:GetLevel()
    local category = GAC.playerCharacter:GetCategory()
    
    local hp = GAC.playerCharacter:GetHealthPoints()
    local sp = GAC.playerCharacter:GetShieldPoints()
    
    local maxHealth = hp.max
    local currentHealth = hp.current
    local currentShield = sp and sp.current or 0
    
    local payload = string.format("%s:%s:%s:%s:%s:%s:%s", GAC.Enums.Events.RES, UnitGUID("player") or "UNKNOWN", tostring(currentLevel), tostring(category), tostring(maxHealth), tostring(currentHealth), tostring(currentShield))
    
    if isBroadcast then
        if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
            C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, payload, "INSTANCE_CHAT")
        elseif IsInRaid() then
            C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, payload, "RAID")
        elseif IsInGroup() then
            C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, payload, "PARTY")
        end

        if not GAC.requestersCache then return end
        local now = GetTime()
        for requester, timestamp in pairs(GAC.requestersCache) do
            if now - timestamp < 300 then
                C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, payload, "WHISPER", requester)
            else
                GAC.requestersCache[requester] = nil
            end
        end
    else
        if not targetName or targetName == "" then return end
        C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, payload, "WHISPER", targetName)
    end
end)
