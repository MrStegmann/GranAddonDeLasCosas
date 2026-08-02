--- Combat Traits Service
--- Specific trait mechanical calculation functions for combat functionality.
local CombatTraitsService = {}

--- Calculates dual-wielding attack penalty modifier for agile weapons (agileAmbidextrous trait).
--- @param traitLevel number Level of agileAmbidextrous trait (1-3)
--- @param basePenalty number Base dual-wield penalty
--- @return number Modified penalty/bonus
function CombatTraitsService.getAgileAmbidextrousModifier(traitLevel, basePenalty)
    if not traitLevel or traitLevel <= 0 then return basePenalty end
    if traitLevel == 1 then
        return 0 -- Eliminates penalty at level 1 for agile weapons
    elseif traitLevel == 2 then
        return 2 -- Bonus modifier at level 2
    elseif traitLevel >= 3 then
        return 3 -- Bonus modifier at level 3
    end
    return basePenalty
end

--- Calculates dual-wielding attack penalty modifier for 1-handed and 2-handed weapons (strongAmbidextrous trait).
--- @param traitLevel number Level of strongAmbidextrous trait (1-3)
--- @param basePenalty number Base dual-wield penalty
--- @return number Modified penalty
function CombatTraitsService.getStrongAmbidextrousModifier(traitLevel, basePenalty)
    if not traitLevel or traitLevel <= 0 then return basePenalty end
    if traitLevel == 1 then
        return math.floor(basePenalty / 2) -- Reduces penalty by half
    elseif traitLevel == 2 then
        return math.max(0, basePenalty - 1) -- Decreases penalty by 1
    elseif traitLevel >= 3 then
        return math.max(0, basePenalty - 3) -- Decreases penalty by 3
    end
    return basePenalty
end

--- Calculates critical stroke range bonus provided by bully trait.
--- @param traitLevel number
--- @return number Bonus added to critical strike range
function CombatTraitsService.getBullyCriticalRangeBonus(traitLevel)
    if not traitLevel or traitLevel <= 0 then return 0 end
    return math.min(3, traitLevel)
end

--- Calculates extra combat actions granted by advantaged trait.
--- @param traitLevel number
--- @return number Extra actions count
function CombatTraitsService.getAdvantagedExtraActions(traitLevel)
    if traitLevel and traitLevel >= 1 then return 1 end
    return 0
end

--- Calculates initiative bonus for prepared trait.
--- @param traitLevel number
--- @return number Initiative bonus
function CombatTraitsService.getPreparedInitiativeBonus(traitLevel)
    if not traitLevel or traitLevel <= 0 then return 0 end
    if traitLevel == 1 then return 25 end
    if traitLevel == 2 then return 50 end
    if traitLevel >= 3 then return 999 end
    return 0
end

--- Checks if character is immune to flanked disadvantage (fast trait).
--- @param hasFastTrait boolean
--- @return boolean
function CombatTraitsService.isImmuneToFlanking(hasFastTrait)
    return hasFastTrait == true
end

--- Checks if character is immune to grapple and root status effects (swift trait).
--- @param hasSwiftTrait boolean
--- @return boolean
function CombatTraitsService.isImmuneToGrappleOrRoot(hasSwiftTrait)
    return hasSwiftTrait == true
end

_G.GAC_CombatTraitsService = CombatTraitsService
return CombatTraitsService
