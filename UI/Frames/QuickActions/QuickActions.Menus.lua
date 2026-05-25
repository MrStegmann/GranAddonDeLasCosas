local addonName, addon = ...
local qa = addon.quickActions or {}

function addon:GetTalentRollMenu()
    local menu = {
        {
            text = "Tirada de Talentos",
            isTitle = true,
            notCheckable = true,
        },
    }

    for _, group in ipairs(self.attributeGroups or {}) do
        local subMenu = {}

        for _, talent in ipairs(group.talents or {}) do
            subMenu[#subMenu + 1] = {
                text = talent,
                notCheckable = true,
                func = function()
                    addon:StartTalentRoll(group.name, talent)
                end,
            }
        end

        menu[#menu + 1] = {
            text = group.name,
            notCheckable = true,
            hasArrow = true,
            menuList = subMenu,
        }
    end

    return menu
end

function addon:GetAttributeRollMenu()
    local menu = {
        {
            text = "Tirada de Atributos",
            isTitle = true,
            notCheckable = true,
        },
    }

    for _, group in ipairs(self.attributeGroups or {}) do
        menu[#menu + 1] = {
            text = group.name,
            notCheckable = true,
            func = function()
                addon:StartAttributeRoll(group.name)
            end,
        }
    end

    return menu
end

function addon:GetAttackRollMenu()
    local menu = {
        {
            text = "Tirada de Ataque",
            isTitle = true,
            notCheckable = true,
        },
    }

    for _, sides in ipairs({ 4, 6, 8, 10, 12 }) do
        local diceSides = sides
        local talentSubmenu = {}

        for _, option in ipairs(qa.ATTACK_TALENT_OPTIONS or {}) do
            local currentOption = option
            talentSubmenu[#talentSubmenu + 1] = {
                text = currentOption.label,
                notCheckable = true,
                func = function()
                    addon:StartAttackRoll(diceSides, currentOption.key, currentOption.label)
                end,
            }
        end

        menu[#menu + 1] = {
            text = "1D" .. diceSides,
            notCheckable = true,
            hasArrow = true,
            menuList = talentSubmenu,
        }
    end

    return menu
end

