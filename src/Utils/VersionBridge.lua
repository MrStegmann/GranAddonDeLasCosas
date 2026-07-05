local addonName, GAC = ...

function GAC:NormalizeAttributeNameThroughtVersions(attributeName)
    local normalizationMap = {
        ["Destreza"] = "dexterity",
        ["Fuerza"] = "strength",
        ["Inteligencia"] = "intelligence",
        ["Voluntad"] = "willpower",
        ["Constitución"] = "constitution",
        ["Sabiduría"] = "wisdom",
        ["Carisma"] = "charisma",
    }
    return normalizationMap[attributeName] or attributeName
end

function GAC:NormalizeTalentNameThroughtVersions(talentName)
    local normalizationMap = {
        ["Precisión"] = "precision",
        ["Combate Ágil"] = "agileCombat",
        ["Acrobacias"] = "acrobatics",
        ["Sigilo"] = "stealth",
        ["Juego de Manos"] = "sleightOfHand",
        ["Defensa Ágil"] = "agileDefense",

        ["Combate a 2 manos"] = "twoHandedCombat",
        ["Combate a 1 mano"] = "oneHandedCombat",
        ["Atletismo"] = "athletics",
        ["Brutalidad"] = "brutality",
        ["Defensa Robusta"] = "sturdyDefense",
        
        ["Arcano"] = "arcane",
        ["Vil"] = "fel",
        ["Naturaleza"] = "nature",
        ["Sombras"] = "shadow",
        ["Nigromancia"] = "necromancy",
        
        ["Resistencia Mágica"] = "magicResistance",
        ["Resistencia a la Pérdida de Control"] = "lossOfControlResistance",
        ["Fe"] = "faith",
        ["Conexión Elemental"] = "elementalConnection",
        ["Chi"] = "chi",
        ["Regeneración de Maná"] = "manaRegeneration",

        ["Resiliencia"] = "resilience",
        ["Resistencia a Aturdimientos"] = "stunResistance",
        ["Resistencia a Derribos"] = "knockdownResistance",
        ["Resistencia al Frío"] = "coldResistance",
        ["Resistencia al Calor"] = "heatResistance",
        ["Fortaleza"] = "fortitude",

        ["Conexión con los animales"] = "animalConnection",
        ["Supervivencia"] = "survival",
        ["Percepción"] = "perception",

        ["Persuasión"] = "persuasion",
        ["Diplomacia"] = "diplomacy",
        ["Comercio"] = "commerce",
        ["Provocación"] = "provocation",
        ["Seducción"] = "seduction",
        ["Interpretación"] = "performance",
    }
    return normalizationMap[talentName] or talentName
end

function GAC:NormalizeCategoryLevelThroughtVersions(category)
    local normalizationMap = {
         ["Novato"] = "noob",
         ["Normal"] = "normal",
         ["Élite"] = "elite",
         ["Jefe"] = "boss",
    }
    return normalizationMap[category] or category
end

function GAC:MigrateToModelData()
    if not self.characterData then return end
    
    local c = self.characterData.characteristics
    local p = self.characterData.progress
    local a = self.characterData.attributes
    local t = self.characterData.talents
    
    local m = self.characterData.modelData
    if not m then
        self.characterData.modelData = {}
        m = self.characterData.modelData
    end

    -- Migrate level and category
    if p and not m.level then
        m.level = p.level
        m.category = p.category
        m.experience = { current = p.currentExp or 0, max = p.maxExp or 100 }
    end
    
    -- Migrate attributes
    if a and not m.attributes then
        m.attributes = {}
        for k, v in pairs(a) do
            local normKey = self:NormalizeAttributeNameThroughtVersions(k)
            m.attributes[normKey] = v
        end
    elseif m.attributes then
        -- Repara claves que ya migraron con el formato incorrecto (español)
        local repaired = {}
        for k, v in pairs(m.attributes) do
            local normKey = self:NormalizeAttributeNameThroughtVersions(k)
            repaired[normKey] = v
        end
        m.attributes = repaired
    end
    
    -- Migrate talents
    if t and not m.talents then
        m.talents = {}
        for k, v in pairs(t) do
            local normKey = self:NormalizeTalentNameThroughtVersions(k)
            m.talents[normKey] = v
        end
    elseif m.talents then
        -- Repara claves que ya migraron con el formato incorrecto (español)
        local repaired = {}
        for k, v in pairs(m.talents) do
            local normKey = self:NormalizeTalentNameThroughtVersions(k)
            repaired[normKey] = v
        end
        m.talents = repaired
    end
    
    -- Migrate health/shield/mana/spirit
    if not m.healthPoints and (self.characterData.currentHealth or self.characterData.maxHealth) then
        m.healthPoints = { current = self.characterData.currentHealth or 10, max = self.characterData.maxHealth or 10 }
    end
    if not m.shieldPoints and self.characterData.currentShield then
        m.shieldPoints = { current = self.characterData.currentShield or 0 }
    end
    if not m.manapoints and (self.characterData.currentMana or self.characterData.maxMana) then
        m.manapoints = { current = self.characterData.currentMana or 0, max = self.characterData.maxMana or 0 }
    end
    if not m.spiritPoints and (self.characterData.currentSpirit or self.characterData.maxSpirit) then
        m.spiritPoints = { current = self.characterData.currentSpirit or 0, max = self.characterData.maxSpirit or 0 }
    end

    -- Si tenemos characteristics antiguas pero raceTalents y race array no existen en modelData
    if c and (c.race1 or c.race2) and not m.race then
        local r1 = c.race1
        local r2 = c.race2
        
        m.race = {}
        if r1 and r1 ~= "Ninguna" and r1 ~= "void" then table.insert(m.race, r1) end
        if r2 and r2 ~= "Ninguna" and r2 ~= "void" then table.insert(m.race, r2) end
        if #m.race == 0 then table.insert(m.race, "human") end

        m.raceTalents = m.raceTalents or {}
        
        if c.activeAdvantages then
            for k, v in pairs(c.activeAdvantages) do
                m.raceTalents[k] = v
            end
        end
        if c.activeDisadvantages then
            for k, v in pairs(c.activeDisadvantages) do
                m.raceTalents[k] = v
            end
        end
        if c.activeSpecial then
            for k, v in pairs(c.activeSpecial) do
                m.raceTalents[k] = v
            end
        end

        -- Clean up old variables
        c.race1 = nil
        c.race2 = nil
        c.activeAdvantages = nil
        c.activeDisadvantages = nil
        c.activeSpecial = nil
        c.mestizoTraits = nil
    end
end