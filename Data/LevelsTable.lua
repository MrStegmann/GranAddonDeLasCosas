local _, addon = ...

addon.levelCategories = {
    "Novato",
    "Normal",
    "Élite",
    "Jefe",
}

addon.levelsTable = {
    ["Novato"] = {
        [1] = { maxHealth = 10, expToLevel = 10, attPoints = 0, skillPoints= 2, heroicPoints= 1, maxPositiveTraits = 0 },
        [2] = { maxHealth = 11, expToLevel = 12, attPoints = 1, skillPoints= 3, heroicPoints= 1, maxPositiveTraits = 0 },
        [3] = { maxHealth = 13, expToLevel = 14, attPoints = 3, skillPoints= 4, heroicPoints= 1, maxPositiveTraits = 0 },
        [4] = { maxHealth = 16, expToLevel = 16, attPoints = 3, skillPoints= 5, heroicPoints= 1, maxPositiveTraits = 0 },
        [5] = { maxHealth = 20, expToLevel = 20, attPoints = 5, skillPoints= 5, heroicPoints= 1, maxPositiveTraits = 0 },
    },
    ["Normal"] = {
        [1] = { maxHealth = 20, expToLevel = 30, attPoints = 5, skillPoints = 5, heroicPoints = 2, maxPositiveTraits = 2 },
        [2] = { maxHealth = 27, expToLevel = 45, attPoints = 5, skillPoints = 6, heroicPoints = 2, maxPositiveTraits = 2 },
        [3] = { maxHealth = 34, expToLevel = 68, attPoints = 6, skillPoints = 6, heroicPoints = 2, maxPositiveTraits = 2 },
        [4] = { maxHealth = 41, expToLevel = 102, attPoints = 7, skillPoints = 7, heroicPoints = 2, maxPositiveTraits = 2 },
        [5] = { maxHealth = 49, expToLevel = 153, attPoints = 7, skillPoints = 7, heroicPoints = 3, maxPositiveTraits = 2 },
        [6] = { maxHealth = 57, expToLevel = 230, attPoints = 8, skillPoints = 8, heroicPoints = 3, maxPositiveTraits = 2 },
        [7] = { maxHealth = 65, expToLevel = 345, attPoints = 9, skillPoints = 8, heroicPoints = 3, maxPositiveTraits = 2 },
        [8] = { maxHealth = 74, expToLevel = 518, attPoints = 9, skillPoints = 9, heroicPoints = 3, maxPositiveTraits = 2 },
        [9] = { maxHealth = 83, expToLevel = 777, attPoints = 10, skillPoints = 9, heroicPoints = 3, maxPositiveTraits = 2 },
        [10] = { maxHealth = 92, expToLevel = 1166, attPoints = 10, skillPoints = 10, heroicPoints = 4, maxPositiveTraits = 3 },
    },
    ["Élite"] = {
        [1] = { maxHealth = 40, expToLevel = 1749, attPoints = 10, skillPoints = 10, heroicPoints = 4, maxPositiveTraits = 3 },
        [2] = { maxHealth = 54, expToLevel = 2624, attPoints = 11, skillPoints = 11, heroicPoints = 4, maxPositiveTraits = 3 },
        [3] = { maxHealth = 68, expToLevel = 3936, attPoints = 12, skillPoints = 11, heroicPoints = 4, maxPositiveTraits = 3 },
        [4] = { maxHealth = 82, expToLevel = 5904, attPoints = 13, skillPoints = 12, heroicPoints = 4, maxPositiveTraits = 3 },
        [5] = { maxHealth = 98, expToLevel = 6495, attPoints = 13, skillPoints = 12, heroicPoints = 5, maxPositiveTraits = 3 },
        [6] = { maxHealth = 114, expToLevel = 7145, attPoints = 14, skillPoints = 13, heroicPoints = 5, maxPositiveTraits = 3 },
        [7] = { maxHealth = 130, expToLevel = 7858, attPoints = 14, skillPoints = 13, heroicPoints = 5, maxPositiveTraits = 3 },
        [8] = { maxHealth = 148, expToLevel = 8646, attPoints = 14, skillPoints = 14, heroicPoints = 5, maxPositiveTraits = 3 },
        [9] = { maxHealth = 166, expToLevel = 9511, attPoints = 15, skillPoints = 14, heroicPoints = 5, maxPositiveTraits = 3 },
        [10] = { maxHealth = 184, expToLevel = 10462, attPoints = 15, skillPoints = 15, heroicPoints = 6, maxPositiveTraits = 4 },
    },
    ["Jefe"] = {
        [1] = { maxHealth = 80, expToLevel = 11508, attPoints = 15, skillPoints = 15, heroicPoints = 6, maxPositiveTraits = 4 },
        [2] = { maxHealth = 108, expToLevel = 12659, attPoints = 16, skillPoints = 16, heroicPoints = 6, maxPositiveTraits = 4 },
        [3] = { maxHealth = 136, expToLevel = 13925, attPoints = 17, skillPoints = 16, heroicPoints = 6, maxPositiveTraits = 4 },
        [4] = { maxHealth = 164, expToLevel = 15318, attPoints = 18, skillPoints = 17, heroicPoints = 6, maxPositiveTraits = 4 },
        [5] = { maxHealth = 196, expToLevel = 16850, attPoints = 18, skillPoints = 17, heroicPoints = 7, maxPositiveTraits = 4 },
        [6] = { maxHealth = 228, expToLevel = 18535, attPoints = 19, skillPoints = 18, heroicPoints = 7, maxPositiveTraits = 4 },
        [7] = { maxHealth = 260, expToLevel = 20389, attPoints = 19, skillPoints = 18, heroicPoints = 7, maxPositiveTraits = 4 },
        [8] = { maxHealth = 296, expToLevel = 22428, attPoints = 19, skillPoints = 19, heroicPoints = 7, maxPositiveTraits = 4 },
        [9] = { maxHealth = 332, expToLevel = 24671, attPoints = 20, skillPoints = 19, heroicPoints = 7, maxPositiveTraits = 4 },
        [10] = { maxHealth = 368, expToLevel = nil, attPoints = 20, skillPoints = 20, heroicPoints = 8, maxPositiveTraits = 5 },
    },
}

local function clamp(numberValue, minValue, maxValue)
    local value = tonumber(numberValue) or minValue
    if value < minValue then
        return minValue
    end

    if value > maxValue then
        return maxValue
    end

    return value
end

function addon:GetMaxLevelForCategory(category)
    local categoryLevels = self.levelsTable and self.levelsTable[category]
    if not categoryLevels then
        return 1
    end

    local maxLevel = 1
    for level in pairs(categoryLevels) do
        if level > maxLevel then
            maxLevel = level
        end
    end

    return maxLevel
end

function addon:GetLevelEntry(category, level)
    local categoryLevels = self.levelsTable and self.levelsTable[category]
    if not categoryLevels then
        return nil
    end

    return categoryLevels[level]
end

function addon:GetRequiredExperience(category, level)
    local entry = self:GetLevelEntry(category, level)
    if not entry then
        return nil
    end

    return entry.expToLevel
end

function addon:GetNextExperienceCategory(category)
    local categories = self.levelCategories or {}
    local categoryIndex = nil

    for index, categoryName in ipairs(categories) do
        if categoryName == category then
            categoryIndex = index
            break
        end
    end

    if not categoryIndex then
        return nil
    end

    return categories[categoryIndex + 1]
end

function addon:IsPrestigeAvailable()
    local snapshot = self:GetExperienceProgressSnapshot()
    local maxLevel = self:GetMaxLevelForCategory(snapshot.category)
    local nextCategory = self:GetNextExperienceCategory(snapshot.category)

    if not nextCategory then
        return false
    end

    if snapshot.level < maxLevel then
        return false
    end

    local requiredExperience = snapshot.requiredExperience
    if not requiredExperience or requiredExperience <= 0 then
        return false
    end

    return snapshot.currentExperience >= requiredExperience
end

function addon:PrestigeToNextCategory()
    if not self.characterData then
        return false
    end

    if not self:IsPrestigeAvailable() then
        return false
    end

    local snapshot = self:GetExperienceProgressSnapshot()
    local nextCategory = self:GetNextExperienceCategory(snapshot.category)
    if not nextCategory then
        return false
    end

    if self.ResetAttributesUIValues then
        self:ResetAttributesUIValues()
    end

    self.characterData.progress = self.characterData.progress or {}
    self.characterData.progress.category = nextCategory
    self.characterData.progress.level = 1
    self.characterData.progress.currentExperience = 0

    self:NormalizeExperienceProgressData()
    return true
end

function addon:NormalizeExperienceProgressData()
    if not self.characterData then
        return
    end

    self.characterData.progress = self.characterData.progress or {}

    local progress = self.characterData.progress
    local category = progress.category

    if not self.levelsTable[category] then
        category = "Normal"
    end

    local maxLevel = self:GetMaxLevelForCategory(category)
    local level = clamp(progress.level or 1, 1, maxLevel)
    local requiredExp = self:GetRequiredExperience(category, level)
    local currentExperience = math.max(0, math.floor(tonumber(progress.currentExperience) or 0))

    if requiredExp and requiredExp > 0 and currentExperience > requiredExp then
        currentExperience = requiredExp
    end

    progress.category = category
    progress.level = level
    progress.currentExperience = currentExperience
end

function addon:GetExperienceProgressSnapshot()
    self:NormalizeExperienceProgressData()

    local progress = self.characterData and self.characterData.progress or {}
    local category = progress.category or "Normal"
    local level = progress.level or 1
    local currentExperience = progress.currentExperience or 0
    local requiredExperience = self:GetRequiredExperience(category, level)

    return {
        category = category,
        level = level,
        currentExperience = currentExperience,
        requiredExperience = requiredExperience,
    }
end

function addon:SetExperienceCategory(category)
    if not self.characterData then
        return
    end

    if not self.levelsTable[category] then
        return
    end

    self.characterData.progress = self.characterData.progress or {}

    local maxLevel = self:GetMaxLevelForCategory(category)
    local currentLevel = tonumber(self.characterData.progress.level) or 1

    self.characterData.progress.category = category
    self.characterData.progress.level = clamp(currentLevel, 1, maxLevel)
    self.characterData.progress.currentExperience = 0

    self:NormalizeExperienceProgressData()
end

function addon:SetExperienceLevel(level)
    if not self.characterData then
        return
    end

    self.characterData.progress = self.characterData.progress or {}

    local category = self.characterData.progress.category or "Normal"
    if not self.levelsTable[category] then
        category = "Normal"
    end

    local maxLevel = self:GetMaxLevelForCategory(category)
    self.characterData.progress.level = clamp(level, 1, maxLevel)
    self.characterData.progress.currentExperience = 0

    self:NormalizeExperienceProgressData()
end

function addon:SetCurrentExperience(experienceValue)
    if not self.characterData then
        return
    end

    self.characterData.progress = self.characterData.progress or {}

    local snapshot = self:GetExperienceProgressSnapshot()
    local value = math.max(0, math.floor(tonumber(experienceValue) or 0))

    if snapshot.requiredExperience and snapshot.requiredExperience > 0 then
        value = math.min(value, snapshot.requiredExperience)
    end

    self.characterData.progress.currentExperience = value
    self:NormalizeExperienceProgressData()
end

-- Función para imprimir el mensaje informativo de subida de nivel en el chat
function addon:PrintLevelUpMessage(oldLevel, newLevel, category)
    if not self.characterData then return end

    -- Obtener datos de perfil TRP3 para el nombre y color
    local name = self.GetActiveTRP3ProfileName and self:GetActiveTRP3ProfileName() or UnitName("player")
    local nameColor = self.GetActiveTRP3ProfileColor and self:GetActiveTRP3ProfileColor() or "ffffff"
    
    -- Formatear color hex para WoW (de RRGGBB a AARRGGBB)
    if #nameColor == 6 then nameColor = "ff" .. nameColor end
    local playerDisplayName = string.format("|c%s%s|r", nameColor, name)

    local newEntry = self:GetLevelEntry(category, newLevel)
    if not newEntry then return end

    local prevEntry = self:GetLevelEntry(category, oldLevel)

    -- Calcular la diferencia de puntos con respecto al nivel anterior
    local attDelta = (newEntry.attPoints or 0) - (prevEntry and prevEntry.attPoints or 0)
    local skillDelta = (newEntry.skillPoints or 0) - (prevEntry and prevEntry.skillPoints or 0)
    local heroicDelta = (newEntry.heroicPoints or 0) - (prevEntry and prevEntry.heroicPoints or 0)
    local traitsDelta = (newEntry.maxPositiveTraits or 0) - (prevEntry and prevEntry.maxPositiveTraits or 0)

    local msg = string.format("¡%s ha alcanzado el nivel |cff00ff00%d|r en la categoría |cffffff00%s|r!\n", playerDisplayName, newLevel, category)
    msg = msg .. string.format("  Vida máxima: |cffff5555%d|r\n", newEntry.maxHealth or 0)
    
    if attDelta > 0 then msg = msg .. string.format("  Puntos de atributo nuevos: |cff55ff55%d|r\n", attDelta) end
    if skillDelta > 0 then msg = msg .. string.format("  Ranuras de hechizo/habilidad ganadas: |cff55ffff%d|r\n", skillDelta) end
    if heroicDelta > 0 then msg = msg .. string.format("  Ranura de heroicas ganadas: |cffffaa00%d|r\n", heroicDelta) end
    if traitsDelta > 0 then msg = msg .. string.format("  Puntos de rasgos positivos máximos ganados: |cffaaaaff%d|r", traitsDelta) end

    print(msg)
end

function addon:AddExperience(experienceAmount)
    if not self.characterData then
        return
    end

    local amount = math.floor(tonumber(experienceAmount) or 0)
    if amount <= 0 then
        return
    end

    self.characterData.progress = self.characterData.progress or {}
    self:NormalizeExperienceProgressData()

    local progress = self.characterData.progress
    local category = progress.category or "Normal"
    local level = tonumber(progress.level) or 1
    local currentExperience = tonumber(progress.currentExperience) or 0
    local maxLevel = self:GetMaxLevelForCategory(category)
    local oldLevel = level -- Guardar nivel actual antes de procesar el incremento

    if level >= maxLevel then
        local requiredAtCap = self:GetRequiredExperience(category, level)
        if requiredAtCap and requiredAtCap > 0 then
            progress.currentExperience = math.min(currentExperience + amount, requiredAtCap)
        else
            progress.currentExperience = currentExperience
        end

        self:NormalizeExperienceProgressData()
        return
    end

    local remaining = amount

    while remaining > 0 do
        local requiredExperience = self:GetRequiredExperience(category, level)
        if not requiredExperience or requiredExperience <= 0 then
            -- Max level in this category.
            currentExperience = 0
            remaining = 0
            break
        end

        local missingToLevel = requiredExperience - currentExperience
        if remaining < missingToLevel then
            currentExperience = currentExperience + remaining
            remaining = 0
            break
        end

        remaining = remaining - missingToLevel
        if level >= maxLevel then
            currentExperience = requiredExperience
            remaining = 0
            break
        end

        level = level + 1
        currentExperience = 0

        -- Lanzar el mensaje informativo cada vez que sube un nivel
        self:PrintLevelUpMessage(oldLevel, level, category)
        oldLevel = level
    end

    progress.level = level
    progress.currentExperience = currentExperience
    self:NormalizeExperienceProgressData()
end