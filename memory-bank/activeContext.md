# Active Context & Current Focus

## Current Phase: Feature 002 — TRP3 Bridges (Completed)

## Recent Architectural Deliverables
1. **TRP3 Ports Bridge Implementation (`src/main/ports/TR3Bridge/`):**
   - Created `characteristics.lua` with `getFullName()` and `getClass()` port functions.
   - Created `inventory.lua` with `getEquipedItems()` (returning `ItemsResponse` structure) and `updateItem()` port functions.
   - Registered scripts in `src/main/ports/TR3Bridge/TR3Bridge.xml` and wired sub-manifest in `src/main/ports/ports.xml`.
2. **Character Sheet Domain Models Transpilation (`src/main/domain/models/`):**
   - Implemented pure Lua 5.1 domain entities: `Armor.lua`, `Weapon.lua`, `Shield.lua`, and `Character.lua`.
   - Created schema factories (`Model.create(raw_data)`) and default initializer (`Character.createDefault()`).
   - Registered model scripts in `models.xml`.

## Active Architectural Principles
* **Hexagonal Domain Purity:** Logic in `src/main/domain/` operates exclusively in pure Lua 5.1 with zero WoW client API references.
* **Micro-Frontend UI Isolation:** UI views communicate exclusively over `LocalIPCAdapter` using feature-scoped client APIs.
* **Cascading XML Load Order:** All files are declared in bottom-up cascading XML manifests (`[folder].xml`).
