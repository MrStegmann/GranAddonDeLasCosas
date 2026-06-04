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
    
    -- Creamos el paquete serializado. Formato: RES:nivel:categoria:vidaMaxima:vidaActual
    local payload = string.format("RES:%s:%s:%s:%s", tostring(currentLevel), tostring(category), tostring(maxHealth), tostring(currentHealth))
    
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
