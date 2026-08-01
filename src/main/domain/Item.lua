--- @module domain.Item
-- Pure Lua entity representing an Item domain model.

local Item = {}
Item.__index = Item

--- Factory method to instantiate and validate an Item entity.
-- @param raw_data table|nil Raw input data
-- @return table Item instance
function Item.create(raw_data)
    local instance = setmetatable({}, Item)
    raw_data = type(raw_data) == "table" and raw_data or {}

    instance.id = raw_data.id or ""
    instance.name = raw_data.name or "Objeto Desconocido"
    instance.icon = raw_data.icon or ""
    instance.quality = type(raw_data.quality) == "number" and raw_data.quality or 1
    instance.description = raw_data.description or ""
    instance.variable = type(raw_data.variable) == "table" and raw_data.variable or {}

    return instance
end

function Item:GetId() return self.id end
function Item:GetName() return self.name end
function Item:GetIcon() return self.icon end
function Item:GetQuality() return self.quality end
function Item:GetDescription() return self.description end
function Item:GetVariable() return self.variable end

--- Serializes the Item entity to a plain Lua table.
-- @return table Serialized item state
function Item:Serialize()
    return {
        classType = "Item",
        id = self.id,
        name = self.name,
        icon = self.icon,
        quality = self.quality,
        description = self.description,
        variable = self.variable
    }
end

return Item
