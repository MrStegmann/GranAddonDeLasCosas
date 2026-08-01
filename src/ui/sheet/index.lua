--- @module ui.sheet.index
-- Feature orchestrator for Character Sheet micro-frontend.

local sheetApi = require and pcall(require, "src.ui.sheet.api.sheetApi") and require("src.ui.sheet.api.sheetApi") or nil
local sheetHooks = require and pcall(require, "src.ui.sheet.hooks.sheetHooks") and require("src.ui.sheet.hooks.sheetHooks") or nil

local SheetModule = {}
SheetModule.__index = SheetModule

function SheetModule.create(ipcAdapter)
    local instance = setmetatable({}, SheetModule)
    local apiFactory = sheetApi or (GAC and GAC.sheetApi)
    if apiFactory and apiFactory.create then
        instance.api = apiFactory.create(ipcAdapter)
    end
    return instance
end

function SheetModule:Init()
    if self.api then
        self.api:OnCharacterUpdated(function(data)
            self:Render(data)
        end)
    end
end

function SheetModule:Render(characterData)
    -- Visual update rendering logic driven by IPC broadcast
end

return SheetModule
