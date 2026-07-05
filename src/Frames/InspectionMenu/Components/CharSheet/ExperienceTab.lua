local addonName, GAC = ...

GAC.Components = GAC.Components or {}
GAC.Components.InspectionMenu = GAC.Components.InspectionMenu or {}

function GAC.Components.InspectionMenu:CreateExperienceTab(parent)
    local expBg = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    expBg:SetAllPoints()
    expBg:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12,
    })
    expBg:SetBackdropColor(0, 0, 0, 0.3)
    expBg:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)

    local expTitle = expBg:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    expTitle:SetPoint("TOPLEFT", 15, -15)
    expTitle:SetText("Gestión de Experiencia")
    expTitle:SetTextColor(0.25, 0.78, 0.94)

    local expBarBg = CreateFrame("Frame", nil, expBg, "BackdropTemplate")
    expBarBg:SetSize(400, 30)
    expBarBg:SetPoint("TOPLEFT", 20, -60)
    expBarBg:SetBackdrop({bgFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 8})
    expBarBg:SetBackdropColor(0.1, 0.1, 0.1, 0.8)

    local expBar = CreateFrame("StatusBar", nil, expBarBg)
    expBar:SetPoint("TOPLEFT", 3, -3)
    expBar:SetPoint("BOTTOMRIGHT", -3, 3)
    expBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    expBar:SetStatusBarColor(0.58, 0.0, 0.82)

    local expBarText = expBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    expBarText:SetPoint("CENTER")
    expBarText:SetText("0 / 0")

    local giveExpLabel = expBg:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    giveExpLabel:SetPoint("TOPLEFT", 20, -110)
    giveExpLabel:SetText("Otorgar Exp:")

    local giveExpInput = CreateFrame("EditBox", nil, expBg, "InputBoxTemplate")
    giveExpInput:SetSize(80, 25)
    giveExpInput:SetPoint("LEFT", giveExpLabel, "RIGHT", 10, 0)
    giveExpInput:SetAutoFocus(false)
    giveExpInput:SetNumeric(true)

    local giveExpBtn = CreateFrame("Button", nil, expBg, "UIPanelButtonTemplate")
    giveExpBtn:SetSize(80, 25)
    giveExpBtn:SetPoint("LEFT", giveExpInput, "RIGHT", 10, 0)
    giveExpBtn:SetText("Otorgar")
    giveExpBtn:SetScript("OnClick", function()
        local val = tonumber(giveExpInput:GetText())
        if val and val > 0 and GAC.inspectedPlayer then
            if GAC.Transmitter then
                GAC.Transmitter:Trigger(GAC.Enums.Events.ADD_EXP, GAC.inspectedPlayer.name, val)
                giveExpInput:SetText("")
                print("|cff00ccff[GAC]|r Has otorgado " .. val .. " de experiencia a " .. Ambiguate(GAC.inspectedPlayer.name, "none"))
                
                if GAC.Transmitter then
                    GAC.Transmitter:Trigger(GAC.Enums.Events.INSPECT_REQ, GAC.inspectedPlayer.name)
                end
            end
        end
    end)

    expBg:SetScript("OnShow", function()
        if GAC.inspectedPlayer then
            local curr = GAC.inspectedPlayer.currentExp or 0
            local mx = GAC.inspectedPlayer.maxExp or 0
            if mx <= 0 then mx = 1 end
            expBar:SetMinMaxValues(0, mx)
            expBar:SetValue(curr)
            expBarText:SetText(curr .. " / " .. mx)
        end
    end)

    expBg.Update = function(self, p)
        if self:IsShown() then
            self:GetScript("OnShow")()
        end
    end

    return expBg
end
