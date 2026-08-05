--- Probing unit test for Equipment Ports: ArmorPort, WeaponsPort, ShieldPort
-- Probes every GetAll() and GetById(id) endpoint for 100% structural parity.

local ArmorDatabase = ArmorDatabase or require("src.main.domain.database.ArmorDatabase")
local WeaponsDatabase = WeaponsDatabase or require("src.main.domain.database.WeaponsDatabase")
local ShieldDatabase = ShieldDatabase or require("src.main.domain.database.ShieldDatabase")

local ArmorPort = ArmorPort or require("src.main.ports.metadata.ArmorPort")
local WeaponsPort = WeaponsPort or require("src.main.ports.metadata.WeaponsPort")
local ShieldPort = ShieldPort or require("src.main.ports.metadata.ShieldPort")

local TestEquipmentPorts = {}

function TestEquipmentPorts.Run()
    print("[TEST] Running Equipment Ports Probing Suite...")

    -- 1. ArmorPort Probing
    local armorAll = ArmorPort.GetAll()
    assert(armorAll ~= nil, "ArmorPort.GetAll() returned nil")
    assert(armorAll.ArmorList ~= nil, "ArmorPort missing ArmorList")
    assert(armorAll.ArmorReinforcement ~= nil, "ArmorPort missing ArmorReinforcement")

    local plateEntry = ArmorPort.GetById("plate")
    assert(plateEntry ~= nil, "ArmorPort.GetById('plate') returned nil")
    assert(plateEntry.name == "Placas", "ArmorPort plate name mismatch")
    assert(plateEntry.physicalReduction == 6, "ArmorPort plate reduction mismatch")
    
    local reinfPlate = ArmorPort.GetReinforcementById("plate")
    assert(reinfPlate ~= nil and reinfPlate.bonusReduction == 2, "ArmorPort GetReinforcementById('plate') failed")
    assert(ArmorPort.GetById("invalid_armor") == nil, "ArmorPort invalid ID check failed")

    -- 2. WeaponsPort Probing
    local weaponsAll = WeaponsPort.GetAll()
    assert(weaponsAll ~= nil, "WeaponsPort.GetAll() returned nil")
    
    local daggerEntry = WeaponsPort.GetById("dagger")
    assert(daggerEntry ~= nil, "WeaponsPort.GetById('dagger') returned nil")
    assert(daggerEntry.name == "Daga", "WeaponsPort dagger name mismatch")
    assert(daggerEntry.damage == 4, "WeaponsPort dagger damage mismatch")

    local shotgunEntry = WeaponsPort.GetById("shotgun")
    assert(shotgunEntry ~= nil, "WeaponsPort.GetById('shotgun') returned nil")
    assert(shotgunEntry.damage == 12, "WeaponsPort shotgun damage mismatch")
    assert(WeaponsPort.GetById("invalid_weapon") == nil, "WeaponsPort invalid ID check failed")

    -- 3. ShieldPort Probing
    local shieldsAll = ShieldPort.GetAll()
    assert(shieldsAll ~= nil, "ShieldPort.GetAll() returned nil")
    assert(shieldsAll.heavy ~= nil, "ShieldPort missing heavy shield")

    local heavyShield = ShieldPort.GetById("heavy")
    assert(heavyShield ~= nil, "ShieldPort.GetById('heavy') returned nil")
    assert(heavyShield.name == "Escudo pesado", "ShieldPort heavy name mismatch")
    assert(heavyShield.durability == 20, "ShieldPort heavy durability mismatch")
    assert(ShieldPort.GetById("invalid_shield") == nil, "ShieldPort invalid ID check failed")

    print("[SUCCESS] Equipment Ports Probing Suite Passed 100%!")
    return true
end

return TestEquipmentPorts
