# Feature Specification: Critical Fixes & Infrastructure Setup

**Feature Branch**: `001-critical-infrastructure-setup`

**Created**: 2026-09-18

**Status**: Draft

**Input**: User description: "Refactor: Critical Fixes & Infrastructure Setup - Establishes core add-on bootstrapping and global environment stability across root manifest inclusion, submanifest tag alignment, and global namespace exposure."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Root Manifest XML Ingestion (Priority: P1)

As a World of Warcraft player and add-on user, I want the add-on manifest to properly load its sub-tree XML configuration without parser errors during client initialization so that all add-on components load reliably.

**Why this priority**: Correct XML manifest semantics are mandatory for the WoW engine to load the add-on's UI submanifests. Without valid XML tags, the add-on fails at load time.

**Independent Test**: Can be tested independently by starting the WoW client (or `/reload` UI) and verifying `GranAddonDeLasCosas.xml` correctly includes `src/GAC.xml` without XML schema errors.

**Acceptance Scenarios**:

1. **Given** the add-on is enabled in WoW client (`Interface: 90207`), **When** the client parses `GranAddonDeLasCosas.xml`, **Then** line 3 (`<Include file="src\GAC.xml"/>`) loads `src/GAC.xml` as a submanifest without script error popup.

---

### User Story 2 - Submanifest Script Source Alignment (Priority: P1)

As a developer and player, I want all XML submanifests to accurately distinguish XML sub-trees (`<Include>`) from Lua script files (`<Script>`) so that every Lua source file executes correctly during load sequence.

**Why this priority**: Using `<Include>` for `.lua` files violates WoW XML schema rules and causes silent or hard file load failures.

**Independent Test**: Inspect frame loading logs and verify that `Communication.xml`, `Data.xml`, `Utils.xml`, `UI.xml`, `Components.xml`, `Screens.xml`, and `Hooks.xml` declare Lua files with `<Script file="*.lua"/>`.

**Acceptance Scenarios**:

1. **Given** the submanifest XML files, **When** the client processes submanifest entries, **Then** all `.lua` script resources are loaded using `<Script file="..." />` tags.
2. **Given** nested XML manifests, **When** sub-directory manifests load, **Then** `<Include file="..." />` tags are reserved strictly for `.xml` files.

---

### User Story 3 - Global Namespace Exposure (Priority: P1)

As an add-on developer, macro writer, or external add-on integrator, I want the primary `GAC` add-on table exposed globally under `_G.GAC` and `_G.GranAddonDeLasCosas` so that functions and state can be safely queried across files and macros.

**Why this priority**: Prevents `nil` reference crashes when macros, slash commands, or XML handler scripts attempt to invoke methods on `GAC` globally.

**Independent Test**: Type `/run print(GAC.version)` or `/run print(GranAddonDeLasCosas.name)` in chat and verify the table is returned without LUA errors.

**Acceptance Scenarios**:

1. **Given** the add-on initialization in `src/index.lua`, **When** `ADDON_LOADED` triggers, **Then** `_G.GAC` and `_G.GranAddonDeLasCosas` reference the active add-on table instance.

---

### Edge Cases

- What happens when external add-ons (such as TRP3) load before `GAC`? `GAC` global reference must exist immediately after `src/index.lua` runs so hooks and event listeners can safely access `GAC`.
- What happens when a macro executes `/gac` before `ADDON_LOADED` completes? The global `_G.GAC` table must be declared at file scope in `src/index.lua` rather than delayed inside `ADDON_LOADED`.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Root manifest (`GranAddonDeLasCosas.xml`) MUST use `<Include file="src\GAC.xml"/>` to declare nested XML manifest loading.
- **FR-002**: All submanifest XML files (`Communication.xml`, `Data.xml`, `Utils.xml`, `UI.xml`, `Components.xml`, `Screens.xml`, `Hooks.xml`) MUST declare `.lua` source files using `<Script file="*.lua"/>` tags.
- **FR-003**: The primary add-on entry point (`src/index.lua`) MUST expose the local add-on table to `_G.GAC` and `_G.GranAddonDeLasCosas` at file evaluation time.
- **FR-004**: All sub-modules MUST retain access to the shared `GAC` table both through engine parameter injection (`local addonName, GAC = ...`) and global scope (`_G.GAC`).

### Key Entities

- **GAC Global Namespace (`_G.GAC`)**: The singleton root table managing add-on state, database handles (`GAC.db`, `GAC.characterData`), event frame dispatcher, and module methods.
- **XML Submanifests**: Declarative manifest files organizing script loading order across domain subdirectories (`Communication/`, `Data/`, `Utils/`, `Frames/`, `Locales/`).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of XML submanifest tags correctly align with schema standards (`<Include>` for XML, `<Script>` for Lua).
- **SC-002**: Client loads add-on without generating any XML schema or Lua syntax load errors in WoW client Interface 90207.
- **SC-003**: Global access check `/run print(GAC.name)` and `/run print(GranAddonDeLasCosas.version)` returns valid string properties in chat console.

## Assumptions

- Target environment is World of Warcraft Retail / Epsilon WoW (`Interface: 90207`).
- The primary `.toc` file (`GAC_DEV.toc`) points to `GranAddonDeLasCosas.xml` as its entry manifest.
- Saved variable tables `GranAddonDeLasCosasDB` and `GranAddonDeLasCosasCharDB` persist across sessions as declared.
