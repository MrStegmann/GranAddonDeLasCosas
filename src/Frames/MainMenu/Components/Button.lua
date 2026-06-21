local addonName, GAC = ...

-- Función constructora del botón reutilizable
function GAC:CreateButton(parent, text, size, point, isHidden)
    local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    
    -- Tamaño (Por defecto 140x26 si no se especifica)
    if type(size) == "table" and #size == 2 then
        btn:SetSize(size[1], size[2])
    else
        btn:SetSize(140, 26) 
    end
    
    -- Posición
    if type(point) == "table" then
        btn:SetPoint(unpack(point))
    end
    
    -- Texto
    btn:SetText(text or "")
    
    -- Ocultar por defecto si se requiere
    if isHidden then
        btn:Hide()
    end
    
    return btn
end
