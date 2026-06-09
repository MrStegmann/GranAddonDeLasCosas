local addonName, GAC = ...

function GAC:CreateArmorContent(parent)
    local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    frame:SetAllPoints()

    -- Título
    local header = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    header:SetPoint("TOPLEFT", 15, -15)
    header:SetText("Armadura")
    header:SetTextColor(1, 1, 1)

    local line = frame:CreateTexture(nil, "ARTWORK")
    line:SetPoint("TOPLEFT", 15, -40)
    line:SetPoint("TOPRIGHT", -15, -40)
    line:SetHeight(1)
    line:SetColorTexture(1, 1, 1, 0.1)

    local slots = {
        { id = "head", label = "Cabeza", texture = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Head" },
        { id = "chest", label = "Pecho", texture = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Chest" },
        { id = "hands", label = "Manos", texture = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Hands" },
        { id = "legs", label = "Piernas", texture = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Legs" }
    }

    local startY = -70
    local spacingY = -55

    frame.armorSlots = {}

    for i, slotData in ipairs(slots) do
        local slotBtn = CreateFrame("Button", nil, frame)
        slotBtn:SetSize(37, 37)
        slotBtn:SetPoint("TOPLEFT", 30, startY + (i - 1) * spacingY)

        local icon = slotBtn:CreateTexture(nil, "BACKGROUND")
        icon:SetAllPoints()
        icon:SetTexture(slotData.texture)
        slotBtn.icon = icon

        -- Borde estilo ranura de inventario
        local border = slotBtn:CreateTexture(nil, "OVERLAY")
        border:SetTexture("Interface\\Buttons\\UI-Quickslot2")
        border:SetSize(64, 64)
        border:SetPoint("CENTER", 0, 0)
        
        -- Resaltado al pasar el ratón
        local highlight = slotBtn:CreateTexture(nil, "HIGHLIGHT")
        highlight:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
        highlight:SetAllPoints()
        highlight:SetBlendMode("ADD")
        
        local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("LEFT", slotBtn, "RIGHT", 15, 0)
        label:SetText(slotData.label)

        local equipText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        equipText:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -4)
        equipText:SetText("Sin equipar")
        equipText:SetTextColor(0.5, 0.5, 0.5)

        slotBtn.label = label
        slotBtn.equipText = equipText
        slotBtn.slotId = slotData.id

        frame.armorSlots[slotData.id] = slotBtn

        slotBtn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(slotData.label)
            GameTooltip:AddLine("Haz clic para equipar o modificar la armadura.", 1, 1, 1, true)
            GameTooltip:Show()
        end)
        slotBtn:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)
    end

    frame.Update = function(self)
        -- Aquí se puede añadir la lógica para actualizar los iconos si hay un objeto equipado
    end

    return frame
end
