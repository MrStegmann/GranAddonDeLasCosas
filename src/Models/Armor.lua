local _, GAC = ...

local Armor = setmetatable({}, {__index = GAC.Item})
Armor.__index = Armor

function Armor:new(data)
    local instance = GAC.Item.new(self, data)
    
    data = data or {}
    instance.slot = data.slot or ""           -- tooltipRight
    instance.material = data.material or ""   -- tooltipLeft
    
    return instance
end

function Armor:GetSlot() return self.slot end
function Armor:GetMaterial() return self.material end

function Armor:Serialize()
    local data = GAC.Item.Serialize(self)
    data.classType = "Armor"
    data.slot = self.slot
    data.material = self.material
    return data
end

GAC.Armor = Armor
