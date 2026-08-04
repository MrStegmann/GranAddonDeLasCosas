---
trigger: always_on
---

---
description: XML manifest rules, bottom-up dependency loading, and file ordering standards
globs: **/*.xml, src/**/*.xml
---

# 04 - XML Manifests & Cascading Load Order

## 1. Directory Manifest Standard
* **Explicit Directory Manifests:** Every folder inside `src/` MUST export a single XML manifest file named after its parent directory (`[folder].xml`).
* **No Dynamic Script Injectors:** ALL Lua scripts and sub-manifest XML files MUST be declared explicitly via standard XML tags. Never use dynamic Lua script loaders or runtime load strings.
* **Root Entry Point:** The master manifest `src/src.xml` MUST be referenced directly by the main addon `.toc` file.

## 2. Strict Cascading Load Order (Bottom-Up)
To ensure dependencies are fully initialized before higher-level modules execute, XML loading MUST strictly adhere to bottom-up resolution:

* **Root Order (`src/src.xml`):** Loads backend logic (`main/main.xml`) FIRST, then presentation features (`ui/ui.xml`) SECOND.
* **Backend Order (`src/main/main.xml`):** Loads `ports/` → `domain/` → `adapters/` in strict sequence.
* **Adapters Order (`src/main/adapters/adapters.xml`):** Loads `events/`, `network/`, and `cache/` sub-manifests FIRST, followed by concrete script adapters.
* **UI Feature Order (`src/ui/[feature]/[feature].xml`):** Loads `components/` XML layout FIRST, `api/` IPC client SECOND, `hooks/` visual event logic THIRD, and the `index.lua` orchestrator LAST.

## 3. XML Formatting & Tag Hygiene
* **Proper Tags:** Use `<Include file="path\file.xml"/>` for sub-manifest XML files and `<Script file="path\file.lua"/>` for Lua execution files.
* **Windows Path Separators:** Always use backslashes (`\`) for file paths inside XML attributes to ensure compatibility across all World of Warcraft client versions (e.g., `<Include file="ports\ports.xml"/>`).
* **Blizzard Schema Compliance:** All XML files must declare standard WoW UI namespaces:
  ```xml
  <Ui xmlns="[http://www.blizzard.com/wow/ui/](http://www.blizzard.com/wow/ui/)" xmlns:xsi="[http://www.w3.org/2001/XMLSchema-instance](http://www.w3.org/2001/XMLSchema-instance)">