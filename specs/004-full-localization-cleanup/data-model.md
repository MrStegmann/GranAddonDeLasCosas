# Data Model & Interface Contracts: Full Localization & Code Cleanup

## 1. Locales Table Schema (`src/Locales/ES_es.lua`)

```lua
local _, GAC = ...

GAC.Locales = GAC.Locales or {}

-- Core / Common
GAC.Locales["ACCEPT"] = "Aceptar"
GAC.Locales["CANCEL"] = "Cancelar"
GAC.Locales["SAVE"] = "Guardar"

-- CharSheetContent
GAC.Locales["CHAR_SHEET_TITLE"] = "Ficha de Personaje"
GAC.Locales["CHAR_SHEET_BACKGROUND_HINT"] = "Escribe aquí el trasfondo de tu personaje..."
GAC.Locales["CHAR_SHEET_SAVE_STORY"] = "Guardar Historia"
GAC.Locales["CHAR_SHEET_SAVE_PROGRESSION"] = "Guardar Progresión"
GAC.Locales["CHAR_SHEET_PROG_TITLE"] = "Información de Nivel Disponible"
GAC.Locales["CHAR_SHEET_MAX_HP"] = "Salud Máxima"
GAC.Locales["CHAR_SHEET_EXP_TO_LEVEL"] = "Exp para Nivel"
GAC.Locales["CHAR_SHEET_ATT_POINTS"] = "Puntos de Atributo"
GAC.Locales["CHAR_SHEET_SKILL_SLOTS"] = "Ranuras de hechizos/habilidades"
GAC.Locales["CHAR_SHEET_HEROIC_POINTS"] = "Puntos Heroicos"
GAC.Locales["CHAR_SHEET_POSITIVE_TRAITS"] = "Rasgos Positivos"

-- ExperienceConfigurator
GAC.Locales["EXP_TITLE"] = "Experiencia"
GAC.Locales["EXP_CURRENT_LEVEL_FMT"] = "Nivel Actual: %d (%s)"
GAC.Locales["EXP_RECEIVED"] = "Experiencia recibida:"
GAC.Locales["EXP_MAX_LEVEL"] = "Nivel Máximo Alcanzado"
GAC.Locales["EXP_GAINED_MSG_FMT"] = "Has recibido %d puntos de experiencia."

-- InventoryContent
GAC.Locales["INV_INVALID_COMB"] = "* Comb. Inválidas:\n"
GAC.Locales["INV_REQ_NOT_MET"] = "* No cumples con los requisitos *"

-- QuickButtonsMenu
GAC.Locales["QB_MODIFY_LIFE_TITLE"] = "Modificar Vida (Ej: 5 o -5)"
GAC.Locales["QB_MODIFY_SHIELD_TITLE"] = "Modificar Escudo (Ej: 5 o -5)"
```

## 2. Localization Resolver Interface (`GAC:_`)

```lua
function GAC:_(key)
    if not key then return "" end
    if self.Locales and self.Locales[key] then
        return self.Locales[key]
    end
    return key
end
```
