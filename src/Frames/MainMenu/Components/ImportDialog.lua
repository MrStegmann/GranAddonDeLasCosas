local addonName, GAC = ...

GAC.Components = GAC.Components or {}
GAC.Components.MainMenu = GAC.Components.MainMenu or {}

-------------------------------------------------------------------------------
-- Lógica de importación
-- Formato del string de importación (separado por ":"):
--
--   GAC:v1:<raza1>:<raza2>:<nivel>:<categoría>:<atributos>:<talentos>:<isWorgenCurse>:<rasgosPositivos>:<rasgosNegativos>
--
-- Donde:
--   <raza1>           = nombre interno de la raza principal (ej: "human", "orc", "void")
--   <raza2>           = nombre interno de la raza secundaria (ej: "void" si no aplica)
--   <nivel>           = número entero (ej: "5")
--   <categoría>       = "noob", "normal", "elite" o "boss"
--   <atributos>       = pares clave=valor separados por coma
--                       ej: "dexterity=3,strength=2,intelligence=1,willpower=0,constitution=4,wisdom=1,charisma=2"
--   <talentos>        = pares clave=valor separados por coma
--                       ej: "precision=1,agileCombat=2,stealth=0,..."
--   <isWorgenCurse>   = booleano como string: "true" o "false"
--   <rasgosPositivos> = pares clave=valor separados por coma (TODO)
--                       ej: "rasgo1=1,rasgo2=2,..."
--   <rasgosNegativos> = pares clave=valor separados por coma (TODO)
--                       ej: "rasgo1=1,rasgo2=2,..."
--
-- Ejemplo completo:
--   GAC:v1:human:void:5:normal:dexterity=3,strength=2,intelligence=1:precision=1,agileCombat=2:false:rasgoPos=1:rasgoNeg=1
-------------------------------------------------------------------------------

local function SafeCall(func, ...)
    if type(func) == "function" then
        local ok, err = pcall(func, ...)
        if not ok then
            print("|cffff0000[GAC Error]|r " .. tostring(err))
        end
        return ok
    end
    return false
end

--- Parsea un bloque de pares "clave=valor,clave=valor" hacia una tabla.
local function ParseKVPairs(str)
    local t = {}
    if not str or str == "" then return t end
    for pair in (str .. ","):gmatch("([^,]+),") do
        local k, v = pair:match("^([^=]+)=(.+)$")
        if k and v then
            t[k:match("^%s*(.-)%s*$")] = tonumber(v) or 0
        end
    end
    return t
end

--- Valida e importa un string de ficha exportada.
--- Devuelve true si el import fue exitoso, false + mensaje si no.
local function ImportFichaString(importStr)
    if not importStr or importStr == "" then
        return false, "El campo de importación está vacío."
    end

    -- Limpieza de espacios y saltos de línea
    importStr = importStr:match("^%s*(.-)%s*$")

    -- Verificar prefijo
    if not importStr:match("^GAC:v1:") then
        return false, "Formato no reconocido. La cadena debe comenzar con 'GAC:v1:'."
    end

    -- Separar los segmentos (índices 1-N tras eliminar el prefijo)
    -- Formato: GAC:v1:<raza1>:<raza2>:<nivel>:<categoría>:<atributos>:<talentos>:<isWorgenCurse>:<rasgosPositivos>:<rasgosNegativos>
    local segments = {}
    for seg in importStr:gmatch("[^:]+") do
        table.insert(segments, seg)
    end

    -- segments[1]="GAC", [2]="v1", [3]=raza1, [4]=raza2, [5]=nivel, [6]=categoria,
    --            [7]=atributos, [8]=talentos, [9]=isWorgenCurse, [10]=rasgosPositivos, [11]=rasgosNegativos
    if #segments < 7 then
        return false, "La cadena está incompleta. Faltan segmentos."
    end

    local race1          = segments[3]
    local race2          = segments[4]
    local nivel          = tonumber(segments[5])
    local categoria      = segments[6]
    local attrStr        = segments[7] or ""
    local talStr         = segments[8] or ""
    local worgenCurseStr = segments[9] or "false"
    local rasgPosStr     = segments[10] or ""
    local rasgNegStr     = segments[11] or ""

    -- Validaciones básicas
    if not nivel or nivel < 1 then
        return false, "Nivel inválido: '" .. tostring(segments[5]) .. "'. Debe ser un número entero >= 1."
    end

    local validCats = { noob = true, normal = true, elite = true, boss = true }
    if not validCats[categoria] then
        return false, "Categoría inválida: '" .. tostring(categoria) .. "'. Valores válidos: noob, normal, elite, boss."
    end

    -- Garantizar que characterData existe
    if not GAC.characterData then
        return false, "Los datos del personaje aún no han sido inicializados."
    end
    GAC.characterData.characteristics = GAC.characterData.characteristics or {}
    GAC.characterData.attributes = GAC.characterData.attributes or {}
    GAC.characterData.talents = GAC.characterData.talents or {}
    GAC.characterData.progress = GAC.characterData.progress or {}

    -- Importar raza
    GAC.characterData.characteristics.race1 = race1
    GAC.characterData.characteristics.race2 = race2

    -- Actualizar los datos raciales activos
    if race2 == "void" and race1 ~= "void" then
        local data = GAC:GetRaceData(race1)
        if data then
            GAC.characterData.characteristics.activeAdvantages = data.advantages
            GAC.characterData.characteristics.activeDisadvantages = data.disadvantages
            GAC.characterData.characteristics.activeSpecial = data.special
        end
    elseif race1 ~= "void" and race2 ~= "void" then
        local allAdv, allDis, allSpec = GAC.Utils.MainMenu:MergeRaceTraits(race1, race2)
        GAC.characterData.characteristics.activeAdvantages = allAdv
        GAC.characterData.characteristics.activeDisadvantages = allDis
        GAC.characterData.characteristics.activeSpecial = allSpec
    else
        GAC.characterData.characteristics.activeAdvantages = nil
        GAC.characterData.characteristics.activeDisadvantages = nil
        GAC.characterData.characteristics.activeSpecial = nil
    end

    -- Importar progresión
    GAC.characterData.progress.level = nivel
    GAC.characterData.progress.category = categoria

    -- Importar atributos
    local attrValues = ParseKVPairs(attrStr)
    for k, v in pairs(attrValues) do
        GAC.characterData.attributes[k] = v
    end

    -- Importar talentos
    local talValues = ParseKVPairs(talStr)
    for k, v in pairs(talValues) do
        GAC.characterData.talents[k] = v
    end

    -- Importar maldición Worgen
    GAC.characterData.isWorgenCurse = (worgenCurseStr == "true")

    -- Importar rasgos positivos
    -- TODO: Implementar lógica de importación de rasgos positivos
    local _rasgPosValues = ParseKVPairs(rasgPosStr)
    -- TODO: Aplicar _rasgPosValues a GAC.characterData

    -- Importar rasgos negativos
    -- TODO: Implementar lógica de importación de rasgos negativos
    local _rasgNegValues = ParseKVPairs(rasgNegStr)
    -- TODO: Aplicar _rasgNegValues a GAC.characterData

    -- Propagar cambios si la API lo permite
    SafeCall(function()
        if GAC.SetExperienceCategory then GAC:SetExperienceCategory(categoria) end
        if GAC.SetExperienceLevel then GAC:SetExperienceLevel(nivel) end
        if GAC.UpdateGameExpBar then GAC:UpdateGameExpBar() end
    end)

    -- Refrescar la UI si el frame del MainMenu está disponible
    SafeCall(function()
        local screen = GAC.Screens and GAC.Screens.MainMenu
        if screen and screen.frame and screen.frame.Update then
            screen.frame:Update()
        end
    end)

    return true, string.format(
        "Ficha importada correctamente.\nRaza: %s / %s | Nivel: %d | Categoría: %s",
        race1, race2, nivel, categoria
    )
end

-------------------------------------------------------------------------------
-- Creación del cuadro de diálogo de importación
-------------------------------------------------------------------------------

function GAC.Components.MainMenu:OpenImportDialog()
    -- Si ya existe el diálogo, solo mostrarlo
    if GAC._importDialog then
        GAC._importDialog:Show()
        GAC._importDialog.editBox:SetText("")
        GAC._importDialog.editBox:SetFocus()
        return
    end

    local consts = GAC.Stores.MainMenu.Constants

    -- Marco principal del diálogo
    local dialog = CreateFrame("Frame", "GAC_ImportDialog", UIParent, "BackdropTemplate")
    dialog:SetSize(480, 260)
    dialog:SetPoint("CENTER", UIParent, "CENTER", 0, 40)
    dialog:SetFrameStrata("DIALOG")
    dialog:SetMovable(true)
    dialog:EnableMouse(true)
    dialog:RegisterForDrag("LeftButton")
    dialog:SetScript("OnDragStart", dialog.StartMoving)
    dialog:SetScript("OnDragStop", dialog.StopMovingOrSizing)
    dialog:SetClampedToScreen(true)

    dialog:SetBackdrop({
        bgFile   = consts.BACKDROP_BG,
        edgeFile = consts.BACKDROP_EDGE,
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    dialog:SetBackdropColor(consts.BG_COLOR.r, consts.BG_COLOR.g, consts.BG_COLOR.b, 0.97)
    dialog:SetBackdropBorderColor(consts.BORDER_COLOR.r, consts.BORDER_COLOR.g, consts.BORDER_COLOR.b, consts.BORDER_COLOR.a)

    -- Título
    local titleText = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    titleText:SetPoint("TOPLEFT", 18, -16)
    titleText:SetText("Importar Ficha")
    titleText:SetTextColor(consts.TITLE_COLOR.r, consts.TITLE_COLOR.g, consts.TITLE_COLOR.b, 1)

    -- Botón cerrar
    local closeBtn = CreateFrame("Button", nil, dialog, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -4, -4)

    -- Línea divisoria
    local line = dialog:CreateTexture(nil, "ARTWORK")
    line:SetHeight(1)
    line:SetPoint("TOPLEFT", 12, -42)
    line:SetPoint("TOPRIGHT", -12, -42)
    line:SetColorTexture(consts.LINE_COLOR.r, consts.LINE_COLOR.g, consts.LINE_COLOR.b, consts.LINE_COLOR.a)

    -- Instrucción
    local instrText = dialog:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    instrText:SetPoint("TOPLEFT", 18, -52)
    instrText:SetPoint("TOPRIGHT", -18, -52)
    instrText:SetJustifyH("LEFT")
    instrText:SetWordWrap(true)
    instrText:SetText("Pega aquí la cadena de importación de la ficha:")
    instrText:SetTextColor(0.8, 0.8, 0.8, 1)

    -- Scroll frame para el EditBox (permite textos largos)
    local scrollFrame = CreateFrame("ScrollFrame", nil, dialog, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 18, -75)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 60)

    local editBox = CreateFrame("EditBox", nil, scrollFrame)
    editBox:SetMultiLine(true)
    editBox:SetAutoFocus(false)
    editBox:SetFontObject("ChatFontNormal")
    editBox:SetWidth(scrollFrame:GetWidth())
    editBox:SetScript("OnEscapePressed", function(s) s:ClearFocus() end)
    editBox:SetScript("OnTextChanged", function(s)
        scrollFrame:UpdateScrollChildRect()
    end)
    scrollFrame:SetScrollChild(editBox)

    -- Fondo del editBox
    local editBg = CreateFrame("Frame", nil, dialog, "BackdropTemplate")
    editBg:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", -4, 4)
    editBg:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", 4, -4)
    editBg:SetBackdrop({
        bgFile = consts.BACKDROP_BG,
        edgeFile = consts.BACKDROP_EDGE,
        tile = true, tileSize = 8, edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    editBg:SetBackdropColor(0, 0, 0, 0.6)
    editBg:SetBackdropBorderColor(consts.BORDER_COLOR.r, consts.BORDER_COLOR.g, consts.BORDER_COLOR.b, 0.3)
    editBg:SetFrameLevel(dialog:GetFrameLevel())
    scrollFrame:SetFrameLevel(editBg:GetFrameLevel() + 1)
    editBox:SetFrameLevel(scrollFrame:GetFrameLevel() + 1)

    -- Botón Cancelar
    local cancelBtn = CreateFrame("Button", nil, dialog, "UIPanelButtonTemplate")
    cancelBtn:SetSize(110, 26)
    cancelBtn:SetPoint("BOTTOMRIGHT", -18, 18)
    cancelBtn:SetText("Cancelar")
    cancelBtn:SetScript("OnClick", function()
        dialog:Hide()
        editBox:SetText("")
    end)

    -- Botón Aceptar
    local acceptBtn = CreateFrame("Button", nil, dialog, "UIPanelButtonTemplate")
    acceptBtn:SetSize(110, 26)
    acceptBtn:SetPoint("RIGHT", cancelBtn, "LEFT", -8, 0)
    acceptBtn:SetText("Aceptar")
    acceptBtn:SetScript("OnClick", function()
        local str = editBox:GetText()
        local ok, msg = ImportFichaString(str)
        if ok then
            print("|cFF40C7EB[GAC]|r: " .. msg)
            dialog:Hide()
            editBox:SetText("")
        else
            print("|cffff6666[GAC - Error de Importación]|r: " .. msg)
        end
    end)

    dialog.editBox = editBox
    GAC._importDialog = dialog

    dialog:Show()
    editBox:SetFocus()
end
