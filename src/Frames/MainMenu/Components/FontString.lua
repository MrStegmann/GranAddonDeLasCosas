local addonName, GAC = ...

function GAC:CreateFontString(parent, text, fontType, point, color)
    local fs = parent:CreateFontString(nil, "OVERLAY", fontType)
    
    if type(point) == "table" then
        fs:SetPoint(unpack(point))
    end
    
    fs:SetText(text)
    
    if type(color) == "table" then
        fs:SetTextColor(unpack(color))
    end
    
    return fs
end