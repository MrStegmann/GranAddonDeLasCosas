--- @module TR3Bridge.characteristics
--- Port bridge for retrieving Total RP 3 character profile characteristics.

local addonName, GAC = ...
GAC = GAC or {}
GAC.TR3Bridge = GAC.TR3Bridge or {}

local characteristics = {}

--- Returns the character's full name from TRP3 profile or default fallback.
--- @return string
function characteristics.getFullName()
    if _G.TRP3_API and _G.TRP3_API.profile and type(_G.TRP3_API.profile.getData) == "function" then
        local data = _G.TRP3_API.profile.getData("characteristics")
        if type(data) == "table" then
            local fn = type(data.FN) == "string" and data.FN or ""
            local ni = type(data.NI) == "string" and data.NI or ""
            local ln = type(data.LN) == "string" and data.LN or ""

            if fn ~= "" and ni ~= "" and ln ~= "" then
                return fn .. ' "' .. ni .. '" ' .. ln
            elseif fn ~= "" and ln ~= "" then
                return fn .. " " .. ln
            elseif fn ~= "" then
                return fn
            end
        end
    end

    return 'No Name Found'
end

--- Returns the character's class string from TRP3 profile or default fallback.
--- @return string
function characteristics.getClass()
    if _G.TRP3_API and _G.TRP3_API.profile and type(_G.TRP3_API.profile.getData) == "function" then
        local data = _G.TRP3_API.profile.getData("characteristics")
        if type(data) == "table" and type(data.CL) == "string" and data.CL ~= "" then
            return data.CL
        end
    end

    return "Class Not Found"
end

GAC.TR3Bridge.characteristics = characteristics
return characteristics
