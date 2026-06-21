local addonName, GAC = ...

GAC.Components = GAC.Components or {}
GAC.Components.QuickButtonsMenu = GAC.Components.QuickButtonsMenu or {}

function GAC.Components.QuickButtonsMenu:CreateCustomDiceBar(frame)
    local modLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    modLabel:SetText("Mod")
    modLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 215, -13)

    local modInput = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    modInput:SetSize(26, 18)
    modInput:SetPoint("LEFT", modLabel, "RIGHT", 10, 0)
    modInput:SetAutoFocus(false)
    modInput:SetMaxLetters(5)
    frame.modifierInput = modInput

    local dadoLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    dadoLabel:SetText("Dado")
    dadoLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 215, -41)

    local qtyInput = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    qtyInput:SetSize(22, 18)
    qtyInput:SetPoint("LEFT", dadoLabel, "RIGHT", 8, 0)
    qtyInput:SetAutoFocus(false)
    qtyInput:SetNumeric(true)
    qtyInput:SetText("1")

    local sep = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sep:SetText("d")
    sep:SetPoint("LEFT", qtyInput, "RIGHT", 3, 0)

    local faceInput = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    faceInput:SetSize(28, 18)
    faceInput:SetPoint("LEFT", sep, "RIGHT", 3, 0)
    faceInput:SetAutoFocus(false)
    faceInput:SetNumeric(true)
    faceInput:SetText("20")

    local customRollBtn = GAC:CreateQuickButton(frame)
    customRollBtn:SetSize(25, 25)
    customRollBtn:SetPoint("LEFT", faceInput, "RIGHT", 5, 0)
    local customIcon = customRollBtn:CreateTexture(nil, "ARTWORK")
    customIcon:SetTexture("Interface\\Icons\\INV_Misc_Dice_02")
    customIcon:SetPoint("TOPLEFT", 2, -2)
    customIcon:SetPoint("BOTTOMRIGHT", -2, 2)
    customIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    customRollBtn:SetScript("OnClick", function()
        GAC:StartCustomDiceRoll(qtyInput:GetText(), faceInput:GetText())
    end)
    GAC:SetupQuickTooltip(customRollBtn, "Tirada Personalizada", "Lanza la cantidad y caras de dados indicadas.")
end
