local addonName, addon = ...
local qa = addon.quickActions or {}

function addon:GetActiveRollModifier()
    local frame = self.quickActionsFrame
    if not frame or not frame.modifierInput then
        return 0, false
    end

    local rawValue = (frame.modifierInput:GetText() or ""):match("^%s*(.-)%s*$")
    if rawValue == "" then
        return 0, false
    end

    local numericValue = tonumber(rawValue)
    if not numericValue then
        return 0, false
    end

    return qa.normalizeModifierValue(numericValue), true
end


function addon:StartTalentRoll(attributeName, talentName)
    if not self.characterData then
        return
    end

    if not qa.canTriggerRoll() then
        return
    end

    local attributeValue = tonumber(self.characterData.attributes[attributeName]) or 0
    local talentValue = tonumber(self.characterData.talents[talentName]) or 0
    local modifierValue, hasModifier = self:GetActiveRollModifier()

    self.pendingTalentRoll = {
        attributeName = attributeName,
        talentName = talentName,
        attributeValue = attributeValue,
        talentValue = talentValue,
        modifierValue = modifierValue,
        hasModifier = hasModifier,
        min = 1,
        max = 20,
    }

    self.randomRollPattern = self.randomRollPattern or qa.buildRandomRollPattern()

    RandomRoll(1, 20)
end

function addon:StartAttributeRoll(attributeName)
    if not self.characterData then
        return
    end

    if not qa.canTriggerRoll() then
        return
    end

    local attributeValue = tonumber(self.characterData.attributes[attributeName]) or 0
    local modifierValue, hasModifier = self:GetActiveRollModifier()

    self.pendingAttributeRoll = {
        attributeName = attributeName,
        attributeValue = attributeValue,
        modifierValue = modifierValue,
        hasModifier = hasModifier,
        min = 1,
        max = 20,
    }

    self.randomRollPattern = self.randomRollPattern or qa.buildRandomRollPattern()

    RandomRoll(1, 20)
end

function addon:StartAttackRoll(diceSides, talentKey, talentLabel)
    if not self.characterData then
        return
    end

    if not qa.canTriggerRoll() then
        return
    end

    local talentValue = tonumber(self.characterData.talents[talentKey]) or 0
    local modifierValue, hasModifier = self:GetActiveRollModifier()

    self.pendingAttackRoll = {
        diceSides = diceSides,
        talentKey = talentKey,
        talentLabel = talentLabel,
        talentValue = talentValue,
        modifierValue = modifierValue,
        hasModifier = hasModifier,
        min = 1,
        max = diceSides,
    }

    self.randomRollPattern = self.randomRollPattern or qa.buildRandomRollPattern()

    RandomRoll(1, diceSides)
end

function addon:StartCustomDiceRoll(quantity, faces)
    if not qa.canTriggerRoll() then
        return
    end

    local diceCount = tonumber(quantity) or 0
    local diceFaces = tonumber(faces) or 0

    if diceCount < 1 or diceFaces < 2 then
        print("Introduce valores validos: cantidad >= 1 y caras >= 2.")
        return
    end

    diceCount = math.min(math.floor(diceCount), 20)
    diceFaces = math.min(math.floor(diceFaces), 1000)

    local modifierValue, hasModifier = self:GetActiveRollModifier()

    local total = 0
    local rollParts = {}
    for _ = 1, diceCount do
        local value = random(1, diceFaces)
        total = total + value
        rollParts[#rollParts + 1] = tostring(value)
    end

    if hasModifier then
        total = total + modifierValue
    end

    local displayName = self.GetRollDisplayNameWithColor and self:GetRollDisplayNameWithColor()
        or (self.GetRollDisplayName and self:GetRollDisplayName())
        or addonName

    local finalMessage = displayName .. " tira " .. diceCount .. "D" .. diceFaces
        .. " (" .. table.concat(rollParts, "+") .. ")"
        .. qa.buildModifierSegment(hasModifier, modifierValue)
        .. " = " .. total

    print(finalMessage)

    if self.BroadcastRollMessage then
        self:BroadcastRollMessage(finalMessage)
    end
end

