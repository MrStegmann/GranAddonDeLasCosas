local addonName, GAC = ...

local worgenMod = {
    worgen = {
        athletics = 2,
        brutality = 2,
        magicResistance = 2,
        perception = 2,
        resilience = 2,
        lossOfControlResistance = -5,
        stealth = -3,
        sleightOfHand = -2
    },
    human = {
        athletics = 1,
        brutality = 1,
        magicResistance = 1,
        perception = 1,
        resilience = 1,
        lossOfControlResistance = -2,
        stealth = -2,
        sleightOfHand = -1
    },
    special = {
        "superStrength",
        "hughMovility:fourLegs",
    }
}

local function checkWorgenAura()
    for i = 1, 40 do
        local name, _, _, _, _, _, _, _, _, spellId = UnitAura("player", i, "HELPFUL")
        if not name then break end
        if spellId == 97709 then
            return true
        end
    end
    return false
end

function GAC:GetModificators()
    -- Comprobamos si el jugador ha activado la Maldición Huargen en su ficha
    if not self.characterData or not self.characterData.isWorgenCurse then
        return nil
    end

    if checkWorgenAura() then
        return worgenMod.worgen
    else
        return worgenMod.human
    end
end