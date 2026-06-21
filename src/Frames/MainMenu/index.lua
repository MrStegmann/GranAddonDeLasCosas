local addonName, GAC = ...

GAC.Screens = GAC.Screens or {}
GAC.Screens.MainMenu = GAC.Screens.MainMenu or {}

function GAC.Screens.MainMenu:Create()
    if self.frame then return end

    local store = GAC.Stores.MainMenu
    local consts = store.Constants

    -- Marco principal
    local frame = CreateFrame("Frame", "GACMainMenuFrame", UIParent, "BackdropTemplate")
    frame:Hide()
    frame:SetSize(consts.FRAME_WIDTH, consts.FRAME_HEIGHT)
    
    -- Posicionamiento persistente
    GAC.characterData = GAC.characterData or {}
    GAC.characterData.ui = GAC.characterData.ui or {}
    GAC.characterData.ui.mainMenu = GAC.characterData.ui.mainMenu or {}
    local pos = GAC.characterData.ui.mainMenu
    if not pos.anchor then
        pos.anchor, pos.relativeAnchor, pos.x, pos.y = "CENTER", "CENTER", 0, 0
    end
    
    frame:SetPoint(pos.anchor, UIParent, pos.relativeAnchor, pos.x, pos.y)
    frame:SetMovable(true)
    
    -- SafeCall para SetClampedWithVisiblePixels en caso de que no exista
    if GAC.SetClampedWithVisiblePixels then
        GAC:SetClampedWithVisiblePixels(frame, 20)
    end
    
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetClampedToScreen(true)
    frame:SetFrameStrata("HIGH")

    frame:SetBackdrop({
        bgFile = consts.BACKDROP_BG,
        edgeFile = consts.BACKDROP_EDGE,
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    frame:SetBackdropColor(consts.BG_COLOR.r, consts.BG_COLOR.g, consts.BG_COLOR.b, consts.BG_COLOR.a)
    frame:SetBackdropBorderColor(consts.BORDER_COLOR.r, consts.BORDER_COLOR.g, consts.BORDER_COLOR.b, consts.BORDER_COLOR.a)

    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(s)
        s:StopMovingOrSizing()
        GAC.Utils.MainMenu:SavePosition(s)
    end)

    -- Botón cerrar
    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4)

    -- Título del Addon
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 20, -18)
    title:SetText("GRAN ADDON DE LAS COSAS")
    title:SetTextColor(consts.TITLE_COLOR.r, consts.TITLE_COLOR.g, consts.TITLE_COLOR.b, consts.TITLE_COLOR.a)

    -- Línea divisoria
    local line = frame:CreateTexture(nil, "ARTWORK")
    line:SetSize(frame:GetWidth() - 24, 1)
    line:SetPoint("TOP", 0, -45)
    line:SetColorTexture(consts.LINE_COLOR.r, consts.LINE_COLOR.g, consts.LINE_COLOR.b, consts.LINE_COLOR.a)

    -- Barra lateral de navegación
    local sidebar = GAC.Components.MainMenu:CreateSidebar(frame)

    -- Contenedor principal de pestañas
    local contentArea = CreateFrame("Frame", nil, frame)
    contentArea:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 10, 0)
    contentArea:SetPoint("BOTTOMRIGHT", -12, 12)
    frame.contentArea = contentArea

    self.frame = frame

    -- Inserción de las pestañas
    if GAC.Screens.MainMenu.CreateCharSheetScreen then
        GAC.Utils.MainMenu:AddTab("CharSheet", "Ficha de Personaje", function(p) return GAC.Screens.MainMenu:CreateCharSheetScreen(p) end, sidebar, contentArea)
    end
    if GAC.CreateInventoryContent then
        GAC.Utils.MainMenu:AddTab("Inventory", "Inventario", function(p) return GAC:CreateInventoryContent(p) end, sidebar, contentArea)
    end
    if GAC.CreateExperienceConfigurator then
        GAC.Utils.MainMenu:AddTab("ExpConfig", "Conf. Experiencia", function(p) return GAC:CreateExperienceConfigurator(p) end, sidebar, contentArea)
    end

    GAC.Utils.MainMenu:SelectTab("CharSheet")
end

function GAC.Screens.MainMenu:Toggle()
    self:Create()
    if self.frame:IsShown() then 
        self.frame:Hide() 
    else 
        self.frame:Show() 
    end
end