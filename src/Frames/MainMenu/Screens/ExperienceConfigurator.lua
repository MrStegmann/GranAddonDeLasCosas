local addonName, GAC = ...

function GAC:CreateExperienceConfigurator(parent)
    local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    frame:SetAllPoints()

    -- Título
    local header = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    header:SetPoint("TOPLEFT", 15, -15)
    header:SetText(GAC:_("expHeaderTitle"))
    header:SetTextColor(1, 1, 1)

    local line = frame:CreateTexture(nil, "ARTWORK")
    line:SetPoint("TOPLEFT", 15, -40)
    line:SetPoint("TOPRIGHT", -15, -40)
    line:SetHeight(1)
    line:SetColorTexture(1, 1, 1, 0.1)

    -- Nivel Actual: #nivel (Categoria)
    local levelText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    levelText:SetPoint("TOPLEFT", 20, -60)
    levelText:SetTextColor(0.25, 0.78, 0.94)
    
    -- Barra de experiencia
    local expBar = CreateFrame("StatusBar", nil, frame, "BackdropTemplate")
    expBar:SetSize(400, 24)
    expBar:SetPoint("TOPLEFT", levelText, "BOTTOMLEFT", 0, -20)
    expBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    expBar:SetStatusBarColor(0.6, 0.2, 0.8) -- Morado estilo experiencia
    expBar:SetBackdrop({ bgFile = "Interface\\ChatFrame\\ChatFrameBackground" })
    expBar:SetBackdropColor(0, 0, 0, 0.8)
    
    local expBarBorder = CreateFrame("Frame", nil, expBar, "BackdropTemplate")
    expBarBorder:SetAllPoints()
    expBarBorder:SetBackdrop({ edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12 })
    expBarBorder:SetBackdropBorderColor(0.25, 0.78, 0.94, 0.8)

    local expText = expBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    expText:SetPoint("CENTER")

    -- Input: Experiencia recibida
    local inputLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    inputLabel:SetPoint("TOPLEFT", expBar, "BOTTOMLEFT", 0, -30)
    inputLabel:SetText(GAC:_("expReceivedLabel"))

    local expInput = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    expInput:SetSize(100, 20)
    expInput:SetPoint("LEFT", inputLabel, "RIGHT", 10, 0)
    expInput:SetAutoFocus(false)
    expInput:SetNumeric(true)
    
    local function UpdateUI()
        local snapshot = GAC:GetExperienceProgressSnapshot() or {}
        local categoryStr = GAC:_(snapshot.category) or snapshot.category or "normal"
        if type(categoryStr) == "string" then
            categoryStr = categoryStr:gsub("^%l", string.upper)
        else
            categoryStr = tostring(categoryStr)
        end
        levelText:SetText(string.format(GAC:_("expCurrentLevelFmt"), snapshot.level or 1, categoryStr))
        
        local currentExp = snapshot.currentExperience
        local reqExp = snapshot.requiredExperience or 1
        
        if snapshot.requiredExperience and reqExp > 0 then
            expBar:SetMinMaxValues(0, reqExp)
            expBar:SetValue(currentExp)
            expText:SetText(string.format("%d / %d (%.1f%%)", currentExp, reqExp, (currentExp / reqExp) * 100))
        else
            expBar:SetMinMaxValues(0, 1)
            expBar:SetValue(1)
            expText:SetText(GAC:_("expMaxLevelReached"))
        end
        GAC:UpdateGameExpBar()
    end

    expInput:SetScript("OnEnterPressed", function(self)
        local val = tonumber(self:GetText()) or 0
        if val > 0 then
            if GAC.Dispatcher and GAC.Actions then
                GAC.Dispatcher:Dispatch(GAC.Actions.ADD_EXPERIENCE, { expAmount = val })
            else
                GAC:AddExperience(val)
                UpdateUI()
            end
            self:SetText("")
            self:ClearFocus()
            print(string.format("|cFF40C7EBGAC:|r " .. GAC:_("expReceivedMsgFmt"), val))
        end
    end)
    expInput:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    frame.Update = function(self)
        UpdateUI()
    end

    if GAC.Store and GAC.Store.Subscribe then
        GAC.Store:Subscribe(function()
            if frame:IsShown() and frame.Update then
                frame:Update()
            end
        end)
    end

    return frame
end
