# Contexto: Creación de Hechizos Arcanos

Este documento sirve como base y guía de referencia para la creación de hechizos de la rama Arcana (que incluye Arcana, Fuego y Escarcha en la tradición de los magos), asegurando que todas las creaciones mantengan un balance mecánico estricto y una fuerte cohesión temática con el lore de **World of Warcraft**.

---

## 1. Escuelas de Magia Arcana (Lore de World of Warcraft)

Según las enseñanzas del Kirin Tor y los eruditos de Dalaran, la magia arcana se divide en diferentes escuelas de estudio. Cada hechizo creado debe pertenecer a una de ellas y respetar su filosofía:

- **Conjuración:** El estudio de invocar materia y energía de la nada o desde otros lugares. Los magos conjuradores pueden crear agua, alimentos, o invocar poderosos Elementales de Agua. También abarca la manifestación física de fuego y hielo para atacar.
- **Abjuración:** La escuela de la protección y la defensa. Se centra en la creación de barreras mágicas, la anulación de hechizos enemigos y la protección contra los elementos (ej. *Escudo de maná*, *Resguardo de hielo*, *Armadura de mago*).
- **Adivinación:** La rama enfocada en la recolección de información. Permite a los magos ver cosas lejanas, revelar lo invisible, traducir idiomas desconocidos y percibir el mundo más allá de los sentidos físicos (ej. *Invisibilidad*, *Ver invisibilidad*).
- **Ilusión:** El arte de engañar la realidad y los sentidos. Los ilusionistas manipulan la luz y la mente para ocultarse, crear señuelos o disfrazarse (ej. *Reflejo exacto*, *Invisibilidad*, *Cópula de ilusión*).
- **Encantamiento:** El proceso de imbuir objetos o criaturas con poder mágico, alterando sus propiedades. Puede usarse para fortalecer armas o para alterar ligeramente la voluntad de los seres.
- **Transmutación:** La manipulación del tiempo, el espacio y las propiedades fundamentales de la materia. Es una de las escuelas más peligrosas y versátiles (ej. *Polimorfia*, *Traslación/Blink*, *Caída lenta*, *Distorsión temporal*).

---

## 2. Flujo de Trabajo para Crear Nuevos Hechizos

Cuando se requiera la creación de un nuevo hechizo o rama mágica, se debe seguir **estrictamente** este orden de prioridades:

1. **Adaptación de World of Warcraft:** Primero, se debe buscar si existe un hechizo similar en el universo de World of Warcraft (clase Mago u otras afines). Si existe, se debe adaptar su concepto y funcionamiento a las reglas del sistema (escalonando de Truco a Potente).
2. **Adaptación de D&D o Pathfinder:** Si el concepto buscado no existe en WoW, se buscarán hechizos equivalentes en sistemas como *Dungeons & Dragons* o *Pathfinder*. **Importante:** Su temática debe ser reimaginada y adaptada para que encaje al 100% en el lore de World of Warcraft antes de integrarlo al sistema.
3. **Invención Original:** Solo si no existen referencias útiles en los pasos anteriores, se inventará el hechizo desde cero. Este debe diseñarse respetando la lógica de las escuelas arcanas de WoW y las métricas de balance del sistema actual.

---

## 3. Lógica del Sistema de Escalado de Hechizos

Partiendo de un **Truco** como la unidad mágica más elemental, un hechizo debe tener variaciones que escalen en tres niveles adicionales (**Rápido**, **Básico**, y **Potente**). 
*Cada nivel se considera un hechizo independiente, pero todos deben mantener la misma cohesión temática y de utilidad.*

### Límites Mecánicos por Categoría:

| Categoría | Recurso (Maná) | Poder (Daño/Escudo) | Acciones | Ataque Oportunidad | Canalizable | Turnos | Enfriamiento | Ranuras | Dificultad |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Trucos** | 0 | 1d4 | 1 | Falso | Falso | 1 | 1 | 1 | 0 |
| **Rápidos** | 2 - 4 | 1d6 | 1 | Falso | Falso | 1 - 2 | 2 - 3 | 1 - 2 | 10 |
| **Básicos** | 5 - 7 | 1d8 | 2 | Verdadero | Verdadero | 3 - 4 | 4 - 6 | 1 - 3 | 12 |
| **Potentes** | 8+ | 1d10 | 3 | Verdadero | Verdadero | 5+ | 6+ | 3 - 5 | 15 |

*Nota sobre Acciones:* Si un hechizo requiere 3 acciones (sabiendo que el máximo por turno es 2), requerirá gastar 1 acción de tu turno actual y el hechizo se lanzará al inicio de tu siguiente turno, pudiendo ser interrumpido si recibes daño entre medias.

---

## 4. Ejemplo de Cohesión (Magia de Escarcha - Abjuración)

Como se establece en el documento `ensayo.md`, los hechizos de una misma familia mantienen una lógica escalonada:

1. **Truco (Resguardo de escarcha):** Protege 1d4, un turno de duración. Anula daño de frío en su primer golpe.
2. **Rápido (Armadura de escarcha):** Protege 1d6, mayor duración. Aplica penalizaciones menores (evita ataques de oportunidad del rival al golpear).
3. **Básico (Barrera de hielo):** Protege 1d8, gasta más acciones. Escudo más fuerte que sigue congelando/penalizando al contacto.
4. **Potente (Muro de hielo):** Protege 1d10, coste muy elevado (3 acciones). Bloque de hielo impenetrable (similar al *Ice Block* de WoW) que anula por completo mecánicas de daño, pero con un gran tiempo de enfriamiento.

Esta metodología de progresión debe replicarse para cualquier nueva familia de hechizos (ej. *Traslación*, *Polimorfia*, *Invisibilidad*).


## 5. Lista de hechizos
Para tomar referencias de hechizos, consultar archivos em `src\data\meta` de la respectiva escuela mágica (arcane, chi, shadow, necromance, fel, holy_light, elune, nature, elemental) y los nuevos hechizos se añadiran al final de dicho archivo JSON.