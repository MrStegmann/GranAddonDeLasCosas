# Feature Specification: Architectural Realignment & Hexagonal Infrastructure

**Feature Branch**: `001-architectural-realignment-hexagonal-infrastructure`

**Created**: 01/08/2026

**Status**: DONE

**Input**: `sprint.md`

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Cascading Directory & Manifest Scaffolding (Priority: P1)

As a developer, I need the application to load through a structured, cascading manifest system so that backend modules and UI components initialize in a strict, predictable order without dependency failures.

**Why this priority**: This is critical blocker (P1) because the enteri architecture depends on it. If cascading manifests do not load correctly at startup, no downstream domain modules or UI elements can be found or executed by the system.

**Independent Test**: Can be tested by loading the root entry manifest in isolation and verifying that all sub-manifest dependencies load in bottom-up sequence without raising missing-file or out-of-order runtime errors.

**Acceptance Scenarios**:

1. **Given** a fresh system initialization sequence, **When** the root manifest is executed, **Then** all underlying sub-manifest (domain, ports, adapters, and UI) load in strict bottom-up dependency order.
2. **Given** a child manifest with script dependencies, **When** the file tree is evaluated, **Then** dependency scripts are processed before dependent scripts to prevent missing reference errors.

---

### User Story 2 - Primary Application Entry Point Integration (Priority: P1)

As a system, the application must execute its initialization sequence through the updated root entry point so that all legacy manifests are bypassed and character storage data is handed off cleanly.

**Why this priority**: P1 (Critical Blocker). Without updating the primary entry point to point to the new root manifest, the application defaults to legacy loading patterns and fails to initialize newly refactored features.

**Independent Test**: Can be verified by executing an application reload trigger and confirming that the application boots without runtime startup errors while correctly initializing character storage.

**Acceptance Scenarios**:

1. **Given** the application is triggered to load or reload, **When** the main entry point is evaluated by the environment, **Then** execution is directed strictly to the new root manifest without calling legacy manifests.
2. **Given** stored user configuration and character state, **When** the application completes its startup sequence, **Then** storage variables are successfully bound to the new storage adapters.

---

### User Story 3 - Lifecycle Events Dispatching & System Signals (Priority: P2)

As a system, the application must capture game engine events and convert them into isolated internal signals so that modules can respond to startup phases and network messages without depending directly on the game engine interface.

**Why this priority**: P2. Once the application entry point is running (P1), the system needs a centralized way to handle startup triggers (like player login and data loading) before features can interact with the user.

**Independent Test**: Can be verified by triggering simulated engine signals in isolation and confirming that the internal event dispatcher receives them and notifies registered internal listeners without throwing engine errors.

**Acceptance Scenarios**:

1. **Given** the application is initializing during player entry, **When** the primary startup engine signal is caught, **Then** the event dispatcher sequences and fires internal startup lifecycle events in order.
2. **Given** incoming engine communication or chat events, **When** a external message event is received, **Then** the dispatcher converts the raw event payload into an internal message format for downstream modules.

---

### User Story 4 - Character Model Structure and Isolation (Priority: P1)

As a core domain agent, I need to refactor the character model to isolate it from the game engine and other modules so that validate the model is self-contained and can be tested independently of the game engine and other modules

**Why this priority**: P1. Once application architecture is established (P1), the character model is the next critical component to refactor to ensure it can be used as the Character schema validation and storage.

**Independent Test**: Can be tested by passing incomplete character data into the factory function outside the game client and verifying it returns a valid, default-populated object without invoking external APIs.

**Acceptance Scenarios**:

1. **Given** raw character data, **When** the character model is instantiated, **Then** the character model is validated and enriched with default values.
2. **Given** a character model, **When** game engine events are simulated, **Then** the character model updates its state and triggers internal events without depending on the game engine interface.

---

### User Story 5 - Refactor Item, Armor & Weapon Domain Entities (Priority: P2)

Refactor core game entities (Items, Armors, Weapons) into pure Lua domain objects residing in `src/main/domain/` with explicit serialization and XML registration. This decouples entity instantiation and default schema state from the global legacy context (`GAC`).

**Why this priority**: Refactoring these core inventory and equipment entities into pure, isolated factories is essential for removing global state dependencies (`GAC`) and ensuring predictable domain modeling across the game loop.

**Independent Test**: Can be fully tested by instantiating Items, Armors, and Weapons directly via their factory functions without loading `GAC`, verifying schema defaults and checking that `Serialize()` outputs accurate state structures.

**Acceptance Scenarios**:

1. **Given** no global `GAC` context initialized, **When** an Item, Armor, or Weapon factory is called, **Then** a pure Lua object is instantiated with valid schema defaults without throwing runtime global reference errors.
2. **Given** an instantiated Item, Armor, or Weapon entity, **When** calling `Serialize()`, **Then** it produces a serializable Lua table matching the expected schema format.
3. **Given** the domain configuration, **When** `src/main/domain/domain.xml` is loaded, **Then** all three entities (Item, Armor, Weapon) are registered and resolved properly by the framework.

---

### User Story 5 - Decouple Character Service & Stat Calculations (Priority: P2)

Refactor character stat calculation logic from `CharacterService.lua` into a dedicated `CharacterCalculator.lua` domain module. Convert attribute and talent modifiers into pure, side-effect-free mathematical functions isolated from World of Warcraft API dependencies.

**Why this priority**: Decoupling game math from client-side runtime state allows deterministic unit testing and guarantees consistent stat evaluation across all character operations.

**Independent Test**: Can be fully tested by running unit tests against `CharacterCalculator.lua` using mock inputs in a standard CLI Lua environment without launching the WoW client.

**Acceptance Scenarios**:

1. **Given** a set of character attributes and talent inputs, **When** passed into `CharacterCalculator.lua`, **Then** it produces exact, deterministic outputs without invoking global WoW API functions or mutating external state.
2. **Given** identical character stat inputs, **When** stat calculation functions are executed multiple times, **Then** they consistently return identical numerical results without side effects.
3. **Given** a standard standalone Lua test environment (outside the WoW client), **When** `CharacterCalculator.lua` unit tests are executed, **Then** all calculation tests pass without missing global dependency errors.

---

### User Story 6 - Implement Local IPC Adapter (Priority: P1)

Implement a publish/subscribe local IPC adapter based on the `IPCMessagePort` contract to decouple UI components from backend domain logic. This enables event-driven communication between `src/main/` and `src/ui/` across supported channels like character updates, combat state changes, and inspection data.

**Why this priority**: High-priority architectural core because decoupling UI micro-frontends from direct backend state prevents tight coupling, eliminates memory leaks, and enables independent UI testing.

**Independent Test**: Can be fully tested by subscribing mock listeners to `LocalIPCAdapter` channels, publishing payload events from the backend port, and verifying subscribers receive messages without direct backend class coupling.

**Acceptance Scenarios**:

1. **Given** a listener subscribed to `CHARACTER_UPDATED`, `COMBAT_STATE_CHANGED`, or `INSPECTION_DATA_READY`, **When** the backend emits an event through `IPCMessagePort`, **Then** the `LocalIPCAdapter` dispatches the payload to all registered UI subscribers.
2. **Given** a UI micro-frontend component, **When** sending or receiving state updates, **Then** all communication flows strictly through the `LocalIPCAdapter` without holding direct references to backend instances.
3. **Given** an invalid or unsubscribed event channel, **When** a message is published, **Then** the adapter safely handles or ignores the message without throwing unhandled exceptions or leaking listener references.

---

### User Story 7 - Storage & TRP3 Integration Adapters (Priority: P2)

Encapsulate external persistence and third-party Total RP 3 (TRP3) dependencies inside dedicated infrastructure adapters within `src/main/adapters/`. This provides safe read/write access to `GAC_CharacterDB` via `SavedVarsStorageAdapter.lua` and defensive read-only access to TRP3 profiles via `TRP3Adapter.lua`.

**Why this priority**: Encapsulating direct global table operations and external add-on dependencies prevents legacy state corruption, insulates domain logic from TRP3 API changes, and allows graceful fallbacks when TRP3 is disabled.

**Independent Test**: Can be fully tested by simulating persistence reads/writes and mocking TRP3 global objects (both present and missing) to verify data mapping and defensive fallback behavior without loading full add-on environments.

**Acceptance Scenarios**:

1. **Given** global `GAC_CharacterDB` state, **When** domain services request read or write operations through `SavedVarsStorageAdapter.lua`, **Then** data is safely persisted and retrieved without domain entities directly accessing the global table.
2. **Given** TRP3 is active in the environment, **When** `TRP3Adapter.lua` queries profile names or base info, **Then** it returns structured profile data without leaking internal TRP3 data structures into the core domain.
3. **Given** TRP3 is disabled or uninitialized, **When** `TRP3Adapter.lua` is queried, **Then** it fails gracefully and returns default fallback values without throwing nil reference errors.
4. **Given** the application runtime, **When** inspecting code dependencies outside `src/main/adapters/`, **Then** no direct references to `GAC_CharacterDB` or `TRP3` global variables exist.

---

### User Story 8 - Establish Base UI Architecture & Shared Templates (Priority: P2)

Establish the foundational XML layout structure and shared template infrastructure for UI micro-frontends under `src/ui/`. This registers shared XML frame templates in `src/ui/shared/Templates.xml` and isolates UI helper utilities strictly within `src/ui/shared/`.

**Why this priority**: Establishing early layout templates and scoping visual helpers prevents UI micro-frontends from duplicating code or creating tight cross-feature script dependencies as feature views expand.

**Independent Test**: Can be fully tested by instantiating UI frames defined in `Templates.xml` from isolated micro-frontend views, ensuring they render correctly and access shared helpers without importing cross-feature scripts.

**Acceptance Scenarios**:

1. **Given** shared XML templates registered in `src/ui/shared/Templates.xml`, **When** any UI micro-frontend inherits from these base templates in `src/ui/ui.xml`, **Then** the visual components instantiate with correct default layouts and styles.
2. **Given** UI helper functions scoped strictly within `src/ui/shared/`, **When** executed by micro-frontend views, **Then** all helpers execute predictably without polluting the global namespace or depending on domain backend code.
3. **Given** distinct micro-frontend views, **When** loading UI assets, **Then** visual components render using shared templates without direct cross-references or script dependencies between sibling UI modules.

---

### User Story 9 - Refactor Character Sheet UI Micro-Frontend (Priority: P2)

Refactor the Character Sheet UI into an isolated micro-frontend module under `src/ui/sheet/` using standard component and API boundaries. Connect `sheetApi.lua` strictly to the `LocalIPCAdapter` so the view consumes character data and triggers updates without direct coupling to backend logic or sibling UI frames.

**Why this priority**: Encapsulating the Character Sheet into a self-contained micro-frontend ensures UI state changes do not cause unintended side effects across other UI features and guarantees independent testability.

**Independent Test**: Can be fully tested by mounting `src/ui/sheet/` with a mocked `LocalIPCAdapter`, verifying character data populates the view and user interactions trigger correct IPC event dispatches without requiring other UI modules.

**Acceptance Scenarios**:

1. **Given** the Character Sheet micro-frontend mounted in isolation, **When** `sheetApi.lua` receives character data via `LocalIPCAdapter`, **Then** internal components and hooks update and render the character sheet UI accurately.
2. **Given** a user interaction within the Character Sheet frame, **When** state actions are triggered, **Then** `sheetApi.lua` dispatches IPC events solely through `LocalIPCAdapter` without directly modifying backend instances or global UI frames.
3. **Given** the module structure under `src/ui/sheet/`, **When** auditing component code, **Then** no direct imports, global calls, or frame references to other UI feature modules exist.

---

### User Story 10 - Clean Up Legacy TypeScript Artifacts (Priority: P3)

Clean up orphaned TypeScript files from the active World of Warcraft Lua runtime directory `src/` by archiving or relocating reusable schema definitions into `.specs/` or `/data/`. This enforces a clean build tree and prevents non-executable source files from polluting the add-on package.

**Why this priority**: Low priority housekeeping that improves project hygiene, prevents build chain confusion, and ensures strict compliance with WoW Lua runtime requirements.

**Independent Test**: Can be fully tested by running a repository directory search across `src/` to verify no `.ts` extension files exist while confirming valid schema references remain accessible in `.specs/` or `/data/`.

**Acceptance Scenarios**:

1. **Given** orphaned TypeScript files located under `src/Models/modelosTS/*.ts`, **When** the cleanup process is executed, **Then** all `.ts` files are removed from the `src/` directory tree.
2. **Given** reusable schema definitions identified within the legacy TypeScript files, **When** migrating them, **Then** they are properly relocated to `.specs/` or `/data/` for specification reference without impacting runtime Lua execution.
3. **Given** the `src/` directory tree, **When** inspecting all contained files, **Then** only valid Lua (`.lua`) and XML (`.xml`) files remain present in the runtime directory.

---

### User Story 11 - Realign Active Context & Progress Memory Bank (Priority: P3)

Realign and update `memory-bank/activeContext.md` and `memory-bank/progress.md` to reflect the current codebase architecture, active Sprint 1 refactoring status, and Phase 1 task progress. This eliminates context drift between AI agent memory files and actual repository state.

**Why this priority**: High-priority governance task because AI developer tools depend on accurate context files to maintain architectural alignment and prevent invalid assumptions during automated refactoring.

**Independent Test**: Can be fully tested by cross-referencing all task statuses and directory structures listed in `activeContext.md` and `progress.md` against actual repository files and completed sprint deliverables.

**Acceptance Scenarios**:

1. **Given** current progress on Sprint 1 refactoring, **When** reviewing `memory-bank/activeContext.md`, **Then** it accurately details the ongoing sprint focus, active refactoring targets, and recent architectural changes without stale context.
2. **Given** the Phase 1 milestone requirements, **When** reviewing `memory-bank/progress.md`, **Then** Phase 1 is marked as "In Progress" with granular, up-to-date task checklists strictly aligned with actual codebase completion.
3. **Given** any AI agent session initialized with the updated memory bank, **When** reading system context, **Then** the agent operates on 100% verified directory structures and sprint statuses without hallucinating legacy paths.

---


### Edge Cases

- **Missing/Corrupted SavedVars (GAC_CharacterDB)**: If `SavedVarsStorageAdapter.lua` encounters nil, partial data, or schema version mismatch on load, it must fall back to initializing clean defaults generated via `Character.create({})` without crashing the loading chain.

- **Uninitialized/Missing TRP3 Addon**: If `TRP3Adapter.lua` attempts to query external profiles while Total RP 3 is disabled or loading out of order, the adapter must catch missing global pointers defensively and return nil or standard default structures.

- **Out-of-Order Manifest Manifestation**: If a developer introduces a new Lua script without updating the cascading bottom-up XML manifest structure ([folder].xml), the execution engine will trigger a missing dependency runtime exception.

- **IPC Unregistered Event Channel Broadcast**: If a backend port publishes an event to an unmapped IPC channel or a channel with no subscribers, LocalIPCAdapter must silently swallow or log a debug trace without leaking memory or throwing nil-table errors.

- **Direct Blizzard API Invocation in Domain**: If a domain entity within src/main/domain/ attempts to execute standard WoW engine globals (e.g., GetTime(), UnitHealth()), the unit test runner outside the client will fail isolated domain execution.

## Requirements *(mandatory)*

### Functional Requirements

* **FR-001**: The system MUST structure file declarations using a bottom-up cascading XML manifest hierarchy starting from src/root.xml.

* **FR-002**: All domain entity factories (Character, Item, Armor, Weapon) MUST implement a strict validation and schema enrichment method (Model.create(raw_data)).

* **FR-003**: Domain logic under src/main/domain/ MUST execute purely within standard Lua runtime constraints without calling WoW engine API functions.

* **FR-004**: The system MUST provide an isolated publish/subscribe IPC adapter (LocalIPCAdapter.lua) under src/main/adapters/ implementing the IPCMessagePort contract.

* **FR-005**: All UI micro-frontends under src/ui/ MUST communicate with backend domain logic exclusively via LocalIPCAdapter channels (CHARACTER_UPDATED, COMBAT_STATE_CHANGED, INSPECTION_DATA_READY).

* **FR-006**: Persistence operations on GAC_CharacterDB MUST be isolated within SavedVarsStorageAdapter.lua.

* **FR-007**: Interaction with Total RP 3 data MUST be defensively wrapped inside TRP3Adapter.lua to prevent unhandled global variable exceptions when the add-on is inactive.

* **FR-008**: Mathematical stat and talent calculations MUST be encapsulated within CharacterCalculator.lua as pure, side-effect-free functions.

* **FR-009**: The repository MUST maintain strict Lua variable scoping using standard local keywords across all new files to eliminate global namespace leaks.

* **FR-010**: The active codebase under src/ MUST contain only executable .lua and .xml files, relocating obsolete TypeScript (.ts) definitions to .specs/ or /data/.

### Key Entities *(include if feature involves data)*

* **Character Model**: Domain entity representing a character's core identity, stats, equipment, and state schema. Instantiated and validated via `Character.create(raw_data)`.

* **Item / Armor / Weapon Entities**: Domain entities defining equipment items, properties, and serialization interfaces (`Serialize()`).

* **Local IPC Adapter**: Messaging broker managing event channels between backend domain ports and UI micro-frontend consumers.

* **SavedVars Storage Adapter**: Gateway handling read/write operations against the engine's persistent GAC_CharacterDB table.

* **TRP3 Adapter**: Defensive adapter providing read-only access to Total RP 3 player profiles with default fallback handling.

* **Character Calculator**: Pure domain service dedicated to computing stat totals, modifiers, and character metrics.

## Success Criteria *(mandatory)*

### Measurable Outcomes

* **SC-001**: Zero global scope leaks across all newly implemented or refactored Lua files (verified via linter/static analysis).

* **SC-002**: 100% decoupling of domain modules (src/main/domain/), resulting in zero runtime calls to WoW APIs within domain source files.

* **SC-003**: 100% of UI components in src/ui/ route state mutations and data requests through LocalIPCAdapter without importing backend concrete classes or sibling UI modules.

* **SC-004**: Automated unit test execution for CharacterCalculator.lua and domain models achieves 100% pass rate in a standard CLI Lua engine outside the game client.

* **SC-005**: 0 non-executable TypeScript (.ts) files remaining inside the active src/ directory tree.

## Assumptions
* **Target Runtime Engine**: World of Warcraft Lua environment (Lua 5.1 dialect) utilizing standard .toc and cascading .xml manifests.

* **IPC Synchronicity**: The LocalIPCAdapter operates synchronously within the client thread loop for instant UI state updates.

* **Add-on Isolation**: Third-party add-ons (such as TRP3) are optional dependencies; core application features remain functional with fallback defaults when TRP3 is disabled.

* **Backward Compatibility**: Existing saved variable structures in GAC_CharacterDB can be parsed and mapped safely into the updated Character entity schema.
