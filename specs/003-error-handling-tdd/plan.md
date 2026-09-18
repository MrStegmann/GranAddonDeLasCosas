# Implementation Plan: Error Handling & TDD Integration

**Branch**: `003-error-handling-tdd` | **Date**: 2026-09-18 | **Spec**: [spec.md](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/specs/003-error-handling-tdd/spec.md)

**Input**: Feature specification from `/specs/003-error-handling-tdd/spec.md`

## Summary

Centralize safe execution by replacing duplicate `safeCall` implementations with `GAC:SafeCall` across `TRP3Bridge.lua`, `Receiver.lua`, and UI handlers, while establishing a dedicated unit testing suite for core RPG data modules (`LevelTable.lua`, `Armor.lua`, `Weapons.lua`, and `Helpers.lua`).

## Technical Context

**Language/Version**: Lua 5.1 / World of Warcraft Client API (Retail 9.0.2 / 9.2.7 `Interface: 90207`)

**Primary Dependencies**: World of Warcraft Frame API, TRP3 / TRP3_Extended global APIs

**Storage**: SavedVariables (`GranAddonDeLasCosasCharDB`)

**Testing**: Lua standalone test suite / WoW in-game test verification for RPG math (`LevelTable.lua`, `Armor.lua`, `Weapons.lua`, `Helpers.lua`)

**Target Platform**: WoW Client Environment (`Interface: 90207`)

**Project Type**: World of Warcraft Addon

**Performance Goals**: Zero overhead on safe calls (< 0.1ms), instant unit test execution (< 1s for entire suite)

**Constraints**: WoW 9.0.2 Lua sandbox limitations; strict alignment with Constitution Principle IV (TDD & Safe API Calling)

**Scale/Scope**: `TRP3Bridge.lua`, `Receiver.lua`, `LevelTable.lua`, `Armor.lua`, `Weapons.lua`, `Helpers.lua`, `tests/`

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Principle I: Clean Global `_G`**: ✅ Compliant. `GAC` & `GranAddonDeLasCosas` global access points exported.
- **Principle II: XML Manifest Rules**: ✅ Compliant. Manifest XML tag syntax verified.
- **Principle III: Separation of Concerns**: ✅ Compliant. Data math isolated from presentation.
- **Principle IV: TDD & Safe API Calling**: ✅ Compliant. Primary goal of this feature.
- **Principle V: Addon Ecosystem & Libs**: ✅ Compliant. Safe checks for TRP3 presence.
- **Principle VI: Localization**: ✅ Compliant. UI text routed via Locales.
- **Principle VII: Flux UI Architecture**: ✅ Compliant. Reactive state flow established.
- **Principle VIII: SOLID Principles**: ✅ Compliant. SRP & DIP enforced.

## Project Structure

### Documentation (this feature)

```text
specs/003-error-handling-tdd/
├── plan.md              # Implementation plan
├── research.md          # Technical research & design decisions
├── data-model.md        # Data models & interface contracts
├── quickstart.md        # Validation scenarios & test instructions
└── checklists/
    └── requirements.md  # Specification quality checklist
```

### Source Code & Test Structure

```text
src/
├── Communication/
│   ├── Receiver.lua     # SafeCall wrapped packet processing
│   └── TRP3Bridge.lua   # Centralized GAC:SafeCall usage
├── Data/
│   ├── Armor.lua        # RPG armor stat formulas
│   ├── LevelTable.lua   # Level progression tables & formulas
│   └── Weapons.lua      # Weapon stat formulas
└── Utils/
    └── Helpers.lua      # GAC:SafeCall and utility helpers

tests/
├── run_tests.lua        # Test suite runner
├── test_helpers.lua     # Unit tests for Helpers.lua
├── test_leveltable.lua  # Unit tests for LevelTable.lua
├── test_armor.lua       # Unit tests for Armor.lua
└── test_weapons.lua     # Unit tests for Weapons.lua
```

**Structure Decision**: Standard WoW Addon architecture with dedicated `tests/` folder for standalone unit testing of domain math logic.

## Complexity Tracking

> No constitution violations detected. Standard design patterns applied.
