# Implementation Plan: Flux UI Architecture & SOLID Refactoring

**Branch**: `002-flux-ui-architecture` | **Date**: 2026-09-18 | **Spec**: [spec.md](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/specs/002-flux-ui-architecture/spec.md)

**Input**: Feature specification from `/specs/002-flux-ui-architecture/spec.md`

## Summary

Establishes core reactive Flux state management infrastructure (`src/Core/Dispatcher.lua`, `src/Core/Store.lua`, `src/Core/Actions.lua`) and refactors UI presentation layers (`CharSheetContent.lua`, `ExperienceConfigurator.lua`, `QuickButtonsMenu/index.lua`) to dispatch actions and subscribe reactively to store state updates, eliminating inline state mutations and complying with SOLID principles.

## Technical Context

**Language/Version**: World of Warcraft Lua / WoW Client Interface `90207` (Shadowlands / Epsilon WoW)

**Primary Dependencies**: Blizzard FrameXML API, `GAC:SafeCall` error handling wrapper

**Storage**: SavedVariables (`GranAddonDeLasCosasCharDB`) encapsulated inside `GAC.Store`

**Testing**: Store action dispatch unit tests & view subscription re-rendering validation

**Target Platform**: Epsilon WoW / WoW Retail 9.2.7 Client

**Project Type**: WoW Addon

**Performance Goals**: Sub-16ms store state update propagation and view re-rendering cycle.

**Constraints**: Strict unidirectional data flow (`Action` → `Dispatcher` → `Store` → `View`). Direct inline mutation of persistent saved variables from UI script handlers is strictly prohibited.

**Scale/Scope**: `src/Core/Actions.lua`, `src/Core/Dispatcher.lua`, `src/Core/Store.lua`, `src/Core/Core.xml`, `src/GAC.xml`, `CharSheetContent.lua`, `ExperienceConfigurator.lua`, `QuickButtonsMenu/index.lua`.

## Constitution Check

*GATE: Passed prior to Phase 0 research.*

- **Principle I (Clean Global `_G` & Private Addon Namespace)**: PASS. Core Flux objects attached to `GAC.Dispatcher`, `GAC.Store`, `GAC.Actions`.
- **Principle II (XML Manifest & Standard UI Declarations)**: PASS. New core manifest `src/Core/Core.xml` included via `<Include>` and registering `.lua` scripts with `<Script>`.
- **Principle III (Separation of Concerns)**: PASS. Decouples state storage from frame creation and event handling.
- **Principle IV (Test-Driven Development & Safe API Calling)**: PASS. All dispatcher callbacks and store subscription loops wrapped in `GAC:SafeCall`.
- **Principle V (WoW Addon Ecosystem & Library Integration)**: PASS. Clean internal event-driven architecture.
- **Principle VI (Localization & Strict Code Conventions)**: PASS. Standard `camelCase` method signatures and property keys.
- **Principle VII (Flux-Driven Modular UI Architecture)**: PASS. Directly enforces the mandated Flux pattern.
- **Principle VIII (SOLID Design Principles)**: PASS. Achieves Single Responsibility (SRP) for UI views and Dependency Inversion (DIP) for state handlers.

## Project Structure

### Documentation (this feature)

```text
specs/002-flux-ui-architecture/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
└── quickstart.md        # Phase 1 output
```

### Source Code (repository root)

```text
GAC_DEV/
└── src/
    ├── Core/
    │   ├── Core.xml
    │   ├── Actions.lua
    │   ├── Dispatcher.lua
    │   └── Store.lua
    ├── GAC.xml (Updated to include Core/Core.xml)
    └── Frames/
        ├── MainMenu/
        │   └── Screens/
        │       ├── CharSheetContent.lua (Refactored to Action dispatch)
        │       └── ExperienceConfigurator.lua (Refactored to Action dispatch)
        └── QuickButtonsMenu/
            └── index.lua (Refactored to Action dispatch)
```

**Structure Decision**: Add `src/Core/` directory to contain core architectural services (`Actions.lua`, `Dispatcher.lua`, `Store.lua`), registered via `src/Core/Core.xml` in `src/GAC.xml`.

## Complexity Tracking

*No constitution violations.*
