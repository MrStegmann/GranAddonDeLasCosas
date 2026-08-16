---
name: wow-lib
description: Provides documentation and best practices for standard World of Warcraft utility libraries. Use this skill whenever the user asks about or wants to write code using LibStub, CallbackHandler-1.0, LibDataBroker-1.1, LibDBIcon-1.0, or LibDeflate. This skill helps you understand how to create DataBroker plugins, add minimap icons, compress data, register library callbacks, and use LibStub to manage library versioning.
---

# WoW Utility Libraries

This skill covers common non-Ace WoW libraries found in the `libs/` directory.

When working with one of these libraries, **read its specific reference file** for API details and usage examples:

- [LibStub](references/LibStub.md): Universal library version manager.
- [CallbackHandler-1.0](references/CallbackHandler-1.0.md): Event and callback registry backend for libraries.
- [LibDataBroker-1.1](references/LibDataBroker-1.1.md): DataBroker (LDB) API for sharing data and creating plugins.
- [LibDBIcon-1.0](references/LibDBIcon-1.0.md): Minimap icon creation from DataBroker objects.
- [LibDeflate](references/LibDeflate.md): Data compression and encoding for network transmission.

## General Best Practices
- Addons should never embed these libraries by directly modifying the global namespace; always rely on `LibStub:GetLibrary(...)`.
- The most common pattern is to create an LDB object with `LibDataBroker-1.1` and then use `LibDBIcon-1.0` to display it on the minimap if the user has no dedicated display addon (like Titan Panel or ElvUI).
