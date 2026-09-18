# Feature Specification: Full Localization & Code Cleanup

**Feature Branch**: `004-full-localization-cleanup`

**Created**: 2026-09-18

**Status**: Draft

**Input**: User description: "The Full Localization and Code Cleanup phase transitions the user interface toward a maintainable, localized architecture starting with Spanish support. This workflow is divided into two sequential objectives. First, Task 4.1 consolidates all static user interface text scattered across `CharSheetContent.lua`, `ExperienceConfigurator.lua`, `InventoryContent.lua`, and `QuickButtonsMenu/index.lua` by migrating them into the central Spanish locale file at `src/Locales/ES_es.lua`. Second, Task 4.2 refactors the script logic in those same modules to replace raw string literals with dynamic translation lookups via `GAC:_("KEY")`. Completing these items eliminates hardcoded presentation text across these four primary views and standardizes string resolution moving forward."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Centralized Spanish Locales Dictionary (Priority: P1)

As a developer maintaining the GAC addon, I want all user interface labels, tooltip descriptions, menu button titles, and notification strings centralized in `src/Locales/ES_es.lua` so that all user-facing text is managed in a single, organized localization table.

**Why this priority**: Centralizing localization keys satisfies Constitution Principle VI (Localization & Naming) and enables effortless multi-language support in the future.

**Independent Test**: Inspect `src/Locales/ES_es.lua` and verify all string keys for `CharSheetContent`, `ExperienceConfigurator`, `InventoryContent`, and `QuickButtonsMenu` are present and mapped to clean Spanish translation values.

**Acceptance Scenarios**:

1. **Given** hardcoded UI text in `CharSheetContent.lua`, `ExperienceConfigurator.lua`, `InventoryContent.lua`, and `QuickButtonsMenu/index.lua`, **When** auditing localization tables, **Then** all static strings have corresponding unique keys registered in `src/Locales/ES_es.lua`.
2. **Given** any locale key query via `GAC:_("KEY")`, **When** the locale file is loaded, **Then** `GAC:_("KEY")` returns the matching localized text or fallback string without errors.

---

### User Story 2 - UI Screen String Decoupling (Priority: P1)

As a World of Warcraft player using the GAC addon in Spanish, I want all UI screens (`CharSheetContent`, `ExperienceConfigurator`, `InventoryContent`, and `QuickButtonsMenu`) to resolve labels and descriptions dynamically through `GAC:_("KEY")` so that no hardcoded English/Spanish text literals exist in UI view scripts.

**Why this priority**: Decouples UI presentation views from hardcoded strings, ensuring code cleanliness and adherence to project governance.

**Independent Test**: Render `CharSheetContent`, `ExperienceConfigurator`, `InventoryContent`, and `QuickButtonsMenu` frames in-game and verify all titles, button texts, inputs, and tooltips render correctly via `GAC:_("KEY")`.

**Acceptance Scenarios**:

1. **Given** `CharSheetContent.lua` tab headers, titles, section labels, and buttons, **When** rendered, **Then** all text components derive string values from `GAC:_("KEY")`.
2. **Given** `ExperienceConfigurator.lua` headers, level indicators, and XP bar labels, **When** rendered, **Then** all text components derive string values from `GAC:_("KEY")`.
3. **Given** `InventoryContent.lua` headers, slot titles, requirement warnings, and action buttons, **When** rendered, **Then** all text components derive string values from `GAC:_("KEY")`.
4. **Given** `QuickButtonsMenu/index.lua` button titles, popups, tooltips, and action labels, **When** rendered, **Then** all text components derive string values from `GAC:_("KEY")`.

---

### Edge Cases

- What happens if a key is missing from `src/Locales/ES_es.lua`? `GAC:_("KEY")` falls back to returning the key name cleanly without throwing runtime Lua errors.
- How are dynamic string formats handled? Use `string.format(GAC:_("KEY_PATTERN"), ...)` for localized format strings containing numbers or player names.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST extract all hardcoded UI strings from `CharSheetContent.lua`, `ExperienceConfigurator.lua`, `InventoryContent.lua`, and `QuickButtonsMenu/index.lua` into `src/Locales/ES_es.lua`.
- **FR-002**: System MUST refactor UI label, header, button, popup, and tooltip creations in `CharSheetContent.lua` to use `GAC:_("KEY")`.
- **FR-003**: System MUST refactor UI label, header, input, and bar text creations in `ExperienceConfigurator.lua` to use `GAC:_("KEY")`.
- **FR-004**: System MUST refactor UI label, header, warning message, and button creations in `InventoryContent.lua` to use `GAC:_("KEY")`.
- **FR-005**: System MUST refactor button tooltips, popups, and labels in `QuickButtonsMenu/index.lua` to use `GAC:_("KEY")`.
- **FR-006**: System MUST support format string parameters in localized messages via `string.format(GAC:_("KEY"), ...)`.

### Key Entities *(include if feature involves data)*

- **Locales Table (`GAC.Locales`)**: Dictionary mapping camelCase / UPPERCASE string keys to translated string values.
- **Translation Method (`GAC:_`)**: Localization helper function resolving string keys against `GAC.Locales` with graceful key fallback.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Zero raw hardcoded UI string literals remain in `CharSheetContent.lua`, `ExperienceConfigurator.lua`, `InventoryContent.lua`, and `QuickButtonsMenu/index.lua`.
- **SC-002**: 100% of UI labels, buttons, tooltips, and popups across the 4 primary views render localized text via `GAC:_("KEY")`.

## Assumptions

- `src/Locales/ES_es.lua` is loaded prior to UI screen module manifests.
- Spanish (`ES_es`) is the primary active language for `GAC_DEV`.
