local ReadOnlyHelper = {}

--- Wraps a table in a read-only proxy or returns a protected table to prevent runtime mutations
-- @param tbl table
-- @return table read-only proxy table
function ReadOnlyHelper.makeReadOnly(tbl)
    if type(tbl) ~= "table" then
        return tbl
    end
    local proxy = {}
    local mt = {
        __index = tbl,
        __newindex = function(_, key, _)
            error("Attempt to modify read-only metadata table key: " .. tostring(key), 2)
        end,
        __metatable = false
    }
    return setmetatable(proxy, mt)
end

--- Performs a shallow copy of a table
-- @param tbl table
-- @return table shallow copy
function ReadOnlyHelper.copyTable(tbl)
    if type(tbl) ~= "table" then
        return tbl
    end
    local copy = {}
    for k, v in pairs(tbl) do
        copy[k] = v
    end
    return copy
end

return ReadOnlyHelper
