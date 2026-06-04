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
            local modStr = ""
            if self.pendingTalentRoll.hasModifier then
                local modVal = tonumber(self.pendingTalentRoll.modifierValue) or 0
                if modVal ~= 0 then
                    total = total + modVal
                    modStr = " + Mod (" .. modVal .. ")"
                end
            end
   
            local displayName = self.GetRollDisplayNameWithColor and self:GetRollDisplayNameWithColor()
                or (self.GetRollDisplayName and self:GetRollDisplayName())
                or displayAddonName
            local formattedRoll = self.FormatRollValue and self:FormatRollValue(rollValue) or tostring(rollValue)
            finalMessage = displayName .. " tira "
                .. " 1D20 (" .. formattedRoll .. ") + "
                .. self.pendingTalentRoll.attributeName .. " (" .. self.pendingTalentRoll.attributeValue .. ") + "
                .. self.pendingTalentRoll.talentName .. " (" .. self.pendingTalentRoll.talentValue .. ")"
                .. modStr
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
            local modStr = ""
            if self.pendingAttributeRoll.hasModifier then
                local modVal = tonumber(self.pendingAttributeRoll.modifierValue) or 0
                if modVal ~= 0 then
                    total = total + modVal
                    modStr = " + Mod (" .. modVal .. ")"
                end
            end

            local displayName = self.GetRollDisplayNameWithColor and self:GetRollDisplayNameWithColor()
                or (self.GetRollDisplayName and self:GetRollDisplayName())
                or displayAddonName
            local formattedRoll = self.FormatRollValue and self:FormatRollValue(rollValue) or tostring(rollValue)

            finalMessage = displayName .. " tira "
                .. " 1D20 (" .. formattedRoll .. ") + "
                .. self.pendingAttributeRoll.attributeName .. " (" .. self.pendingAttributeRoll.attributeValue .. ")"
                .. modStr
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
            local modStr = ""
            if self.pendingInitiativeRoll.hasModifier then
                local modVal = tonumber(self.pendingInitiativeRoll.modifierValue) or 0
                if modVal ~= 0 then
                    total = total + modVal
                    modStr = " + Mod (" .. modVal .. ")"
                end
            end

            local displayName = self.GetRollDisplayNameWithColor and self:GetRollDisplayNameWithColor()
                or (self.GetRollDisplayName and self:GetRollDisplayName())
                or displayAddonName
            local formattedRoll = self.FormatRollValue and self:FormatRollValue(rollValue) or tostring(rollValue)

            finalMessage = displayName .. " tira por Iniciativa: "
                .. " 1D100 (" .. formattedRoll .. ")"
                .. modStr
                .. " = " .. total

            self.pendingInitiativeRoll = nil
            self.rollType = nil
            
        end

    elseif self.rollType == "attack" then
                if not self.pendingAttackRoll then
            return
        end
        if rollValue and lowValue == self.pendingAttackRoll.min and highValue == self.pendingAttackRoll.max then
            local total = rollValue + self.pendingAttackRoll.talentValue
            local modStr = ""
            if self.pendingAttackRoll.hasModifier then
                local modVal = tonumber(self.pendingAttackRoll.modifierValue) or 0
                if modVal ~= 0 then
                    total = total + modVal
                    modStr = " + Mod (" .. modVal .. ")"
                end
            end

            local displayName = self.GetRollDisplayNameWithColor and self:GetRollDisplayNameWithColor()
                or (self.GetRollDisplayName and self:GetRollDisplayName())
                or displayAddonName
            local formattedRoll = self.FormatRollValue and self:FormatRollValue(rollValue) or tostring(rollValue)

            finalMessage = displayName .. " tira "
                .. " 1D" .. self.pendingAttackRoll.max .. " (" .. formattedRoll .. ") + "
                .. self.pendingAttackRoll.talentName .. " (" .. self.pendingAttackRoll.talentValue .. ")"
                .. modStr
                .. " = " .. total

            self.pendingAttackRoll = nil
            self.rollType = nil
            
           
        end
    elseif self.rollType == "custom" then
        if not self.pendingCustomRoll then
            return
        end
        if rollValue and lowValue == 1 and highValue == self.pendingCustomRoll.faces then
            local total = rollValue
            local modStr = ""
            if self.pendingCustomRoll.hasModifier then
                local modVal = tonumber(self.pendingCustomRoll.modifierValue) or 0
                if modVal ~= 0 then
                    total = total + modVal
                    modStr = " + Mod (" .. modVal .. ")"
                end
            end

            local displayName = self.GetRollDisplayNameWithColor and self:GetRollDisplayNameWithColor()
                or (self.GetRollDisplayName and self:GetRollDisplayName())
                or displayAddonName
            local formattedRoll = self.FormatRollValue and self:FormatRollValue(rollValue) or tostring(rollValue)

            local rollMessage = displayName .. " tira "
                .. " 1D" .. self.pendingCustomRoll.faces .. " (" .. formattedRoll .. ")"
                .. modStr
                .. " = " .. total

            print(rollMessage)
            if self.BroadcastRollMessage then self:BroadcastRollMessage(rollMessage) end

            self.pendingCustomRoll.quantity = self.pendingCustomRoll.quantity - 1
            if self.pendingCustomRoll.quantity <= 0 then
                self.pendingCustomRoll = nil
                self.rollType = nil
            end
            
            -- Retornamos para evitar el print final del archivo
            return
        end
    end

    if finalMessage then
        print(finalMessage)
        if self.BroadcastRollMessage then self:BroadcastRollMessage(finalMessage) end
    end
end

