# Feature Specification: Flux UI Architecture & SOLID Refactoring

**Feature Branch**: `002-flux-ui-architecture`

**Created**: 2026-09-18

**Status**: Draft

**Input**: User description: "Feature: Flux UI Architecture & SOLID Refactoring - Transitions the UI architecture toward a reactive Flux pattern aligned with SOLID principles via core Dispatcher, Store, Action dispatches, and reactive view subscriptions."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Core Flux Infrastructure (Priority: P1)

As an add-on developer, I want a centralized `Dispatcher` and `Store` state management system in `src/Core/` so that application state transitions are unidirectional, predictable, and decoupled from UI frame script logic.

**Why this priority**: Core state management infrastructure is the mandatory prerequisite for refactoring any UI views to reactive action dispatching.

**Independent Test**: Can be tested independently by calling `GAC.Dispatcher:Dispatch(GAC.Actions.SET_CHARACTER_PROGRESS, { category = "elite", level = 5 })` and verifying the `GAC.Store` updates state and notifies subscriber callbacks.

**Acceptance Scenarios**:

1. **Given** `src/Core/Dispatcher.lua` and `src/Core/Store.lua`, **When** an action is dispatched via `GAC.Dispatcher:Dispatch(actionType, payload)`, **Then** the registered store handler executes the state update and broadcasts change notifications to all subscribers.
2. **Given** a subscriber callback registered via `GAC.Store:Subscribe(callback)`, **When** store state changes, **Then** the callback is invoked with the updated state snapshot.

---

### User Story 2 - Action Dispatching from UI Screens (Priority: P1)

As a player interacting with character sheet, experience configurator, or quick action frames, I want UI interactions (such as saving progression, changing levels, or modifying health) to dispatch discrete actions rather than mutating saved variables directly, ensuring UI handlers follow Single Responsibility and Dependency Inversion principles.

**Why this priority**: Eliminates direct inline mutations of `GranAddonDeLasCosasCharDB` from OnClick script handlers, isolating UI handlers to presentation behavior.

**Independent Test**: Trigger "Save Progression" on `CharSheetContent.lua` or "Set XP" on `ExperienceConfigurator.lua` and verify an action is dispatched to the store rather than mutating `GAC.characterData` inline inside the button script.

**Acceptance Scenarios**:

1. **Given** `CharSheetContent.lua`, **When** the player clicks "Guardar Progresión", **Then** the button handler dispatches `GAC.Actions.UPDATE_PROGRESS` with `{ category, level }` payload.
2. **Given** `ExperienceConfigurator.lua`, **When** the player inputs received experience, **Then** the handler dispatches `GAC.Actions.ADD_EXPERIENCE` with `{ expAmount }` payload.
3. **Given** `QuickButtonsMenu/index.lua`, **When** quick buttons adjust health or shield, **Then** handlers dispatch `GAC.Actions.MODIFY_HEALTH` / `GAC.Actions.MODIFY_SHIELD`.

---

### User Story 3 - Reactive View Re-Rendering (Priority: P1)

As a player, I want UI frames (such as character sheet summary, XP bar, health plates, and quick buttons) to automatically re-render when store state changes, so that UI elements are always in sync with the underlying state.

**Why this priority**: Completes the unidirectional Flux loop (`Action` → `Dispatcher` → `Store` → `View`), allowing UI components to remain stateless and purely reactive.

**Independent Test**: Modify store state via action dispatch and verify character sheet text displays, level labels, and XP bars instantly re-render without requiring manual UI open/close toggles.

**Acceptance Scenarios**:

1. **Given** UI screens (`CharSheetContent`, `ExperienceConfigurator`, `PlayerPlate`), **When** store state updates, **Then** subscribed render functions receive state changes and update frame text and progress bars reactively.

---

### Edge Cases

- What happens if an invalid action type is dispatched? `GAC.Dispatcher:Dispatch` MUST validate action types and log error messages via `GAC:SafeCall` without crashing the client.
- What happens if a view subscriber throws an error during re-rendering? Store subscription loop MUST wrap subscriber invocations in `GAC:SafeCall` so one broken frame callback does not block other UI views from updating.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide `src/Core/Dispatcher.lua` supporting action registration, dispatching, and error-wrapped execution (`GAC:SafeCall`).
- **FR-002**: System MUST provide `src/Core/Store.lua` maintaining application state, processing action updates, and notifying subscribed listeners.
- **FR-003**: UI handlers in `CharSheetContent.lua`, `ExperienceConfigurator.lua`, and `QuickButtonsMenu/index.lua` MUST NOT mutate persistent saved variables (`GranAddonDeLasCosasCharDB`) directly.
- **FR-004**: UI handlers MUST dispatch explicit actions (`GAC.Actions.*`) to request state changes.
- **FR-005**: UI presentation components MUST subscribe to `GAC.Store` updates and re-render views reactively upon state change notifications.
- **FR-006**: Core modules `src/Core/Dispatcher.lua` and `src/Core/Store.lua` MUST be declared in `src/GAC.xml` manifest in valid load order.

### Key Entities

- **Flux Dispatcher (`GAC.Dispatcher`)**: Central hub receiving actions and broadcasting payload objects to registered store reducers/handlers.
- **Flux Store (`GAC.Store`)**: Single source of truth containing application state (`progress`, `attributes`, `health`, `shield`, `ui`), broadcasting state change events to UI subscribers.
- **Actions Catalog (`GAC.Actions`)**: Enumeration of valid state mutation intent types (`UPDATE_PROGRESS`, `ADD_EXPERIENCE`, `MODIFY_HEALTH`, `MODIFY_SHIELD`, `UPDATE_STORY`).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of UI OnClick/OnValueChange handlers in target screens (`CharSheetContent`, `ExperienceConfigurator`, `QuickButtonsMenu`) dispatch actions instead of executing direct table mutations.
- **SC-002**: Store state updates trigger subscriber view updates within 16ms (single frame render budget).
- **SC-003**: All store and dispatcher operations are wrapped in `GAC:SafeCall`, preventing Lua errors from breaking UI rendering loops.

## Assumptions

- Core infrastructure setup from feature `001-critical-infrastructure-setup` (`_G.GAC` binding and XML manifest tags) is complete.
- Target client environment is World of Warcraft Retail / Epsilon WoW (`Interface: 90207`).
- Character data structures in `GranAddonDeLasCosasCharDB` persist across sessions.
