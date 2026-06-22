local _, GAC = ...

local function injectModifier(pendingTable)
    if not pendingTable then return end
    local mod, has = GAC:GetQuickModifierValue()
    if has then
        pendingTable.hasModifier = true
        pendingTable.modifierValue = mod
    end
end

function GAC:CreateTalentsOptions()
    local options = {}
    for _, group in ipairs(GAC.attributeGroups) do
        local groupOptions = {
            text = GAC:_(group.name),
            hasArrow = true,
            notCheckable = true,
            menuList = {},
        }
        for _, talent in ipairs(group.talents) do
            table.insert(groupOptions.menuList, {
                text = GAC:_(talent),
                notCheckable = true,
                func = function() 
                    GAC:StartTalentRoll(group.name, talent)
                    injectModifier(GAC.pendingTalentRoll)
                end,
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
            text = GAC:_(group.name),
            notCheckable = true,
            func = function() 
                GAC:StartAttributeRoll(group.name) 
                injectModifier(GAC.pendingAttributeRoll)
            end,
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
            hasArrow = true,
            notCheckable = true,
            menuList = {},
        }
        for _, talentOption in ipairs(GAC.ATTACK_TALENT_OPTIONS) do
            table.insert(attackOptions.menuList, {
                text = talentOption.label,
                notCheckable = true,
                func = function() 
                    GAC:ShowHitZonePopup(function(zoneLabel, zoneSlotId)
                        local physicalTalents = {
                            agileCombat = true,
                            precision = true,
                            oneHandedCombat = true,
                            twoHandedCombat = true,
                            brutality = true,
                            acrobatics = true
                        }
                        if physicalTalents[talentOption.key] then
                            GAC:ShowDamageTypePopup(function(dmgLabel, dmgKey)
                                GAC:StartAttackRoll(attack, talentOption.key, talentOption.label, zoneLabel, zoneSlotId, dmgKey, dmgLabel) 
                                injectModifier(GAC.pendingAttackRoll)
                            end)
                        else
                            GAC:StartAttackRoll(attack, talentOption.key, talentOption.label, zoneLabel, zoneSlotId) 
                            injectModifier(GAC.pendingAttackRoll)
                        end
                    end)
                end,
            })
        end
        table.insert(options, attackOptions)
    end
    return options
end