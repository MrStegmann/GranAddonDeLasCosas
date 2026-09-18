# Research & Design Decisions: Full Localization & Code Cleanup

## 1. Localization Dictionary Structure

### Decision
Consolidate all static UI string literals into `src/Locales/ES_es.lua` under a structured key-value table `GAC.Locales`.

### Rationale
- Standardizes all user-facing strings in Spanish (`ES_es`), making strings reusable and editable in a single location.
- Complies with Constitution Principle VI (Localization & Naming).
- Using camelCase key naming conventions (e.g. `charSheetBackgroundHint`, `expReceivedLabel`, `saveProgression`) aligns with project coding standards.

### Alternatives Considered
- *Inline string tables in individual screen files*: Rejected because it scatters localization strings and complicates translation management.
- *Hardcoding strings directly in `CreateFrame` call parameters*: Rejected as it violates Constitution Principle VI.

---

## 2. Dynamic String Formatting Pattern

### Decision
Use `string.format(GAC:_("KEY_PATTERN"), ...)` for localized strings containing dynamic parameters (e.g. level numbers, player names, class names, experience numbers).

### Rationale
- Keeps format string patterns clean and localized without breaking variable interpolation.
- Ensures `GAC:_("KEY")` always returns the raw localized format string, which can be safely passed to `string.format`.

### Alternatives Considered
- *String concatenation (`"Level " .. level)`*: Rejected because sentence structure and word order differ across languages.
