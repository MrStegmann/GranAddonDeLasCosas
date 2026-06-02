local addonName, GAC = ...
local displayAddonName = GAC.name or addonName or "GranAddonDeLasCosas"

function GAC:CHAT_MSG_SYSTEM(message) 
    local finalMessage = nil
    self.randomRollPattern = self.randomRollPattern or self:BuildRandomRollPattern()

    local plainMessage = self:StripColorCodes(message)
    local roller, roll, low, high = plainMessage:match(self.randomRollPattern)
    if not roller or not self:IsPlayerRoll(roller) then
        return
    end

    local rollValue = tonumber(roll)
    local lowValue = tonumber(low)
    local highValue = tonumber(high)
    
    if self.rollType == "talent" then
        if not self.pendingTalentRoll then
            return
        end

        if rollValue and lowValue == self.pendingTalentRoll.min and highValue == self.pendingTalentRoll.max then
            local total = rollValue + self.pendingTalentRoll.attributeValue + self.pendingTalentRoll.talentValue
            if self.pendingTalentRoll.hasModifier then
                total = total + (tonumber(self.pendingTalentRoll.modifierValue) or 0)
            end
   
            local displayName = self.GetRollDisplayNameWithColor and self:GetRollDisplayNameWithColor()
                or (self.GetRollDisplayName and self:GetRollDisplayName())
                or displayAddonName
            local formattedRoll = self.FormatRollValue and self:FormatRollValue(rollValue) or tostring(rollValue)
            finalMessage = displayName .. " tira "
                .. " 1D20 (" .. formattedRoll .. ") + "
                .. self.pendingTalentRoll.attributeName .. " (" .. self.pendingTalentRoll.attributeValue .. ") + "
                .. self.pendingTalentRoll.talentName .. " (" .. self.pendingTalentRoll.talentValue .. ")"
                .. " = " .. total

            self.pendingTalentRoll = nil
            self.rollType = nil
        end
    elseif self.rollType == "attribute" then
        if not self.pendingAttributeRoll then
            return
        end
        if rollValue and lowValue == self.pendingAttributeRoll.min and highValue == self.pendingAttributeRoll.max then
            local total = rollValue + self.pendingAttributeRoll.attributeValue
            if self.pendingAttributeRoll.hasModifier then
                total = total + (tonumber(self.pendingAttributeRoll.modifierValue) or 0)
            end

            local displayName = self.GetRollDisplayNameWithColor and self:GetRollDisplayNameWithColor()
                or (self.GetRollDisplayName and self:GetRollDisplayName())
                or displayAddonName
            local formattedRoll = self.FormatRollValue and self:FormatRollValue(rollValue) or tostring(rollValue)

            finalMessage = displayName .. " tira "
                .. " 1D20 (" .. formattedRoll .. ") + "
                .. self.pendingAttributeRoll.attributeName .. " (" .. self.pendingAttributeRoll.attributeValue .. ")"
                .. " = " .. total

            self.pendingAttributeRoll = nil
            self.rollType = nil
        end

    elseif self.rollType == "initiative" then
        if not self.pendingInitiativeRoll then
            return
        end
        if rollValue and lowValue == self.pendingInitiativeRoll.min and highValue == self.pendingInitiativeRoll.max then
            local total = rollValue
            
            if self.pendingInitiativeRoll.hasModifier then
                total = total + (tonumber(self.pendingInitiativeRoll.modifierValue) or 0)
            end

            local displayName = self.GetRollDisplayNameWithColor and self:GetRollDisplayNameWithColor()
                or (self.GetRollDisplayName and self:GetRollDisplayName())
                or displayAddonName
            local formattedRoll = self.FormatRollValue and self:FormatRollValue(rollValue) or tostring(rollValue)

            finalMessage = displayName .. " tira "
                .. " 1D20 (" .. formattedRoll .. ")"
                .. " = " .. total

            self.pendingInitiativeRoll = nil
            self.rollType = nil
        end

    elseif self.rollType == "attack" then
                if not self.pendingAttackRoll then
            return
        end
        if rollValue and lowValue == self.pendingAttackRoll.min and highValue == self.pendingAttackRoll.max then
            local total = rollValue
            
            if self.pendingAttackRoll.hasModifier then
                total = total + (tonumber(self.pendingAttackRoll.modifierValue) or 0)
            end

            local displayName = self.GetRollDisplayNameWithColor and self:GetRollDisplayNameWithColor()
                or (self.GetRollDisplayName and self:GetRollDisplayName())
                or displayAddonName
            local formattedRoll = self.FormatRollValue and self:FormatRollValue(rollValue) or tostring(rollValue)

            finalMessage = displayName .. " tira "
                .. " 1D" .. self.pendingAttackRoll.max .. " (" .. formattedRoll .. ")"
                .. " = " .. total

            self.pendingAttackRoll = nil
            self.rollType = nil
        end
    end

    print(finalMessage)

    -- if self.BroadcastRollMessage and (IsInRaid() or IsInGroup()) then
    --     self:BroadcastRollMessage(finalMessage)
    -- end
end

