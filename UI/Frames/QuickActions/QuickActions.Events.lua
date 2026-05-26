local _, addon = ...
local qa = addon.quickActions or {}
local addonName = addon.name or "GranAddonDeLasCosas"

function addon:CHAT_MSG_SYSTEM(message)
    if self.CaptureRaidRollForTurnOrder then
        self:CaptureRaidRollForTurnOrder(message)
    end

    if not self.pendingTalentRoll and not self.pendingAttributeRoll and not self.pendingAttackRoll and not self.pendingInitiativeRoll then
        return
    end

    local plainMessage = qa.stripColorCodes(message)
    local roller, roll, low, high = plainMessage:match(self.randomRollPattern)
    if not roller or not qa.isPlayerRoll(roller) then
        return
    end

    -- Lógica de validación y obtención de penalizadores de armadura
    local requirementsMet = true
    local allPenalties = {}
    if self.CheckArmourRequirementsMet and self.GetArmourTotalPenalties then
        requirementsMet = self:CheckArmourRequirementsMet()
        allPenalties = self:GetArmourTotalPenalties()
    end
    local penaltyMultiplier = requirementsMet and 1 or 2

    local function getPenalty(key)
        if not key then return 0 end
        return math.abs(tonumber(allPenalties[key]) or 0) * penaltyMultiplier
    end

    local rollValue = tonumber(roll)
    local lowValue = tonumber(low)
    local highValue = tonumber(high)

    if self.pendingTalentRoll and (lowValue == self.pendingTalentRoll.min and highValue == self.pendingTalentRoll.max) then
        local armorPenalty = getPenalty(self.pendingTalentRoll.attributeName) + getPenalty(self.pendingTalentRoll.talentName)
        
        local total = rollValue + self.pendingTalentRoll.attributeValue + self.pendingTalentRoll.talentValue - armorPenalty
        if self.pendingTalentRoll.hasModifier then
            total = total + self.pendingTalentRoll.modifierValue
        end
        local localizedAttr = addon:GetLocalizedText(self.pendingTalentRoll.attributeName)
        local localizedTal = addon:GetLocalizedText(self.pendingTalentRoll.talentName)
        local displayName = self.GetRollDisplayNameWithColor and self:GetRollDisplayNameWithColor()
            or (self.GetRollDisplayName and self:GetRollDisplayName())
            or addonName

        local formattedRoll = qa.formatRollValue(rollValue)
        local finalMessage = displayName .. " tira "
            .. " 1D20 (" .. formattedRoll .. ") + "
        .. localizedAttr .. " (" .. self.pendingTalentRoll.attributeValue .. ") + "
        .. localizedTal .. " (" .. self.pendingTalentRoll.talentValue .. ")"
            .. qa.buildModifierSegment(self.pendingTalentRoll.hasModifier, self.pendingTalentRoll.modifierValue)
            .. (armorPenalty > 0 and (" - Armadura (" .. armorPenalty .. ")") or "")
            .. " = " .. total

        print(finalMessage)

        if self.BroadcastRollMessage then
            self:BroadcastRollMessage(finalMessage)
        end

        self.pendingTalentRoll = nil
    elseif self.pendingAttributeRoll and (lowValue == self.pendingAttributeRoll.min and highValue == self.pendingAttributeRoll.max) then
        local armorPenalty = getPenalty(self.pendingAttributeRoll.attributeName)
        local total = rollValue + self.pendingAttributeRoll.attributeValue - armorPenalty
        if self.pendingAttributeRoll.hasModifier then
            total = total + self.pendingAttributeRoll.modifierValue
        end
        local localizedAttr = addon:GetLocalizedText(self.pendingAttributeRoll.attributeName)
        local displayName = self.GetRollDisplayNameWithColor and self:GetRollDisplayNameWithColor()
            or (self.GetRollDisplayName and self:GetRollDisplayName())
            or addonName
        local formattedRoll = qa.formatRollValue(rollValue)
        local finalMessage = displayName .. " tira "
            .. localizedAttr
            .. " 1D20 (" .. formattedRoll .. ") + "
            .. localizedAttr .. " (" .. self.pendingAttributeRoll.attributeValue .. ")"
            .. qa.buildModifierSegment(self.pendingAttributeRoll.hasModifier, self.pendingAttributeRoll.modifierValue)
            .. (armorPenalty > 0 and (" - Armadura (" .. armorPenalty .. ")") or "")
            .. " = " .. total

        print(finalMessage)

        if self.BroadcastRollMessage then
            self:BroadcastRollMessage(finalMessage)
        end

        self.pendingAttributeRoll = nil
    elseif self.pendingAttackRoll and (lowValue == self.pendingAttackRoll.min and highValue == self.pendingAttackRoll.max) then
        local armorPenalty = getPenalty(self.pendingAttackRoll.talentKey)
        local total = rollValue + self.pendingAttackRoll.talentValue - armorPenalty
        if self.pendingAttackRoll.hasModifier then
            total = total + self.pendingAttackRoll.modifierValue
        end
        local displayName = self.GetRollDisplayNameWithColor and self:GetRollDisplayNameWithColor()
            or (self.GetRollDisplayName and self:GetRollDisplayName())
            or addonName
        local talentLabel = addon:GetLocalizedText(self.pendingAttackRoll.talentKey or self.pendingAttackRoll.talentLabel)
        local formattedRoll = qa.formatRollValue(rollValue)
        local finalMessage = displayName .. " tira 1D" .. self.pendingAttackRoll.diceSides
            .. " (" .. formattedRoll .. ") + "
            .. talentLabel .. " (" .. self.pendingAttackRoll.talentValue .. ")"
            .. qa.buildModifierSegment(self.pendingAttackRoll.hasModifier, self.pendingAttackRoll.modifierValue)
            .. (armorPenalty > 0 and (" - Armadura (" .. armorPenalty .. ")") or "")
            .. " = " .. total

        print(finalMessage)

        if self.BroadcastRollMessage then
            self:BroadcastRollMessage(finalMessage)
        end

        self.pendingAttackRoll = nil
    elseif self.pendingInitiativeRoll and (lowValue == self.pendingInitiativeRoll.min and highValue == self.pendingInitiativeRoll.max) then
        local armorPenalty = getPenalty("initiative")
        local plainDisplayName = self.GetRollDisplayName and self:GetRollDisplayName() or addonName
        local displayName = self.GetRollDisplayNameWithColor and self:GetRollDisplayNameWithColor()
            or plainDisplayName
            or addonName
        local formattedRoll = qa.formatInitiativeRollValue(rollValue)
        local modifierValue = self.pendingInitiativeRoll.modifierValue or 0
        local hasModifier = self.pendingInitiativeRoll.hasModifier
        local finalMessage
        if hasModifier then
            local total = rollValue + modifierValue - armorPenalty
            finalMessage = displayName .. " tira por Iniciativa: " .. formattedRoll
                .. qa.buildModifierSegment(true, modifierValue)
                .. (armorPenalty > 0 and (" - Armadura (" .. armorPenalty .. ")") or "")
                .. " = " .. total
        else
            local total = rollValue - armorPenalty
            finalMessage = displayName .. " tira por Iniciativa: " .. formattedRoll
                .. (armorPenalty > 0 and (" - Armadura (" .. armorPenalty .. ") = " .. total) or "")
        end

        print(finalMessage)

        if self.BroadcastRollMessage then
            self:BroadcastRollMessage(finalMessage)
        end

        self.pendingInitiativeRoll = nil
    else
        return
    end
end
