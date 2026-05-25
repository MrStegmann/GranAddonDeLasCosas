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

    local rollValue = tonumber(roll)
    local lowValue = tonumber(low)
    local highValue = tonumber(high)
    if self.pendingTalentRoll and (lowValue == self.pendingTalentRoll.min and highValue == self.pendingTalentRoll.max) then
        local total = rollValue + self.pendingTalentRoll.attributeValue + self.pendingTalentRoll.talentValue
        if self.pendingTalentRoll.hasModifier then
            total = total + self.pendingTalentRoll.modifierValue
        end
        local displayName = self.GetRollDisplayNameWithColor and self:GetRollDisplayNameWithColor()
            or (self.GetRollDisplayName and self:GetRollDisplayName())
            or addonName
        local formattedRoll = qa.formatRollValue(rollValue)
        local finalMessage = displayName .. " tira "
            .. " 1D20 (" .. formattedRoll .. ") + "
            .. self.pendingTalentRoll.attributeName .. " (" .. self.pendingTalentRoll.attributeValue .. ") + "
            .. self.pendingTalentRoll.talentName .. " (" .. self.pendingTalentRoll.talentValue .. ")"
            .. qa.buildModifierSegment(self.pendingTalentRoll.hasModifier, self.pendingTalentRoll.modifierValue)
            .. " = " .. total

        print(finalMessage)

        if self.BroadcastRollMessage then
            self:BroadcastRollMessage(finalMessage)
        end

        self.pendingTalentRoll = nil
    elseif self.pendingAttributeRoll and (lowValue == self.pendingAttributeRoll.min and highValue == self.pendingAttributeRoll.max) then
        local total = rollValue + self.pendingAttributeRoll.attributeValue
        if self.pendingAttributeRoll.hasModifier then
            total = total + self.pendingAttributeRoll.modifierValue
        end
        local displayName = self.GetRollDisplayNameWithColor and self:GetRollDisplayNameWithColor()
            or (self.GetRollDisplayName and self:GetRollDisplayName())
            or addonName
        local formattedRoll = qa.formatRollValue(rollValue)
        local finalMessage = displayName .. " tira "
            .. self.pendingAttributeRoll.attributeName
            .. " 1D20 (" .. formattedRoll .. ") + "
            .. self.pendingAttributeRoll.attributeName .. " (" .. self.pendingAttributeRoll.attributeValue .. ")"
            .. qa.buildModifierSegment(self.pendingAttributeRoll.hasModifier, self.pendingAttributeRoll.modifierValue)
            .. " = " .. total

        print(finalMessage)

        if self.BroadcastRollMessage then
            self:BroadcastRollMessage(finalMessage)
        end

        self.pendingAttributeRoll = nil
    elseif self.pendingAttackRoll and (lowValue == self.pendingAttackRoll.min and highValue == self.pendingAttackRoll.max) then
        local total = rollValue + self.pendingAttackRoll.talentValue
        if self.pendingAttackRoll.hasModifier then
            total = total + self.pendingAttackRoll.modifierValue
        end
        local displayName = self.GetRollDisplayNameWithColor and self:GetRollDisplayNameWithColor()
            or (self.GetRollDisplayName and self:GetRollDisplayName())
            or addonName
        local formattedRoll = qa.formatRollValue(rollValue)
        local finalMessage = displayName .. " tira 1D" .. self.pendingAttackRoll.diceSides
            .. " (" .. formattedRoll .. ") + "
            .. self.pendingAttackRoll.talentLabel .. " (" .. self.pendingAttackRoll.talentValue .. ")"
            .. qa.buildModifierSegment(self.pendingAttackRoll.hasModifier, self.pendingAttackRoll.modifierValue)
            .. " = " .. total

        print(finalMessage)

        if self.BroadcastRollMessage then
            self:BroadcastRollMessage(finalMessage)
        end

        self.pendingAttackRoll = nil
    elseif self.pendingInitiativeRoll and (lowValue == self.pendingInitiativeRoll.min and highValue == self.pendingInitiativeRoll.max) then
        local plainDisplayName = self.GetRollDisplayName and self:GetRollDisplayName() or addonName
        local displayName = self.GetRollDisplayNameWithColor and self:GetRollDisplayNameWithColor()
            or plainDisplayName
            or addonName
        local formattedRoll = qa.formatInitiativeRollValue(rollValue)
        local modifierValue = self.pendingInitiativeRoll.modifierValue or 0
        local hasModifier = self.pendingInitiativeRoll.hasModifier
        local finalMessage
        if hasModifier then
            local total = rollValue + modifierValue
            finalMessage = displayName .. " tira por Iniciativa: " .. formattedRoll
                .. qa.buildModifierSegment(true, modifierValue)
                .. " = " .. total
        else
            finalMessage = displayName .. " tira por Iniciativa: " .. formattedRoll
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

