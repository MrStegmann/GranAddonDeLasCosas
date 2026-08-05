local WorgenCurseDatabase = WorgenCurseDatabase or require("src.main.domain.database.WorgenCurseDatabase")
local ReadOnlyHelper = ReadOnlyHelper or require("src.main.ports.metadata.ReadOnlyHelper")

local WorgenCursePort = {}

--- Retrieves the entire Worgen Curse data table
-- @return table read-only proxy of Worgen Curse data
function WorgenCursePort.GetAll()
    return ReadOnlyHelper.makeReadOnly(WorgenCurseDatabase)
end

--- Retrieves Worgen Curse form data by form key ("humanoid" or "worgen")
-- @param form string
-- @return table|nil read-only proxy of form entry or nil
function WorgenCursePort.GetByForm(form)
    if not form or type(form) ~= "string" then
        return nil
    end
    if WorgenCurseDatabase[form] then
        return ReadOnlyHelper.makeReadOnly(WorgenCurseDatabase[form])
    end
    return nil
end

--- Retrieves Worgen Curse form data by ID ("humanoid" or "worgen")
-- @param id string
-- @return table|nil read-only proxy of form entry or nil
function WorgenCursePort.GetById(id)
    return WorgenCursePort.GetByForm(id)
end

return WorgenCursePort
