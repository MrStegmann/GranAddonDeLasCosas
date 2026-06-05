local _, GAC = ...

GAC.targetDataCache = {}

function GAC:InitializeReceiver()
    local receiverFrame = CreateFrame("Frame")
    receiverFrame:RegisterEvent("CHAT_MSG_ADDON")
    
    receiverFrame:SetScript("OnEvent", function(self, event, prefix, text, channel, sender, target, zoneChannelID, localID, name, instanceID)
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
            end
        end
    end)
end
