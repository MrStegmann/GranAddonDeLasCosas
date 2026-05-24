local _, addon = ...

addon.levelCategories = {
    "Novato",
    "Normal",
    "Élite",
    "Jefe",
}

addon.levelsTable = {
    ["Novato"] = {
        [1] = { expToLevel = 10 },
        [2] = { expToLevel = 12 },
        [3] = { expToLevel = 14 },
        [4] = { expToLevel = 16 },
        [5] = { expToLevel = 20 },
    },
    ["Normal"] = {
        [1] = { expToLevel = 30 },
        [2] = { expToLevel = 45 },
        [3] = { expToLevel = 68 },
        [4] = { expToLevel = 102 },
        [5] = { expToLevel = 153 },
        [6] = { expToLevel = 230 },
        [7] = { expToLevel = 345 },
        [8] = { expToLevel = 518 },
        [9] = { expToLevel = 777 },
        [10] = { expToLevel = 1166 },
    },
    ["Élite"] = {
        [1] = { expToLevel = 1749 },
        [2] = { expToLevel = 2624 },
        [3] = { expToLevel = 3936 },
        [4] = { expToLevel = 5904 },
        [5] = { expToLevel = 6495 },
        [6] = { expToLevel = 7145 },
        [7] = { expToLevel = 7858 },
        [8] = { expToLevel = 8646 },
        [9] = { expToLevel = 9511 },
        [10] = { expToLevel = 10462 },
    },
    ["Jefe"] = {
        [1] = { expToLevel = 11508 },
        [2] = { expToLevel = 12659 },
        [3] = { expToLevel = 13925 },
        [4] = { expToLevel = 15318 },
        [5] = { expToLevel = 16850 },
        [6] = { expToLevel = 18535 },
        [7] = { expToLevel = 20389 },
        [8] = { expToLevel = 22428 },
        [9] = { expToLevel = 24671 },
        [10] = { expToLevel = nil },
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
    end

    progress.level = level
    progress.currentExperience = currentExperience
    self:NormalizeExperienceProgressData()
end
