--- @module ui.shared.UIHelpers
-- UI helper functions scoped strictly within src/ui/shared/.

local UIHelpers = {}

--- Formats a numerical value cleanly.
-- @param val number
-- @return string Formatted text
function UIHelpers.FormatNumber(val)
    if type(val) ~= "number" then return "0" end
    return string.format("%d", math.floor(val))
end

--- Toggles visibility of a target frame safely.
-- @param frame table UI frame reference
function UIHelpers.ToggleFrame(frame)
    if type(frame) ~= "table" then return end
    if frame.IsShown and frame:IsShown() then
        if frame.Hide then frame:Hide() end
    else
        if frame.Show then frame:Show() end
    end
end

return UIHelpers
