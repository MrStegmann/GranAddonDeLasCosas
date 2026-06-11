local addonName, GAC = ...

function GAC:CreateInventoryContent(parent)
    local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    frame:SetAllPoints()

    local function DrawTooltip(tooltipFrame, itemData, isNotAllowed)
        tooltipFrame:ClearLines()
        local r, g, b = 1, 1, 1
        if itemData.itemQuality and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[itemData.itemQuality] then
            local color = ITEM_QUALITY_COLORS[itemData.itemQuality]
            r, g, b = color.r, color.g, color.b
        end
        
        tooltipFrame:AddLine(itemData.itemName, r, g, b)
        
        if itemData.armorData then
            local data = itemData.armorData
            local leftText = data.baseStr
            if data.hasReinforcement then
                leftText = leftText .. ": Reforzado con " .. data.reinforcementStr
            end
            tooltipFrame:AddDoubleLine(leftText, data.slotStr, 1, 1, 1, 1, 1, 1)
            
            tooltipFrame:AddLine("Reducción física: " .. data.physRed, 1, 1, 1)
            tooltipFrame:AddLine("Reducción mágica: " .. data.magRed, 1, 1, 1)
            
            local statNames = {
                brutality = "Brutalidad", agileDefense = "Defensa Ágil", movement = "Movimiento",
                perception = "Percepción", stealth = "Sigilo", acrobatics = "Acrobacias", sleightOfHand = "Juego de Manos"
            }
            
            local hasReqs = false
            for stat, val in pairs(data.requirements) do
                if not hasReqs then
                    tooltipFrame:AddLine(" ")
                    hasReqs = true
                end
                tooltipFrame:AddLine((statNames[stat] or stat) .. " " .. val, 0, 1, 0)
            end
            
            local hasPens = false
            for stat, val in pairs(data.penalties) do
                if not hasPens then
                    if not hasReqs then tooltipFrame:AddLine(" ") end
                    hasPens = true
                end
                tooltipFrame:AddLine((statNames[stat] or stat) .. " " .. val, 1, 0, 0)
            end
            
            tooltipFrame:AddLine(" ")
            tooltipFrame:AddLine(data.currentDurability, 1, 1, 1)
            
            if isNotAllowed then
                tooltipFrame:AddLine(" ")
                tooltipFrame:AddLine("* " .. string.upper(tostring(isNotAllowed)) .. " *", 1, 0, 0, true)
            elseif data.meetsRequirements == false then
                tooltipFrame:AddLine(" ")
                tooltipFrame:AddLine("* No cumples con los requisitos *", 1, 0.2, 0.2)
            end
        else
            if itemData.itemDescription and itemData.itemDescription ~= "" then
                tooltipFrame:AddLine(itemData.itemDescription, 1, 0.82, 0, true)
            end
        end
        
        if isNotAllowed and tooltipFrame.SetBackdropBorderColor then
            tooltipFrame.originalBorderR, tooltipFrame.originalBorderG, tooltipFrame.originalBorderB, tooltipFrame.originalBorderA = tooltipFrame:GetBackdropBorderColor()
            tooltipFrame:SetBackdropBorderColor(1, 0, 0, 1)
        end
        
        tooltipFrame:Show()
    end

    -- Título
    local header = GAC:CreateFontString(frame, "Inventario", "GameFontNormalLarge", { "TOPLEFT", 15, -15 }, { 1, 1, 1 })

    local line = frame:CreateTexture(nil, "ARTWORK")
    line:SetPoint("TOPLEFT", 15, -40)
    line:SetPoint("TOPRIGHT", -15, -40)
    line:SetHeight(1)
    line:SetColorTexture(1, 1, 1, 0.1)

    local slots = {
        { id = 1, label = "Cabeza", name="head", icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Head" },
        { id = 5, label = "Pecho", name="chest", icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Chest" },
        { id = 10, label = "Manos", name="hands", icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Hands" },
        { id = 7, label = "Piernas", name="legs", icon = "Interface\\PaperDoll\\UI-PaperDoll-Slot-Legs" },
    }

    local slotFrames = {}

    local startX = 30
    local startY = -70
    local yOffset = -60
    for i, slotData in ipairs(slots) do
        
        local slotButton = CreateFrame("Button", "GAC_InventorySlot" .. slotData.id, frame)
        slotButton:SetSize(37, 37)
        slotButton:SetPoint("TOPLEFT", startX, startY + (i - 1) * yOffset)
        
        local icon = slotButton:CreateTexture(nil, "BACKGROUND")
        icon:SetAllPoints()
        slotButton.icon = icon
        
        local border = slotButton:CreateTexture(nil, "OVERLAY")
        border:SetTexture("Interface\\Buttons\\UI-Quickslot2")
        border:SetSize(60, 60)
        border:SetPoint("CENTER", 0, 0)
        slotButton.customBorder = border
        
        slotButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
        slotButton:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")

        slotButton.icon:SetTexture(slotData.icon)
        local label = GAC:CreateFontString(frame, slotData.label, "GameFontNormal", { "LEFT", slotButton, "RIGHT", 15, 0 }, { 0.5, 0.5, 0.5 })
        
        slotButton.slotID = slotData.id
        slotButton.slotName = slotData.name
        slotButton.emptyIcon = slotData.icon
        slotButton.emptyLabel = slotData.label
        slotButton.label = label
        slotButton:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            if self.itemDataList and #self.itemDataList > 0 then
                DrawTooltip(GameTooltip, self.itemDataList[1], self.itemDataList.notAllowed)
                
                if self.itemDataList[2] then
                    ShoppingTooltip1:SetOwner(GameTooltip, "ANCHOR_NONE")
                    ShoppingTooltip1:ClearAllPoints()
                    ShoppingTooltip1:SetPoint("TOPLEFT", GameTooltip, "TOPRIGHT", 5, 0)
                    DrawTooltip(ShoppingTooltip1, self.itemDataList[2], self.itemDataList.notAllowed)
                end
            else
                GameTooltip:SetText(self.emptyLabel)
                GameTooltip:Show()
            end
        end)
        slotButton:SetScript("OnLeave", function(self)
            if GameTooltip.originalBorderR then
                GameTooltip:SetBackdropBorderColor(GameTooltip.originalBorderR, GameTooltip.originalBorderG, GameTooltip.originalBorderB, GameTooltip.originalBorderA)
                GameTooltip.originalBorderR = nil
            end
            GameTooltip:Hide()
            
            if ShoppingTooltip1.originalBorderR then
                ShoppingTooltip1:SetBackdropBorderColor(ShoppingTooltip1.originalBorderR, ShoppingTooltip1.originalBorderG, ShoppingTooltip1.originalBorderB, ShoppingTooltip1.originalBorderA)
                ShoppingTooltip1.originalBorderR = nil
            end
            ShoppingTooltip1:Hide()
        end)
        slotFrames[#slotFrames + 1] = slotButton
    end
    local summaryFrame = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    summaryFrame:SetSize(220, 260)
    summaryFrame:SetPoint("TOPRIGHT", -30, -70)
    summaryFrame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12, insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    summaryFrame:SetBackdropColor(0, 0, 0, 0.5)
    summaryFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.5)
    
    local summaryTitle = GAC:CreateFontString(summaryFrame, "Resumen de Equipo", "GameFontNormal", { "TOP", 0, -10 }, { 1, 0.82, 0 })
    
    local reqHeader = GAC:CreateFontString(summaryFrame, "Requerimientos Totales", "GameFontHighlight", { "TOPLEFT", 15, -40 }, { 0, 1, 0 })
    local reqText = GAC:CreateFontString(summaryFrame, "", "GameFontHighlightSmall", { "TOPLEFT", reqHeader, "BOTTOMLEFT", 5, -5 }, { 1, 1, 1 })
    reqText:SetJustifyH("LEFT")
    
    local penHeader = GAC:CreateFontString(summaryFrame, "Penalizadores Totales", "GameFontHighlight", { "TOPLEFT", reqHeader, "BOTTOMLEFT", 0, -80 }, { 1, 0, 0 })
    local penText = GAC:CreateFontString(summaryFrame, "", "GameFontHighlightSmall", { "TOPLEFT", penHeader, "BOTTOMLEFT", 5, -5 }, { 1, 1, 1 })
    penText:SetJustifyH("LEFT")
    
    local meetsReqText = GAC:CreateFontString(summaryFrame, "", "GameFontNormalSmall", { "BOTTOM", 0, 15 }, { 1, 0.2, 0.2 })

    frame.Update = function(self)
        if GAC.UpdateEquippedArmor then GAC:UpdateEquippedArmor() end
        
        local equippedBySlot = GAC.characterData and GAC.characterData.inventory and GAC.characterData.inventory.equippedArmor or {}
        
        local totalReqs = {}
        local totalPens = {}
        local meetsAll = true
        local hasAnyArmor = false
        local notAllowedErrors = {}
        
        for _, btn in ipairs(slotFrames) do
            local slotList = equippedBySlot[btn.slotName] or equippedBySlot[btn.slotID]
            btn.itemDataList = slotList
            
            if slotList and #slotList > 0 then
                local item = slotList[1]
                local icon = item.itemIcon or "INV_Misc_QuestionMark"
                if type(icon) == "string" and not icon:match("\\") then
                    icon = "Interface\\Icons\\" .. icon
                end
                btn.icon:SetTexture(icon)
                
                local r, g, b = 1, 1, 1
                if item.itemQuality and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[item.itemQuality] then
                    local color = ITEM_QUALITY_COLORS[item.itemQuality]
                    r, g, b = color.r, color.g, color.b
                end
                
                btn.label:SetText(item.itemName)
                btn.label:SetTextColor(r, g, b)
                
                if slotList.notAllowed then
                    btn.customBorder:SetVertexColor(1, 0, 0)
                    btn.icon:SetVertexColor(1, 0, 0)
                    local name1 = slotList[1].armorData and slotList[1].armorData.baseStr or "Pieza 1"
                    local name2 = slotList[2] and slotList[2].armorData and slotList[2].armorData.baseStr or "Pieza 2"
                    table.insert(notAllowedErrors, btn.emptyLabel .. ": " .. name1 .. " y " .. name2 .. "\n  - " .. tostring(slotList.notAllowed))
                else
                    btn.customBorder:SetVertexColor(1, 1, 1)
                    btn.icon:SetVertexColor(1, 1, 1)
                end
                
                for _, listIt in ipairs(slotList) do
                    if listIt.armorData then
                        hasAnyArmor = true
                        if listIt.armorData.meetsRequirements == false then
                            meetsAll = false
                        end
                        if listIt.armorData.requirements then
                            for stat, val in pairs(listIt.armorData.requirements) do
                                totalReqs[stat] = (totalReqs[stat] or 0) + val
                            end
                        end
                        if listIt.armorData.penalties then
                            for stat, val in pairs(listIt.armorData.penalties) do
                                totalPens[stat] = (totalPens[stat] or 0) + val
                            end
                        end
                    end
                end
            else
                btn.icon:SetTexture(btn.emptyIcon)
                btn.label:SetText(btn.emptyLabel)
                btn.label:SetTextColor(0.5, 0.5, 0.5)
                btn.customBorder:SetVertexColor(1, 1, 1)
                btn.icon:SetVertexColor(1, 1, 1)
            end
        end
        
        local statNames = {
            brutality = "Brutalidad", agileDefense = "Defensa Ágil", movement = "Movimiento",
            perception = "Percepción", stealth = "Sigilo", acrobatics = "Acrobacias", sleightOfHand = "Juego de Manos"
        }
        
        local rStr = ""
        for stat, val in pairs(totalReqs) do
            rStr = rStr .. "- " .. (statNames[stat] or stat) .. " " .. val .. "\n"
        end
        if rStr == "" then rStr = "Ninguno" end
        reqText:SetText(rStr)
        
        local pStr = ""
        for stat, val in pairs(totalPens) do
            pStr = pStr .. "- " .. (statNames[stat] or stat) .. " " .. val .. "\n"
        end
        if pStr == "" then pStr = "Ninguno" end
        penText:SetText(pStr)
        
        if #notAllowedErrors > 0 then
            meetsReqText:SetText("* Comb. Inválidas:\n" .. table.concat(notAllowedErrors, "\n"))
        elseif hasAnyArmor and not meetsAll then
            meetsReqText:SetText("* No cumples con los requisitos *")
        else
            meetsReqText:SetText("")
        end
    end
    GAC.contentFrames.inventory = frame
    return frame
end
