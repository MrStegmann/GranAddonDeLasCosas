local _, GAC = ...

function GAC:StartTalentRoll(attributeName, talentName)
    if not self.characterData then
        return
    end
    if not GAC:CanTriggerRoll() then
        return
    end

    local attributeValue = self.characterData.attributes and self.characterData.attributes[attributeName] and tonumber(self.characterData.attributes[attributeName]) or 0
    local talentValue = self.characterData.talents and self.characterData.talents[talentName] and tonumber(self.characterData.talents[talentName]) or 0

    self.pendingTalentRoll = {
        attributeName = attributeName,
        talentName = talentName,
        attributeValue = attributeValue,
        talentValue = talentValue,
        min = 1,
        max = 20,
    }

    self.randomRollPattern = self.randomRollPattern or GAC:BuildRandomRollPattern()
    self.rollType = "talent"
    self.lastTalentRolled = { attributeName = attributeName, talentName = talentName }
    RandomRoll(1, 20)
end


function GAC:StartCustomDiceRoll(quantity, faces)
    local q = tonumber(quantity) or 1
    local f = tonumber(faces) or 20
    RandomRoll(1, f)
end

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
    
    -- Clamp entre 0 y el máximo
    if self.characterData.currentHealth < 0 then
        self.characterData.currentHealth = 0
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

function GAC:StartAttributeRoll(attributeName)
    if not self.characterData then
        return
    end
    if not GAC:CanTriggerRoll() then
        return
    end

    local attributeValue = self.characterData.attributes and self.characterData.attributes[attributeName] and tonumber(self.characterData.attributes[attributeName]) or 0

    self.pendingAttributeRoll = {
        attributeName = attributeName,
        attributeValue = attributeValue,
        min = 1,
        max = 20,
    }

    self.randomRollPattern = self.randomRollPattern or GAC:BuildRandomRollPattern()
    self.rollType = "attribute"
    self.lastAttributeRolled = { attributeName = attributeName }
    RandomRoll(1, 20)
end

function GAC:StartInitiativeRoll()
    if not GAC:CanTriggerRoll() then
        return
    end

    self.pendingInitiativeRoll = {
        min = 1,
        max = 100,
    }

    self.randomRollPattern = self.randomRollPattern or GAC:BuildRandomRollPattern()
    self.rollType = "initiative"

    RandomRoll(1, 100)

end

function GAC:StartAttackRoll(dice, talentKey, talentLabel)
    if not self.characterData then
        return
    end
    if not GAC:CanTriggerRoll() then
        return
    end

    local talentValue = self.characterData.talents and self.characterData.talents[talentKey] and tonumber(self.characterData.talents[talentKey]) or 0

    self.pendingAttackRoll = {
        talentName = talentLabel,
        talentValue = talentValue,
        min = 1,
        max = dice,
    }

    self.randomRollPattern = self.randomRollPattern or GAC:BuildRandomRollPattern()
    self.rollType = "attack"
    self.lastAttackRolled = { dice = dice, talentKey = talentKey, talentLabel = talentLabel }
    RandomRoll(1, dice)
end