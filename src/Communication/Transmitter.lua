local _, GAC = ...

GAC.COMM_PREFIX = "GAC_Sync"

GAC.Transmitter = {
    events = {}
}

function GAC.Transmitter:AddEvent(eventName, callback)
    if type(eventName) ~= "string" then return print("[GAC:ERROR] Event name must be a string") end
    if self.events[eventName] then return print("[GAC:ERROR] Event " .. eventName .. " already exists") end
    if type(callback) ~= "function" then return print("[GAC:ERROR] Callback must be a function") end

    self.events[eventName] = callback
end

function GAC.Transmitter:Trigger(eventName, ...)
    if self.events[eventName] then
        self.events[eventName](...)
    else
        print("[GAC:ERROR] Event " .. eventName .. " does not exist")
    end
end

function GAC:InitializeTransmitter()
    -- Solo nos aseguramos de que el prefijo esté registrado
    C_ChatInfo.RegisterAddonMessagePrefix(self.COMM_PREFIX)
end



