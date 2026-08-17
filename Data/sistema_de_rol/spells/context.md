# Guía de Creación y Uso de Hechizos

Este documento detalla las reglas de diseño, mecánicas y categorización para los **Hechizos** dentro del sistema de juego, basándose en la estructura maestra de configuración.

## Organización de los Archivos
Para mantener una correcta organización en la base de datos, los hechizos **deben estar debidamente separados y categorizados por el tipo de talento mágico al que pertenecen**.

No existirá un único archivo de hechizos, sino que se dividirán en archivos `.json` individuales correspondientes a su rama mágica:
*   `arcano_spells.json` (Inteligencia)
*   `vil_spells.json` (Inteligencia)
*   `nigromancia_spells.json` (Inteligencia)
*   `naturaleza_spells.json` (Inteligencia)
*   `sombras_spells.json` (Inteligencia)
*   `light_spells.json` (Voluntad)
*   `elune_spells.json` (Voluntad)
*   `elemental_spells.json` (Voluntad)
*   `chi_spells.json` (Voluntad)

---

## Categorías de Poder de los Hechizos
Cada hechizo debe pertenecer a una de las siguientes categorías, lo que dictará sus límites mecánicos:

| Categoría | Recurso | Poder | Acciones | Ataque Oportunidad | Canalizable | Turnos | Enfriamiento | Ranuras |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Trucos** | 0 | 4 | 1 | Falso | Falso | 0 | 1 | 1 |
| **Rápidos** | 2 - 4 | 6 | 1 | Falso | Falso | 2 - 3 | 2 | 1 - 2 |
| **Básicos** | 5 - 7 | 8 | 2 | Verdadero | Verdadero | 4 - 5 | 3 | 1 - 3 |
| **Potentes** | 8+ | 10 | 3 | Verdadero | Verdadero | 6+ | 4 | 3 - 5 |

---

## Definiciones de Propiedades de los Hechizos
Al crear un hechizo en su JSON correspondiente, debe seguir estos parámetros:

*   **Recurso:** Puntos de maná o espíritu que consume el hechizo.
*   **Poder:** Potencia del efecto (Determina el dado de daño, de sanación o intensidad de los efectos aplicados).
*   **Acciones:** Cuántas acciones consume. 
    *   *Lanzamiento Prolongado:* Si un hechizo requiere 3 acciones (siendo 2 el máximo por turno ofensivo), se completará al comienzo del siguiente turno. Durante ese turno, el personaje tendrá una acción menos.
    *   *Interrupción:* Si el lanzador recibe daño antes de completar un lanzamiento prolongado, el hechizo se interrumpe, aunque no consume el recurso ni entra en enfriamiento.
*   **Ataque de Oportunidad:** Determina si invocar este hechizo cuerpo a cuerpo provoca un ataque de oportunidad del enemigo.
*   **Canalizable:** Si permanece activo varios turnos.
    *   No es necesario repetir tirada de acierto, solo se lanza el dado de poder cada turno.
    *   Cada tirada consume el recurso indicado.
    *   Recibir daño o moverse rompe la canalización.
*   **Turnos:** Duración del efecto. Si la tirada de lanzamiento es un **Crítico**, la duración se duplica.
*   **Enfriamiento:** Turnos que deben pasar antes de volver a usarlo.
*   **Dificultad:** La dificultad estática que el jugador debe superar para lanzar hechizos de sanación, escudos o efectos (que no tienen tirada de defensa opuesta).
*   **Ranura:** Ranuras requeridas en la ficha para conocerlo.

---

## Reglas de Creación y Diseño
Todo nuevo hechizo debe ceñirse a las siguientes directrices:
1.  **Trucos:** No pueden ser hechizos de mejora (buffs) ni de penalización (debuffs), solo efectos o daños directos leves.
2.  **Hechizos Defensivos:** Los hechizos que se utilicen como reacción en la fase de defensa solo pueden pertenecer a las categorías **Rápidos** o **Básicos**, y deben incluir textualmente en su descripción la frase: *"Puede usarse en defensa"*.
3.  **Contraconjuros:** Absolutamente todos los hechizos son susceptibles de ser interrumpidos por habilidades o hechizos especializados en interrupción.
4.  **Coherencia de Lore (World of Warcraft):** Los hechizos deben ser estrictamente coherentes con la cosmología y Lore de World of Warcraft. Los hechizos elementales deben estar ligados a los elementos puros (Tierra, Fuego, Agua, Aire), la Luz Sagrada a la Luz, las Sombras al Vacío, la Nigromancia a la Muerte, la Naturaleza a la Vida, la magia Arcana al Orden, y la magia Vil al Caos. Por ejemplo: no deben mezclarse temáticas arcanas (como la escarcha) dentro de la rama del chamanismo elemental.

---

## Aprendizaje: Grimorios vs Memoria
Los hechizos pueden originarse desde dos fuentes:

*   **Hechizos Aprendidos:** Consumen tus Ranuras de Hechizo permanentes. Se lanzan de forma natural y no requieren acciones adicionales para usarse.
*   **Grimorios y Libros:** Cualquier personaje puede lanzar un hechizo desde un grimorio.
    *   Cuesta **+1 acción** adicional lanzarlos por tener que leerlos.
    *   Es obligatorio tener el libro equipado/en las manos.
    *   Se puede intentar recordar un hechizo sin el libro (Dificultad de 8 a 15 de VOL + Talento dependiendo de la familiaridad).
