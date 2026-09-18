local addonName, GAC = ...

local Dispatcher = {}
GAC.Dispatcher = Dispatcher

local handlers = {}

function Dispatcher:Register(actionType, callback)
    if type(actionType) ~= "string" or type(callback) ~= "function" then
        return
    end

    handlers[actionType] = handlers[actionType] or {}
    table.insert(handlers[actionType], callback)
end

function Dispatcher:Dispatch(actionType, payload)
    if not actionType or not handlers[actionType] then
        return
    end

    for _, callback in ipairs(handlers[actionType]) do
        if GAC.SafeCall then
            GAC:SafeCall(callback, payload, actionType)
        else
            pcall(callback, payload, actionType)
        end
    end
end
