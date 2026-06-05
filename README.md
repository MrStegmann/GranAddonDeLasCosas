# GranAddonDeLasCosas

Plantilla base para un addon de World of Warcraft (Retail).

## Estructura

- `GranAddonDeLasCosas.toc`: Metadatos y orden de carga de archivos.
- `Core/Init.lua`: Inicializacion y registro de eventos.
- `Core/Events.lua`: Manejadores de eventos de WoW.
- `Core/Commands.lua`: Comandos de chat (`/gac`).

## Como probar

1. Inicia el juego.
2. En la pantalla de seleccion de personajes, abre `AddOns` y verifica que `GranAddonDeLasCosas` este activo.
3. Entra con un personaje.
4. Escribe `/gac` en el chat para ver ayuda.
