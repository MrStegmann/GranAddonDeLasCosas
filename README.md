# Gran Addon De Las Cosas (GAC)

**Gran Addon De Las Cosas (GAC)** es un robusto _framework_ y complemento de rol (Roleplay) desarrollado para World of Warcraft (optimizando la experiencia en el entorno de Epsilon WoW). 

Proporciona un conjunto completo de herramientas para adaptar las mecánicas de WoW a un sistema de rol de mesa (RPG), integrando atributos, tiradas de dados automatizadas, progresión de niveles personalizada, sincronización en tiempo real y comunicación entre jugadores.

---

## 🌟 Características Principales

### 📜 Ficha de Personaje Personalizada
GAC introduce una ficha de personaje completa, dividida en varias pestañas:
- **Historia**: Guarda y edita el trasfondo de tu personaje.
- **Progresión**: Administra tu Categoría (Novato, Normal, Élite, Jefe) y tu Nivel. El addon recalcula dinámicamente tu **Salud Máxima** basándose en tu progresión y el atributo de Constitución.
- **Atributos y Talentos**: Distribuye y lleva el seguimiento de atributos clásicos (Fuerza, Destreza, Voluntad...) y talentos específicos (Atletismo, Sigilo, Magia Arcana...).
- **Modificadores Especiales**: Incluye soporte para estados persistentes como la **Maldición Huargen**, que altera dinámicamente el resultado de tus tiradas de dados según la forma en la que te encuentres.

### 🎲 Sistema de Tiradas Automatizado
Olvídate de las macros complejas y matemáticas manuales en el chat:
- **Botones de Acción Rápida (Quick Action Menu)**: Una barra en pantalla (320x65, diseño minimalista) que permite invocar tiradas de Atributos, Talentos y Dados Personalizados.
- **Cálculo Automático**: El addon suma el valor de tu atributo + tu talento + modificadores temporales + bonos pasivos (como la Maldición Huargen) automáticamente a tu tirada D20.
- **Captura de Chat**: Intercepta de forma transparente el mensaje de dados del servidor y lo formatea limpiamente en el chat, detallando cada suma (ej: `Nombre tira 1D20 (14) + Destreza (2) + Acrobacias (1) = 17`).

### 🔍 Sistema de Inspección
Haz clic en el botón de la lupa en tu menú de acciones rápidas teniendo a un compañero seleccionado para:
- Visualizar sus Atributos y Talentos en modo lectura.
- Consultar su Categoría, Nivel, Vida y Escudo actuales.
- **Otorgar Experiencia**: Los líderes o directores de partida pueden enviar puntos de experiencia directos al jugador objetivo, actualizando su barra en tiempo real.

### ⚔️ Combate e Interfaz (UI Plates)
Modificaciones limpias a los marcos nativos de WoW (Player y Target):
- Sustituye los textos de salud para reflejar tus Puntos de Vida y Puntos de Escudo del rol (`Vida (Escudo) / VidaMáxima`).
- Superposiciones visuales: Muestra dragones raros o élites en tu retrato y en el de tu objetivo en base a la "Categoría de Poder" asignada.
- Sincronización continua en segundo plano garantizada en rangos de 0.5 segundos para que siempre veas la vida y categoría reales en rol de tu objetivo.

### 🤝 Integración Nativa
- **TotalRP 3 (TRP3)**: GAC se comunica con TRP3 para obtener el Nombre, Raza y Clase definidos en tu perfil actual.
- **P2P Oculto**: Todo el intercambio de datos (vidas, atributos, experiencia) entre jugadores se realiza de manera invisible mediante `C_ChatInfo.SendAddonMessage` usando el canal `GAC_Sync`.

---

## 🛠️ Instalación

1. Descarga el repositorio o la carpeta `GranAddonDeLasCosas`.
2. Extrae la carpeta dentro de tu directorio de World of Warcraft: `_retail_\Interface\AddOns\GranAddonDeLasCosas`.
3. Inicia el juego.
4. En la pantalla de selección de personajes, abre el botón **Accesorios (AddOns)** y asegúrate de que la casilla de `GranAddonDeLasCosas` esté marcada.

---

## 🎮 Cómo Usar

- **`/gac`**: Abre el panel principal del addon, donde encontrarás la Ficha de Personaje y las configuraciones de experiencia.
- **Barra Rápida**: Aparecerá de forma predeterminada en tu pantalla. Puedes arrastrarla manteniendo el clic izquierdo. Úsala para:
  - Modificar tu vida o escudo (`+1`/`-1` haciendo clics izquierdo y derecho).
  - Desplegar el menú de atributos para realizar tiradas directamente.
  - Inspeccionar a tu objetivo.
  - Tirar dados personalizados (`1D100`, `2D6`, etc.).
  
---

## 📁 Estructura del Código
El código está puramente construido en Lua, separado modularmente bajo la carpeta `src/`:
- `src/Communication/`: Emisor y receptor del protocolo P2P invisible del addon.
- `src/Data/`: Bases de datos internas (Tabla de niveles de experiencia, modificadores de Huargen, listado de atributos).
- `src/Events/`: Controladores de auras y eventos que no están atados a UI gráfica.
- `src/Frames/`: Toda la construcción de Interfaz (XML y Lua). Se divide en `MainMenu`, `InspectionMenu`, `QuickButtonsMenu` y modificaciones de `UI` nativa (PlayerPlate/TargetPlate).
- `src/Locales/`: Archivos de traducción y localización (ej. `ES_es`).
- `src/Utils/`: Funciones genéricas de apoyo (TRP3 Bridge, Helpers matemáticos).

---

## ⚙️ Notas de Desarrollo
- Proyecto desarrollado para **Epsilon WoW** bajo el cliente de *Shadowlands/Dragonflight*. 
- Los perfiles de guardado persisten a nivel de personaje en las `SavedVariablesPerCharacter`.
- El módulo de "Registro Maestro" y la herramienta de "Telemetría (Distancias)" están en fase activa de desarrollo en la lista de Tareas (`TODO`).
