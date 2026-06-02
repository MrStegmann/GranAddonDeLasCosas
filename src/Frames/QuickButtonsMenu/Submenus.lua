local _, GAC = ...

function GAC:CreateTalentsOptions()
    local options = {}
    for _, group in ipairs(GAC.attributeGroups) do
        local groupOptions = {
            text = group.name,
            subOptions = {},
        }
        for _, talent in ipairs(group.talents) do
            table.insert(groupOptions.subOptions, {
                text = talent,
                func = function() GAC:StartTalentRoll(group.name, talent) end,
            })
        end
        table.insert(options, groupOptions)
    end
    return options

end

function GAC:CreateAttributesOptions()
    local options = {}
    for _, group in ipairs(GAC.attributeGroups) do
        local groupOptions = {
            text = group.name,
            func = function() GAC:StartAttributeRoll(group.name) end,
        }
        table.insert(options, groupOptions)
    end
    return options
end

function GAC:CreateAttackOptions()
    local options = {}
    for _, attack in ipairs({ 4, 6, 8, 10, 12 }) do
        local attackOptions = {
            text = "1D" .. attack,
            subOptions = {},
        }
        for _, talentOption in ipairs(GAC.ATTACK_TALENT_OPTIONS) do
            table.insert(attackOptions.subOptions, {
                text = talentOption.label,
                func = function() GAC:StartAttackRoll(attack, talentOption.key, talentOption.label) end,
                })
        end
        table.insert(options, attackOptions)
    end
    return options
end