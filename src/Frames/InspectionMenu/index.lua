local addonName, GAC = ...

function GAC:CreateInspectionMenu()
    if self.inspectionMenuFrame then return end

    -- Marco principal
    local frame = CreateFrame("Frame", "GACInspectionMenuFrame", UIParent, "BackdropTemplate")
    frame:Hide()
    frame:SetSize(750, 550)
    frame:SetPoint("CENTER", UIParent, "CENTER", 100, 0)
    frame:SetMovable(true)
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
    frame:SetBackdropBorderColor(0.94, 0.25, 0.25, 0.8) -- Borde rojo para diferenciar de MainMenu

    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(s) s:StopMovingOrSizing() end)

    -- Botón cerrar
    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4)

    -- Título del Addon
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 20, -18)
    title:SetText("INSPECCIÓN - GRAN ADDON DE LAS COSAS")
    title:SetTextColor(0.94, 0.25, 0.25)

    -- Línea divisoria
    local line = frame:CreateTexture(nil, "ARTWORK")
    line:SetSize(frame:GetWidth() - 24, 1)
    line:SetPoint("TOP", 0, -45)
    line:SetColorTexture(1, 1, 1, 0.1)

    -- Barra lateral estática (solo para mantener estructura visual)
    local sidebar = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    sidebar:SetSize(180, 0)
    sidebar:SetPoint("TOPLEFT", 12, -50)
    sidebar:SetPoint("BOTTOMLEFT", 12, 12)
    sidebar:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 8, edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    sidebar:SetBackdropColor(0, 0, 0, 0.4)
    sidebar:SetBackdropBorderColor(0.94, 0.25, 0.25, 0.15)
    
    local sidebarTitle = sidebar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    sidebarTitle:SetPoint("TOP", 0, -15)
    sidebarTitle:SetText("Modo Inspección")

    local contentArea = CreateFrame("Frame", nil, frame)
    contentArea:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 10, 0)
    contentArea:SetPoint("BOTTOMRIGHT", -12, 12)
    
    -- Inyectar contenido
    local content = GAC:CreateInspectionMenuContent(contentArea)
    frame.contentArea = content

    self.inspectionMenuFrame = frame
end

function GAC:OpenInspectionMenu()
    if not self.inspectionMenuFrame then
        self:CreateInspectionMenu()
    end
    self.inspectionMenuFrame:Show()
    if self.inspectionMenuFrame.contentArea.Update then
        self.inspectionMenuFrame.contentArea:Update()
    end
end
