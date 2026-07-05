local _, GAC = ...

local Item = {}
Item.__index = Item

function Item:new(data)
    local instance = {}
    setmetatable(instance, self)
    
    data = data or {}
    instance.id = data.id
    instance.name = data.name or "Objeto Desconocido"
    instance.icon = data.icon
    instance.quality = data.quality or 1
    instance.description = data.description or ""
    instance.variable = data.variable or {}
    
    return instance
end

function Item:GetId() return self.id end
function Item:GetName() return self.name end
function Item:GetIcon() return self.icon end
function Item:GetQuality() return self.quality end
function Item:GetDescription() return self.description end
function Item:GetVariable() return self.variable end

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

GAC.Item = Item
