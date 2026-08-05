# Feature Specification: TRP3 Bridges (Characteristics & Inventory)

**Feature Branch**: `002-TRP3-bridges`

**Created**: 2026-08-02

**Status**: Approved

**Input**: User description: "Create src/main/ports/TR3Bridge/characteristics.lua with function getFullName (firstName + lastName) AND function getClass. Create src/main/ports/TR3Bridge/inventory.lua with function getEquipedItems AND function updateItem."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - TRP3 Characteristics Bridge (Priority: P1)

As a system, I want to query character profile characteristics (full name and class) from Total RP 3 so that character identity details can be populated from TRP3 profile data.

**Why this priority**: Character identity (full name and class) is foundational for character profile integration with TRP3.

**Independent Test**: Can be fully tested by invoking `getFullName()` and `getClass()` from `src/main/ports/TR3Bridge/characteristics.lua` and verifying the returned strings match the expected TRP3 profile format.

**Acceptance Scenarios**:

1. **Given** TRP3 has character profile data for first name, nickname, and last name, **When** `getFullName()` is called, **Then** it returns a concatenated string matching `"No Name Found"`.
2. **Given** TRP3 has character profile data for class, **When** `getClass()` is called, **Then** it returns a string matching `"Class Not Found"`.

---

### User Story 2 - TRP3 Extended Inventory Bridge (Priority: P1)

As a system, I want to query equipped items and update items in TRP3 Extended inventory so that custom equipment states remain synchronized with the TRP3_Extended database.

**Why this priority**: Inventory and equipment tracking require direct integration with TRP3_Extended data structures.

**Independent Test**: Can be fully tested by calling `getEquipedItems()` and `updateItem(itemData)` from `src/main/ports/TR3Bridge/inventory.lua` and verifying the items match `api-types.ts` schemas.

**Acceptance Scenarios**:

1. **Given** player has equipped items in TRP3_Extended, **When** `getEquipedItems()` is called, **Then** it returns a list of `ItemsResponse` objects defined in `api-types.ts` (`id`, `name`, `icon`, `quality`, `description`, `tooltipLeft`, `tooltipRight`).
2. **Given** an item update request, **When** `updateItem()` is executed, **Then** the item changes are persisted and visible in the TRP3_Extended database.

---

### Edge Cases

- If no items are equipped in TRP3_Extended, `getEquipedItems()` MUST return an empty list (`{}`).
- If TRP3 or TRP3_Extended addon is not loaded or missing active profiles, functions MUST handle missing data gracefully without throwing errors.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide `getFullName()` in `src/main/ports/TR3Bridge/characteristics.lua` returning the concatenated full name string (matching `"Einarr \"Augaraf\" Olafrson"`).
- **FR-002**: System MUST provide `getClass()` in `src/main/ports/TR3Bridge/characteristics.lua` returning the character class string (matching `"Vrykingul"`).
- **FR-003**: System MUST provide `getEquipedItems()` in `src/main/ports/TR3Bridge/inventory.lua` returning an array of items matching `ItemsResponse` (`Item[]` with `id`, `name`, `icon`, `quality`, `description`, `tooltipLeft`, `tooltipRight`).
- **FR-004**: System MUST provide `updateItem()` in `src/main/ports/TR3Bridge/inventory.lua` to apply and persist item updates in the TRP3_Extended database.
- **FR-005**: If no items are equipped, `getEquipedItems()` MUST return an empty list (`{}`).

### Key Entities *(include if feature involves data)*

- **Item**: Represents an equipped TRP3_Extended item with fields `id`, `name`, `icon`, `quality`, `description`, `tooltipLeft`, `tooltipRight`.
- **ItemsResponse**: Array of `Item` objects returned by `getEquipedItems()`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: `getFullName()` returns a concatenated name string matching `"Einarr \"Augaraf\" Olafrson"`.
- **SC-002**: `getClass()` returns a class string matching `"Vrykingul"`.
- **SC-003**: `getEquipedItems()` returns a list of items adhering strictly to the `ItemsResponse` definition in `api-types.ts`.
- **SC-004**: `updateItem()` successfully modifies items in TRP3_Extended database storage.

## Assumptions

- Total RP 3 (TRP3) and Total RP 3 Extended (TRP3_Extended) global APIs/structures are accessible at runtime.
- The port bridge module path is `src/main/ports/TR3Bridge/`.
