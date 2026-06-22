local addonName, GAC = ...
local displayAddonName = GAC.name or addonName or "GranAddonDeLasCosas"

function GAC:CHAT_MSG_SYSTEM(message) 
    GAC:SafeCall(function()
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
            local armorPen = 0
            if GAC.GetArmorPenalty then
                armorPen = GAC:GetArmorPenalty(self.pendingTalentRoll.talentName) + GAC:GetArmorPenalty(self.pendingTalentRoll.attributeName)
            end
            
            local total = rollValue + self.pendingTalentRoll.attributeValue + self.pendingTalentRoll.talentValue + armorPen
            
            local modStr = ""
            if self.pendingTalentRoll.hasModifier then
                local modVal = tonumber(self.pendingTalentRoll.modifierValue) or 0
                if modVal ~= 0 then
                    total = total + modVal
                    modStr = " + Mod (" .. modVal .. ")"
                end
            end
            
            local worgenModStr = ""
            if self.pendingTalentRoll.worgenModifier and self.pendingTalentRoll.worgenModifier ~= 0 then
                total = total + self.pendingTalentRoll.worgenModifier
                worgenModStr = " + Huargen (" .. self.pendingTalentRoll.worgenModifier .. ")"
            end
            
            local armorModStr = ""
            if armorPen ~= 0 then
                armorModStr = " + Armadura (" .. armorPen .. ")"
            end
   
            local displayName = self.GetRollDisplayNameWithColor and self:GetRollDisplayNameWithColor()
                or (self.GetRollDisplayName and self:GetRollDisplayName())
                or displayAddonName
            local formattedRoll = self.FormatRollValue and self:FormatRollValue(rollValue) or tostring(rollValue)
            finalMessage = displayName .. " tira "
                .. " 1D20 (" .. formattedRoll .. ") + "
                .. GAC:_(self.pendingTalentRoll.attributeName) .. " (" .. self.pendingTalentRoll.attributeValue .. ") + "
                .. GAC:_(self.pendingTalentRoll.talentName) .. " (" .. self.pendingTalentRoll.talentValue .. ")"
                .. modStr
                .. worgenModStr
                .. armorModStr
                .. " = " .. total

            self.pendingTalentRoll = nil
            self.rollType = nil
            
        end
    elseif self.rollType == "attribute" then
        if not self.pendingAttributeRoll then
            return
        end
        if rollValue and lowValue == self.pendingAttributeRoll.min and highValue == self.pendingAttributeRoll.max then
            local armorPen = 0
            if GAC.GetArmorPenalty then
                armorPen = GAC:GetArmorPenalty(self.pendingAttributeRoll.attributeName)
            end
            
            local total = rollValue + self.pendingAttributeRoll.attributeValue + armorPen
            
            local modStr = ""
            if self.pendingAttributeRoll.hasModifier then
                local modVal = tonumber(self.pendingAttributeRoll.modifierValue) or 0
                if modVal ~= 0 then
                    total = total + modVal
                    modStr = " + Mod (" .. modVal .. ")"
                end
            end
            
            local armorModStr = ""
            if armorPen ~= 0 then
                armorModStr = " + Armadura (" .. armorPen .. ")"
            end

            local displayName = self.GetRollDisplayNameWithColor and self:GetRollDisplayNameWithColor()
                or (self.GetRollDisplayName and self:GetRollDisplayName())
                or displayAddonName
            local formattedRoll = self.FormatRollValue and self:FormatRollValue(rollValue) or tostring(rollValue)

            finalMessage = displayName .. " tira "
                .. " 1D20 (" .. formattedRoll .. ") + "
                .. GAC:_(self.pendingAttributeRoll.attributeName) .. " (" .. self.pendingAttributeRoll.attributeValue .. ")"
                .. modStr
                .. armorModStr
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
            
            if GAC.AddInitiativeRoll then
                local shortName = Ambiguate(UnitName("player"), "none")
                GAC:AddInitiativeRoll(shortName, total)
                if GAC.BroadcastInitiativeAdd then
                    GAC:BroadcastInitiativeAdd(shortName, total)
                end
            end
        end

    elseif self.rollType == "attack" then
                if not self.pendingAttackRoll then
            return
        end
        if rollValue and lowValue == self.pendingAttackRoll.min and highValue == self.pendingAttackRoll.max then
            local armorPen = 0
            if GAC.GetArmorPenalty and self.pendingAttackRoll.talentKey then
                armorPen = GAC:GetArmorPenalty(self.pendingAttackRoll.talentKey)
            end
            
            local total = rollValue + self.pendingAttackRoll.talentValue + armorPen
            
            local modStr = ""
            if self.pendingAttackRoll.hasModifier then
                local modVal = tonumber(self.pendingAttackRoll.modifierValue) or 0
                if modVal ~= 0 then
                    total = total + modVal
                    modStr = " + Mod (" .. modVal .. ")"
                end
            end
            
            local armorModStr = ""
            if armorPen ~= 0 then
                armorModStr = " + Armadura (" .. armorPen .. ")"
            end

            local displayName = self.GetRollDisplayNameWithColor and self:GetRollDisplayNameWithColor()
                or (self.GetRollDisplayName and self:GetRollDisplayName())
                or displayAddonName
            local formattedRoll = self.FormatRollValue and self:FormatRollValue(rollValue) or tostring(rollValue)

            if self.pendingAttackRoll.targetZone then
                finalMessage = displayName .. " ataca a " .. self.pendingAttackRoll.targetZone .. ": "
            else
                finalMessage = displayName .. " tira Ataque: "
            end

            local dmgSuffix = ""
            if self.pendingAttackRoll.damageLabel then
                dmgSuffix = " (" .. self.pendingAttackRoll.damageLabel .. ")"
            end
            
            finalMessage = finalMessage
                .. " 1D" .. self.pendingAttackRoll.max .. " (" .. formattedRoll .. ") + "
                .. self.pendingAttackRoll.talentName .. " (" .. self.pendingAttackRoll.talentValue .. ")"
                .. modStr
                .. armorModStr
                .. " = " .. total .. dmgSuffix

            if self.pendingAttackRoll.targetZone and self.pendingAttackRoll.damageType and UnitExists("target") and UnitIsPlayer("target") then
                local targetName = GetUnitName("target", true)
                local shortTargetName = Ambiguate(targetName, "none")
                local payload = "ARMOR_HIT:" .. tostring(self.pendingAttackRoll.targetZoneId) .. ":" .. tostring(self.pendingAttackRoll.damageType) .. ":" .. tostring(total)
                C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX or "GAC_Sync", payload, "WHISPER", shortTargetName)
            end

            self.pendingAttackRoll = nil
            self.rollType = nil
            
           
        end
    elseif self.rollType == "weapon" then
        if not self.pendingWeaponRoll then
            return
        end
        if rollValue and lowValue == 1 and highValue == self.pendingWeaponRoll.damage then
            table.insert(self.pendingWeaponRoll.rolls, rollValue)
            self.pendingWeaponRoll.currentTotal = self.pendingWeaponRoll.currentTotal + rollValue
            self.pendingWeaponRoll.quantity = self.pendingWeaponRoll.quantity - 1
            
            if self.pendingWeaponRoll.quantity <= 0 then
                local armorPen = 0
                if GAC.GetArmorPenalty and self.pendingWeaponRoll.talentKey ~= "" then
                    armorPen = GAC:GetArmorPenalty(self.pendingWeaponRoll.talentKey)
                end
                
                local total = self.pendingWeaponRoll.currentTotal + self.pendingWeaponRoll.talentValue + armorPen + (self.pendingWeaponRoll.weaponModifier or 0)
                
                local modStr = ""
                if self.pendingWeaponRoll.hasModifier then
                    local modVal = tonumber(self.pendingWeaponRoll.modifierValue) or 0
                    if modVal ~= 0 then
                        total = total + modVal
                        modStr = " + Mod (" .. modVal .. ")"
                    end
                end
                
                local wModStr = ""
                if self.pendingWeaponRoll.weaponModifier and self.pendingWeaponRoll.weaponModifier ~= 0 then
                    wModStr = " + Mejora (+" .. self.pendingWeaponRoll.weaponModifier .. ")"
                end
                
                local armorModStr = ""
                if armorPen ~= 0 then
                    armorModStr = " + Armadura (" .. armorPen .. ")"
                end

                local displayName = self.GetRollDisplayNameWithColor and self:GetRollDisplayNameWithColor()
                    or (self.GetRollDisplayName and self:GetRollDisplayName())
                    or displayAddonName
                
                local rollsStr = table.concat(self.pendingWeaponRoll.rolls, ", ")
                local diceFormula = self.pendingWeaponRoll.diceNumber .. "D" .. self.pendingWeaponRoll.damage
                local talentKeyLoc = GAC:_(self.pendingWeaponRoll.talentKey)
                if talentKeyLoc == self.pendingWeaponRoll.talentKey then talentKeyLoc = "Talento" end

                local dmgTypeES = { piercing = "Perforante", crushing = "Contundente", slashing = "Cortante" }
                local dtLoc = dmgTypeES[self.pendingWeaponRoll.damageType] or self.pendingWeaponRoll.damageType
                
                local rollMessage = displayName
                if self.pendingWeaponRoll.targetZone then
                    rollMessage = rollMessage .. " ataca a " .. self.pendingWeaponRoll.targetZone .. " [con " .. self.pendingWeaponRoll.weaponName .. "]: "
                else
                    rollMessage = rollMessage .. " tira Daño (" .. self.pendingWeaponRoll.weaponName .. "): "
                end
                
                rollMessage = rollMessage .. diceFormula .. " (" .. rollsStr .. ") + "
                    .. talentKeyLoc .. " (" .. self.pendingWeaponRoll.talentValue .. ")"
                    .. wModStr
                    .. modStr
                    .. armorModStr
                    .. " = " .. total .. " (" .. dtLoc .. ")"

                print(rollMessage)
                if self.BroadcastRollMessage then self:BroadcastRollMessage(rollMessage) end

                if self.pendingWeaponRoll.targetZone and UnitExists("target") and UnitIsPlayer("target") then
                    local targetName = GetUnitName("target", true)
                    local shortTargetName = Ambiguate(targetName, "none")
                    local payload = "ARMOR_HIT:" .. tostring(self.pendingWeaponRoll.targetZoneId) .. ":" .. tostring(self.pendingWeaponRoll.damageType) .. ":" .. tostring(total)
                    C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX or "GAC_Sync", payload, "WHISPER", shortTargetName)
                end

                self.pendingWeaponRoll = nil
                self.rollType = nil
            end
            return
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
    end)
end

