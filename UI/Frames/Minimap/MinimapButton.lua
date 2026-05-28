local addonName, addon = ...

local function clampAngle(angle)
    local normalized = angle % 360
    if normalized < 0 then
        normalized = normalized + 360
    end

    return normalized
end

function addon:UpdateMinimapButtonPosition()
    if not self.minimapButton or not self.characterData or not self.characterData.ui then
        return
    end

    local angle = clampAngle(self.characterData.ui.minimapAngle or 220)
    local radians = math.rad(angle)
    local radius = 80

    local x = math.cos(radians) * radius
    local y = math.sin(radians) * radius

    self.minimapButton:ClearAllPoints()
    self.minimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

function addon:CreateMinimapButton()
    if self.minimapButton then
        self:UpdateMinimapButtonPosition()
        return
    end

    local button = CreateFrame("Button", "GACMinimapButton", Minimap)
    button:SetSize(32, 32)
    button:SetFrameStrata("MEDIUM")
    button:SetMovable(true)
    button:EnableMouse(true)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")

    local icon = button:CreateTexture(nil, "BACKGROUND")
    icon:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
    icon:SetSize(18, 18)
    icon:SetPoint("CENTER", 0, 0)
    button.icon = icon

    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetSize(54, 54)
    border:SetPoint("TOPLEFT")

    local highlight = button:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    highlight:SetBlendMode("ADD")
    highlight:SetSize(56, 56)
    highlight:SetPoint("CENTER")

    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText(addonName)
        GameTooltip:AddLine("Click: Abrir panel de atributos/experiencia", 1, 1, 1)
        GameTooltip:AddLine("Arrastrar: Mover boton", 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    button:SetScript("OnClick", function(_, mouseButton)
        if mouseButton == "LeftButton" and addon.ToggleAttributesUI then
            addon:ToggleAttributesUI()
            return
        end

        if mouseButton == "RightButton" then
            local menu = {
                {
                    text = "Restaurar posición de barra rápida",
                    func = function()
                        if GranAddonDeLasCosasDB then
                            GranAddonDeLasCosasDB.quickActionsFramePos = nil
                        end
                        if addon.quickActionsFrame and addon.quickActionsFrame.ClearAllPoints then
                            addon.quickActionsFrame:ClearAllPoints()
                            addon.quickActionsFrame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -200, 180)
                        end
                        print("|cffffff00Posición de la barra rápida restaurada.|r")
                    end,
                },
                {
                    text = "Cancelar",
                    func = function() end,
                },
            }
            EasyMenu(menu, CreateFrame("Frame", "GACMinimapButtonMenuFrame", UIParent, "UIDropDownMenuTemplate"), button, 0, 0, "MENU", 2)
        end
    end)

    button:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", function()
            local mx, my = GetCursorPosition()
            local scale = Minimap:GetEffectiveScale()
            local px, py = Minimap:GetCenter()

            mx = mx / scale
            my = my / scale

            local angle = math.deg(math.atan2(my - py, mx - px))
            addon.characterData.ui.minimapAngle = clampAngle(angle)
            addon:UpdateMinimapButtonPosition()
        end)
    end)

    button:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)

    self.minimapButton = button

    self:UpdateMinimapButtonPosition()
end
