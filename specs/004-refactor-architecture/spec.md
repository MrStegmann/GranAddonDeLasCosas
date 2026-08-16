# Feature: Architecture Refactor to MVC

## 1. Context & Motivation
The current `src/main/` architecture is structured around Hexagonal Architecture (`domain`, `adapters`, `ports`) and there is an external `src/Data` directory containing static databases. 
However, the project's global design rules (`DESIGN.md` and `.agents/rules/001-mvc-architecture.md`) strictly enforce an **MVC Pattern** (Models, API, Controllers). We need to refactor the entire `src/` directory to adhere to this established rule pattern and migrate the static data into the proper Model layer.

## 2. Requirements
- **FR-1**: Migrate `src/Data` (static data tables) into `src/main/Models/Data`.
- **FR-2**: Migrate `src/main/domain/` into `src/main/Models/`.
- **FR-3**: Migrate `src/main/adapters/` (network, events, cache) into `src/main/Controllers/` and `src/main/Models/` as appropriate.
- **FR-4**: Migrate `src/main/ports/` (interfaces/DTOs) into `src/main/API/`.
- **NFR-1**: Ensure zero global state leaks.
- **NFR-2**: Maintain load order correctness in the XML manifests (`main.xml`, `Models.xml`, etc.).

## 3. Interface & Contract Changes
- The root structure of `src/main/` will change from `adapters`, `domain`, `ports` to `Models`, `API`, `Controllers`.
- XML manifests must be updated to reflect the new paths.
- File requires and internal API paths may need updates to reflect the new module locations.

## 4. Edge Cases & Failure Modes
- **Manifest Loading Failures:** If XML load order is incorrect, the addon will fail to initialize. We must strictly load Models -> API -> Controllers.
- **Data Loss:** `SavedVariables` could be corrupted if Model initialization sequences are altered. We must ensure schema initialization remains identical.

## 5. Acceptance Criteria
- [ ] `src/main/` exclusively contains `Models`, `API`, and `Controllers` folders (no adapters/domain/ports).
- [ ] `src/Data/` no longer exists in the root; its contents live inside `src/main/Models/Data/`.
- [ ] The addon loads successfully without Lua script errors.
- [ ] The XML manifests are properly cascaded and ordered.
