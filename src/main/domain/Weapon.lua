--- @module domain.Weapon
-- Pure Lua entity representing a Weapon domain model.

local Weapon = {}
Weapon.__index = Weapon

--- Factory method to instantiate and validate a Weapon entity.
-- @param raw_data table|nil Raw input data
-- @return table Weapon instance
function Weapon.create(raw_data)
    local instance = setmetatable({}, Weapon)
    raw_data = type(raw_data) == "table" and raw_data or {}

    instance.id = raw_data.id or ""
    instance.name = raw_data.name or "Arma Desconocida"
    instance.icon = raw_data.icon or ""
    instance.quality = type(raw_data.quality) == "number" and raw_data.quality or 1
    instance.description = raw_data.description or ""
    instance.variable = type(raw_data.variable) == "table" and raw_data.variable or {}
    instance.type = raw_data.type or ""
    instance.modificator = raw_data.modificator or ""

    return instance
end

function Weapon:GetId() return self.id end
function Weapon:GetName() return self.name end
function Weapon:GetIcon() return self.icon end
function Weapon:GetQuality() return self.quality end
function Weapon:GetDescription() return self.description end
function Weapon:GetVariable() return self.variable end
function Weapon:GetType() return self.type end
function Weapon:GetModificator() return self.modificator end

--- Serializes the Weapon entity to a plain Lua table.
-- @return table Serialized weapon state
function Weapon:Serialize()
    return {
        classType = "Weapon",
        id = self.id,
        name = self.name,
        icon = self.icon,
        quality = self.quality,
        description = self.description,
        variable = self.variable,
        type = self.type,
        modificator = self.modificator
    }
end

return Weapon
