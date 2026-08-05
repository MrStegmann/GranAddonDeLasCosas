--- Probing unit test for Core Data Ports: RacePort, LevelPort, TraitsPort
-- Probes every GetAll() and GetById(id) endpoint for 100% structural parity.

local RaceDatabase = RaceDatabase or require("src.main.domain.database.RaceDatabase")
local LevelDatabase = LevelDatabase or require("src.main.domain.database.LevelDatabase")
local TraitsDatabase = TraitsDatabase or require("src.main.domain.database.TraitsDatabase")

local RacePort = RacePort or require("src.main.ports.metadata.RacePort")
local LevelPort = LevelPort or require("src.main.ports.metadata.LevelPort")
local TraitsPort = TraitsPort or require("src.main.ports.metadata.TraitsPort")

local TestCoreDataPorts = {}

function TestCoreDataPorts.Run()
    print("[TEST] Running Core Data Ports Probing Suite...")

    -- 1. RacePort Probing
    local racesAll = RacePort.GetAll()
    assert(racesAll ~= nil, "RacePort.GetAll() returned nil")
    assert(racesAll.human ~= nil, "RacePort.GetAll() missing human")
    assert(racesAll.orc ~= nil, "RacePort.GetAll() missing orc")
    
    local humanEntry = RacePort.GetById("human")
    assert(humanEntry ~= nil, "RacePort.GetById('human') returned nil")
    assert(humanEntry.name == "Humano", "RacePort human name mismatch")
    assert(humanEntry.special[1] == "adaptability", "RacePort human special mismatch")
    assert(RacePort.GetById("non_existent_race") == nil, "RacePort invalid ID check failed")

    -- 2. LevelPort Probing
    local levelsAll = LevelPort.GetAll()
    assert(levelsAll ~= nil, "LevelPort.GetAll() returned nil")
    assert(levelsAll.normal ~= nil, "LevelPort.GetAll() missing normal category")
    
    local normalCat = LevelPort.GetById("normal")
    assert(normalCat ~= nil, "LevelPort.GetById('normal') returned nil")
    assert(#normalCat == 10, "LevelPort normal category length expected 10")
    assert(normalCat[5].maxHealth == 49, "LevelPort level 5 maxHealth mismatch")
    assert(LevelPort.GetById("invalid_cat") == nil, "LevelPort invalid ID check failed")

    -- 3. TraitsPort Probing
    local traitsAll = TraitsPort.GetAll()
    assert(traitsAll ~= nil, "TraitsPort.GetAll() returned nil")
    assert(#traitsAll.PositiveTraits > 0, "TraitsPort missing PositiveTraits")
    assert(#traitsAll.NegativeTraits > 0, "TraitsPort missing NegativeTraits")
    
    local posTraits = TraitsPort.GetPositiveTraits()
    assert(#posTraits > 0, "TraitsPort.GetPositiveTraits() empty")
    local negTraits = TraitsPort.GetNegativeTraits()
    assert(#negTraits > 0, "TraitsPort.GetNegativeTraits() empty")

    local bullyTrait = TraitsPort.GetPositiveTraitById("bully")
    assert(bullyTrait ~= nil and bullyTrait.name == "Abusón/a", "TraitsPort.GetPositiveTraitById('bully') failed")
    
    local genericByIdPos = TraitsPort.GetById("bully")
    assert(genericByIdPos ~= nil and genericByIdPos.id == "bully", "TraitsPort.GetById('bully') failed")
    assert(TraitsPort.GetById("non_existent_trait") == nil, "TraitsPort invalid ID check failed")

    print("[SUCCESS] Core Data Ports Probing Suite Passed 100%!")
    return true
end

return TestCoreDataPorts
