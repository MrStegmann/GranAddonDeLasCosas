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

    local mod, hasMod = self:GetQuickModifierValue()
    
    local worgenModValue = 0
    if GAC.GetModificators then
        local wMod = GAC:GetModificators()
        if wMod and wMod[talentName] then
            worgenModValue = tonumber(wMod[talentName]) or 0
        end
    end

    self.pendingTalentRoll = {
        attributeName = attributeName,
        talentName = talentName,
        attributeValue = attributeValue,
        talentValue = talentValue,
        min = 1,
        max = 20,
        hasModifier = hasMod,
        modifierValue = mod,
        worgenModifier = worgenModValue,
    }

    self.randomRollPattern = self.randomRollPattern or GAC:BuildRandomRollPattern()
    self.rollType = "talent"
    self.lastTalentRolled = { attributeName = attributeName, talentName = talentName }
    RandomRoll(1, 20)
end


function GAC:StartCustomDiceRoll(quantity, faces)
    if not GAC:CanTriggerRoll() then return end
    
    local q = tonumber(quantity) or 1
    local f = tonumber(faces) or 20
    
    -- Limitamos a 10 dados para evitar spam o desconexiones por rate-limit
    if q > 10 then q = 10 end
    if q < 1 then q = 1 end
    
    local mod, hasMod = self:GetQuickModifierValue()
    
    self.pendingCustomRoll = {
        quantity = q,
        faces = f,
        rolls = {},
        hasModifier = hasMod,
        modifierValue = mod,
    }
    
    self.randomRollPattern = self.randomRollPattern or GAC:BuildRandomRollPattern()
    self.rollType = "custom"
    
    for i = 1, q do
        RandomRoll(1, f)
    end
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

function GAC:StartAttributeRoll(attributeName)
    if not self.characterData then
        return
    end
    if not GAC:CanTriggerRoll() then
        return
    end

    local attributeValue = self.characterData.attributes and self.characterData.attributes[attributeName] and tonumber(self.characterData.attributes[attributeName]) or 0

    local mod, hasMod = self:GetQuickModifierValue()

    self.pendingAttributeRoll = {
        attributeName = attributeName,
        attributeValue = attributeValue,
        min = 1,
        max = 20,
        hasModifier = hasMod,
        modifierValue = mod,
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

    local mod, hasMod = self:GetQuickModifierValue()

    self.pendingInitiativeRoll = {
        min = 1,
        max = 100,
        hasModifier = hasMod,
        modifierValue = mod,
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

    local mod, hasMod = self:GetQuickModifierValue()

    self.pendingAttackRoll = {
        talentKey = talentKey,
        talentName = talentLabel,
        talentValue = talentValue,
        min = 1,
        max = dice,
        hasModifier = hasMod,
        modifierValue = mod,
    }

    self.randomRollPattern = self.randomRollPattern or GAC:BuildRandomRollPattern()
    self.rollType = "attack"
    self.lastAttackRolled = { dice = dice, talentKey = talentKey, talentLabel = talentLabel }
    RandomRoll(1, dice)
end

function GAC:StartWeaponDamageRoll(weaponKey, mode, weaponName, damageModifier)
    if not self.characterData or not GAC:CanTriggerRoll() then return end
    
    local wInfo = GAC:GetWeaponInfo(weaponKey)
    if not wInfo then return end
    
    local rollData = wInfo
    local modeLabel = "Normal"
    if mode == "twoHanded" and wInfo.twoHanded then
        rollData = wInfo.twoHanded
        modeLabel = "A dos manos"
    elseif mode == "throwable" and wInfo.throwable then
        rollData = wInfo.throwable
        modeLabel = "Lanzar"
    end
    
    local playerAttrs = self.characterData.attributes or {}
    local playerTalents = self.characterData.talents or {}
    local maxTalentVal = 0
    local usedTalentKey = ""
    
    if type(rollData.talent) == "table" then
        for _, t in ipairs(rollData.talent) do
            local val = (tonumber(playerAttrs[t]) or 0) + (tonumber(playerTalents[t]) or 0)
            if val > maxTalentVal or usedTalentKey == "" then
                maxTalentVal = val
                usedTalentKey = t
            end
        end
    elseif type(rollData.talent) == "string" then
        maxTalentVal = (tonumber(playerAttrs[rollData.talent]) or 0) + (tonumber(playerTalents[rollData.talent]) or 0)
        usedTalentKey = rollData.talent
    end
    
    local mod, hasMod = self:GetQuickModifierValue()
    
    self.pendingWeaponRoll = {
        weaponKey = weaponKey,
        weaponName = weaponName or weaponKey,
        modeLabel = modeLabel,
        diceNumber = rollData.diceNumber or 1,
        damage = rollData.damage or 4,
        talentValue = maxTalentVal,
        talentKey = usedTalentKey,
        hasModifier = hasMod,
        modifierValue = mod,
        weaponModifier = damageModifier or 0,
        currentTotal = 0,
        rolls = {},
        quantity = rollData.diceNumber or 1
    }
    
    self.randomRollPattern = self.randomRollPattern or GAC:BuildRandomRollPattern()
    self.rollType = "weapon"
    
    for i = 1, self.pendingWeaponRoll.quantity do
        RandomRoll(1, self.pendingWeaponRoll.damage)
    end
end