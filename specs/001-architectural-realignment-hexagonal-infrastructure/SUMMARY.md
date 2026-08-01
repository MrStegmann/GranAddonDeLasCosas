Listed directory GAC_DEV
Listed directory memory-bank
Listed directory src
Viewed CONTEXT.md:1-166
Viewed activeContext.md:1-17
Viewed progress.md:1-31
Viewed systemPatterns.md:1-55
Searched for "."
Viewed GAC_DEV.toc:1-10
Viewed GranAddonDeLasCosas.xml:1-14
Viewed index.lua:1-73
Viewed CharacterService.lua:1-32
Viewed Character.lua:1-336
Viewed TODO.md:1-16
Viewed DevNotes.md:1-46
Listed directory .agents
Listed directory .github
Listed directory rules
Viewed 01-domain-purity.md:1-26
Viewed 05-lua-good-practices.md:1-33

Como **Scrum Master** del equipo de desarrollo de **GAC_DEV**, he realizado una auditoría completa del directorio `src/`, la estructura del proyecto, los manifiestos XML, la configuración `.toc` y el estado de la documentación en `CONTEXT.md` y `memory-bank/`.

A continuación presento el informe de salud del proyecto, el análisis comparativo de la documentación, las mejores y peores prácticas detectadas y el **siguiente paso más urgente**.

---

# 1. Resumen del Estado Actual del Proyecto (`src/`)

### 🔍 Situación Real en la Base de Código
Actualmente, el proyecto se encuentra en una **fase de transición crítica**:
* **Estructura FÍSICA en `src/` (Legada / Monolítica):** Contiene una implementación funcional basada en la arquitectura clásica de Addons de WoW:
  * `Communication/`, `Constants/`, `Data/`, `Enums/`, `Events/`, `Frames/`, `Hooks/`, `Locales/`, `Models/`, `Services/`, `Utils/`.
  * La carga de archivos está orquestada desde [GranAddonDeLasCosas.xml](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/GranAddonDeLasCosas.xml) y la lógica de inicialización en el [index.lua](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/index.lua) raíz, que vincula todo a una tabla global `GAC`.
* **Desalineación con la Arquitectura Objetivo (`AGENTS.md` / `CONTEXT.md`):**
  * Se diseñó un nuevo estándar basado en **Hexagonal Architecture** (`src/main/domain/`, `src/main/ports/`, `src/main/adapters/`) y **Micro-frontends aislados** (`src/ui/`).
  * Sin embargo, dicha migración **aún no se ha materializado físicamente en el disco**.

---

# 2. Diferencia entre `CONTEXT.md` y `memory-bank/`

| Característica | `CONTEXT.md` | `memory-bank/` |
| :--- | :--- | :--- |
| **Naturaleza** | **Plano Arquitectónico Fijo (Blueprint)** | **Sistema Vivo de Memoria Operativa** |
| **Propósito** | Define la visión general, especificaciones técnicas globales, límites de capas y decisiones de arquitectura a largo plazo. | Mantiene el estado en tiempo real del desarrollo, las decisiones activas del sprint y el progreso diario. |
| **Estructura** | Documento único consolidado de especificación máster. | Directorio multi-archivo ([activeContext.md](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/memory-bank/activeContext.md), [progress.md](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/memory-bank/progress.md), [systemPatterns.md](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/memory-bank/systemPatterns.md), etc.). |
| **Respuesta a:** | *¿Qué estamos construyendo y cómo debe estar diseñado el sistema completo?* | *¿Dónde estamos hoy, qué tareas se han completado y qué reglas aplican al trabajo actual?* |

---

# 3. Mejores y Peores Prácticas de Ingeniería Identificadas en `src/`

### ✅ Mejores Prácticas (Good Practices)

1. **Carga Modular mediante Manifiestos XML Cascada:**
   * Uso sistemático de `<Include>` y `<Script>` en archivos `[folder].xml` (ej. `Models.xml`, `Services.xml`, `Utils.xml`) para controlar el orden de evaluación sin recurrir a scripts de carga dinámica.
2. **Defensa y Sanitización en Constructores de Modelos:**
   * En [Character.lua](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/src/Models/Character.lua#L8-L66), la función `Character:new(savedData)` sanitiza valores de entrada, asigna *fallbacks* seguros e instancia submódulos según `classType` (`Armor`, `Weapon`, `Item`).
3. **Estandarización de Payloads de Red mediante Enums:**
   * En `src/Enums/EventsName.lua`, el uso de códigos cortos estandarizados reduce el consumo de ancho de banda en los mensajes `CHAT_MSG_ADDON`.
4. **Separación de Tablas de Datos (`/data/*.md` y `src/Data/`):**
   * Las reglas de juego, habilidades y datos estáticos se mantienen aislados de la lógica de presentación.

---

### ❌ Peores Prácticas y Deuda Técnica (Bad Practices)

1. **Violación de Pureza de Dominio (Regla 01 - `01-domain-purity.md`):**
   * En [Character.lua](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/src/Models/Character.lua#L17), el modelo de dominio realiza llamadas directas a APIs de WoW Client (`UnitName("player")`) y llamadas globales (`GAC:GetLevelEntry`). El dominio debe ser Lua 5.1 puro sin dependencias de WoW.
2. **Contaminación del Namespace Global (`_G`) y Acoplamiento Fuerte:**
   * Prácticamente todos los componentes se adjuntan directamente a `GAC` (`GAC.Services.CharacterService`, `GAC.Character`, `GAC.playerCharacter`), impidiendo la inyección de dependencias o tests aislados.
3. **Acoplamiento Directo de la UI con Eventos del Motor (Regla 03 - `03-ui-microfrontends.md`):**
   * El archivo [index.lua](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/index.lua#L16-L54) registra directamente eventos de Blizzard (`ADDON_LOADED`, `CHAT_MSG_SYSTEM`) y dispara la creación de frames UI directamente (`CreateQuickActionsFrame`, `InitializePlayerPlate`), en lugar de pasar por un bus IPC / `EventDispatcher`.
4. **Desfase de Estado entre Memoria y Disco:**
   * `activeContext.md` y `progress.md` indican que la Fase 1 (`src/main/` y `src/ui/`) ya fue completada, cuando en el disco `src/` sigue conservando la estructura legacy. Esto genera riesgo de alucinación/desorientación en los agentes.
5. **Archivos Huérfanos/Fuera de Entorno:**
   * Presencia de archivos TypeScript (`src/Models/modelosTS/*.ts`) en un proyecto nativo de Lua 5.1 para WoW sin pipeline de compilación asociado en el `.toc`.

---

# 4. El Paso Siguiente Más Urgente (SOP de Scrum)

> 🚨 **IMPERATIVO:** Resolver la desalineación entre el Plano Arquitectónico (`AGENTS.md`/`CONTEXT.md`), el Memory Bank (`memory-bank/`) y la estructura real de `src/`.

### 🎯 Tarea Inmediata (Prioridad Alta): **Plan de Migración Fase 1 & Sincronización de Memoria**

1. **Creación de la Estructura Hexagonal Objetiva:**
   * Crear la carpeta `src/main/` (`domain/`, `ports/`, `adapters/`) y `src/ui/` (`sheet/`, `combat/`, `shared/`).
   * Migrar los modelos de `src/Models/` hacia `src/main/domain/`, eliminando toda llamada a `UnitName`, `CreateFrame` o `GAC` para garantizar **Pureza de Dominio**.
2. **Implementación de Adapters e IPC (Fase 2 Infrastructure):**
   * Crear `EventDispatcher.lua` en `src/main/adapters/events/` para encapsular la recepción de `ADDON_LOADED` y `CHAT_MSG_ADDON`.
   * Crear `LocalIPCAdapter.lua` en `src/main/adapters/` para conectar el backend con la UI mediante mensajes desacoplados.
3. **Actualización de Manifiestos XML:**
   * Configurar `src/src.xml`, `src/main/main.xml` y `src/ui/ui.xml` reemplazando la carga legacy de `GranAddonDeLasCosas.xml`.
4. **Sincronización de `memory-bank/`:**
   * Actualizar [activeContext.md](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/memory-bank/activeContext.md) y [progress.md](file:///j:/Juegos/Epsilon927/Epsilon/_retail_/Interface/AddOns/GAC_DEV/memory-bank/progress.md) reflejando el progreso real y registrando las tareas de refactorización pendientes.