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
    if not self.requestersCache then return end
    local now = GetTime()
    for requester, timestamp in pairs(self.requestersCache) do
        -- Mantener la suscripción viva durante 5 minutos (300 segundos)
        if now - timestamp < 300 then
            self:SendPlayerData(requester)
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
