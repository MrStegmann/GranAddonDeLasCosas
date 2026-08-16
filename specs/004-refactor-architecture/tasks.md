# Tasks: Architecture Refactor to MVC

- [x] **Phase 1: File & Directory Migrations**
  - [x] Task 1.1: Create `src/main/Models/`, `src/main/API/`, `src/main/Controllers/`
  - [x] Task 1.2: Move `src/Data/sistema_de_rol` into `src/main/Models/Data/`
  - [x] Task 1.3: Move `src/main/domain/` contents into `src/main/Models/`
  - [x] Task 1.4: Move `src/main/ports/` contents into `src/main/API/`
  - [x] Task 1.5: Move `src/main/adapters/events` and `network` into `src/main/Controllers/`
  - [x] Task 1.6: Evaluate and migrate remaining `src/main/adapters/` (cache, services, locales) to appropriate MVC folders.
  - [x] Task 1.7: Delete old `adapters/`, `domain/`, `ports/`, and `src/Data/` directories.
- [x] **Phase 2: Manifest Resolution**
  - [x] Task 2.1: Update `src/main/main.xml` to point to the new MVC sub-folders.
  - [x] Task 2.2: Create/Update XML manifests inside `Models/`, `API/`, and `Controllers/`.
  - [x] Task 2.3: Update `src.xml` and `GAC_DEV.toc` if necessary to reflect root changes.
- [x] **Phase 3: Integration & Polish**
  - [x] Task 3.1: Verify load order dependencies (Models -> API -> Controllers).
  - [x] Task 3.2: Search and replace any hardcoded paths in scripts that referenced old folder names.
  - [x] Task 3.3: Update `memory-bank` and close feature.
