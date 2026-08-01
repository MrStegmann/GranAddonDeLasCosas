--- @module ui.sheet.hooks.sheetHooks
-- Visual state and interaction hooks for Character Sheet UI.

local sheetHooks = {}

function sheetHooks.BindDrag(frame)
    if type(frame) == "table" and type(frame.EnableMouse) == "function" then
        frame:EnableMouse(true)
        if type(frame.SetMovable) == "function" then
            frame:SetMovable(true)
            frame:RegisterForDrag("LeftButton")
            frame:SetScript("OnDragStart", frame.StartMoving)
            frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
        end
    end
end

return sheetHooks
