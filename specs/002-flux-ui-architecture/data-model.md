# Phase 1 Data Model: Flux UI Architecture & SOLID Refactoring

## Entity 1: Actions Catalog (`GAC.Actions`)

Enumeration table defining all valid intent action types.

### Actions
- `UPDATE_PROGRESS`: `{ category = string, level = number }`
- `ADD_EXPERIENCE`: `{ expAmount = number }`
- `MODIFY_HEALTH`: `{ delta = number }`
- `MODIFY_SHIELD`: `{ delta = number }`
- `UPDATE_STORY`: `{ text = string }`

---

## Entity 2: Flux Dispatcher (`GAC.Dispatcher`)

Central action router handling action dispatches and store handler invocation.

### Methods
- `Register(actionType, handler)`: Binds a reducer handler to a specific action type.
- `Dispatch(actionType, payload)`: Validates action type and invokes registered store handlers within `GAC:SafeCall`.

---

## Entity 3: Flux Store (`GAC.Store`)

Single source of truth encapsulating persistent character data and notifying UI subscribers.

### Attributes
- `state`: Internal state snapshot synced with `GranAddonDeLasCosasCharDB`.
- `subscribers`: List of registered view render callbacks.

### Methods
- `GetState()`: Returns immutable copy or reference to active state snapshot.
- `Subscribe(callback)`: Registers a view render function to receive state change notifications.
- `NotifySubscribers()`: Iterates subscribers and invokes callbacks wrapped in `GAC:SafeCall`.
