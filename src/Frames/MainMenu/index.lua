local addonName, GAC = ...

function GAC:CreateMainMenuFrame()
    if self.mainMenuFrame then return end

    -- Marco principal
    local frame = CreateFrame("Frame", "GACMainMenuFrame", UIParent, "BackdropTemplate")
    frame:Hide() -- Initialize hidden so the first ToggleMainMenu() call will show it
    frame:SetSize(750, 550)
    -- Posicionamiento persistente
    self.characterData.ui.mainMenu = self.characterData.ui.mainMenu or {}
    local pos = self.characterData.ui.mainMenu
    if not pos.anchor then
        pos.anchor, pos.relativeAnchor, pos.x, pos.y = "CENTER", "CENTER", 0, 0
    end
    
    frame:SetPoint(pos.anchor, UIParent, pos.relativeAnchor, pos.x, pos.y)
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
    frame:SetBackdropBorderColor(0.25, 0.78, 0.94, 0.8)

    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(s)
        s:StopMovingOrSizing()
        local a, _, ra, ox, oy = s:GetPoint(1)
        ra = ra or a -- Si relativePoint es nulo, suele ser igual que el anchor point
        pos.anchor = a
        pos.relativeAnchor = ra
        pos.x = math.floor(ox + 0.5)
        pos.y = math.floor(oy + 0.5)
    end)

    -- Botón cerrar
    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4)

    -- Título del Addon
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 20, -18)
    title:SetText("GRAN ADDON DE LAS COSAS")
    title:SetTextColor(0.25, 0.78, 0.94)

    -- Línea divisoria (Estilo TRP3)
    local line = frame:CreateTexture(nil, "ARTWORK")
    line:SetSize(frame:GetWidth() - 24, 1)
    line:SetPoint("TOP", 0, -45)
    line:SetColorTexture(1, 1, 1, 0.1)

    -- Barra lateral de navegación
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
    sidebar:SetBackdropBorderColor(0.25, 0.78, 0.94, 0.15)

    -- Contenedor principal de pestañas
    local contentArea = CreateFrame("Frame", nil, frame)
    contentArea:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 10, 0)
    contentArea:SetPoint("BOTTOMRIGHT", -12, 12)
    frame.contentArea = contentArea

    local tabs = {}
    local tabCount = 0

    local function SelectTab(tabID)
        for id, data in pairs(tabs) do
            local isSelected = (id == tabID)
            data.button.indicator:SetShown(isSelected)
            if isSelected then
                data.button:SetBackdropColor(1, 1, 1, 0.08)
                data.button.text:SetTextColor(0.25, 0.78, 0.94)
                data.content:Show()
                if data.content.Update then data.content:Update() end
            else
                data.button:SetBackdropColor(0, 0, 0, 0)
                data.button.text:SetTextColor(1, 1, 1)
                data.content:Hide()
            end
        end
    end

    local function AddTab(id, label, createFunc)
        local btnWidth = sidebar:GetWidth() - 4
        local btn = CreateFrame("Button", nil, sidebar, "BackdropTemplate")
        btn:SetSize(btnWidth, 36)
        btn:SetPoint("TOPLEFT", 2, -10 - (tabCount * 38))
        btn:SetBackdrop({ bgFile = "Interface\\ChatFrame\\ChatFrameBackground" })
        btn:SetBackdropColor(0, 0, 0, 0)

        -- Indicador lateral (TRP3 Style)
        local indicator = btn:CreateTexture(nil, "OVERLAY")
        indicator:SetSize(3, 22)
        indicator:SetPoint("LEFT", 2, 0)
        indicator:SetColorTexture(0.25, 0.78, 0.94, 1)
        indicator:Hide()
        btn.indicator = indicator

        local text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        text:SetPoint("LEFT", 15, 0)
        text:SetText(label:upper())
        btn.text = text

        btn:SetScript("OnClick", function() SelectTab(id) end)
        btn:SetScript("OnEnter", function(s) 
            s:SetBackdropColor(1, 1, 1, 0.05)
            s.text:SetTextColor(0.25, 0.78, 0.94)
        end)
        btn:SetScript("OnLeave", function(s)
            if not tabs[id].content:IsShown() then
                s:SetBackdropColor(0, 0, 0, 0)
                s.text:SetTextColor(1, 1, 1)
            end
        end)

        local content = createFunc(contentArea)
        content:Hide()

        tabs[id] = { button = btn, content = content }
        tabCount = tabCount + 1
    end

    -- Inserción de la primera pestaña solicitada
    AddTab("CharSheet", "Ficha de Personaje", function(p) return GAC:CreateCharSheetContent(p) end)
    AddTab("ExpConfig", "Conf. Experiencia", function(p) return GAC:CreateExperienceConfigurator(p) end)

    frame.tabs = tabs
    self.mainMenuFrame = frame
    SelectTab("CharSheet")
end

function GAC:UpdateMainMenu()
    if self.mainMenuFrame and self.mainMenuFrame:IsShown() then
        for id, data in pairs(self.mainMenuFrame.tabs) do
            if data.content and data.content:IsShown() and data.content.Update then
                data.content:Update()
            end
        end
    end
end

function GAC:ToggleMainMenu()
    self:CreateMainMenuFrame()
    if self.mainMenuFrame:IsShown() then self.mainMenuFrame:Hide() else self.mainMenuFrame:Show() end
end

-- Slash Command para facilitar el acceso
SLASH_GACMENU1 = "/gac"
SlashCmdList["GACMENU"] = function() GAC:ToggleMainMenu() end