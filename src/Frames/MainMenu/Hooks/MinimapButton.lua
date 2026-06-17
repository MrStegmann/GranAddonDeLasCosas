local addonName, GAC = ...

function GAC:CreateMinimapButton()
    if self.minimapButton then return end

    -- Asegurar que existan las tablas de datos para la posición
    self.characterData = self.characterData or {}
    self.characterData.ui = self.characterData.ui or {}
    if self.characterData.ui.minimapPos == nil then
        self.characterData.ui.minimapPos = 45 -- Ángulo inicial por defecto
    end

    local button = CreateFrame("Button", "GACMinimapButton", Minimap)
    button:SetSize(31, 31)
    button:SetFrameLevel(8)
    button:SetToplevel(true)
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    local icon = button:CreateTexture(nil, "BACKGROUND")
    icon:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
    icon:SetSize(20, 20)
    icon:SetPoint("CENTER")

    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetSize(53, 53)
    border:SetPoint("TOPLEFT")

    local function UpdatePosition()
        local angle = self.characterData.ui.minimapPos
        local x = math.cos(math.rad(angle)) * 80
        local y = math.sin(math.rad(angle)) * 80
        button:SetPoint("CENTER", Minimap, "CENTER", x, y)
    end

    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")
    button:SetScript("OnDragStart", function(s) s:LockHighlight(); s.isDragging = true end)
    button:SetScript("OnDragStop", function(s) s:UnlockHighlight(); s.isDragging = false end)
    button:SetScript("OnUpdate", function(s)
        if s.isDragging then
            local x, y = GetCursorPosition()
            local scale = Minimap:GetEffectiveScale()
            local cx, cy = Minimap:GetCenter()
            local angle = math.deg(math.atan2(y / scale - cy, x / scale - cx))
            self.characterData.ui.minimapPos = angle
            UpdatePosition()
        end
    end)

    button:SetScript("OnClick", function(s, btn)
        if btn == "RightButton" then
            if not GAC.minimapContextMenu then
                GAC.minimapContextMenu = CreateFrame("Frame", "GACMinimapContextMenu", UIParent, "UIDropDownMenuTemplate")
            end
            
            local menuOptions = {
                { text = "Opciones GAC", isTitle = true, notCheckable = true },
                { text = "Restaurar Posiciones", hasArrow = true, notCheckable = true, menuList = {
                    { text = "Menú Principal", func = function() 
                        self.characterData.ui.mainMenu = { anchor = "CENTER", relativeAnchor = "CENTER", x = 0, y = 0 }
                        if self.mainMenuFrame then 
                            self.mainMenuFrame:ClearAllPoints()
                            self.mainMenuFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0) 
                        end
                        print("|cff00ccff[GAC]|r Posición del Menú Principal restaurada.")
                    end, notCheckable = true },
                    { text = "Botones Rápidos", func = function() 
                        self.characterData.ui.quickFrame = { anchor = "CENTER", relativeAnchor = "CENTER", x = -260, y = -120 }
                        if self.quickActionsFrame then 
                            self.quickActionsFrame:ClearAllPoints()
                            self.quickActionsFrame:SetPoint("CENTER", UIParent, "CENTER", -260, -120) 
                        end
                        print("|cff00ccff[GAC]|r Posición de los Botones Rápidos restaurada.")
                    end, notCheckable = true },
                    { text = "Orden de Turnos", func = function() 
                        self.characterData.ui.initiativeFrame = { anchor = "CENTER", relativeAnchor = "CENTER", x = 300, y = 0 }
                        if self.initiativeFrame then 
                            self.initiativeFrame:ClearAllPoints()
                            self.initiativeFrame:SetPoint("CENTER", UIParent, "CENTER", 300, 0) 
                        end
                        print("|cff00ccff[GAC]|r Posición del Orden de Turnos restaurada.")
                    end, notCheckable = true },
                    { text = "Botón del Minimapa", func = function() 
                        self.characterData.ui.minimapPos = 45
                        UpdatePosition()
                        print("|cff00ccff[GAC]|r Posición del Botón del Minimapa restaurada.")
                    end, notCheckable = true }
                }},
                { text = "Cerrar", func = function() end, notCheckable = true }
            }
            
            EasyMenu(menuOptions, GAC.minimapContextMenu, "cursor", 0, 0, "MENU", 2)
        else
            self:ToggleMainMenu()
        end
    end)
    button:SetScript("OnEnter", function(s)
        GameTooltip:SetOwner(s, "ANCHOR_LEFT")
        GameTooltip:SetText("Gran Addon de las Cosas")
        GameTooltip:AddLine("Click: Abrir menú principal", 1, 1, 1)
        GameTooltip:AddLine("Click derecho: Opciones", 1, 1, 1)
        GameTooltip:AddLine("Arrastrar: Mover botón", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)

    UpdatePosition()
    self.minimapButton = button
end

