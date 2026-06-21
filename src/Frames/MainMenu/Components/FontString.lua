local addonName, GAC = ...

function GAC:CreateFontString(parent, text, fontType, point, color)
    local fs = parent:CreateFontString(nil, "OVERLAY", fontType)
    
    if type(point) == "table" then
        fs:SetPoint(unpack(point))
    end
    
    fs:SetText(text)
    
    if type(color) == "table" then
        if color.r then
            fs:SetTextColor(color.r, color.g, color.b, color.a)
        else
            fs:SetTextColor(unpack(color))
        end
    end
    
    return fs
end