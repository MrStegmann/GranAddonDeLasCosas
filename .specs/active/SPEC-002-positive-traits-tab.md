# SPEC-002: Character Sheet Positive Traits Selection Tab & Target Tooltip Integration

- **Status:** COMPLETED
- **Author:** GEMINI Code Agent
- **Created Date:** 2026-07-28
- **Target Feature Path:** `src/Frames/MainMenu/Components/CharSheet/`

---

## 1. Executive Summary & Problem Statement
Currently, character positive traits are defined in data tables (`src/Data/PositiveTraits.lua`), but players have no UI interface in the Character Sheet (`CharSheetScreen`) to view, select, or upgrade positive traits using their earned positive trait points (`maxPositiveTraits`). Furthermore, selected traits are not displayed in the Target Tooltip when inspecting or targeting another player character.

This feature adds a new **"Rasgos"** sub-tab to the Character Sheet main menu, provides an interactive UI for spending trait points on level 1–3 positive traits within character budget constraints, strictly enforces layout boundaries so content does not overflow `tabContent` or `GACMainMenuFrame`, and updates the target tooltip to display active traits.

---

## 2. Functional Requirements
- [ ] **FR-1:** Add a 4th sub-tab button named **"Rasgos"** in `CharSheetScreen.lua` alongside "Características", "Progresión", and "Atributos y Talentos".
- [ ] **FR-2:** Create `src/Frames/MainMenu/Components/CharSheet/TraitsTab.lua` using `CreateScrollableTab` to guarantee scrollable containment without overflowing main menu bounds.
- [ ] **FR-3:** Display active point budget header: `"Puntos de Rasgos: [Gastados] / [Máximos]"`, where Máximos is fetched from `GAC:GetLevelEntry(category, level).maxPositiveTraits`.
- [ ] **FR-4:** Render all positive traits from `GAC.PositiveTraits` using modular trait card components ([TraitCardComponent.lua](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/src/Frames/MainMenu/Components/CharSheet/components/TraitCardComponent.lua)).
- [ ] **FR-5:** Allow selecting level 1, level 2, or level 3 for each trait. Selecting level $L$ consumes $L$ positive trait points. Disable selection buttons if remaining points are less than level cost.
- [ ] **FR-6:** Persist selected positive traits into `playerCharacter:SetPositiveTraits(traitsTable)` and serialize to `GAC_CharacterDB` via `PersistenceEvents.lua`.
- [ ] **FR-7:** Update `GAC:ShowTargetTooltip` in `src/Frames/InspectionMenu/Hooks/TargetTooltip.lua` to render an active **"Rasgos Positivos:"** section listing trait labels and levels.

---

## 3. Technical Architecture & File Plan

### New Files
- `src/Frames/MainMenu/Components/CharSheet/components/TraitCardComponent.lua` (Component for rendering an individual trait card with level selectors, < 300 lines)
- `src/Frames/MainMenu/Components/CharSheet/TraitsTab.lua` (Main orchestrator tab for positive traits, < 400 lines)

### Modified Files
- `src/Frames/MainMenu/Screens/CharSheetScreen.lua` (Add "Rasgos" sub-tab button & `tab4` container)
- `src/Frames/MainMenu/Components/Components.xml` (Register `TraitCardComponent.lua` and `TraitsTab.lua`)
- `src/Models/Character.lua` (Ensure `GetPositiveTraits()` and `SetPositiveTraits()` getters/setters operate cleanly)
- `src/Frames/InspectionMenu/Hooks/TargetTooltip.lua` (Add rendering logic for `positiveTraits`)

---

## 4. API & Data Flow Contracts

### Data Schema (`playerCharacter._data.positiveTraits`)
Positive traits are stored as a map of trait names to chosen levels:
```lua
-- Example structure stored in character state:
positiveTraits = {
    bully = 1,      -- Abusón Level 1 (costs 1 point)
    athletic = 2    -- Atlético Level 2 (costs 2 points)
}
```

### Point Budget Calculation
```lua
--- Calculates total spent positive trait points.
-- @param positiveTraits table Table of { traitName = level }
-- @return number Total points spent
function GAC:GetSpentTraitPoints(positiveTraits)
    local spent = 0
    if type(positiveTraits) == "table" then
        for _, lvl in pairs(positiveTraits) do
            spent = spent + (tonumber(lvl) or 0)
        end
    end
    return spent
end
```

### Target Tooltip Integration (`TargetTooltip.lua`)
```lua
--- Extended ShowTargetTooltip signature
-- @param anchorFrame Frame Anchor parent
-- @param attributes table
-- @param talents table
-- @param advantages table
-- @param disadvantages table
-- @param special table
-- @param positiveTraits table
function GAC:ShowTargetTooltip(anchorFrame, attributes, talents, advantages, disadvantages, special, positiveTraits)
    -- Renders "Rasgos Positivos:" section when positiveTraits table contains entries
end
```

---

## 5. Non-Functional & Security Constraints
- **File Limit:** Strict 500-line ceiling per file.
- **Scroll Containment:** All trait elements must be anchored inside `GAC.Components.MainMenu:CreateScrollableTab` with dynamic height calculation to ensure zero overflow beyond `tabContent` boundaries.
- **LDoc Standard:** `@module`, `@param`, `@return` annotations required on all exported functions.
- **Naming Standard:** `camelCase` for variables/functions; `PascalCase` for XML/Frames/Models.

---

## 6. Implementation Checklist
- [ ] **Step 1:** Create `src/Frames/MainMenu/Components/CharSheet/components/TraitCardComponent.lua` for trait card layout and level selection buttons.
- [ ] **Step 2:** Create `src/Frames/MainMenu/Components/CharSheet/TraitsTab.lua` with scrollable tab container and point counter.
- [ ] **Step 3:** Modify `src/Frames/MainMenu/Screens/CharSheetScreen.lua` to add 4th sub-tab button ("Rasgos") and wire up tab switching.
- [ ] **Step 4:** Update `src/Frames/MainMenu/Components/Components.xml` manifest load order.
- [ ] **Step 5:** Modify `src/Frames/InspectionMenu/Hooks/TargetTooltip.lua` to display positive traits in target tooltip.
- [ ] **Step 6:** Update `DevNotes.md` under `### Características Nuevas`.
