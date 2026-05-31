local addonName, GAC = ...
local WLVX = nil

if WLV_Extends then
    WLVX = WLV_Extends
else return end

local menuId = "QuickButtonsMenu"

local iconSize = 25

local quickButtonsMenu = WLVX:CreateMenu(menuId, "", true, 300, 60, true, function(frame)
    WLVX:SetMargin(frame, 5)
    -- UpperRow
    local upperId = menuId .. "_Upper"
    WLVX:AddRow(frame, upperId, '100%', 25, function(row)
        WLVX:AddIconButton(row, upperId .. "_Btn1", "Spell_Holy_Renew", iconSize, iconSize, function() print("Acción rápida 1 ejecutada") end, function(button)
           WLVX:CreateTooltip(button, "Dar/Quitar 1 HP", {
                { text = "Clic izquierdo: Añade 1 punto de vida.", r = 1, g = 1, b = 1 },
                { text = "Clic derecho: Quita 1 punto de vida.", r = 1, g = 0.7, b = 0.7 },
            })
        end)
        WLVX:AddIconButton(row, upperId .. "_Btn2", "Spell_Holy_PowerWordShield", iconSize, iconSize, function() print("Acción rápida 2 ejecutada") end, function(button)
           WLVX:CreateTooltip(button, "Dar/Quitar 1 Escudo", {
                { text = "Clic izquierdo: Añade 1 punto de escudo.", r = 1, g = 1, b = 1 },
                { text = "Clic derecho: Quita 1 punto de escudo.", r = 1, g = 0.7, b = 0.7 },
            })
        end)
    end)
    -- End UpperRow
    -- LowerRow
    local lowerId = menuId .. "_Lower"
    WLVX:AddRow(frame, lowerId, '100%', 25, function(row)
        WLVX:AddIconButton(row, upperId .. "_Btn1", "INV_Misc_Dice_01", iconSize, iconSize, function() print("Acción rápida 1 ejecutada") end, function(button)
           WLVX:CreateTooltip(button, "Talentos 1D20", {
                { text = "Muestra la lista de tiradas de talentos.", r = 1, g = 1, b = 1 },
            })
        end)

        WLVX:AddIconButton(row, upperId .. "_Btn2", "INV_Misc_Book_11", iconSize, iconSize, function() print("Acción rápida 1 ejecutada") end, function(button)
           WLVX:CreateTooltip(button, "Atributos 1D20", {
                { text = "Muestra la lista de tiradas de atributos.", r = 1, g = 1, b = 1 },
            })
        end)

        WLVX:AddIconButton(row, upperId .. "_Btn3", "Ability_Rogue_Sprint", iconSize, iconSize, function() print("Acción rápida 1 ejecutada") end, function(button)
           WLVX:CreateTooltip(button, "Iniciativa 1D100", {
                { text = "Realiza una tirada de Iniciativa.", r = 1, g = 1, b = 1 },
            })
        end)

        WLVX:AddIconButton(row, upperId .. "_Btn4", "Ability_MeleeDamage", iconSize, iconSize, function() print("Acción rápida 1 ejecutada") end, function(button)
           WLVX:CreateTooltip(button, "Ataques", {
                { text = "Muestra la lista de tiradas de ataques.", r = 1, g = 1, b = 1 },
            })
        end)

        
    end)
    -- End LowerRow
end)