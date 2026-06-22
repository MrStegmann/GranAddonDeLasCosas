local _, GAC = ...

GAC.targetDataCache = {}

function GAC:InitializeReceiver()
    local receiverFrame = CreateFrame("Frame")
    receiverFrame:RegisterEvent("CHAT_MSG_ADDON")
    
    receiverFrame:SetScript("OnEvent", function(self, event, prefix, text, channel, sender, target, zoneChannelID, localID, name, instanceID)
        GAC:SafeCall(function()
            if event == "CHAT_MSG_ADDON" and prefix == GAC.COMM_PREFIX then
                -- Limpiamos el nombre del sender para quitar el servidor si estamos en el mismo
            local shortSender = Ambiguate(sender, "none")
            
            if text == "REQ" then
                -- Alguien solicita nuestros datos
                if GAC.SendPlayerData then
                    GAC.requestersCache = GAC.requestersCache or {}
                    GAC.requestersCache[shortSender] = GetTime()
                    GAC:SendPlayerData(shortSender)
                end
            elseif string.sub(text, 1, 4) == "RES:" then
                -- Recibimos datos de alguien
                local payload = string.sub(text, 5) -- Quita "RES:"
                local level, category, maxHealth, currentHealth, currentShield = strsplit(":", payload)
                
                if level and category and maxHealth then
                    GAC.targetDataCache[shortSender] = {
                        level = tonumber(level) or 1,
                        category = category,
                        maxHealth = tonumber(maxHealth) or 10,
                        currentHealth = tonumber(currentHealth) or tonumber(maxHealth) or 10,
                        currentShield = tonumber(currentShield) or 0,
                        timestamp = GetTime()
                    }
                    
                    -- Si el jugador que acabamos de recibir es nuestro objetivo actual, actualizamos el plate
                    local currentTargetName = UnitName("target")
                    if currentTargetName and currentTargetName == shortSender then
                        if GAC.UpdateTargetPlate then
                            GAC:UpdateTargetPlate()
                        end
                        if GAC.UpdateTargetInspectButtonVisibility then
                            GAC:UpdateTargetInspectButtonVisibility()
                        end
                    end
                end
            elseif string.sub(text, 1, 5) == "ROLL:" then
                local rollMessage = string.sub(text, 6)
                if shortSender ~= UnitName("player") then
                    GAC.recentRolls = GAC.recentRolls or {}
                    local rollKey = shortSender .. ":" .. rollMessage
                    local now = GetTime()
                    
                    -- Si no lo hemos recibido en el último segundo (evita duplicados si llega por PARTY y por WHISPER)
                    if not GAC.recentRolls[rollKey] or (now - GAC.recentRolls[rollKey]) > 1 then
                        GAC.recentRolls[rollKey] = now
                        print(rollMessage)
                    end
                end
            elseif string.sub(text, 1, 5) == "INIT:" then
                local initPayload = string.sub(text, 6)
                if shortSender ~= UnitName("player") then
                    if string.sub(initPayload, 1, 4) == "ADD:" then
                        local data = string.sub(initPayload, 5)
                        local initName, initTotal = strsplit(":", data)
                        if initName and initTotal and GAC.AddInitiativeRoll then
                            GAC:AddInitiativeRoll(initName, initTotal)
                        end
                    elseif string.sub(initPayload, 1, 7) == "ACTION:" then
                        local action = string.sub(initPayload, 8)
                        if action == "CLEAR" and GAC.ClearInitiativeOrder then
                            GAC:ClearInitiativeOrder()
                        elseif action == "SORT" and GAC.SortInitiativeOrder then
                            GAC:SortInitiativeOrder()
                        end
                    elseif string.sub(initPayload, 1, 5) == "MOVE:" then
                        local data = string.sub(initPayload, 6)
                        local fromStr, toStr = strsplit(":", data)
                        local fromIdx = tonumber(fromStr)
                        local toIdx = tonumber(toStr)
                        if fromIdx and toIdx and GAC.MoveInitiativeIndex then
                            GAC:MoveInitiativeIndex(fromIdx, toIdx)
                        end
                    elseif string.sub(initPayload, 1, 5) == "ICON:" then
                        local data = string.sub(initPayload, 6)
                        local idxStr, iconStr = strsplit(":", data)
                        local idx = tonumber(idxStr)
                        local iconID = tonumber(iconStr)
                        if idx and iconID and GAC.SetInitiativeIcon then
                            GAC:SetInitiativeIcon(idx, iconID)
                        end
                    end
                end
            elseif text == "INSPECT:REQ" then
                if GAC.SendInspectionData then
                    GAC:SendInspectionData(shortSender)
                end
            elseif string.sub(text, 1, 10) == "INSP:INFO:" then
                local data = string.sub(text, 11)
                local level, category, race, class, maxHealth, currentShield, currentExp, maxExp = strsplit(":", data)
                GAC.inspectedPlayer = {
                    name = shortSender,
                    level = tonumber(level) or 1,
                    category = category or "normal",
                    race = race or "Desconocida",
                    class = class or "Desconocida",
                    maxHealth = tonumber(maxHealth) or 10,
                    currentShield = tonumber(currentShield) or 0,
                    currentExp = tonumber(currentExp) or 0,
                    maxExp = tonumber(maxExp) or 0,
                    attributes = {},
                    talents = {}
                }
            elseif string.sub(text, 1, 8) == "ADD_EXP:" then
                local amount = tonumber(string.sub(text, 9))
                if amount and GAC.AddExperience then
                    GAC:AddExperience(amount)
                    GAC:UpdateGameExpBar()
                    print("|cff00ccff[GAC]|r Has recibido " .. amount .. " de experiencia de " .. shortSender .. ".")
                end
            elseif string.sub(text, 1, 9) == "INSP:ATT:" then
                local data = string.sub(text, 10)
                if GAC.inspectedPlayer and GAC.inspectedPlayer.name == shortSender then
                    for pair in string.gmatch(data, "([^;]+)") do
                        local k, v = strsplit("=", pair)
                        if k and v then
                            GAC.inspectedPlayer.attributes[k] = tonumber(v) or 0
                        end
                    end
                end
            elseif string.sub(text, 1, 9) == "INSP:TAL:" then
                local data = string.sub(text, 10)
                if GAC.inspectedPlayer and GAC.inspectedPlayer.name == shortSender then
                    for pair in string.gmatch(data, "([^;]+)") do
                        local k, v = strsplit("=", pair)
                        if k and v then
                            GAC.inspectedPlayer.talents[k] = tonumber(v) or 0
                        end
                    end
                end
            elseif string.sub(text, 1, 9) == "INSP:ADV:" then
                local data = string.sub(text, 10)
                if GAC.inspectedPlayer and GAC.inspectedPlayer.name == shortSender then
                    GAC.inspectedPlayer.advantages = GAC.inspectedPlayer.advantages or {}
                    for pair in string.gmatch(data, "([^;]+)") do
                        local k, v = strsplit("=", pair)
                        if k and v then
                            GAC.inspectedPlayer.advantages[k] = tonumber(v) or 0
                        end
                    end
                end
            elseif string.sub(text, 1, 9) == "INSP:DIS:" then
                local data = string.sub(text, 10)
                if GAC.inspectedPlayer and GAC.inspectedPlayer.name == shortSender then
                    GAC.inspectedPlayer.disadvantages = GAC.inspectedPlayer.disadvantages or {}
                    for pair in string.gmatch(data, "([^;]+)") do
                        local k, v = strsplit("=", pair)
                        if k and v then
                            GAC.inspectedPlayer.disadvantages[k] = tonumber(v) or 0
                        end
                    end
                end
            elseif string.sub(text, 1, 9) == "INSP:SPC:" then
                local data = string.sub(text, 10)
                if GAC.inspectedPlayer and GAC.inspectedPlayer.name == shortSender then
                    GAC.inspectedPlayer.special = GAC.inspectedPlayer.special or {}
                    for spc in string.gmatch(data, "([^;]+)") do
                        table.insert(GAC.inspectedPlayer.special, spc)
                    end
                end
            elseif string.sub(text, 1, 9) == "INSP:RAC:" then
                local data = string.sub(text, 10)
                if GAC.inspectedPlayer and GAC.inspectedPlayer.name == shortSender then
                    local r1, r2, worgen = strsplit(":", data)
                    GAC.inspectedPlayer.race1 = r1 or "Ninguna"
                    GAC.inspectedPlayer.race2 = r2 or "Ninguna"
                    GAC.inspectedPlayer.worgenCurse = (worgen == "1")
                end
            elseif text == "INSP:END" then
                if GAC.inspectedPlayer and GAC.inspectedPlayer.name == shortSender then
                    if GAC.OpenInspectionMenu then
                        GAC:OpenInspectionMenu()
                    end
                end
            elseif string.sub(text, 1, 10) == "ARMOR_HIT:" then
                local payload = string.sub(text, 11)
                local slotIDStr, dmgType, rawDmgStr = strsplit(":", payload)
                local slotID = tonumber(slotIDStr)
                local rawDmg = tonumber(rawDmgStr) or 0
                
                if slotID and GAC.characterData and GAC.characterData.inventory and GAC.characterData.inventory.equippedArmor then
                    local slotIDToKey = { [1] = "head", [5] = "chest", [10] = "hands", [7] = "legs" }
                    local slotKey = slotIDToKey[slotID] or slotID
                    local slotList = GAC.characterData.inventory.equippedArmor[slotKey]
                    
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
                        
                        local selfMsg = "|cff00ccff[GAC]|r " .. shortSender .. " te ha golpeado en " .. zoneName .. " por " .. rawDmg .. " de daño " .. dmgType .. "."
                        if mitigationResult == "vulnerable" then
                            selfMsg = selfMsg .. " ¡Tu armadura es VULNERABLE! (Reducción anulada). Pierdes " .. durabilityLoss .. " de durabilidad."
                            C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX or "GAC_Sync", "MSG:¡Tu ataque ha sido DEVASTADOR contra su armadura!", "WHISPER", shortSender)
                        elseif mitigationResult == "weak" then
                            selfMsg = selfMsg .. " Tu armadura es DÉBIL (Reducción a la mitad). Pierdes " .. durabilityLoss .. " de durabilidad."
                        elseif mitigationResult == "resistant" then
                            selfMsg = selfMsg .. " Tu armadura es RESISTENTE (Reducción doble). Pierdes " .. durabilityLoss .. " de durabilidad."
                        elseif mitigationResult == "very_resistant" then
                            selfMsg = selfMsg .. " ¡Tu armadura es MUY RESISTENTE! Bloqueas el impacto y no sufres daño."
                            C_ChatInfo.SendAddonMessage(GAC.COMM_PREFIX or "GAC_Sync", "MSG:¡Tu ataque ha rebotado contra su armadura! (Sin daño)", "WHISPER", shortSender)
                        else
                            selfMsg = selfMsg .. " Pierdes " .. durabilityLoss .. " de durabilidad."
                        end
                        
                        selfMsg = selfMsg .. " Daño final recibido: " .. finalDmg
                        
                        print(selfMsg)
                    else
                        local selfMsg = "|cff00ccff[GAC]|r " .. shortSender .. " te ha golpeado en " .. zoneName .. " por " .. rawDmg .. " de daño " .. dmgType .. ". ¡No llevas armadura en esa zona! Daño final recibido: " .. finalDmg
                        print(selfMsg)
                    end
                    
                    if finalDmg > 0 then
                        local remainingDmg = finalDmg
                        local currentShield = GAC.characterData.currentShield or 0
                        
                        if currentShield > 0 then
                            if currentShield >= remainingDmg then
                                GAC:ModifyPlayerShield(-remainingDmg)
                                remainingDmg = 0
                            else
                                remainingDmg = remainingDmg - currentShield
                                GAC:ModifyPlayerShield(-currentShield)
                            end
                        end
                        
                        if remainingDmg > 0 then
                            GAC:ModifyPlayerLife(-remainingDmg)
                        end
                    end
                end
            elseif string.sub(text, 1, 4) == "MSG:" then
                local chatMsg = string.sub(text, 5)
                print("|cff00ccff[GAC]|r (" .. shortSender .. "): " .. chatMsg)
            end
            end
        end)
    end)
end
