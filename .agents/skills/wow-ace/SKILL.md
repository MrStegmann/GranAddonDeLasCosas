---
name: wow-ace
description: Provides documentation and best practices for the Ace3 addon framework libraries. Use this skill whenever the user asks about or wants to write code using AceAddon-3.0, AceComm-3.0, AceConsole-3.0, AceDB-3.0, AceDBOptions-3.0, AceEvent-3.0, AceGUI-3.0, or AceSerializer-3.0. This skill helps you understand how to register addons, handle events, manage saved variables, and communicate between players in World of Warcraft addons using Ace3.
---

# Ace3 Library Framework

The Ace3 framework is a collection of libraries for World of Warcraft addon development. It is modular, meaning you can use only the parts you need.

This skill contains documentation for the following Ace3 libraries found in the `libs/` directory. When working with one of these libraries, **read its specific reference file** for API details and usage examples:

- [AceAddon-3.0](references/AceAddon-3.0.md): Addon lifecycle, modularity, and initialization (`OnInitialize`, `OnEnable`).
- [AceComm-3.0](references/AceComm-3.0.md): Addon communication over hidden chat channels.
- [AceConsole-3.0](references/AceConsole-3.0.md): Chat command registration and printing.
- [AceDB-3.0](references/AceDB-3.0.md): Saved variables management and profiles.
- [AceDBOptions-3.0](references/AceDBOptions-3.0.md): UI options generation for AceDB profiles.
- [AceEvent-3.0](references/AceEvent-3.0.md): Event registration and messaging.
- [AceGUI-3.0](references/AceGUI-3.0.md): Widget-based GUI creation.
- [AceSerializer-3.0](references/AceSerializer-3.0.md): Data serialization for transmission or storage.

## General Best Practices
- Always use `LibStub` to get a reference to an Ace3 library. E.g., `local AceAddon = LibStub("AceAddon-3.0")`.
- Ace3 libraries often use mixins. You can embed them into your addon table (e.g., `AceAddon:NewAddon("MyAddon", "AceConsole-3.0", "AceEvent-3.0")`).
