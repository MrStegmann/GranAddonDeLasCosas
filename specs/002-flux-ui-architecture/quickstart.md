# Quickstart & Verification Guide: Flux UI Architecture & SOLID Refactoring

## Setup Instructions

1. Verify `src/Core/Core.xml` is added to `src/GAC.xml` manifest prior to UI frame manifest includes.
2. Verify `GAC.Dispatcher` and `GAC.Store` are initialized during `ADDON_LOADED`.

## Validation Scenarios

### Scenario 1: Action Dispatching & Store Update
- **Action**: Run `/run GAC.Dispatcher:Dispatch(GAC.Actions.UPDATE_PROGRESS, { category = "elite", level = 10 })` in chat console.
- **Expected Outcome**: `GAC.Store` state updates category to "elite" and level to 10; `GranAddonDeLasCosasCharDB.progress` reflects the changes.

### Scenario 2: UI Button Dispatching (CharSheetContent & ExperienceConfigurator)
- **Action**: Open main menu (`/gac`), navigate to Character Sheet or XP Configurator, change level/experience, and click Save/Apply.
- **Expected Outcome**: Button handler dispatches action to store without mutating `characterData` inline; UI labels instantly update.

### Scenario 3: Reactive View Subscription
- **Action**: Open quick action menu and click `+1` / `-1` Health buttons.
- **Expected Outcome**: Health plate and character summary reactively re-render to reflect new health values without requiring UI reopening.
