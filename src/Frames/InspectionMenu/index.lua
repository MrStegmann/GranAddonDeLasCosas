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

    -- Barra lateral
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
    
    local contentArea = CreateFrame("Frame", nil, frame)
    contentArea:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 10, 0)
    contentArea:SetPoint("BOTTOMRIGHT", -12, 12)
    frame.contentArea = contentArea

    local tabs = {}
    local tabCount = 0
    frame.currentTab = nil

    local function SelectTab(tabID)
        for id, data in pairs(tabs) do
            data.button.indicator:SetShown(false)
            data.button:SetBackdropColor(0, 0, 0, 0)
            data.button.text:SetTextColor(1, 1, 1)
            data.content:Hide()
        end
        
        if tabs[tabID] then
            local data = tabs[tabID]
            data.button.indicator:SetShown(true)
            data.button:SetBackdropColor(1, 1, 1, 0.08)
            data.button.text:SetTextColor(0.94, 0.25, 0.25)
            data.content:Show()
            frame.currentTab = tabID
            
            if data.content.Update then
                local success, err = pcall(data.content.Update, data.content)
                if not success then
                    print("|cffff0000[GAC Error]|r Fallo al actualizar la pestaña " .. tabID .. ": " .. tostring(err))
                end
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

        local indicator = btn:CreateTexture(nil, "OVERLAY")
        indicator:SetSize(3, 22)
        indicator:SetPoint("LEFT", 2, 0)
        indicator:SetColorTexture(0.94, 0.25, 0.25, 1)
        indicator:Hide()
        btn.indicator = indicator

        local text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        text:SetPoint("LEFT", 15, 0)
        text:SetText(label:upper())
        btn.text = text

        btn:SetScript("OnClick", function() SelectTab(id) end)
        btn:SetScript("OnEnter", function(s) 
            s:SetBackdropColor(1, 1, 1, 0.05)
            s.text:SetTextColor(0.94, 0.25, 0.25)
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

    AddTab("CharSheet", "Ficha de Personaje", function(p) return GAC:CreateInspectionMenuContent(p) end)
    AddTab("Inventory", "Inventario", function(p) return GAC:CreateInspectionInventoryContent(p) end)

    frame.tabs = tabs
    frame.Update = function(self)
        if self.currentTab and self.tabs[self.currentTab] and self.tabs[self.currentTab].content.Update then
            self.tabs[self.currentTab].content:Update()
        end
    end

    self.inspectionMenuFrame = frame
    SelectTab("CharSheet")
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
