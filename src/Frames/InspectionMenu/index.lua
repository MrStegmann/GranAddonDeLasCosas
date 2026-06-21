local addonName, GAC = ...

function GAC:CreateInspectionMenu()
    if self.inspectionMenuFrame then return end

    -- Marco principal
    local frame = CreateFrame("Frame", "GACInspectionMenuFrame", UIParent, "BackdropTemplate")
    frame:Hide()
    frame:SetSize(750, 550)
    frame:SetPoint("CENTER", UIParent, "CENTER", 100, 0)
    frame:SetMovable(true)
    GAC:SetClampedWithVisiblePixels(frame, 20)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetClampedToScreen(true)
    frame:SetFrameStrata("HIGH")

    frame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    frame:SetBackdropColor(0.05, 0.06, 0.08, 0.95)
    local tc = GAC.Stores.InspectionMenu.Constants.THEME_COLOR
    frame:SetBackdropBorderColor(tc.r, tc.g, tc.b, 0.8)

    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(s) s:StopMovingOrSizing() end)

    -- Botón cerrar
    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4)

    -- Título del Addon
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 20, -18)
    title:SetText("INSPECCIÓN - GRAN ADDON DE LAS COSAS")
    title:SetTextColor(tc.r, tc.g, tc.b, tc.a)

    -- Línea divisoria
    local line = frame:CreateTexture(nil, "ARTWORK")
    line:SetSize(frame:GetWidth() - 24, 1)
    line:SetPoint("TOP", 0, -45)
    line:SetColorTexture(1, 1, 1, 0.1)

    local sidebar = GAC.Components.InspectionMenu:CreateSidebar(frame)
    
    local contentArea = CreateFrame("Frame", nil, frame)
    contentArea:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 10, 0)
    contentArea:SetPoint("BOTTOMRIGHT", -12, 12)
    frame.contentArea = contentArea

    self.inspectionMenuFrame = frame

    GAC.Utils.InspectionMenu:AddTab("CharSheet", "Ficha de Personaje", function(p) return GAC.Screens.InspectionMenu:CreateCharSheetScreen(p) end, sidebar, contentArea)
    GAC.Utils.InspectionMenu:AddTab("Inventory", "Inventario", function(p) return GAC.Screens.InspectionMenu:CreateInventoryScreen(p) end, sidebar, contentArea)

    frame.Update = function(self)
        local currentTab = self.currentTab
        local store = GAC.Stores.InspectionMenu
        if currentTab and store.Tabs[currentTab] and store.Tabs[currentTab].content.Update then
            store.Tabs[currentTab].content:Update()
        end
    end

    GAC.Utils.InspectionMenu:SelectTab("CharSheet")
end

function GAC:OpenInspectionMenu()
    if not self.inspectionMenuFrame then
        self:CreateInspectionMenu()
    end
    self.inspectionMenuFrame:Show()
    if self.inspectionMenuFrame.Update then
        self.inspectionMenuFrame:Update()
    end
end
