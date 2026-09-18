# Implementation Plan: Critical Fixes & Infrastructure Setup

**Branch**: `001-critical-infrastructure-setup` | **Date**: 2026-09-18 | **Spec**: [spec.md](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/specs/001-critical-infrastructure-setup/spec.md)

**Input**: Feature specification from `/specs/001-critical-infrastructure-setup/spec.md`

## Summary

Establishes core add-on bootstrapping and global environment stability across root manifest inclusion (`GranAddonDeLasCosas.xml`), submanifest tag alignment (`Communication.xml`, `Data.xml`, `Utils.xml`, `UI.xml`, `Components.xml`, `Screens.xml`, `Hooks.xml`), and global namespace exposure (`_G.GAC` and `_G.GranAddonDeLasCosas` in `src/index.lua`).

## Technical Context

**Language/Version**: World of Warcraft Lua / WoW Client Interface `90207` (Shadowlands / Epsilon WoW)

**Primary Dependencies**: Blizzard FrameXML API, WoW XML UI Schema (`UI-Classic.xsd`)

**Storage**: SavedVariables (`GranAddonDeLasCosasDB`, `GranAddonDeLasCosasCharDB`)

**Testing**: Manual client verification (`/reload` UI, console `/run print(GAC.name)`)

**Target Platform**: Epsilon WoW / WoW Retail 9.2.7 Client

**Project Type**: WoW Addon

**Performance Goals**: Clean add-on load execution with zero XML/Lua load errors during client boot.

**Constraints**: Strict XML UI schema compliance (`<Include>` reserved for `.xml`, `<Script>` reserved for `.lua`).

**Scale/Scope**: Root manifest (`GranAddonDeLasCosas.xml`), `src/GAC.xml`, 7 submanifest files, and `src/index.lua`.

## Constitution Check

*GATE: Passed prior to Phase 0 research.*

- **Principle I (Clean Global `_G` & Private Addon Namespace)**: PASS. Exposing `_G.GAC` and `_G.GranAddonDeLasCosas` cleanly in `src/index.lua`.
- **Principle II (XML Manifest & Standard UI Declarations)**: PASS. Correcting root `<Script>` tag to `<Include>` and aligning submanifest `<Include file="*.lua"/>` to `<Script file="*.lua"/>`.
- **Principle III (Separation of Concerns)**: PASS. Pure environment bootstrapping and loading structure fix.
- **Principle IV (Test-Driven Development & Safe API Calling)**: PASS. Validated via pre-flight manifest checks.
- **Principle V (WoW Addon Ecosystem & Library Integration)**: PASS. Follows standard WoW add-on manifest patterns.
- **Principle VI (Localization & Strict Code Conventions)**: PASS. Maintains `camelCase` identifiers.
- **Principle VII (Flux-Driven Modular UI Architecture)**: PASS. Infrastructure setup does not alter UI state management.
- **Principle VIII (SOLID Design Principles)**: PASS. Single responsibility per manifest file.

## Project Structure

### Documentation (this feature)

```text
specs/001-critical-infrastructure-setup/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
└── quickstart.md        # Phase 1 output
```

### Source Code (repository root)

```text
GAC_DEV/
├── GranAddonDeLasCosas.xml
├── GAC_DEV.toc
└── src/
    ├── index.lua
    ├── GAC.xml
    ├── Communication/
    │   └── Communication.xml
    ├── Data/
    │   └── Data.xml
    ├── Utils/
    │   └── Utils.xml
    ├── Locales/
    │   └── Locales.xml
    └── Frames/
        ├── Frames.xml
        ├── UI/UI.xml
        ├── MainMenu/
        │   ├── MainMenu.xml
        │   ├── Components/Components.xml
        │   ├── Screens/Screens.xml
        │   └── Hooks/Hooks.xml
        ├── QuickButtonsMenu/
        │   ├── QuickButtonsMenu.xml
        │   ├── Components/Components.xml
        │   └── Hooks/Hooks.xml
        └── InitiativeOrders/
            ├── InitiativeOrders.xml
            ├── Components/Components.xml
            ├── Screens/Screens.xml
            └── Hooks/Hooks.xml
```

**Structure Decision**: Single World of Warcraft Addon structure adhering to standard WoW `Interface/AddOns` layout.

## Complexity Tracking

*No constitution violations.*
