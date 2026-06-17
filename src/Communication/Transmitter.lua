local _, GAC = ...

GAC.COMM_PREFIX = "GAC_Sync"

function GAC:InitializeTransmitter()
    -- Solo nos aseguramos de que el prefijo esté registrado
    C_ChatInfo.RegisterAddonMessagePrefix(self.COMM_PREFIX)
end

function GAC:RequestTargetData(targetName)
    if not targetName or targetName == "" then return end
    
    -- Enviamos una solicitud al objetivo por susurro invisible
    C_ChatInfo.SendAddonMessage(self.COMM_PREFIX, "REQ", "WHISPER", targetName)
end

function GAC:RequestGroupData()
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        C_ChatInfo.SendAddonMessage(self.COMM_PREFIX, "REQ", "INSTANCE_CHAT")
    elseif IsInRaid() then
        C_ChatInfo.SendAddonMessage(self.COMM_PREFIX, "REQ", "RAID")
    elseif IsInGroup() then
        C_ChatInfo.SendAddonMessage(self.COMM_PREFIX, "REQ", "PARTY")
    end
end

function GAC:SendPlayerData(requesterName)
    if not requesterName or requesterName == "" then return end
    
    local progress = self.characterData and self.characterData.progress or {}
    local currentLevel = progress.level or 1
    local category = progress.category or "normal"
    
    -- Calculamos la salud usando la lógica que ya teníamos
    local levelEntry = self:GetLevelEntry(category, currentLevel)
    local baseHealth = levelEntry and levelEntry.maxHealth or 10
    
    local attributes = self.characterData and self.characterData.attributes or {}
    local constitution = attributes["constitution"] or 0
    local maxHealth = baseHealth + constitution
    if maxHealth < 1 then maxHealth = 1 end
    
    local currentHealth = self.characterData and self.characterData.currentHealth
    if currentHealth == nil then currentHealth = maxHealth end
    
    local currentShield = self.characterData and self.characterData.currentShield or 0
    
    -- Creamos el paquete serializado. Formato: RES:nivel:categoria:vidaMaxima:vidaActual:escudoActual
    local payload = string.format("RES:%s:%s:%s:%s:%s", tostring(currentLevel), tostring(category), tostring(maxHealth), tostring(currentHealth), tostring(currentShield))
    
    C_ChatInfo.SendAddonMessage(self.COMM_PREFIX, payload, "WHISPER", requesterName)
end

function GAC:BroadcastPlayerData()
    local progress = self.characterData and self.characterData.progress or {}
    local currentLevel = progress.level or 1
    local category = progress.category or "normal"
    local levelEntry = self:GetLevelEntry(category, currentLevel)
    local baseHealth = levelEntry and levelEntry.maxHealth or 10
    local attributes = self.characterData and self.characterData.attributes or {}
    local constitution = attributes["constitution"] or 0
    local maxHealth = baseHealth + constitution
    if maxHealth < 1 then maxHealth = 1 end
    
    local currentHealth = self.characterData and self.characterData.currentHealth
    if currentHealth == nil then currentHealth = maxHealth end
    local currentShield = self.characterData and self.characterData.currentShield or 0
    
    local payload = string.format("RES:%s:%s:%s:%s:%s", tostring(currentLevel), tostring(category), tostring(maxHealth), tostring(currentHealth), tostring(currentShield))
    
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        C_ChatInfo.SendAddonMessage(self.COMM_PREFIX, payload, "INSTANCE_CHAT")
    elseif IsInRaid() then
        C_ChatInfo.SendAddonMessage(self.COMM_PREFIX, payload, "RAID")
    elseif IsInGroup() then
        C_ChatInfo.SendAddonMessage(self.COMM_PREFIX, payload, "PARTY")
    end

    if not self.requestersCache then return end
    local now = GetTime()
    for requester, timestamp in pairs(self.requestersCache) do
        -- Mantener la suscripción viva durante 5 minutos (300 segundos)
        if now - timestamp < 300 then
            C_ChatInfo.SendAddonMessage(self.COMM_PREFIX, payload, "WHISPER", requester)
        else
            self.requestersCache[requester] = nil
        end
    end
end

function GAC:BroadcastRollMessage(message)
    if not message or message == "" then return end
    local payload = "ROLL:" .. message
    
    -- Mandar a grupo/banda
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        C_ChatInfo.SendAddonMessage(self.COMM_PREFIX, payload, "INSTANCE_CHAT")
    elseif IsInRaid() then
        C_ChatInfo.SendAddonMessage(self.COMM_PREFIX, payload, "RAID")
    elseif IsInGroup() then
        C_ChatInfo.SendAddonMessage(self.COMM_PREFIX, payload, "PARTY")
    end
    
    -- Mandarlo también por susurro a todos los que nos tienen seleccionados (suscritos a nuestra vida)
    if self.requestersCache then
        local now = GetTime()
        for requester, timestamp in pairs(self.requestersCache) do
            if now - timestamp < 300 then
                C_ChatInfo.SendAddonMessage(self.COMM_PREFIX, payload, "WHISPER", requester)
            else
                self.requestersCache[requester] = nil
            end
        end
    end
end

function GAC:BroadcastInitiativeAdd(playerName, total)
    if not playerName or not total then return end
    local payload = "INIT:ADD:" .. tostring(playerName) .. ":" .. tostring(total)
    
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        C_ChatInfo.SendAddonMessage(self.COMM_PREFIX, payload, "INSTANCE_CHAT")
    elseif IsInRaid() then
        C_ChatInfo.SendAddonMessage(self.COMM_PREFIX, payload, "RAID")
    elseif IsInGroup() then
        C_ChatInfo.SendAddonMessage(self.COMM_PREFIX, payload, "PARTY")
    end
end

function GAC:BroadcastInitiativeAction(action)
    if not action then return end
    local payload = "INIT:ACTION:" .. tostring(action)
    
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        C_ChatInfo.SendAddonMessage(self.COMM_PREFIX, payload, "INSTANCE_CHAT")
    elseif IsInRaid() then
        C_ChatInfo.SendAddonMessage(self.COMM_PREFIX, payload, "RAID")
    elseif IsInGroup() then
        C_ChatInfo.SendAddonMessage(self.COMM_PREFIX, payload, "PARTY")
    end
end

function GAC:BroadcastInitiativeMove(fromIndex, toIndex)
    if not fromIndex or not toIndex then return end
    local payload = "INIT:MOVE:" .. tostring(fromIndex) .. ":" .. tostring(toIndex)
    
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        C_ChatInfo.SendAddonMessage(self.COMM_PREFIX, payload, "INSTANCE_CHAT")
    elseif IsInRaid() then
        C_ChatInfo.SendAddonMessage(self.COMM_PREFIX, payload, "RAID")
    elseif IsInGroup() then
        C_ChatInfo.SendAddonMessage(self.COMM_PREFIX, payload, "PARTY")
    end
end

function GAC:BroadcastInitiativeIcon(index, iconID)
    if not index or not iconID then return end
    local payload = "INIT:ICON:" .. tostring(index) .. ":" .. tostring(iconID)
    
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        C_ChatInfo.SendAddonMessage(self.COMM_PREFIX, payload, "INSTANCE_CHAT")
    elseif IsInRaid() then
        C_ChatInfo.SendAddonMessage(self.COMM_PREFIX, payload, "RAID")
    elseif IsInGroup() then
        C_ChatInfo.SendAddonMessage(self.COMM_PREFIX, payload, "PARTY")
    end
end

function GAC:RequestInspection(targetName)
    if not targetName or targetName == "" then return end
    C_ChatInfo.SendAddonMessage(self.COMM_PREFIX, "INSPECT:REQ", "WHISPER", targetName)
end

function GAC:SendInspectionData(requesterName)
    if not requesterName or requesterName == "" then return end
    if not self.characterData then return end
    
    -- 1. INFO PACKET: INSP:INFO:Nivel:Categoria:Raza:Clase:SaludMax:EscudoMax
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
    
    local infoPayload = string.format("INSP:INFO:%s:%s:%s:%s:%s:%s:%s:%s", tostring(currentLevel), tostring(category), tostring(race), tostring(class), tostring(maxHealth), tostring(currentShield), tostring(currentExp), tostring(maxExp))
    C_ChatInfo.SendAddonMessage(self.COMM_PREFIX, infoPayload, "WHISPER", requesterName)
    
    -- 2. ATT PACKET: INSP:ATT:key=val;key=val;
    local attStr = ""
    for k, v in pairs(attributes) do
        attStr = attStr .. tostring(k) .. "=" .. tostring(v) .. ";"
    end
    if attStr ~= "" then
        C_ChatInfo.SendAddonMessage(self.COMM_PREFIX, "INSP:ATT:" .. attStr, "WHISPER", requesterName)
    end
    
    -- 3. TAL PACKET: INSP:TAL:key=val;key=val;
    local talents = self.characterData.talents or {}
    local talStr = ""
    for k, v in pairs(talents) do
        talStr = talStr .. tostring(k) .. "=" .. tostring(v) .. ";"
    end
    if talStr ~= "" then
        C_ChatInfo.SendAddonMessage(self.COMM_PREFIX, "INSP:TAL:" .. talStr, "WHISPER", requesterName)
    else
        -- If no talents, we just send empty TAL so the receiver knows the inspection transmission is done
        C_ChatInfo.SendAddonMessage(self.COMM_PREFIX, "INSP:TAL:", "WHISPER", requesterName)
    end

end

function GAC:SendExperienceToTarget(targetName, amount)
    if not targetName or targetName == "" then return end
    C_ChatInfo.SendAddonMessage(self.COMM_PREFIX, "ADD_EXP:" .. tostring(amount), "WHISPER", targetName)
end

