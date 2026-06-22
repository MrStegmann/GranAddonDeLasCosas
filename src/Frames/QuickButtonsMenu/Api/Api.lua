local addonName, GAC = ...

function GAC:ModifyPlayerLife(amount)
    if type(amount) ~= "number" or amount == 0 then return end
    if not self.characterData then return end
    
    local progress = self.characterData.progress or {}
    local currentLevel = progress.level or 1
    local category = progress.category or "normal"
    local levelEntry = self:GetLevelEntry(category, currentLevel)
    local baseHealth = levelEntry and levelEntry.maxHealth or 10
    
    local attributes = self.characterData.attributes or {}
    local constitution = attributes["constitution"] or 0
    local maxHealth = baseHealth + constitution
    if maxHealth < 1 then maxHealth = 1 end
    
    -- Inicializamos la vida si nunca se ha tocado
    if self.characterData.currentHealth == nil then
        self.characterData.currentHealth = maxHealth
    end
    
    self.characterData.currentHealth = self.characterData.currentHealth + amount
    
    -- Clamp entre -maxHealth y el máximo
    if self.characterData.currentHealth < -maxHealth then
        self.characterData.currentHealth = -maxHealth
    elseif self.characterData.currentHealth > maxHealth then
        self.characterData.currentHealth = maxHealth
    end
    
    -- Forzamos la actualización del marco de jugador
    if PlayerFrameHealthBar then
        UnitFrameHealthBar_Update(PlayerFrameHealthBar, "player")
        if TextStatusBar_UpdateTextString then
            TextStatusBar_UpdateTextString(PlayerFrameHealthBar)
        end
    end
    
    -- Notificar a todos los que nos tengan en target (han hecho REQ en los últimos 5 mins)
    if self.BroadcastPlayerData then
        self:BroadcastPlayerData()
    end
end

function GAC:ModifyPlayerShield(amount)
    if type(amount) ~= "number" or amount == 0 then return end
    if not self.characterData then return end
    
    if self.characterData.currentShield == nil then
        self.characterData.currentShield = 0
    end
    
    self.characterData.currentShield = self.characterData.currentShield + amount
    if self.characterData.currentShield < 0 then
        self.characterData.currentShield = 0
    end
    
    if PlayerFrameHealthBar then
        UnitFrameHealthBar_Update(PlayerFrameHealthBar, "player")
        if TextStatusBar_UpdateTextString then
            TextStatusBar_UpdateTextString(PlayerFrameHealthBar)
        end
    end
    
    if self.BroadcastPlayerData then
        self:BroadcastPlayerData()
    end
end
