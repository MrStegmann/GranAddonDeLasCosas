local _, GAC = ...

local Weapon = setmetatable({}, {__index = GAC.Item})
Weapon.__index = Weapon

function Weapon:new(data)
    local instance = GAC.Item.new(self, data)
    
    data = data or {}
    instance.type = data.type or ""             -- tooltipRight
    instance.modificator = data.modificator or "" -- tooltipLeft
    
    return instance
end

function Weapon:GetType() return self.type end
function Weapon:GetModificator() return self.modificator end

function Weapon:Serialize()
    local data = GAC.Item.Serialize(self)
    data.classType = "Weapon"
    data.type = self.type
    data.modificator = self.modificator
    return data
end

GAC.Weapon = Weapon
