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
    local progress = GAC.characterData and GAC.characterData.progress or {}
    local currentLevel = progress.level or 1
    local category = progress.category or "normal"
    
    local levelEntry = GAC:GetLevelEntry(category, currentLevel)
    local baseHealth = levelEntry and levelEntry.maxHealth or 10
    
    local attributes = GAC.characterData and GAC.characterData.attributes or {}
    local constitution = attributes["constitution"] or 0
    local maxHealth = baseHealth + constitution
    if maxHealth < 1 then maxHealth = 1 end
    
    local currentHealth = GAC.characterData and GAC.characterData.currentHealth
    if currentHealth == nil then currentHealth = maxHealth end
    
    local currentShield = GAC.characterData and GAC.characterData.currentShield or 0
    
    local payload = string.format("%s:%s:%s:%s:%s:%s", GAC.Enums.Events.RES, tostring(currentLevel), tostring(category), tostring(maxHealth), tostring(currentHealth), tostring(currentShield))
    
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
