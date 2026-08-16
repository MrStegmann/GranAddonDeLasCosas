# GAC Constitution (Code Quality & Performance)

## Core Principles

### I. Pure Lua over WoW API Where Possible
The core business logic and domain models must strictly rely on pure Lua 5.1 constructs. Avoid calls to Blizzard UI APIs (`CreateFrame`, `RegisterEvent`, etc.) outside of the designated Controller and UI layers. This ensures our logic is lightweight, easily testable, and less prone to engine-specific bugs.

### II. Strict MVC Architecture
Adhere rigorously to the MVC (Model-View-Controller) architectural pattern:
- **Models** own the data and validation. They do not know about the UI or external events.
- **Views (API layer)** expose clean interfaces (DTOs) and dispatch events. Zero UI frames are defined here.
- **Controllers** act as the bridge, listening to WoW events and updating Models or triggering Views.

### III. Micro-Frontend Isolation
All UI elements are isolated features. A feature frame must never access the state or elements of another feature frame. State and events must be synchronized through the backend (`src/main/`) to guarantee decoupling and high maintainability.

### IV. Defensive Data Handling & Taint Protection
Never leak mutable internal state to the public API layer. Always return deep-copies or read-only proxy tables to prevent external addons from corrupting our `SavedVariables`. Fail fast with `assert` when validating API inputs.

### V. Performance First
Since GAC manages real-time P2P syncing (like Health/Shields and dice rolls):
- Use object pooling for dynamically generated frames (e.g., list rows).
- Throttle high-frequency events (`UNIT_HEALTH`, `OnUpdate`) intelligently.
- Avoid unnecessary garbage collection overhead by reusing tables instead of creating new ones inside hot loops.
