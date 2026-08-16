--- Progression Traits Service
--- Functions for experience, narrative, and progression-based trait mechanics.
local ProgressionTraitsService = {}

--- Roll 1d4 for fastLearner trait bonus experience roll.
--- @return number 1D4 roll result
function ProgressionTraitsService.rollFastLearnerBonusExp()
    -- Uses math.random (1-4) in pure Lua environment
    return math.random(1, 4)
end

--- Calculates modified experience award considering fastLearner and disastrous traits.
--- @param baseExp number Base experience earned
--- @param hasFastLearner boolean
--- @param hasDisastrous boolean
--- @return number Final calculated experience amount
function ProgressionTraitsService.calculateFinalExperience(baseExp, hasFastLearner, hasDisastrous)
    baseExp = type(baseExp) == "number" and baseExp or 0

    if hasDisastrous then
        return math.floor(baseExp / 2)
    end

    if hasFastLearner then
        local bonusRoll = ProgressionTraitsService.rollFastLearnerBonusExp()
        return (baseExp * 2) + bonusRoll
    end

    return baseExp
end

_G.GAC_ProgressionTraitsService = ProgressionTraitsService
return ProgressionTraitsService
