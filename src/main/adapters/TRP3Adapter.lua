--- @module adapters.TRP3Adapter
-- Defensive read-only infrastructure adapter for Total RP 3 profile integration.

local TRP3Adapter = {}
TRP3Adapter.__index = TRP3Adapter

--- Factory method to instantiate TRP3Adapter.
-- @return table TRP3Adapter instance
function TRP3Adapter.create()
    local instance = setmetatable({}, TRP3Adapter)
    return instance
end

--- Safely checks if TRP3 global API is active.
-- @return boolean Is TRP3 loaded
function TRP3Adapter:IsTRP3Available()
    return type(_G.TRP3_API) == "table"
end

--- Safely executes function call and returns result or nil.
local function safeCall(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, res = pcall(fn, ...)
    return ok and res or nil
end

--- Retrieves active player profile name defensively.
-- @return string Profile name or default fallback
function TRP3Adapter:GetPlayerProfileName()
    if self:IsTRP3Available() and GAC and GAC.GetActiveTRP3ProfileName then
        local name = safeCall(GAC.GetActiveTRP3ProfileName, GAC)
        if name and name ~= "" then return name end
    end

    if type(_G.UnitName) == "function" then
        local unitName = _G.UnitName("player")
        if unitName and unitName ~= "" then return unitName end
    end

    return "Desconocido"
end

--- Retrieves active player profile race defensively.
-- @return string Profile race or fallback
function TRP3Adapter:GetPlayerProfileRace()
    if self:IsTRP3Available() and GAC and GAC.GetActiveTRP3ProfileRace then
        local race = safeCall(GAC.GetActiveTRP3ProfileRace, GAC)
        if race and race ~= "" then return race end
    end

    if type(_G.UnitRace) == "function" then
        local race = _G.UnitRace("player")
        if race and race ~= "" then return race end
    end

    return "Humano"
end

--- Retrieves active player profile class defensively.
-- @return string Profile class or fallback
function TRP3Adapter:GetPlayerProfileClass()
    if self:IsTRP3Available() and GAC and GAC.GetActiveTRP3ProfileClass then
        local cls = safeCall(GAC.GetActiveTRP3ProfileClass, GAC)
        if cls and cls ~= "" then return cls end
    end

    if type(_G.UnitClass) == "function" then
        local cls = _G.UnitClass("player")
        if cls and cls ~= "" then return cls end
    end

    return "Guerrero"
end

return TRP3Adapter
