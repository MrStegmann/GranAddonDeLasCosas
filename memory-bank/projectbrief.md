# Project Brief: Custom RP & Turn-Based Combat Manager

## Overview
An in-game World of Warcraft (WoW) Addon built specifically for the **Epsilon Roleplaying Server**. It provides custom tabletop-style character sheet management and a structured, turn-based combat engine while relying on Total RP 3 for basic roleplay profile metadata.

## Core Objectives
1. **Custom Tabletop Mechanics:** Enable players to spend stat points, calculate derived attributes, and execute turn-based actions/dice rolls in RP scenarios.
2. **TRP3 Interoperability:** Safely read identity data (names, titles, statuses) from Total RP 3 without mutating TRP3 state.
3. **P2P Sheet Inspection:** Allow players to view each other's custom stats seamlessly during roleplay or combat encounters using custom addon messaging.
4. **Strict Architectural Integrity:** Maintain clean separation between business logic, network/storage infrastructure, and isolated UI features.

## Target Environment & Tech Stack
* **Target Environment:** World of Warcraft Client (Epsilon Server - Shadowlands 9.2.7)
* **Languages:** Native WoW Lua 5.1 (LuaJIT subset), XML (UI Frame Specifications)
* **Integrations:** Total RP 3 (TRP3), Total RP 3 Extended (TRP3-E)
* **Storage:** `SavedVariablesPerCharacter` (Strictly character-isolated persistence)
* **Documentation Base:** Modular markdown files stored in `/data/*.md`