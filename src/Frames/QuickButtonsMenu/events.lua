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

    local traitModSum = 0
    local traitModStrings = {}
    if self.characterData.positiveTraits and GAC.PositiveTraits then
        for traitNameKey, traitData in pairs(self.characterData.positiveTraits) do
            local lvl = traitData.level or 0
            if lvl > 0 then
                local def = nil
                for _, t in ipairs(GAC.PositiveTraits) do
                    if t.name == traitNameKey then def = t; break end
                end
                if def and def.modifiers and def.modifiers[lvl] then
                    for k, v in pairs(def.modifiers[lvl]) do
                        local key = (k == "_selected") and traitData.selectedTalent or k
                        if key == talentName then
                            traitModSum = traitModSum + v
                            table.insert(traitModStrings, " + " .. def.label .. " Nivel " .. lvl .. " (+" .. v .. ")")
                        end
                    end
                end
            end
        end
    end

    local baseTalentValue = talentValue - traitModSum

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
        talentValue = baseTalentValue,
        traitModSum = traitModSum,
        traitModStrings = table.concat(traitModStrings, ""),
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

    local traitModSum = 0
    local traitModStrings = {}
    if self.characterData.positiveTraits and GAC.PositiveTraits then
        for traitNameKey, traitData in pairs(self.characterData.positiveTraits) do
            local lvl = traitData.level or 0
            if lvl > 0 then
                local def = nil
                for _, t in ipairs(GAC.PositiveTraits) do
                    if t.name == traitNameKey then def = t; break end
                end
                if def and def.modifiers and def.modifiers[lvl] then
                    for k, v in pairs(def.modifiers[lvl]) do
                        local key = (k == "_selected") and traitData.selectedTalent or k
                        if key == talentKey then
                            traitModSum = traitModSum + v
                            table.insert(traitModStrings, " + " .. def.label .. " Nivel " .. lvl .. " (+" .. v .. ")")
                        end
                    end
                end
            end
        end
    end

    local baseTalentValue = talentValue - traitModSum

    local mod, hasMod = self:GetQuickModifierValue()

    self.pendingAttackRoll = {
        talentName = talentLabel,
        talentValue = baseTalentValue,
        traitModSum = traitModSum,
        traitModStrings = table.concat(traitModStrings, ""),
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