--- Talent Traits Service
--- Specific trait functions for calculating talent modifiers granted by traits.
local TalentTraitsService = {}

--- Calculates talent bonuses granted by active positive talent traits.
--- @param traitId string
--- @param traitLevel number
--- @return table Map of talentId to bonus value
function TalentTraitsService.getTraitTalentBonuses(traitId, traitLevel)
    if not traitId or not traitLevel or traitLevel <= 0 then return {} end

    local bonuses = {}
    if traitId == "agile" then
        if traitLevel == 1 then bonuses.agileDefense = 1 end
        if traitLevel == 2 then bonuses.agileDefense = 2 end
        if traitLevel >= 3 then bonuses.agileDefense = 2; bonuses.acrobatics = 1 end
    elseif traitId == "athletic" then
        if traitLevel == 1 then bonuses.athletics = 1 end
        if traitLevel == 2 then bonuses.athletics = 2 end
        if traitLevel >= 3 then bonuses.athletics = 2; bonuses.acrobatics = 1 end
    elseif traitId == "stubborn" then
        if traitLevel == 1 then bonuses.stunResistance = 1 end
        if traitLevel == 2 then bonuses.stunResistance = 2 end
        if traitLevel >= 3 then bonuses.stunResistance = 2; bonuses.knockdownResistance = 1 end
    elseif traitId == "weaponMaster" then
        local val = math.min(3, traitLevel)
        bonuses.twoHandedCombat = val
        bonuses.oneHandedCombat = val
        bonuses.agileCombat = val
    elseif traitId == "resilient" then
        if traitLevel == 1 then bonuses.resilience = 1 end
        if traitLevel == 2 then bonuses.resilience = 2 end
        if traitLevel >= 3 then bonuses.resilience = 2; bonuses.fortitude = 1 end
    elseif traitId == "robust" then
        if traitLevel == 1 then bonuses.robustDefense = 1 end
        if traitLevel == 2 then bonuses.robustDefense = 2 end
        if traitLevel >= 3 then bonuses.robustDefense = 2; bonuses.health = 5 end
    end

    return bonuses
end

_G.GAC_TalentTraitsService = TalentTraitsService
return TalentTraitsService
