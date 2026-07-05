local _, GAC = ...

GAC.Receiver:OnEvent(GAC.Enums.Events.ROLL, function(sender, channel, rollMessage)
    if sender ~= UnitName("player") then
        GAC.recentRolls = GAC.recentRolls or {}
        local rollKey = sender .. ":" .. rollMessage
        local now = GetTime()
        
        -- Evita duplicados si llega por PARTY y por WHISPER
        if not GAC.recentRolls[rollKey] or (now - GAC.recentRolls[rollKey]) > 1 then
            GAC.recentRolls[rollKey] = now
            print(rollMessage)
        end
    end
end)

GAC.Receiver:OnEvent(GAC.Enums.Events.ARMOR_HIT, function(sender, channel, slotIDStr, dmgType, rawDmgStr)
    local slotID = tonumber(slotIDStr)
    local rawDmg = tonumber(rawDmgStr) or 0
    
    if slotID and GAC.playerCharacter then
        local slotIDToKey = { [1] = "head", [5] = "chest", [10] = "hands", [7] = "legs" }
        local slotKey = slotIDToKey[slotID] or slotID
        local equippedItem = GAC.playerCharacter:GetEquippedItems()[slotKey]
        local slotList = nil
        if type(equippedItem) == "table" and equippedItem.GetVariable then
            slotList = equippedItem:GetVariable().slotList
        end
        
        local hasArmor = slotList and slotList[1] and slotList[1].armorData
        local finalDmg = rawDmg
        local aliasZoneMap = { [1] = "la Cabeza", [5] = "el Pecho", [10] = "las Manos", [7] = "las Piernas" }
        local zoneName = aliasZoneMap[slotID] or "una zona"
        
        if hasArmor then
            local armorItem = slotList[1]
            local armorTypeInfo = GAC:GetArmorTypeInfo(armorItem.armorData.baseKey or GAC:GetArmorKeyByAlias(armorItem.armorData.baseStr))
            
            local durabilityLoss = 1
            local mitigationResult = "normal"
            local physRed = tonumber(armorItem.armorData.physRed) or 0
            local magRed = tonumber(armorItem.armorData.magRed) or 0
            local appliedRed = 0
            
            local isPhysical = false
            
            if armorTypeInfo then
                local engToDmgType = {
                    ["Contundente"] = "crushingDamage",
                    ["Cortante"] = "slashingDamage",
                    ["Perforante"] = "piercingDamage",
                    ["piercing"] = "piercingDamage",
                    ["slashing"] = "slashingDamage",
                    ["crushing"] = "crushingDamage"
                }
                local damageStat = engToDmgType[dmgType]
                if damageStat then
                    isPhysical = true
                    local resistanceVal = armorTypeInfo[damageStat] or 0
                    
                    if armorItem.armorData.hasReinforcement and armorItem.armorData.reinforcementStr then
                        local rInfo = GAC:GetArmorReinforcementInfo(GAC:GetArmorKeyByAlias(armorItem.armorData.reinforcementStr))
                        if rInfo and rInfo[damageStat] then
                            resistanceVal = resistanceVal + rInfo[damageStat]
                        end
                    end
                    
                    if resistanceVal <= -2 then
                        durabilityLoss = 2
                        mitigationResult = "vulnerable"
                    elseif resistanceVal == -1 then
                        durabilityLoss = 1
                        mitigationResult = "weak"
                    elseif resistanceVal == 0 then
                        durabilityLoss = 1
                        mitigationResult = "normal"
                    elseif resistanceVal == 1 then
                        durabilityLoss = 1
                        mitigationResult = "resistant"
                    elseif resistanceVal >= 2 then
                        durabilityLoss = 0
                        mitigationResult = "very_resistant"
                    end
                end
            end
            
            if isPhysical then
                appliedRed = physRed
                if mitigationResult == "vulnerable" then
                    appliedRed = 0
                elseif mitigationResult == "weak" then
                    appliedRed = math.floor(physRed / 2)
                elseif mitigationResult == "resistant" then
                    appliedRed = physRed * 2
                elseif mitigationResult == "very_resistant" then
                    finalDmg = 0
                end
            else
                appliedRed = magRed
            end
            
            if finalDmg > 0 then
                finalDmg = math.max(0, finalDmg - appliedRed)
            end
            
            if durabilityLoss > 0 and GAC.UpdateTRP3ItemDurability then
                GAC:UpdateTRP3ItemDurability(slotKey, -durabilityLoss)
            end
            
            local selfMsg = "|cff00ccff[GAC]|r " .. sender .. " te ha golpeado en " .. zoneName .. " por " .. rawDmg .. " de daño " .. dmgType .. "."
            if mitigationResult == "vulnerable" then
                selfMsg = selfMsg .. " ¡Tu armadura es VULNERABLE! (Reducción anulada). Pierdes " .. durabilityLoss .. " de durabilidad."
                if GAC.Transmitter then GAC.Transmitter:Trigger(GAC.Enums.Events.MSG_ARMOR, sender, "¡Tu ataque ha sido DEVASTADOR contra su armadura!") end
            elseif mitigationResult == "weak" then
                selfMsg = selfMsg .. " Tu armadura es DÉBIL (Reducción a la mitad). Pierdes " .. durabilityLoss .. " de durabilidad."
            elseif mitigationResult == "resistant" then
                selfMsg = selfMsg .. " Tu armadura es RESISTENTE (Reducción doble). Pierdes " .. durabilityLoss .. " de durabilidad."
            elseif mitigationResult == "very_resistant" then
                selfMsg = selfMsg .. " ¡Tu armadura es MUY RESISTENTE! Bloqueas el impacto y no sufres daño."
                if GAC.Transmitter then GAC.Transmitter:Trigger(GAC.Enums.Events.MSG_ARMOR, sender, "¡Tu ataque ha rebotado contra su armadura! (Sin daño)") end
            else
                selfMsg = selfMsg .. " Pierdes " .. durabilityLoss .. " de durabilidad."
            end
            
            selfMsg = selfMsg .. " Daño final recibido: " .. finalDmg
            
            print(selfMsg)
        else
            local selfMsg = "|cff00ccff[GAC]|r " .. sender .. " te ha golpeado en " .. zoneName .. " por " .. rawDmg .. " de daño " .. dmgType .. ". ¡No llevas armadura en esa zona! Daño final recibido: " .. finalDmg
            print(selfMsg)
        end
        
        if finalDmg > 0 then
            local remainingDmg = finalDmg
            local sp = GAC.playerCharacter:GetShieldPoints()
            local currentShield = sp and sp.current or 0
            
            if currentShield > 0 then
                if currentShield >= remainingDmg then
                    if GAC.Transmitter then GAC.Transmitter:Trigger(GAC.Enums.Events.MODIFY_SHIELD, -remainingDmg) end
                    remainingDmg = 0
                else
                    remainingDmg = remainingDmg - currentShield
                    if GAC.Transmitter then GAC.Transmitter:Trigger(GAC.Enums.Events.MODIFY_SHIELD, -currentShield) end
                end
            end
            
            if remainingDmg > 0 then
                if GAC.Transmitter then GAC.Transmitter:Trigger(GAC.Enums.Events.MODIFY_LIFE, -remainingDmg) end
            end
        end
    end
end)

GAC.Receiver:OnEvent(GAC.Enums.Events.MSG_ARMOR, function(sender, channel, msg)
    print("|cff00ccff[GAC]|r (" .. sender .. "): " .. msg)
end)
