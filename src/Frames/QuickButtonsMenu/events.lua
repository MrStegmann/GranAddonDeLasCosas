local _, GAC = ...

function GAC:StartTalentRoll(attributeName, talentName)
    if not self.characterData then
        return
    end
    if not GAC:CanTriggerRoll() then
        return
    end

    local attributeValue = self.characterData.attributes and self.characterData.attributes[attributeName] and tonumber(self.characterData.attributes[attributeName]) or 0
    local talentValue = self.characterData.talents and self.characterData.talents[talentName] and tonumber(self.characterData.talents[talentName]) or 0

    self.pendingTalentRoll = {
        attributeName = attributeName,
        talentName = talentName,
        attributeValue = attributeValue,
        talentValue = talentValue,
        min = 1,
        max = 20,
    }

    self.randomRollPattern = self.randomRollPattern or GAC:BuildRandomRollPattern()
    self.rollType = "talent"
    RandomRoll(1, 20)
end


function GAC:StartAttributeRoll(attributeName)
    if not self.characterData then
        return
    end
    if not GAC:CanTriggerRoll() then
        return
    end

    local attributeValue = self.characterData.attributes and self.characterData.attributes[attributeName] and tonumber(self.characterData.attributes[attributeName]) or 0

    self.pendingAttributeRoll = {
        attributeName = attributeName,
        attributeValue = attributeValue,
        min = 1,
        max = 20,
    }

    self.randomRollPattern = self.randomRollPattern or GAC:BuildRandomRollPattern()
    self.rollType = "attribute"
    RandomRoll(1, 20)
end

function GAC:StartInitiativeRoll()
    if not GAC:CanTriggerRoll() then
        return
    end

    self.pendingInitiativeRoll = {
        min = 1,
        max = 100,
    }

    self.randomRollPattern = self.randomRollPattern or GAC:BuildRandomRollPattern()
    self.rollType = "initiative"

    RandomRoll(1, 100)

end

function GAC:StartAttackRoll(dice, talentKey, talentLabel)
    if not self.characterData then
        return
    end
    if not GAC:CanTriggerRoll() then
        return
    end

    local talentValue = self.characterData.talents and self.characterData.talents[talentKey] and tonumber(self.characterData.talents[talentKey]) or 0

    self.pendingAttackRoll = {
        talentName = talentLabel,
        talentValue = talentValue,
        min = 1,
        max = dice,
    }

    self.randomRollPattern = self.randomRollPattern or GAC:BuildRandomRollPattern()
    self.rollType = "attack"
    RandomRoll(1, dice)
end