--- Probing unit test for Empty Dataset Ports: ChiPort, FelPort, NaturePort, NecromancePort
-- Probes every GetAll() and GetById(id) endpoint verifying empty table {} returns.

local ChiDatabase = ChiDatabase or require("src.main.domain.database.ChiDatabase")
local FelDatabase = FelDatabase or require("src.main.domain.database.FelDatabase")
local NatureDatabase = NatureDatabase or require("src.main.domain.database.NatureDatabase")
local NecromanceDatabase = NecromanceDatabase or require("src.main.domain.database.NecromanceDatabase")

local ChiPort = ChiPort or require("src.main.ports.metadata.ChiPort")
local FelPort = FelPort or require("src.main.ports.metadata.FelPort")
local NaturePort = NaturePort or require("src.main.ports.metadata.NaturePort")
local NecromancePort = NecromancePort or require("src.main.ports.metadata.NecromancePort")

local TestEmptyPorts = {}

function TestEmptyPorts.Run()
    print("[TEST] Running Empty Dataset Ports Probing Suite...")

    -- 1. ChiPort Probing
    local chiAll = ChiPort.GetAll()
    assert(chiAll ~= nil, "ChiPort.GetAll() returned nil")
    assert(type(chiAll) == "table" and #chiAll == 0, "ChiPort.GetAll() expected empty table {}")
    assert(ChiPort.GetById("any_id") == nil, "ChiPort.GetById() expected nil for empty dataset")

    -- 2. FelPort Probing
    local felAll = FelPort.GetAll()
    assert(felAll ~= nil, "FelPort.GetAll() returned nil")
    assert(type(felAll) == "table" and #felAll == 0, "FelPort.GetAll() expected empty table {}")
    assert(FelPort.GetById("any_id") == nil, "FelPort.GetById() expected nil for empty dataset")

    -- 3. NaturePort Probing
    local natureAll = NaturePort.GetAll()
    assert(natureAll ~= nil, "NaturePort.GetAll() returned nil")
    assert(type(natureAll) == "table" and #natureAll == 0, "NaturePort.GetAll() expected empty table {}")
    assert(NaturePort.GetById("any_id") == nil, "NaturePort.GetById() expected nil for empty dataset")

    -- 4. NecromancePort Probing
    local necroAll = NecromancePort.GetAll()
    assert(necroAll ~= nil, "NecromancePort.GetAll() returned nil")
    assert(type(necroAll) == "table" and #necroAll == 0, "NecromancePort.GetAll() expected empty table {}")
    assert(NecromancePort.GetById("any_id") == nil, "NecromancePort.GetById() expected nil for empty dataset")

    print("[SUCCESS] Empty Dataset Ports Probing Suite Passed 100%!")
    return true
end

return TestEmptyPorts
