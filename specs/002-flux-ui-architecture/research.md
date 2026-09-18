# Phase 0 Research: Flux UI Architecture & SOLID Refactoring

## Research Topic 1: Flux Dispatcher & Store Pattern in WoW Lua

### Decision
Implement a lightweight, zero-dependency Flux Dispatcher (`GAC.Dispatcher`) and single Store (`GAC.Store`) tailored for World of Warcraft's single-threaded Lua environment.

### Rationale
In WoW client Lua, external state libraries add overhead and global pollution. A clean table-based Dispatcher registering listener functions by Action type ensures zero external library overhead while guaranteeing strict unidirectional flow:
1. View triggers UI event → dispatches `GAC.Actions.UPDATE_PROGRESS` with payload.
2. `GAC.Dispatcher` catches action, passes to `GAC.Store` reducer handler.
3. `GAC.Store` mutates state, saves to `GranAddonDeLasCosasCharDB`, and broadcasts change notifications.
4. Subscribed views execute `render()` functions reactively.

All subscriber calls are wrapped in `GAC:SafeCall` to ensure one faulty UI callback cannot interrupt state updates or crash other UI views.

### Alternatives Considered
- **Direct Rx/Observable Libraries**: Rejected due to unnecessary allocation overhead and complexity in WoW Lua environment.
- **Global EventBus (`RegisterEvent`)**: Rejected because Blizzard's frame event system is optimized for C-engine events, whereas a dedicated Flux Store provides synchronous state snapshots and fine-grained UI view subscriptions.

---

## Research Topic 2: Refactoring UI Handlers for SOLID Compliance

### Decision
Extract inline business rules and saved variable assignments out of `CharSheetContent.lua`, `ExperienceConfigurator.lua`, and `QuickButtonsMenu/index.lua` into Action payload dispatchers and Store reducer handlers.

### Rationale
Currently, UI button click handlers directly modify `GAC.characterData.progress` and calculate level health scaling inside frame scripts. This violates Single Responsibility (SRP) and Dependency Inversion (DIP). Disprinting actions decouples UI components from persistence logic and allows presentation frames to be reused or tested independently.
