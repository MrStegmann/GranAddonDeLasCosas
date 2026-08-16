# Ensayos de Hechizos: Proyecto sistema de hechizos

## Contexto
El propósito de este documento es establecer un marco lógico y escalable para la creación y clasificación de hechizos. Partiendo de los **Trucos** como la unidad mágica más elemental, cada hechizo puede evolucionar a través de tres niveles de progresión: **Rápido**, **Básico** y **Potente**. 

Aunque cada nivel se considera un hechizo independiente con sus propios costes y utilidades tácticas, todos mantienen una cohesión temática y mecánica con su Truco base. Este diseño busca garantizar un balance sólido en la escalada de poder y servir como plantilla estandarizada para seguir poblando el *Gran Grimorio de las Cosas*.

## Escuelas de magia Arcana
- **Conjuración:**
- **Abjuración:**
- **Adivinación:**
- **Ilusión:**
- **Encantamiento:**
- **Transmutación:**

## Categorías de Poder de los Hechizos
Cada hechizo debe pertenecer a una de las siguientes categorías, lo que dictará sus límites mecánicos:

| Categoría | Recurso | Poder | Acciones | Ataque Oportunidad | Canalizable | Turnos | Enfriamiento | Ranuras | Dificultad |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Trucos** | 0 | 4 | 1 | Falso | Falso | 1 | 1 | 1 | 0 |
| **Rápidos** | 2 - 4 | 6 | 1 | Falso | Falso | 1 - 2 | 2 - 3 | 1 - 2 | 10 |
| **Básicos** | 5 - 7 | 8 | 2 | Verdadero | Verdadero | 3 - 4 | 4 - 6 | 1 - 3 | 12 |
| **Potentes** | 8+ | 10 | 3 | Verdadero | Verdadero | 5+ | 6+ | 3 - 5 | 15 |

- **Recurso:** Indica el gasto de maná o espíritu necesario para lanzar el hechizo.

- **Poder:** 
  Indica el número de caras del dado de daño o efecto del hechizo (1d4, 1d6, 1d8, 1d10).

- **Acciones:** 
  Las acciones necesarias para poder usar el hechizo.
  Si las acciones necesarias son 3 (2 máximo por turno), significa que, en tu siguiente turno, tienes 1 acción menos a usar. Estos hechizos se lanzan al comienzo de tu siguiente turno. Si te atacan antes del siguiente turno, el hechizo queda interrumpido. Al no completarlo, no sufres gasto de recurso ni el hechizo entra en CD.

- **A.O.:** 
  Indica si el hechizo puede ser objeto de un Ataque de Oportunidad.

- **Canalizable:** 
  Los hechizos que pueden ser canalizables se mantienen en los turnos sin tener que volver a lanzar un dado de acierto sino que lanzarás únicamente el dado de poder en cada turno.
  Cada vez que lances el dado de poder, pierdes recurso
  Si recibes un ataque, pierdes el canalizado.
  Si te mueves, rompes el canalizado.

- **Turnos:** 
  Indica cuántos turnos dura un efecto mágico, si lo tuviera. Si es crítico, durará el doble.

- **Enfriamiento:** 
  Indica la cantidad de turnos que debe pasar para poder volver a usar el hechizo. Siempre debe ser mayor que los Turnos de duración.

- **Ranuras:**
  Las ranuras es el coste de aprendizaje que tiene el hechizo.

- **Dificultad:** 
  Es la dificultad a superar al lanzar el hechizo sin oposición. Para hechizos de sanación, escudos o de efecto.


## Aplicación de ranuras: Reglas
El coste en **ranuras de hechizo** actúa como el mecanismo principal de balance cuando las estadísticas de un hechizo se desvían de los valores estándar de su categoría. La cantidad de ranuras que ocupa se calcula modificando la base según las siguientes variaciones:

- **Potencia y Nivel:** Si el hechizo escala a una categoría superior siendo más potente (aumentando daño o efecto base), el coste requiere **+1 Ranura**.
- **Duración del Efecto (Turnos):** 
  - Por cada turno extra de duración por encima de la media: **+1 Ranura**.
  - Por cada turno de duración por debajo de la media: **-1 Ranura**.
- **Enfriamiento:**
  - Si el hechizo tiene menor tiempo de enfriamiento (es más repicable): **+1 Ranura** por cada turno que se reduzca.
  - Si el hechizo tiene mayor tiempo de enfriamiento (tarda más en volver a usarse): **-1 Ranura** por cada turno extra de espera.
- **Consumo de Recursos (Maná, etc.):** 
  - Por cada **2 puntos de recurso extra** que el hechizo exija respecto a la base: **-1 Ranura** (compensa su alto coste en partida).
  - Por cada **2 puntos de recurso menos** que el hechizo consuma respecto a la base: **+1 Ranura** (penaliza su gran eficiencia de recursos).

---

## 🔥 Magia de Fuego (Conjuración)
*Identidad:* Los hechizos de fuego son instatáneos (0 turnos de duración). Al no permanecer en el tiempo, ahorran una enorme cantidad de ranuras que emplean para reducir drásticamente su coste de maná y su tiempo de enfriamiento, convirtiéndose en el elemento más rápido y letal del arsenal.

### Explosión de fuego
*Truco | 1 Ranura(s) | 0 Maná | 1 Acción(es)*
- **Tipo:** Conjuración
- **Narrativa:** Una diminuta brasa que conjuras entre tus dedos y lanzas como un chasquido. Aunque su fuego se extingue rápido, el impacto inicial es suficiente para provocar quemaduras superficiales o prender fuego a elementos inflamables.
- **Descripción:** Lanzas una pequeña chispa ardiente a un objetivo cercano.
- **Efecto:** 1d4 + Arcano (Daño de Fuego)
- **Detalles:** Enfriamiento: 1 | Ataque de Oportunidad: No | Canalizable: No | Duración (Turnos): 1

### Agostar
*Rápido | 1 Ranura(s) | 3 Maná | 1 Acción(es)*
- **Tipo:** Conjuración
- **Narrativa:** La temperatura a tu alrededor aumenta bruscamente antes de que un látigo de fuego puro surja de tus manos. El impacto carboniza instantáneamente el tejido, dejando un rastro de humo y un característico olor a carne chamuscada.
- **Descripción:** Un proyectil veloz de fuego puro que impacta al instante y desaparece sin dejar rastro térmico prolongado.
- **Efecto:** 1d6 + Arcano (Daño de Fuego)
- **Extra:** Si el objetivo está Incendiado, consume un turno de Incendiado para provocar instantáneamente 1d4 de daño adicional.
- **Detalles:** Enfriamiento: 2 | Ataque de Oportunidad: No | Canalizable: No | Duración (Turnos): 0

### Bola de fuego
*Básico | 2 Ranura(s) | 4 Maná | 2 Acción(es)*
- **Tipo:** Conjuración
- **Narrativa:** Canalizas tu ira en una esfera de llamas condensadas que ilumina el entorno con un resplandor anaranjado letal. Al chocar, detona en una onda de choque calórica que reduce a cenizas cualquier material mundano cercano.
- **Descripción:** Desatas una corriente de llamas concentradas que envuelven al objetivo, disipándose de golpe tras el impacto.
- **Efecto:** 1d8 + Arcano (Daño de Fuego)
- **Extra:** Provoca el estado *Incendiado* durante 4 turnos.
- **Detalles:** Enfriamiento: 4 | Ataque de Oportunidad: Sí | Canalizable: No | Duración (Turnos): 4

### Piroexplosión
*Potente | 4 Ranura(s) | 6 Maná | 3 Acción(es)*
- **Tipo:** Conjuración
- **Narrativa:** El aire mismo comienza a arder a tu alrededor mientras acumulas una presión termodinámica insostenible. Al liberarla, el cielo ruge y un cono de destrucción absoluta engulle al enemigo, vaporizando incluso la armadura antes de desvanecerse tan rápido como surgió.
- **Descripción:** Conjuras una deflagración colosal y devastadora que empala a tu enemigo en pura destrucción térmica.
- **Efecto:** 1d10 + Arcano (Daño de Fuego)
- **Extra:** Provoca el estado *Incendiado* durante 6 turnos. Si el objetivo ya estaba *Incendiado*, consume el daño de todos los turnos restantes y lo aplica al instante.
- **Detalles:** Enfriamiento: 5 | Ataque de Oportunidad: Sí | Canalizable: No | Duración (Turnos): 6

---

## ❄️ Magia de Escarcha (Conjuración)
*Identidad:* Los hechizos de escarcha destacan por durar muchos turnos en el objetivo, entumeciendo o congelando a los enemigos. Esta extrema duración los encarece en ranuras, lo cual equilibran exigiendo altísimos tiempos de enfriamiento antes de poder usarse otra vez.

### Lanza de hielo
*Truco | 1 Ranura(s) | 0 Maná | 1 Acción(es)*
- **Tipo:** Conjuración
- **Narrativa:** La humedad del aire se condensa de golpe en una esquirla cristalina y afilada. Al golpear, su temperatura bajo cero provoca un intenso escalofrío en el objetivo, entorpeciendo sus primeros reflejos.
- **Descripción:** Disparas un fragmento de hielo que entumece al objetivo.
- **Efecto:** 1d4 + Arcano (Daño de Frío)
- **Detalles:** Enfriamiento: 1 | Ataque de Oportunidad: No | Canalizable: No | Duración (Turnos): 1

### Rayo de escarcha
*Rápido | 1 Ranura(s) | 3 Maná | 1 Acción(es)*
- **Tipo:** Conjuración
- **Narrativa:** De tus manos brota un rayo azulado de frío intenso que cristaliza instantáneamente el aire a su paso. Donde impacta, una placa de escarcha sólida se adhiere a la piel del enemigo, paralizando parcialmente sus articulaciones.
- **Descripción:** Lanzas rápidamente una afilada hoja de hielo contra el enemigo.
- **Efecto:** 1d6 + Arcano (Daño de Frío)
- **Extra:** Anula el *Rango Efectivo de Acción* del objetivo, obligándole a gastar una acción de movimiento adicional para acercarse incluso si está a menos de 10 metros.
- **Detalles:** Enfriamiento: 3 | Ataque de Oportunidad: No | Canalizable: No | Duración (Turnos): 2

### Descarga de escarcha
*Básico | 2 Ranura(s) | 6 Maná | 2 Acción(es)*
- **Tipo:** Conjuración
- **Narrativa:** Invocas los mismísimos vientos del norte, generando un proyectil denso de hielo compacto y nieve en remolino. Al impactar, el hielo no solo corta profundamente, sino que se enraíza, congelando lentamente los fluidos corporales del rival.
- **Descripción:** Un torrente de hielo y nieve golpea fuertemente a tu adversario, prolongando su agonía helada.
- **Efecto:** 1d8 + Arcano (Daño de Frío)
- **Extra:** Entumece tanto al objetivo que reduce en 1 sus Acciones totales durante su próximo turno.
- **Detalles:** Enfriamiento: 7 | Ataque de Oportunidad: Sí | Canalizable: No | Duración (Turnos): 6

### Pica glacial
*Potente | 4 Ranura(s) | 10 Maná | 3 Acción(es)*
- **Tipo:** Conjuración
- **Narrativa:** Haces descender la temperatura ambiental a niveles incompatibles con la vida mientras arrancas del propio vacío un obelisco de hielo puro. Al chocar contra el enemigo, el cero absoluto estalla, sumergiéndolo en una prisión de hielo de la que pocos logran salir.
- **Descripción:** Haces caer una gigantesca estalactita de hielo puro que aplasta a tu objetivo y lo congela severamente.
- **Efecto:** 1d10 + Arcano (Daño de Frío)
- **Extra:** Si el objetivo falla una salvación de Fortaleza (Constitución), queda *Congelado* durante 1 turno.
- **Detalles:** Enfriamiento: 8 | Ataque de Oportunidad: Sí | Canalizable: No | Duración (Turnos): 8

---

## 🔮 Magia Arcana (Conjuración)
*Identidad:* La esencia mágica pura permite ser manipulada con un consumo de energía absurdamente eficiente. Los hechizos arcanos son muy baratos en cuanto a coste de Maná, sacrificando a cambio los turnos de duración en el objetivo.

### Tromba arcana
*Truco | 1 Ranura(s) | 0 Maná | 1 Acción(es)*
- **Tipo:** Conjuración
- **Narrativa:** Canalizas energía etérea en bruto, sin refinar, y la lanzas como un latigazo. Su brillo violeta vibra en el aire, careciendo de la sutileza de otros elementos, pero resultando asombrosamente fiable.
- **Descripción:** Disparas un pequeño proyectil de energía mágica sin refinar.
- **Efecto:** 1d4 + Arcano (Daño Arcano)
- **Detalles:** Enfriamiento: 1 | Ataque de Oportunidad: No | Canalizable: No | Duración (Turnos): 1

### Misiles arcanos
*Rápido | 1 Ranura(s) | 3 Maná | 1 Acción(es)*
- **Tipo:** Conjuración
- **Narrativa:** Apenas con un gesto, formas diminutos dardos de magia persiguiendo instintivamente la esencia del enemigo. Su naturaleza efímera los hace increíblemente fáciles de invocar sin apenas sudar.
- **Descripción:** Liberas una ráfaga inmediata de energía arcana que impacta con precisión y desaparece.
- **Efecto:** 1d6 + Arcano (Daño Arcano)
- **Extra:** Dispara 3 proyectiles mágicos que pueden apuntarse a objetivos distintos. Cada proyectil hace el mismo daño.
- **Detalles:** Enfriamiento: 3 | Ataque de Oportunidad: No | Canalizable: No | Duración (Turnos): 1

### Golpe Arcano
*Básico | 2 Ranura(s) | 6 Maná | 2 Acción(es)*
- **Tipo:** Conjuración
- **Narrativa:** Concentras una masa inestable de fuerza pura que distorsiona la luz a su alrededor. Al liberarla, el golpe es ciego e implacable, empujando el aire como un ariete sin dejar secuelas duraderas.
- **Descripción:** Proyectas una ola inestable de fuerza arcana pura que arrolla al objetivo sin persistir en él.
- **Efecto:** 1d8 + Arcano (Daño Arcano)
- **Extra:** Si el próximo hechizo que lanzas es un hechizo que provoca daño arcano, este hace +1d4 de daño.
- **Detalles:** Enfriamiento: 5 | Ataque de Oportunidad: Sí | Canalizable: No | Duración (Turnos): 2

### Tempestad Arcana
*Potente | 4 Ranura(s) | 8 Maná | 3 Acción(es)*
- **Tipo:** Conjuración
- **Narrativa:** Rasgas el velo de la realidad momentáneamente, inundando el campo de batalla con torrentes caóticos de polvo de estrellas. La tormenta es de una intensidad abrumadora, capaz de desgarrar el alma misma, todo con una fracción del esfuerzo de otras disciplinas.
- **Descripción:** Acumulas poder mágico para liberar un rayo devastador de energía cósmica de corta pero letal duración.
- **Efecto:** 1d10 + Arcano (Daño Arcano)
- **Extra:** Interrumpe cualquier canalización enemiga y aplica el estado *Silenciado* durante 3 turno a todos los afectados.
- **Detalles:** Enfriamiento: 6 | Ataque de Oportunidad: Sí | Canalizable: No | Duración (Turnos): 3

---

## 🛡️ Magia de Fuego (Abjuración)
*Identidad:* Las barreras de fuego son instatáneas (0 turnos de duración) pero extremadamente veloces, diseñadas como reflejos para bloquear e incinerar de golpe un ataque inminente y desaparecer, ahorrando muchas ranuras para su bajo enfriamiento y coste.

### Resguardo de fuego
*Truco | 1 Ranura(s) | 0 Maná | 1 Acción(es)*
- **Tipo:** Abjuración
- **Narrativa:** Una capa invisible de calor intenso rodea tu piel por un brevísimo instante. Es apenas un parpadeo rojizo, pero suficiente para desviar o derretir proyectiles mundanos y causar quemaduras a quien intente agarrarte.
- **Descripción:** Envuelves fugazmente tu cuerpo en una brasa protectora.
- **Efecto:** 1d4 + Arcano (Escudo)
- **Extra:** El escudo otorga inmunidad al daño de fuego contra el primer ataque recibido durante este turno.
- **Detalles:** Enfriamiento: 1 | Ataque de Oportunidad: No | Canalizable: No | Duración (Turnos): 1

### Armadura de Arrabio
*Rápido | 1 Ranura(s) | 3 Maná | 1 Acción(es)*
- **Tipo:** Abjuración
- **Narrativa:** Un muro de llamas surge repentinamente desde el suelo bloqueando el impacto antes de extinguirse sin dejar rastro. Su intensidad es tan abrumadora que puede calcinar las armas de los atacantes cuerpo a cuerpo.
- **Descripción:** El escudo protege del daño de fuego (mitigando la mitad) y devuelve automáticamente 1d4 de daño de fuego a cualquier atacante que te golpee cuerpo a cuerpo.
- **Efecto:** 1d6 + Arcano (Escudo)
- **Detalles:** Enfriamiento: 3 | Ataque de Oportunidad: No | Canalizable: No | Duración (Turnos): 2

### Barrera de llamas
*Básico | 2 Ranura(s) | 4 Maná | 2 Acción(es)*
- **Tipo:** Abjuración
- **Narrativa:** Levantas una gruesa muralla de fuego rugiente frente a ti. Su calor deforma el aire y ciega a los enemigos momentáneamente, absorbiendo ataques mortales en su interior como si el propio fuego devorase el daño.
- **Descripción:** Mientras la barrera esté activa, inflige 1d4 de daño de fuego al final de tu turno a todos los enemigos que estén pegados a ti (a 1 o 2 metros de distancia).
- **Efecto:** 1d8 + Arcano (Escudo)
- **Detalles:** Enfriamiento: 5 | Ataque de Oportunidad: Sí | Canalizable: No | Duración (Turnos): 4

### Muro de llamas
*Potente | 4 Ranura(s) | 6 Maná | 3 Acción(es)*
- **Tipo:** Abjuración
- **Narrativa:** Invocas la máxima protección del fuego primordial, convirtiendo el espacio a tu alrededor en una erupción termonuclear controlada. Durante una fracción de segundo, nada puede penetrar la corona solar que te envuelve.
- **Descripción:** Mientras el muro esté activo, anula por completo todo el daño físico y de fuego entrante.
- **Efecto:** 1d10 + Arcano (Escudo)
- **Detalles:** Enfriamiento: 8 | Ataque de Oportunidad: Sí | Canalizable: No | Duración (Turnos): 5

---

## 🛡️ Magia de Escarcha (Abjuración)
*Identidad:* Las armaduras de hielo son de extrema persistencia, adhiriéndose a tu cuerpo o al entorno durante muchísimos turnos. Su principal debilidad y mecanismo de balance es que requieren un altísimo tiempo de enfriamiento para volver a tejerse.

### Resguardo de escarcha
*Truco | 1 Ranura(s) | 0 Maná | 1 Acción(es)*
- **Tipo:** Abjuración
- **Narrativa:** Tu aliento se cristaliza mientras una fina capa de hielo azulado cubre tus ropajes. Es frágil, pero otorga un pequeño margen de protección contra cortes superficiales, enfriando además el filo de tu atacante.
- **Descripción:** El escudo otorga inmunidad al daño de frío/escarcha contra el primer ataque recibido durante este turno.
- **Efecto:** 1d4 + Arcano (Escudo)
- **Detalles:** Enfriamiento: 1 | Ataque de Oportunidad: No | Canalizable: No | Duración (Turnos): 1

### Armadura de escarcha
*Rápido | 1 Ranura(s) | 3 Maná | 1 Acción(es)*
- **Tipo:** Abjuración
- **Narrativa:** El hielo grueso se forma a través de todo tu cuerpo, endureciéndose como si llevaras una cota de placas cristalina. Al caminar dejas un rastro escarchado, sintiéndote casi inexpugnable ante los golpes físicos.
- **Descripción:** El escudo protege del daño de frío y aplica un estado de enfriamiento que evita que el objetivo pueda realizar ataques de oportunidad.
- **Efecto:** 1d6 + Arcano (Escudo)
- **Detalles:** Enfriamiento: 3 | Ataque de Oportunidad: No | Canalizable: No | Duración (Turnos): 2

### Barrera de hielo
*Básico | 2 Ranura(s) | 6 Maná | 2 Acción(es)*
- **Tipo:** Abjuración
- **Narrativa:** Haces emerger gruesos pilares de hielo inquebrantable a tu alrededor, formando una cúpula resistente a asedios. Quien golpee esta barrera verá sus armas y sus manos cubiertas por dolorosos cristales de escarcha.
- **Descripción:** Creas una barrera de hielo que protege de daño físico y daño de frío. Produce un efecto de enfriamiento a los objetivos que te golpean evitando que pueda realizar ataques de oportunidad.
- **Efecto:** 1d8 + Arcano (Escudo)
- **Detalles:** Enfriamiento: 7 | Ataque de Oportunidad: Sí | Canalizable: No | Duración (Turnos): 6

### Muro de hielo
*Potente | 4 Ranura(s) | 10 Maná | 3 Acción(es)*
- **Tipo:** Abjuración
- **Narrativa:** Congelas incluso el tiempo a tu alrededor, encerrándote en un bloque de hielo opaco e indestructible. Mientras permanezcas en su interior, ninguna fuerza en este mundo puede herirte, pero la magia requerida es extenuante.
- **Descripción:** Te envuelves en un bloque impenetrable de hielo que te hace inmune a todo daño mientras dure o hasta que lo canceles. Si el daño que recibe el bloque de hielo supera el valor resultado del poder, el bloque se hace añicos y el hechizo finaliza. Tu no sufres ningun daño.
- **Efecto:** 1d10 + Arcano (Escudo)
- **Detalles:** Enfriamiento: 8 | Ataque de Oportunidad: Sí | Canalizable: No | Duración (Turnos): 5

---

## 🛡️ Magia Arcana (Abjuración)
*Identidad:* Los escudos arcanos brillan por su ridículo coste de maná, permitiendo a los magos defenderse constantemente sin agotar sus reservas. Para lograr este balance matemático, se disipan rápidamente (pocos turnos).

### Resguardo arcano
*Truco | 1 Ranura(s) | 0 Maná | 1 Acción(es)*
- **Tipo:** Abjuración
- **Narrativa:** Un destello púrpura de energía telequinética detiene repentinamente un impacto cercano. Es tan eficiente y automático que apenas notas la reducción en tu reserva mágica, siendo la defensa favorita de los aprendices.
- **Descripción:** El escudo otorga inmunidad al daño mágico/arcano contra el primer ataque recibido durante este turno.
- **Efecto:** 1d4 + Arcano (Escudo)
- **Detalles:** Enfriamiento: 1 | Ataque de Oportunidad: No | Canalizable: No | Duración (Turnos): 1

### Armadura arcana
*Rápido | 1 Ranura(s) | 2 Maná | 1 Acción(es)*
- **Tipo:** Abjuración
- **Narrativa:** Levantas la mano y un disco translúcido y brillante intercepta el daño. Resuena con un tono agudo al ser golpeado, dispersando la fuerza del impacto en sutiles destellos violáceos antes de disiparse.
- **Descripción:** El escudo protege de daño mágico y empuja mágicamente 2 metros hacia atrás a cualquier atacante que te golpee cuerpo a cuerpo derribandolo si no supera tirada de salvación.
- **Efecto:** 1d6 + Arcano (Escudo)
- **Detalles:** Enfriamiento: 3 | Ataque de Oportunidad: No | Canalizable: No | Duración (Turnos): 2

### Barrera arcana
*Básico | 2 Ranura(s) | 4 Maná | 2 Acción(es)*
- **Tipo:** Abjuración
- **Narrativa:** Te rodeas de anillos rúnicos flotantes que giran absorbiendo impactos de forma inteligente. El coste es casi irrisorio para la cantidad de daño letal que estas complejas fórmulas matemáticas pueden llegar a neutralizar.
- **Descripción:** Una barrera arcana que envuelve al objetivo protegiendolo de daño físico y mágico.
- **Efecto:** 1d8 + Arcano (Escudo)
- **Detalles:** Enfriamiento: 5 | Ataque de Oportunidad: Sí | Canalizable: No | Duración (Turnos): 4

### Cúpula arcana
*Potente | 4 Ranura(s) | 10 Maná | 3 Acción(es)*
- **Tipo:** Abjuración
- **Narrativa:** Alteras la física misma del área a tu alrededor creando una cúpula perfectamente geométrica. Dentro de este espacio, la magia y el daño pierden su significado; es un santuario absoluto mantenido por tu implacable fuerza de voluntad.
- **Descripción:** Crea un campo de fuerza alrededor tuya en un radio de 5 metros, que te protege a ti y los aliados que estén dentro de todo el daño mágico entrante y proyectiles.
- **Efecto:** 1d10 + Arcano (Escudo)
- **Detalles:** Enfriamiento: 8 | Ataque de Oportunidad: Sí | Canalizable: Si | Duración (Turnos): 6
