local addonName, GAC = ...

GAC.Components = GAC.Components or {}
GAC.Components.QuickButtonsMenu = GAC.Components.QuickButtonsMenu or {}

function GAC.Components.QuickButtonsMenu:CreateWeaponBar(frame, anchorBtn)
    local c = GAC.Stores.QuickButtonsMenu.Constants
    frame.weaponButtons = {}
    
    local lastWpnBtn = anchorBtn
    for i, wData in ipairs(GAC.Stores.QuickButtonsMenu.WeaponSlotsData) do
        local btn = GAC:CreateQuickButton(frame)
        btn:SetSize(c.BUTTON_SIZE, c.BUTTON_SIZE)
        btn:SetPoint("LEFT", lastWpnBtn, "RIGHT", c.BUTTON_SPACING + 2, 0)
        local icon = btn:CreateTexture(nil, "ARTWORK")
        icon:SetPoint("TOPLEFT", 2, -2)
        icon:SetPoint("BOTTOMRIGHT", -2, 2)
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        btn.icon = icon
        btn.slotID = wData.id
        btn.slotLabel = wData.label
        
        btn:RegisterForClicks("LeftButtonUp")
        btn:SetScript("OnClick", function(self, buttonClicked)
            if self.weaponKey then
                local wInfo = GAC:GetWeaponInfo(self.weaponKey) or GAC:GetShieldInfo(self.weaponKey)
                if not wInfo then return end
                
                local hasTwoHanded = wInfo.twoHanded ~= nil
                local hasThrowable = wInfo.throwable ~= nil
                
                if hasTwoHanded or hasThrowable then
                    if not GAC.weaponActionsMenuFrame then GAC.weaponActionsMenuFrame = CreateFrame("Frame", "GACWeaponActionsMenuFrame", UIParent, "UIDropDownMenuTemplate") end
                    
                    local menuOptions = {}
                    table.insert(menuOptions, { text = "Daño " .. self.slotLabel, isTitle = true, notCheckable = true })
                    table.insert(menuOptions, { text = "Ataque Normal", func = function() GAC:StartWeaponDamageRoll(self.weaponKey, "normal", self.weaponName, self.damageModifier) end, notCheckable = true })
                    if hasTwoHanded then
                        table.insert(menuOptions, { text = "Ataque a Dos Manos", func = function() GAC:StartWeaponDamageRoll(self.weaponKey, "twoHanded", self.weaponName, self.damageModifier) end, notCheckable = true })
                    end
                    if hasThrowable then
                        table.insert(menuOptions, { text = "Lanzar Arma", func = function() GAC:StartWeaponDamageRoll(self.weaponKey, "throwable", self.weaponName, self.damageModifier) end, notCheckable = true })
                    end
                    table.insert(menuOptions, { text = "Cancelar", notCheckable = true })
                    
                    EasyMenu(menuOptions, GAC.weaponActionsMenuFrame, self, 0, 0, "MENU", 2)
                else
                    GAC:StartWeaponDamageRoll(self.weaponKey, "normal", self.weaponName, self.damageModifier)
                end
            else
                if self.slotID == 16 or self.slotID == 17 then
                    if GAC.StartUnarmedDamageRoll then
                        GAC:StartUnarmedDamageRoll(self.slotLabel)
                    end
                end
            end
        end)
        btn:Hide()
        table.insert(frame.weaponButtons, btn)
        lastWpnBtn = btn
    end
end
