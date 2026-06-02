local addonName, GAC = ...
local WLVX = nil

if WLV_Extends then
    WLVX = WLV_Extends
else return end

local menuId = "MainMenu"
local charSheetId = "_CharSheetContent"

-- Función para manejar la navegación entre secciones del menú principal. Recibe el destino como argumento y muestra el contenido correspondiente. Dejará todos en Hide y hará Show solo del que corresponda.
local function NavigateTo(contentId)
    for id, frame in pairs(GAC.contentFrames) do
        if id == contentId then
            frame:Show()
        else
            frame:Hide()
        end
    end
end


local function buildExpContent(parentFrame)
    
    local expContent = WLVX:AddColumn(parentFrame, expContentId, '100%', '100%', function(content)
        WLVX:SetMargin(content, 5, 15)
        WLVX:AddLabel(content, expContentId .. "_Label", "Contenido de la experiencia", '100%', 20)
    end)
    expContent:Hide() -- Ocultar el contenido de experiencia por defecto, se mostrará al navegar a esa sección.
    GAC.contentFrames[expContentId] = expContent
end

-- alwaysVisible debe ser false. Está en true para construir menu
local mainMenu = WLVX:CreateMenu(menuId, "", {width = 500, height = 600}, {movable = true, alwaysVisible = true  }, function(frame) 
    
    local upperId = menuId .. "_RowContent"
    WLVX:AddRow(frame, upperId, '100%', '100%', function(row)
        WLVX:SetMargin(row, 5)
        
        -- NavBar
        local navBarId = upperId .. "_NavBar"
        WLVX:AddColumn(row, navBarId, 75, '100%', function(navBar)
            WLVX:SetGap(navBar, 5)
            WLVX:SetMargin(navBar, 5, 15)
            WLVX:AddButton(navBar, navBarId .. "_Btn1", "Ficha", '75%', 30, function() NavigateTo(charSheetId) end)
        end)
       -- End NavBar
       -- Content
         local contentId = upperId .. "_Content"
         WLVX:AddColumn(row, contentId, '100%', '100%', function(content)
            WLVX:SetMargin(content, 5, 15)
            GAC:buildCharSheetContent(contentId, charSheetId, content)
         end)
        -- End Content
    end)
end)