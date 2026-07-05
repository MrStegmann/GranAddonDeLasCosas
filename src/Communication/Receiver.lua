local _, GAC = ...

GAC.targetDataCache = {}

GAC.Receiver = {
    events = {}
}

function GAC.Receiver:OnEvent(eventPrefix, callback)
    if type(eventPrefix) ~= "string" then return print("[GAC:ERROR] Event prefix must be a string") end
    if not GAC.Transmitter.events[eventPrefix] then 
        return print("[GAC:ERROR] Event " .. eventPrefix .. " does not exist")
    end
    if type(callback) ~= "function" then return print("[GAC:ERROR] Callback must be a function") end

    self.events[eventPrefix] = callback
end

function GAC:InitializeReceiver()
    local receiverFrame = CreateFrame("Frame")
    receiverFrame:RegisterEvent("CHAT_MSG_ADDON")
    
    receiverFrame:SetScript("OnEvent", function(self, event, prefix, text, channel, sender, target, zoneChannelID, localID, name, instanceID)
        GAC:SafeCall(function()
            if event == "CHAT_MSG_ADDON" and prefix == GAC.COMM_PREFIX then
                -- Limpiamos el nombre del sender para quitar el servidor si estamos en el mismo
            local shortSender = Ambiguate(sender, "none")
            
            local matchedEvent = nil
            local matchedLength = -1
            
            for eventPrefix, _ in pairs(GAC.Receiver.events) do
                if text == eventPrefix or string.sub(text, 1, string.len(eventPrefix) + 1) == eventPrefix .. ":" then
                    if string.len(eventPrefix) > matchedLength then
                        matchedEvent = eventPrefix
                        matchedLength = string.len(eventPrefix)
                    end
                end
            end
            
            if matchedEvent then
                GAC:SafeCall(function()
                    local callback = GAC.Receiver.events[matchedEvent]
                    if text == matchedEvent then
                        callback(shortSender, channel)
                    else
                        local payload = string.sub(text, matchedLength + 2)
                        callback(shortSender, channel, strsplit(":", payload))
                    end
                end)
                return
            end
            end -- End of if event == "CHAT_MSG_ADDON"
        end)
    end)
end
