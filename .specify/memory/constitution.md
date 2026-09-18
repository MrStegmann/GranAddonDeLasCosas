<!--
SYNC IMPACT REPORT
Version: 1.0.0 -> 1.1.0
Added Principles:
- VII. Flux-Driven Modular UI Architecture
Added Sections: None
Removed Sections: None
Follow-up TODOs: None
-->

# Gran Addon De Las Cosas (GAC) Constitution

## Core Principles

### I. Clean Global `_G` & Private Addon Namespace
Every Lua source file MUST receive and operate within the local addon namespace table injected by the World of Warcraft engine (`local addonName, addonTable = ...`). Global table `_G` pollution is strictly prohibited. Any public API or cross-file state exposed to the global environment MUST be scoped under a single, dedicated global table namespace (e.g., `GAC` / `GranAddonDeLasCosas`).

### II. XML Manifest & Standard UI Declarations (Interface 90207)
The project explicitly targets World of Warcraft Interface version 90207 (`## Interface: 90207`). All addon source files and UI template definitions MUST be registered and ordered via the primary XML manifest (`GranAddonDeLasCosas.xml`) declared in `GAC_DEV.toc`. UI layout structures and reusable frame templates MUST be declared using WoW XML UI schemas, maintaining a clear boundary between XML structural templates and Lua behavior script logic.

### III. Strict Separation of Concerns & Modular Architecture
Business logic, data management, network synchronization, and visual frame creation MUST remain strictly separated into distinct, modular files located under logical subdirectories (`Communication/`, `Data/`, `Events/`, `Frames/`, `Locales/`, `Utils/`). UI components MUST be designed for reusability (e.g., custom buttons, scroll frames, status plates) to eliminate code duplication across panels.

### IV. Test-Driven Development (TDD) & Safe API Calling
Domain logic, mathematical formulas (such as RPG roll modifiers and dynamic health recalculations), and state machine transformations MUST be developed following TDD principles (tests written and failing prior to implementation). Any execution block that invokes external client APIs, risky operations, or optional third-party integrations MUST be wrapped in `SafeCall` execution wrappers to prevent Lua errors from disrupting player experience.

### V. WoW Addon Ecosystem & Library Integration
The addon MUST seamlessly integrate into the WoW addon ecosystem by leveraging established shared libraries (e.g., Ace3, LibStub, CallbackHandler) and interoperating safely with external RP addons such as **Total RP 3 (TRP3)** and **Total RP 3: Extended (TRP3_Extended)**. Pre-flight checks (`IsAddOnLoaded` or global object verification) MUST be executed before consuming third-party APIs. Hidden P2P data synchronization MUST use WoW's native `C_ChatInfo.SendAddonMessage` API over dedicated channels (`GAC_Sync`).

### VI. Localization & Strict Code Conventions
All variable names, table fields, and internal identifiers MUST follow `camelCase` naming conventions. Hardcoding user-facing strings or UI labels inside Lua code or XML definitions is forbidden; all strings MUST be routed through the dedicated `Locales` localization table system.

### VII. Flux-Driven Modular UI Architecture
UI frames and view components MUST strictly follow a Flux-driven unidirectional data flow pattern (`Action` → `Dispatcher` → `Store` → `View`). UI views and XML/Lua frames MUST NOT mutate application state directly; all user interactions (e.g., button clicks, attribute allocation changes, health adjustments) MUST dispatch discrete Actions. Stores update internal state and broadcast state-change notifications, causing registered UI views to re-render. UI components MUST remain presentationally focused and modular, subscribing to Store updates rather than maintaining independent parallel state.

## Technical Constraints & Target Client Specifications
- **Target Interface Client**: WoW 9.0.2 / 9.2.7 (`## Interface: 90207`), engineered for retail and custom RP client environments (e.g., Epsilon WoW).
- **Saved Variables**: Persistent user options and character profiles MUST be declared explicitly in `.toc` (`SavedVariables: GranAddonDeLasCosasDB`, `SavedVariablesPerCharacter: GranAddonDeLasCosasCharDB`).
- **Performance Thresholds**: Frame update cycles and polling loops MUST be throttled (e.g., 0.5s intervals) to prevent frame rate drops during target synchronization or combat states.

## Development Workflow & Quality Gates
1. **Red-Green-Refactor Cycle**: Define unit tests for pure logic modules before authoring implementation code.
2. **Safe Interoperability Check**: Verify presence of external addons (`TRP3`, `TRP3_Extended`) before registering hooks or event listeners.
3. **Localization Enforcement**: Verify that every added label or text string has a corresponding entry in the `Locales` module.
4. **Manifest Ordering**: Ensure newly added Lua or XML files are correctly included in `GranAddonDeLasCosas.xml` in valid dependency order.
5. **Flux Data Flow Compliance**: Ensure UI event handlers dispatch Actions to Stores rather than directly mutating shared tables or global frame properties.

## Governance
This Constitution is the supreme governing document for the Gran Addon De Las Cosas (GAC_DEV) codebase. All code contributions, refactorings, pull requests, and AI agent implementations MUST strictly comply with these principles. Amendments to this constitution require explicit documented justification, version revision, and verification against existing architectural patterns.

**Version**: 1.1.0 | **Ratified**: 2026-09-18 | **Last Amended**: 2026-09-18
