# Phase 0 Research: Critical Fixes & Infrastructure Setup

## Research Topic 1: WoW XML UI Schema Rules for Manifests

### Decision
Use `<Include file="filename.xml"/>` exclusively for nested XML files and `<Script file="filename.lua"/>` exclusively for Lua source files.

### Rationale
In World of Warcraft's FrameXML parser (`UI.xsd`), the XML schema parser enforces strict element semantics:
- `<Include>` is defined to load and parse nested XML documents.
- `<Script>` is defined to execute inline or external Lua scripts.

Using `<Script file="src\GAC.xml"/>` causes the WoW client to attempt parsing an XML file as raw Lua code, resulting in syntax errors. Conversely, using `<Include file="*.lua"/>` causes XML parser failures when the client expects valid XML nodes.

### Alternatives Considered
- **Loading all `.lua` files directly in `GAC_DEV.toc`**: Rejected because modular directory manifests (`Communication.xml`, `Data.xml`, `Utils.xml`, `Frames.xml`) maintain cleaner directory isolation and allow XML frame template declarations.

---

## Research Topic 2: Global Namespace Binding Pattern in WoW Lua

### Decision
Bind `_G.GAC = GAC` and `_G.GranAddonDeLasCosas = GAC` at file scope at the top of `src/index.lua`.

### Rationale
In WoW add-ons, `local addonName, GAC = ...` receives a private table shared across all files loaded by the add-on. However, external macros, slash commands (`/gac`), XML handler scripts (e.g., `OnClick="GAC:Toggle()"`), and third-party add-ons (like TRP3) access globals via `_G`. Binding `_G.GAC = GAC` ensures both internal and external callers reference the exact same singleton table.

### Alternatives Considered
- **Binding `_G.GAC` inside `ADDON_LOADED` event handler**: Rejected because macros or early XML handler execution prior to `ADDON_LOADED` would throw `nil` indexing errors.
