# Contexto: Creación de Hechizos Elementales

Este documento establece el marco lógico para la creación de hechizos de la rama **Elemental** (Aire, Fuego, Tierra y Agua), garantizando que se adhieran fielmente al lore chamánico de **World of Warcraft** y mantengan el estricto balance mecánico del sistema.

---

## 1. Los Cuatro Elementos (Lore de World of Warcraft)

En la cosmología de World of Warcraft, la magia elemental se obtiene haciendo peticiones o sometiendo a los espíritus primigenios de la naturaleza. Aunque un chamán o un elementalista puede usar cualquier elemento para dañar, defender o curar, cada fuerza primigenia está altamente especializada por su propia naturaleza caótica u ordenada:

### 🌍 Tierra (Estabilidad, Defensa y Control Físico)
El elemento inamovible. Representa la protección física, la tenacidad y los cimientos del mundo.
- **Ofensivo:** Daño físico contundente, crear terremotos, lanzar púas de roca.
- **Defensivo (Especialización principal):** Mitigación de daño masiva, piel de corteza/piedra, escudos de tierra que sanan al recibir golpes.
- **Utilidad:** Control de masas (Tótems de nexo terrestre para frenar avances), alterar el terreno para crear muros infranqueables.

### 🔥 Fuego (Furia, Daño Explosivo y Caos)
El elemento consumidor. Representa la destrucción pura, la pasión y la purga mediante las llamas.
- **Ofensivo (Especialización principal):** Daño directo explosivo (Ráfagas de lava), daño sostenido en el tiempo (quemaduras prolongadas), daño masivo en área.
- **Defensivo:** Defensa reactiva (ej: escudos que queman y devuelven el daño al atacante).
- **Utilidad:** Imbuir armas con furia incandescente para potenciar a los aliados (ej: Arma Lengua de Fuego).

### 💧 Agua (Sanación, Purificación y Fluidez)
El elemento dador de vida. Representa la restauración, la calma y el flujo constante.
- **Ofensivo:** Daño por impacto de agua a presión o daño por escarcha/hielo para entorpecer los músculos del enemigo.
- **Defensivo:** Escudos fluidos que absorben daño mágico.
- **Utilidad (Especialización principal):** Es el pilar absoluto de la sanación de heridas profundas (Olas de sanación, Mareas vivas) y la purga o limpieza de enfermedades, venenos y maldiciones.

### 🌪️ Aire (Velocidad, Relámpagos y Utilidad Volátil)
El elemento impredecible. Representa las tormentas, la agilidad y el daño errático e inesquivable.
- **Ofensivo:** Descargas de relámpagos de altísimo daño concentrado y cadenas de rayos que saltan entre múltiples objetivos.
- **Defensivo:** Evitar daño por completo mediante la esquiva, desviar proyectiles con ráfagas de viento.
- **Utilidad (Especialización principal junto al daño):** Extraordinaria movilidad (Ráfagas de viento para reposicionarse, Forma de lobo fantasmal), celeridad para el grupo y encantamientos que otorgan ataques extra (ej: Arma Viento Furioso).

---

## 2. Flujo de Trabajo para Crear Nuevos Hechizos

Cuando se requiera crear una familia de hechizos elementales, se seguirá este orden:
1. **Adaptación de World of Warcraft:** Priorizar los hechizos icónicos de la clase Chamán de WoW (*Choque de Tierra, Cadena de Relámpagos, Ola de Sanación, Maleficio*).
2. **Adaptación de D&D o Pathfinder:** Si el concepto no está en WoW, adaptar de Druidas o Hechiceros Elementales asegurándose de re-tematizarlos para que parezcan sacados de Azeroth.
3. **Invención Original:** Crear el hechizo respetando estrictamente el rol del elemento descrito arriba y el balance mecánico del sistema.

---

## 3. Lógica del Sistema de Escalado Mecánico

Los hechizos elementales también deben respetar la estructura de crecimiento. Partiendo de un **Truco**, deben escalar a versiones **Rápida**, **Básica** y **Potente**.

### Límites Mecánicos Generales:

| Categoría | Recurso (Maná/Espíritu) | Poder Base | Acciones | Ataque Oportunidad | Canalizable | Turnos | Enfriamiento | Ranuras |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Trucos** | 0 | 1d4 | 1 | Falso | Falso | 1 | 1 | 1 |
| **Rápidos** | 2 - 4 | 1d6 | 1 | Falso | Falso | 1 - 2 | 2 - 3 | 1 - 2 |
| **Básicos** | 5 - 7 | 1d8 | 2 | Verdadero | Verdadero | 3 - 4 | 4 - 6 | 1 - 3 |
| **Potentes** | 8+ | 1d10 | 3 | Verdadero | Verdadero | 5+ | 6+ | 3 - 5 |

**IMPORTANTE (Regla extraída de ensayo.md):** 
- El tiempo de *Enfriamiento* de un hechizo debe ser siempre **mayor** a los *Turnos* que dura el efecto activo del mismo. 
- Cualquier desviación de poder (más daño del esperado o mucho menor coste de maná) debe ser compensado encareciendo su coste en **Ranuras** de aprendizaje.
