--- @class Combat
--- Domain model for turn-based combat encounters matching Combat.ts schema interface.
local Combat = {}
Combat.__index = Combat

--- Creates a new Combat model instance with schema validation.
--- @param raw table|nil
--- @return Combat
function Combat.create(raw)
    raw = type(raw) == "table" and raw or {}

    local initList = {}
    if type(raw.initiativeOrder) == "table" then
        for _, entry in ipairs(raw.initiativeOrder) do
            if type(entry) == "table" and type(entry.characterId) == "string" then
                table.insert(initList, {
                    characterId = entry.characterId,
                    initiativeResult = type(entry.initiativeResult) == "number" and entry.initiativeResult or 0,
                })
            end
        end
    end

    local logList = {}
    if type(raw.combatLog) == "table" then
        for _, logMsg in ipairs(raw.combatLog) do
            if type(logMsg) == "string" then
                table.insert(logList, logMsg)
            end
        end
    end

    local instance = {
        id = type(raw.id) == "string" and raw.id or "combat_1",
        activeCharacterId = type(raw.activeCharacterId) == "string" and raw.activeCharacterId or "",
        actualRound = type(raw.actualRound) == "number" and math.max(1, raw.actualRound) or 1,
        initiativeOrder = initList,
        combatLog = logList,
    }

    return setmetatable(instance, Combat)
end

_G.Combat = Combat
return Combat
