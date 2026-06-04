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
                    GAC:SendPlayerData(shortSender)
                end
            elseif string.sub(text, 1, 4) == "RES:" then
                -- Recibimos datos de alguien
                local payload = string.sub(text, 5) -- Quita "RES:"
                local level, category, maxHealth = strsplit(":", payload)
                
                if level and category and maxHealth then
                    GAC.targetDataCache[shortSender] = {
                        level = tonumber(level) or 1,
                        category = category,
                        maxHealth = tonumber(maxHealth) or 10,
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
            end
        end
    end)
end
