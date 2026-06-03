local addonName, GAC = ...

function GAC:CreateMainMenuFrame()
    if self.mainMenuFrame then return end

    -- Marco principal
    local frame = CreateFrame("Frame", "GACMainMenuFrame", UIParent, "BackdropTemplate")
    frame:SetSize(750, 550)
    frame:SetPoint("CENTER")
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
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    -- Botón cerrar
    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4)

    -- Título del Addon
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 20, -18)
    title:SetText("GRAN ADDON DE LAS COSAS")
    title:SetTextColor(0.25, 0.78, 0.94)

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
    sidebar:SetBackdropBorderColor(1, 1, 1, 0.1)

    -- Contenedor principal de pestañas
    local contentArea = CreateFrame("Frame", nil, frame)
    contentArea:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 15, 0)
    contentArea:SetPoint("BOTTOMRIGHT", -12, 12)
    frame.contentArea = contentArea

    local tabs = {}
    local tabCount = 0

    local function SelectTab(tabID)
        for id, data in pairs(tabs) do
            if id == tabID then
                data.button:SetBackdropColor(0.25, 0.78, 0.94, 0.3)
                data.content:Show()
                if data.content.Update then data.content:Update() end
            else
                data.button:SetBackdropColor(0, 0, 0, 0)
                data.content:Hide()
            end
        end
    end

    local function AddTab(id, label, createFunc)
        local btn = CreateFrame("Button", nil, sidebar, "BackdropTemplate")
        btn:SetSize(170, 32)
        btn:SetPoint("TOP", 0, -10 - (tabCount * 36))
        btn:SetBackdrop({ bgFile = "Interface\\ChatFrame\\ChatFrameBackground" })
        btn:SetBackdropColor(0, 0, 0, 0)

        local text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        text:SetPoint("LEFT", 12, 0)
        text:SetText(label:upper())

        btn:SetScript("OnClick", function() SelectTab(id) end)
        btn:SetScript("OnEnter", function(s) s:SetBackdropColor(1, 1, 1, 0.05) end)
        btn:SetScript("OnLeave", function(s) end)

        local content = createFunc(contentArea)
        content:Hide()

        tabs[id] = { button = btn, content = content }
        tabCount = tabCount + 1
    end

    -- Inserción de la primera pestaña solicitada
    AddTab("CharSheet", "Ficha de Personaje", function(p) return GAC:CreateCharSheetContent(p) end)

    self.mainMenuFrame = frame
    SelectTab("CharSheet")
end

function GAC:ToggleMainMenu()
    self:CreateMainMenuFrame()
    if self.mainMenuFrame:IsShown() then self.mainMenuFrame:Hide() else self.mainMenuFrame:Show() end
end

-- Slash Command para facilitar el acceso
SLASH_GACMENU1 = "/gac"
SlashCmdList["GACMENU"] = function() GAC:ToggleMainMenu() end