# Implementation Plan: Full Localization & Code Cleanup

**Branch**: `004-full-localization-cleanup` | **Date**: 2026-09-18 | **Spec**: [spec.md](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/specs/004-full-localization-cleanup/spec.md)

**Input**: Feature specification from `/specs/004-full-localization-cleanup/spec.md`

## Summary

Migrate all static UI string literals from `CharSheetContent.lua`, `ExperienceConfigurator.lua`, `InventoryContent.lua`, and `QuickButtonsMenu/index.lua` into `src/Locales/ES_es.lua`, and refactor UI code across these screens to resolve labels and descriptions dynamically using `GAC:_("KEY")`.

## Technical Context

**Language/Version**: Lua 5.1 / World of Warcraft Client API (Retail 9.0.2 / 9.2.7 `Interface: 90207`)

**Primary Dependencies**: `src/Locales/ES_es.lua` localization dictionary table (`GAC.Locales`)

**Storage**: None (Static string table definitions in Lua source files)

**Testing**: In-game visual frame rendering check & verification against `GAC.Locales` table

**Target Platform**: WoW Client Environment (`Interface: 90207`)

**Project Type**: World of Warcraft Addon

**Performance Goals**: Instant key resolution (< 0.01ms), zero memory overhead

**Constraints**: Strict compliance with Constitution Principle VI (Localization & Naming)

**Scale/Scope**: `src/Locales/ES_es.lua`, `CharSheetContent.lua`, `ExperienceConfigurator.lua`, `InventoryContent.lua`, `QuickButtonsMenu/index.lua`

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Principle I: Clean Global `_G`**: ✅ Compliant. `GAC` global access point exported.
- **Principle II: XML Manifest Rules**: ✅ Compliant. XML submanifest syntax verified.
- **Principle III: Separation of Concerns**: ✅ Compliant. UI text separated into Locales.
- **Principle IV: TDD & Safe API Calling**: ✅ Compliant. Safe calling applied.
- **Principle V: Addon Ecosystem & Libs**: ✅ Compliant. Safe API usage.
- **Principle VI: Localization**: ✅ Compliant. Primary goal of this feature.
- **Principle VII: Flux UI Architecture**: ✅ Compliant. Unidirectional state flow preserved.
- **Principle VIII: SOLID Principles**: ✅ Compliant. SRP & DIP enforced.

## Project Structure

### Documentation (this feature)

```text
specs/004-full-localization-cleanup/
├── plan.md              # Implementation plan
├── research.md          # Technical research & design decisions
├── data-model.md        # Data models & interface contracts
├── quickstart.md        # Validation scenarios & test instructions
└── checklists/
    └── requirements.md  # Specification quality checklist
```

### Source Code Structure

```text
src/
├── Locales/
│   └── ES_es.lua        # Centralized Spanish string dictionary (GAC.Locales)
└── Frames/
    ├── MainMenu/
    │   └── Screens/
    │       ├── CharSheetContent.lua        # Refactored string references
    │       ├── ExperienceConfigurator.lua # Refactored string references
    │       └── InventoryContent.lua        # Refactored string references
    └── QuickButtonsMenu/
        └── index.lua                       # Refactored string references
```

**Structure Decision**: Standard WoW Addon localization architecture using centralized `src/Locales/ES_es.lua`.

## Complexity Tracking

> No constitution violations detected. Standard design patterns applied.
