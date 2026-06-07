local addonName, GAC = ...

function GAC:CreateCard(parent, group, saveCallback, statInputsTable)
    local card = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    card:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    card:SetBackdropColor(0, 0, 0, 0.5)
    card:SetBackdropBorderColor(0.25, 0.78, 0.94, 0.6)

    local headerBg = CreateFrame("Frame", nil, card)
    headerBg:SetPoint("TOPLEFT", 3, -3)
    headerBg:SetPoint("TOPRIGHT", -3, -3)
    headerBg:SetHeight(30)

    local attRow, nameLabel = GAC:CreateStatInput(headerBg, GAC:_(group.name), group.name, false, saveCallback, statInputsTable)
    attRow:SetPoint("CENTER")
    nameLabel:SetFontObject("GameFontNormalLarge")
    nameLabel:SetTextColor(0.25, 0.78, 0.94)

    local div = card:CreateTexture(nil, "ARTWORK")
    div:SetHeight(1)
    div:SetPoint("TOPLEFT", headerBg, "BOTTOMLEFT", 5, 0)
    div:SetPoint("TOPRIGHT", headerBg, "BOTTOMRIGHT", -5, 0)
    div:SetColorTexture(1, 1, 1, 0.1)

    local currentY = -40
    for _, talent in ipairs(group.talents) do
        local talRow = GAC:CreateStatInput(card, GAC:_(talent), talent, true, saveCallback, statInputsTable)
        talRow:SetPoint("TOP", 0, currentY)
        currentY = currentY - 26
    end

    card:SetHeight(-currentY + 5)
    return card
end