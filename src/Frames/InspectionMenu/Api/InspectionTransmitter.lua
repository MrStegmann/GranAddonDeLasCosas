local _, GAC = ...

GAC.Transmitter:AddEvent(GAC.Enums.Events.INSPECT_REQ, function(targetName)
    if not targetName or targetName == "" then return end
    C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, GAC.Enums.Events.INSPECT_REQ, "WHISPER", targetName)
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

GAC.Transmitter:AddEvent(GAC.Enums.Events.INSP_END, function(targetName)
    C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, GAC.Enums.Events.INSP_END, "WHISPER", targetName)
end)

function GAC:SendInspectionData(requesterName)
    if not requesterName or requesterName == "" then return end
    if not self.characterData then return end
    
    local progress = self.characterData.progress or {}
    local currentLevel = progress.level or 1
    local category = progress.category or "normal"
    local race = self:GetActiveTRP3ProfileRace() or "Desconocida"
    local class = self:GetActiveTRP3ProfileClass() or "Desconocida"
    
    local levelEntry = self:GetLevelEntry(category, currentLevel)
    local baseHealth = levelEntry and levelEntry.maxHealth or 10
    local attributes = self.characterData.attributes or {}
    local constitution = attributes["constitution"] or 0
    local maxHealth = baseHealth + constitution
    if maxHealth < 1 then maxHealth = 1 end
    
    local currentHealth = self.characterData.currentHealth or maxHealth
    local currentShield = self.characterData.currentShield or 0
    local currentExp = progress.currentExperience or 0
    local maxExp = levelEntry and levelEntry.expToLevel or 0
    
    local infoPayload = string.format("%s:%s:%s:%s:%s:%s:%s:%s", tostring(currentLevel), tostring(category), tostring(race), tostring(class), tostring(maxHealth), tostring(currentShield), tostring(currentExp), tostring(maxExp))
    self.Transmitter:Trigger(GAC.Enums.Events.INSP_INFO, requesterName, infoPayload)
    
    local attStr = ""
    for k, v in pairs(attributes) do
        attStr = attStr .. tostring(k) .. "=" .. tostring(v) .. ";"
    end
    if attStr ~= "" then
        self.Transmitter:Trigger(GAC.Enums.Events.INSP_ATT, requesterName, attStr)
    end
    
    local talents = self.characterData.talents or {}
    local talStr = ""
    for k, v in pairs(talents) do
        talStr = talStr .. tostring(k) .. "=" .. tostring(v) .. ";"
    end
    if talStr ~= "" then
        self.Transmitter:Trigger(GAC.Enums.Events.INSP_TAL, requesterName, talStr)
    end
    
    local advantages = self.characterData.characteristics and self.characterData.characteristics.activeAdvantages or {}
    local advStr = ""
    for k, v in pairs(advantages) do
        advStr = advStr .. tostring(k) .. "=" .. tostring(v) .. ";"
    end
    if advStr ~= "" then
        self.Transmitter:Trigger(GAC.Enums.Events.INSP_ADV, requesterName, advStr)
    end
    
    local disadvantages = self.characterData.characteristics and self.characterData.characteristics.activeDisadvantages or {}
    local disStr = ""
    for k, v in pairs(disadvantages) do
        disStr = disStr .. tostring(k) .. "=" .. tostring(v) .. ";"
    end
    if disStr ~= "" then
        self.Transmitter:Trigger(GAC.Enums.Events.INSP_DIS, requesterName, disStr)
    end
    
    local special = self.characterData.characteristics and self.characterData.characteristics.activeSpecial or {}
    local spcStr = ""
    for _, v in ipairs(special) do
        spcStr = spcStr .. tostring(v) .. ";"
    end
    if spcStr ~= "" then
        self.Transmitter:Trigger(GAC.Enums.Events.INSP_SPC, requesterName, spcStr)
    end
    
    local chars = self.characterData.characteristics or {}
    local r1 = chars.race1 or "Ninguna"
    local r2 = chars.race2 or "Ninguna"
    local worgen = chars.worgenCurse and "1" or "0"
    self.Transmitter:Trigger(GAC.Enums.Events.INSP_RAC, requesterName, string.format("%s:%s:%s", tostring(r1), tostring(r2), worgen))
    
    self.Transmitter:Trigger(GAC.Enums.Events.INSP_END, requesterName)
end

GAC.Transmitter:AddEvent(GAC.Enums.Events.ADD_EXP, function(targetName, amount)
    if not targetName or targetName == "" then return end
    C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX, GAC.Enums.Events.ADD_EXP .. ":" .. tostring(amount), "WHISPER", targetName)
end)
