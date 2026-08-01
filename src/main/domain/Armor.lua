--- @module domain.Armor
-- Pure Lua entity representing an Armor domain model.

local Item = require and pcall(require, "src.main.domain.Item") and require("src.main.domain.Item") or nil

local Armor = {}
Armor.__index = Armor

--- Factory method to instantiate and validate an Armor entity.
-- @param raw_data table|nil Raw input data
-- @return table Armor instance
function Armor.create(raw_data)
    local instance = setmetatable({}, Armor)
    raw_data = type(raw_data) == "table" and raw_data or {}

    instance.id = raw_data.id or ""
    instance.name = raw_data.name or "Armadura Desconocida"
    instance.icon = raw_data.icon or ""
    instance.quality = type(raw_data.quality) == "number" and raw_data.quality or 1
    instance.description = raw_data.description or ""
    instance.variable = type(raw_data.variable) == "table" and raw_data.variable or {}
    instance.slot = raw_data.slot or ""
    instance.material = raw_data.material or ""

    return instance
end

function Armor:GetId() return self.id end
function Armor:GetName() return self.name end
function Armor:GetIcon() return self.icon end
function Armor:GetQuality() return self.quality end
function Armor:GetDescription() return self.description end
function Armor:GetVariable() return self.variable end
function Armor:GetSlot() return self.slot end
function Armor:GetMaterial() return self.material end

--- Serializes the Armor entity to a plain Lua table.
-- @return table Serialized armor state
function Armor:Serialize()
    return {
        classType = "Armor",
        id = self.id,
        name = self.name,
        icon = self.icon,
        quality = self.quality,
        description = self.description,
        variable = self.variable,
        slot = self.slot,
        material = self.material
    }
end

return Armor
