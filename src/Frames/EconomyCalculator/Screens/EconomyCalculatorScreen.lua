local addonName, GAC = ...

GAC.Screens = GAC.Screens or {}
GAC.Screens.EconomyCalculator = GAC.Screens.EconomyCalculator or {}

local function GetSortedKeys(tbl)
    if not tbl then return {} end
    local sorted = {}
    for k, v in pairs(tbl) do
        table.insert(sorted, { key = k, val = v })
    end
    table.sort(sorted, function(a, b) return a.val < b.val end)
    local keys = {}
    for _, item in ipairs(sorted) do
        table.insert(keys, item.key)
    end
    return keys
end

function GAC.Screens.EconomyCalculator:CreateScreen()
    if self.frame then return end

    local store = GAC.Stores.EconomyCalculator
    local consts = store.Constants
    local sel = store.Selections
    local w = store.Weights

    -- Main frame
    local frame = CreateFrame("Frame", "GACEconomyCalculatorFrame", UIParent, "BackdropTemplate")
    frame:Hide()
    frame:SetSize(consts.FRAME_WIDTH, consts.FRAME_HEIGHT)
    
    -- Save/Restore Position
    GAC.characterData = GAC.characterData or {}
    GAC.characterData.ui = GAC.characterData.ui or {}
    GAC.characterData.ui.economyCalc = GAC.characterData.ui.economyCalc or {}
    local pos = GAC.characterData.ui.economyCalc
    if not pos.anchor then
        pos.anchor, pos.relativeAnchor, pos.x, pos.y = "CENTER", "CENTER", 100, 0
    end
    
    frame:SetPoint(pos.anchor, UIParent, pos.relativeAnchor, pos.x, pos.y)
    frame:SetMovable(true)
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
        local point, _, relPoint, x, y = s:GetPoint()
        pos.anchor = point
        pos.relativeAnchor = relPoint
        pos.x = x
        pos.y = y
    end)

    -- Close Button
    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4)

    -- Title
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 20, -18)
    title:SetText("CALCULADORA DE ECONOMÍA")
    title:SetTextColor(consts.TITLE_COLOR.r, consts.TITLE_COLOR.g, consts.TITLE_COLOR.b, consts.TITLE_COLOR.a)

    -- Horizontal division line
    local line = frame:CreateTexture(nil, "ARTWORK")
    line:SetSize(frame:GetWidth() - 24, 1)
    line:SetPoint("TOP", 0, -45)
    line:SetColorTexture(consts.LINE_COLOR.r, consts.LINE_COLOR.g, consts.LINE_COLOR.b, consts.LINE_COLOR.a)

    -- Vertical division line
    local vLine = frame:CreateTexture(nil, "ARTWORK")
    vLine:SetSize(1, frame:GetHeight() - 70)
    vLine:SetPoint("TOPLEFT", 285, -50)
    vLine:SetColorTexture(consts.LINE_COLOR.r, consts.LINE_COLOR.g, consts.LINE_COLOR.b, consts.LINE_COLOR.a)

    self.frame = frame

    -- Gather Economy Data
    local Economy = GAC.Data and GAC.Data.Economy or {}
    
    -- Sync default weights from loaded economy config if present
    if Economy.Weights then
        w.Material = Economy.Weights.Material or w.Material
        w.Rarity = Economy.Weights.Rarity or w.Rarity
        w.Time = Economy.Weights.Time or w.Time
        w.Skill = Economy.Weights.Skill or w.Skill
        w.Quality = Economy.Weights.Quality or w.Quality
    end
    if Economy.K then
        w.K = Economy.K or w.K
    end

    local materialsKeys = GetSortedKeys(Economy.Materials)
    local rarityKeys = GetSortedKeys(Economy.Rarity)
    local locationKeys = GetSortedKeys(Economy.Location)
    local conditionKeys = GetSortedKeys(Economy.Condition)
    local skillKeys = GetSortedKeys(Economy.Skill)

    -- Dropdowns
    local function CreateDropdown(label, x, y, width, keys, selectedValue, onSelectCallback)
        local labelFS = GAC:CreateFontString(frame, label, "GameFontNormal", { "TOPLEFT", x, y }, consts.LABEL_COLOR)
        
        local dropdown = CreateFrame("Frame", nil, frame, "UIDropDownMenuTemplate")
        dropdown:SetPoint("TOPLEFT", labelFS, "BOTTOMLEFT", -15, -2)
        UIDropDownMenu_SetWidth(dropdown, width)
        
        UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
            local info = UIDropDownMenu_CreateInfo()
            for _, key in ipairs(keys) do
                info.text = key
                info.checked = (key == selectedValue)
                info.func = function()
                    UIDropDownMenu_SetText(dropdown, key)
                    onSelectCallback(key)
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
        
        UIDropDownMenu_SetText(dropdown, selectedValue)
        return dropdown
    end

    -- Edit Boxes
    local function CreateEditBox(label, x, y, width, initialValue, onChangeCallback)
        local labelFS = GAC:CreateFontString(frame, label, "GameFontNormal", { "TOPLEFT", x, y }, consts.LABEL_COLOR)
        
        local editBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
        editBox:SetSize(width, 20)
        editBox:SetPoint("TOPLEFT", labelFS, "BOTTOMLEFT", 5, -2)
        editBox:SetAutoFocus(false)
        editBox:SetFontObject("GameFontHighlight")
        editBox:SetTextInsets(4, 4, 0, 0)
        editBox:SetText(tostring(initialValue))
        
        editBox:SetScript("OnTextChanged", function(self, isUserInput)
            if not isUserInput then return end
            onChangeCallback(self:GetText())
        end)
        editBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        editBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
        
        return editBox
    end

    -- Create Left Column UI Elements (Inputs)
    -- Row 1
    local dropMaterial = CreateDropdown("Material:", 20, -60, 110, materialsKeys, sel.Material, function(val)
        sel.Material = val
        self:UpdateDisplay()
    end)
    local editTime = CreateEditBox("Tiempo (Time):", 170, -60, 90, sel.Time, function(val)
        sel.Time = tonumber(val) or 1
        self:UpdateDisplay()
    end)

    -- Row 2
    local dropRarity = CreateDropdown("Rareza (Rarity):", 20, -110, 110, rarityKeys, sel.Rarity, function(val)
        sel.Rarity = val
        self:UpdateDisplay()
    end)
    local editQuality = CreateEditBox("Calidad (Quality):", 170, -110, 90, sel.Quality, function(val)
        sel.Quality = tonumber(val) or 5
        self:UpdateDisplay()
    end)

    -- Row 3
    local dropLocation = CreateDropdown("Ubicación (Location):", 20, -160, 110, locationKeys, sel.Location, function(val)
        sel.Location = val
        self:UpdateDisplay()
    end)
    local editDemand = CreateEditBox("Demanda (Demand):", 170, -160, 90, sel.Demand, function(val)
        sel.Demand = tonumber(val) or 1.0
        self:UpdateDisplay()
    end)

    -- Row 4
    local dropCondition = CreateDropdown("Condición (Condition):", 20, -210, 110, conditionKeys, sel.Condition, function(val)
        sel.Condition = val
        self:UpdateDisplay()
    end)
    local editTax = CreateEditBox("Impuesto (Tax):", 170, -210, 90, sel.Tax, function(val)
        sel.Tax = tonumber(val) or 0.0
        self:UpdateDisplay()
    end)

    -- Row 5
    local dropSkill = CreateDropdown("Habilidad (Skill):", 20, -260, 110, skillKeys, sel.Skill, function(val)
        sel.Skill = val
        self:UpdateDisplay()
    end)
    local editPrestige = CreateEditBox("Prestigio (Prestige):", 170, -260, 90, sel.Prestige, function(val)
        sel.Prestige = tonumber(val) or 1.0
        self:UpdateDisplay()
    end)

    -- Weights Configuration Section
    local weightsTitle = GAC:CreateFontString(frame, "PESOS DE LA FÓRMULA", "GameFontNormal", { "TOPLEFT", 20, -315 }, consts.TITLE_COLOR)
    
    local editMatW = CreateEditBox("Mat W:", 20, -330, 40, w.Material, function(val)
        w.Material = tonumber(val) or 0.30
        self:UpdateDisplay()
    end)
    local editRarW = CreateEditBox("Rar W:", 70, -330, 40, w.Rarity, function(val)
        w.Rarity = tonumber(val) or 0.25
        self:UpdateDisplay()
    end)
    local editTimeW = CreateEditBox("Time W:", 120, -330, 40, w.Time, function(val)
        w.Time = tonumber(val) or 0.20
        self:UpdateDisplay()
    end)
    local editSkillW = CreateEditBox("Skill W:", 170, -330, 40, w.Skill, function(val)
        w.Skill = tonumber(val) or 0.15
        self:UpdateDisplay()
    end)
    local editQualW = CreateEditBox("Qual W:", 220, -330, 40, w.Quality, function(val)
        w.Quality = tonumber(val) or 0.10
        self:UpdateDisplay()
    end)

    local editK = CreateEditBox("K (Calibración):", 20, -380, 75, w.K, function(val)
        w.K = tonumber(val) or 8.33
        self:UpdateDisplay()
    end)

    local btnReset = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    btnReset:SetSize(140, 22)
    btnReset:SetPoint("TOPLEFT", 115, -394)
    btnReset:SetText("Restablecer Pesos")
    btnReset:SetScript("OnClick", function()
        w.Material = (Economy.Weights and Economy.Weights.Material) or 0.30
        w.Rarity = (Economy.Weights and Economy.Weights.Rarity) or 0.25
        w.Time = (Economy.Weights and Economy.Weights.Time) or 0.20
        w.Skill = (Economy.Weights and Economy.Weights.Skill) or 0.15
        w.Quality = (Economy.Weights and Economy.Weights.Quality) or 0.10
        w.K = Economy.K or 8.33
        
        editMatW:SetText(tostring(w.Material))
        editRarW:SetText(tostring(w.Rarity))
        editTimeW:SetText(tostring(w.Time))
        editSkillW:SetText(tostring(w.Skill))
        editQualW:SetText(tostring(w.Quality))
        editK:SetText(tostring(w.K))
        
        self:UpdateDisplay()
    end)

    -- Right Column UI Elements (Results)
    local resultsTitle = GAC:CreateFontString(frame, "RESULTADOS", "GameFontNormalLarge", { "TOPLEFT", 300, -60 }, consts.TITLE_COLOR)

    -- Base Value Info Box
    local baseValueBox = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    baseValueBox:SetSize(250, 45)
    baseValueBox:SetPoint("TOPLEFT", 300, -85)
    baseValueBox:SetBackdrop({bgFile = consts.BACKDROP_BG, edgeFile = consts.BACKDROP_EDGE, edgeSize = 8})
    baseValueBox:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    baseValueBox:SetBackdropBorderColor(0.25, 0.78, 0.94, 0.3)
    
    local lblBaseVal = GAC:CreateFontString(baseValueBox, "Valor Base (Base Value)", "GameFontNormalSmall", { "TOPLEFT", 8, -5 }, consts.LABEL_COLOR)
    local valBaseVal = GAC:CreateFontString(baseValueBox, "-", "GameFontHighlightLarge", { "BOTTOMRIGHT", -10, 5 }, consts.VALUE_COLOR)

    -- Price Box
    local priceBox = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    priceBox:SetSize(250, 60)
    priceBox:SetPoint("TOPLEFT", 300, -140)
    priceBox:SetBackdrop({bgFile = consts.BACKDROP_BG, edgeFile = consts.BACKDROP_EDGE, edgeSize = 8})
    priceBox:SetBackdropColor(0.1, 0.12, 0.15, 0.9)
    priceBox:SetBackdropBorderColor(0.25, 0.78, 0.94, 0.8)
    
    local lblPrice = GAC:CreateFontString(priceBox, "PRECIO FINAL", "GameFontNormal", { "TOPLEFT", 10, -8 }, consts.ACCENT_COLOR)
    local valPrice = GAC:CreateFontString(priceBox, "-", "GameFontHighlightHuge", { "BOTTOMRIGHT", -12, 6 }, { r = 1, g = 0.82, b = 0, a = 1 })

    -- Breakdown Section
    local breakdownTitle = GAC:CreateFontString(frame, "DESGLOSE DE FACTORES", "GameFontNormal", { "TOPLEFT", 300, -215 }, consts.TITLE_COLOR)

    -- Factor Lines
    local factorLines = {}
    local startY = -235
    for i = 1, 9 do
        factorLines[i] = GAC:CreateFontString(frame, "", "GameFontHighlightSmall", { "TOPLEFT", 300, startY }, consts.VALUE_COLOR)
        startY = startY - 18
    end

    -- Formula display string
    local formulaText = GAC:CreateFontString(frame, "", "GameFontNormalSmall", { "TOPLEFT", 300, -400 }, consts.LABEL_COLOR)
    formulaText:SetWidth(250)
    formulaText:SetJustifyH("LEFT")

    -- Update Logic
    self.UpdateDisplay = function()
        local matVal = (Economy.Materials and Economy.Materials[sel.Material]) or 1
        local rarVal = (Economy.Rarity and Economy.Rarity[sel.Rarity]) or 1
        local locVal = (Economy.Location and Economy.Location[sel.Location]) or 1
        local condVal = (Economy.Condition and Economy.Condition[sel.Condition]) or 1
        local skillVal = (Economy.Skill and Economy.Skill[sel.Skill]) or 1

        -- Calculate Base
        local materialTerm = matVal ^ w.Material
        local rarityTerm = rarVal ^ w.Rarity
        local timeTerm = sel.Time ^ w.Time
        local skillTerm = skillVal ^ w.Skill
        local qualityTerm = sel.Quality ^ w.Quality

        local baseVal = materialTerm * rarityTerm * timeTerm * skillTerm * qualityTerm
        valBaseVal:SetText(string.format("%.3f", baseVal))

        -- Calculate Final Price
        local multipliers = locVal * sel.Demand * (1 + sel.Tax) * sel.Prestige * condVal
        local finalPriceRaw = w.K * baseVal * multipliers
        local finalPrice = math.ceil(finalPriceRaw)

        -- Format price beautifully as copper/silver/gold
        -- Since custom monedas are treated here, we can show both custom and WoW format
        local rawPriceText = string.format("%d Monedas", finalPrice)
        valPrice:SetText(rawPriceText)

        -- Update breakdown texts
        factorLines[1]:SetText(string.format("Material: %s (%d) ^ %.2f = %.3f", sel.Material, matVal, w.Material, materialTerm))
        factorLines[2]:SetText(string.format("Rareza: %s (%d) ^ %.2f = %.3f", sel.Rarity, rarVal, w.Rarity, rarityTerm))
        factorLines[3]:SetText(string.format("Tiempo: %s ^ %.2f = %.3f", tostring(sel.Time), w.Time, timeTerm))
        factorLines[4]:SetText(string.format("Habilidad: %s (%d) ^ %.2f = %.3f", sel.Skill, skillVal, w.Skill, skillTerm))
        factorLines[5]:SetText(string.format("Calidad: %s ^ %.2f = %.3f", tostring(sel.Quality), w.Quality, qualityTerm))
        factorLines[6]:SetText(string.format("Ubicación (Loc): %s (x%.2f)", sel.Location, locVal))
        factorLines[7]:SetText(string.format("Condición (Cond): %s (x%.2f)", sel.Condition, condVal))
        factorLines[8]:SetText(string.format("Demanda: x%.2f | Impuesto: +%.0f%%", sel.Demand, sel.Tax * 100))
        factorLines[9]:SetText(string.format("Prestigio: x%.2f", sel.Prestige))

        -- Update formula text
        formulaText:SetText(string.format("Fórmula: K (%.2f) * Base (%.2f) * Loc (%.2f) * Cond (%.2f) * Dem (%.2f) * Tax (1+%.2f) * Pres (%.2f) = %.2f (Ceil: %d)",
            w.K, baseVal, locVal, condVal, sel.Demand, sel.Tax, sel.Prestige, finalPriceRaw, finalPrice))
    end

    self:UpdateDisplay()
end
