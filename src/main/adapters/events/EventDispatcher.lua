--- @module adapters.events.EventDispatcher
-- Driving Adapter: Encapsulates raw WoW event frame listening and dispatches clean internal signals.

local EventDispatcher = {}
EventDispatcher.__index = EventDispatcher

--- Factory method to instantiate the EventDispatcher.
-- @return table EventDispatcher instance
function EventDispatcher.create()
    local instance = setmetatable({}, EventDispatcher)
    instance.listeners = {}

    -- Create WoW frame safely if CreateFrame global is available
    if type(CreateFrame) == "function" then
        local frame = CreateFrame("Frame", "GAC_EventDispatcherFrame")
        instance.frame = frame

        frame:SetScript("OnEvent", function(_, event, ...)
            instance:Dispatch(event, ...)
        end)
    end

    return instance
end

--- Registers an internal listener for a WoW frame event.
-- @param event string Event name (e.g. "ADDON_LOADED")
-- @param handler function Callback function receiving unpacked event payload
function EventDispatcher:RegisterEvent(event, handler)
    if type(event) ~= "string" or type(handler) ~= "function" then return end

    if not self.listeners[event] then
        self.listeners[event] = {}
        if self.frame and type(self.frame.RegisterEvent) == "function" then
            self.frame:RegisterEvent(event)
        end
    end

    table.insert(self.listeners[event], handler)
end

--- Unregisters an event listener.
-- @param event string Event name
-- @param handler function Callback function to remove
function EventDispatcher:UnregisterEvent(event, handler)
    if type(event) ~= "string" or not self.listeners[event] then return end

    for i = #self.listeners[event], 1, -1 do
        if self.listeners[event][i] == handler then
            table.remove(self.listeners[event], i)
        end
    end

    if #self.listeners[event] == 0 then
        self.listeners[event] = nil
        if self.frame and type(self.frame.UnregisterEvent) == "function" then
            self.frame:UnregisterEvent(event)
        end
    end
end

--- Internal dispatcher notifying all registered handlers of an event payload.
-- @param event string Event name
-- @param ... vararg Event payload arguments
function EventDispatcher:Dispatch(event, ...)
    local handlers = self.listeners[event]
    if not handlers then return end

    for _, handler in ipairs(handlers) do
        local ok, err = pcall(handler, ...)
        if not ok and err then
            if geterrorhandler then
                geterrorhandler()(err)
            end
        end
    end
end

return EventDispatcher
