# Contexto Explicativo de Datos

Este documento recoge la información y notas importantes (comentarios) extraídos de los archivos originales `.yml` para dar contexto a las reglas y a los datos exportados en los archivos `.json`.

## 1. Categorías y Niveles

*   **Categoría Novato:** Pensada para personajes que empiezan su aventura desde lo más bajo, sin ningún atributo inicial a repartir.
*   **Categoría Normal:** Base para todo personaje aventurero estándar. Cuando un personaje de esta categoría alcanza el Nivel 10, puede decidir ascender a la categoría **Élite**. Este paso conlleva un reinicio de vida y atributos; sin embargo, las siguientes subidas de nivel otorgan más puntos de vida y atributos. Los hechizos, habilidades y objetos no se pierden (salvo decisión expresa del jugador).
*   **Categoría Élite:** Planteada para personajes que ya tienen una trayectoria de vida y no son simples aventureros noveles.
*   **Categoría Jefe:** Reservada para personajes cuyo nivel de poder es muy alto y no tendría sentido que empezaran en niveles inferiores.
*   **Nivel Máximo:** El nivel 10 es el nivel máximo permitido para cualquier categoría (la experiencia requerida para subir de nivel es nula o no aplica).

## 2. Razas
*   **Mestizos:** Los personajes pueden ser mestizos, por lo que se debe indicar las dos razas entre parentesis. Ejemplos: `Mestizo (Humano y Quel'dorei)`. Se eligirá caracteristicas de cada raza hasta tener un +3 de ventajas raciales o un -3 de desventajas raciales (máximo de +3 en ventajas entre todas las opciones. Igual en desventajas). Las características especiales se heredan todas.
*   **Adaptabilidad (Humano):** Mejora el talento más bajo que tengas antes de aplicar el resto de ventajas y desventajas.
*   **Perfeccionamiento (Gnomo):** Mejora el talento más alto que tengas antes de aplicar el resto de ventajas y desventajas.
*   **Visión Nocturna (Kaldorei):** No recibe penalización por Oscuridad. Esto no se aplica a penalizadores por reducida visibilidad (como niebla o humo).
*   **Audición Superior (Kaldorei, Quel'dorei, Sin'dorei, etc.):** Duplica el rango de percepción auditiva. Tiene ventaja en las tiradas de percepción auditiva. Los sonidos fuertes cercanos aturden durante algunos turnos.
*   **Superfuerza (Orco, Tauren, Vrykul, Huargen Lobo):** Aumenta el daño de las armas finas, armas a 1 mano y armas a 2 manos en +2. Los golpes acertados o los defendidos con Defensa Robusta (DR) provocan posibilidad de Derribo frente a los que no tengan Superfuerza. No puede quedar agarrado por alguien que no tenga Superfuerza. Pueden portar objetos muy pesados con ventaja.
*   **Reemplazo de Miembros (No-muerto):** Permite reemplazar miembros del cuerpo tras haberlos perdido.
*   **Regeneración (Troll):** Puede recuperar puntos de vida en un tiempo determinado o al final de cada ronda.
*   **Maldición Huargen:** Los huargens no son considerados una raza sino una condición especial de una raza. El personaje se aplica las ventajas y desventajas de su raza base y, si sufre la maldición, añade en adición las ventajas y desventajas de la forma humana o lobo.
*   **Gran Movilidad (Huargen en forma de lobo):** A 4 patas pueden moverse el doble de metros que otras razas.

## 3. Atributos y Talentos

### Atributos Principales y Recursos
*   **Constitución:** Los puntos en Constitución aumentan la Salud (vida del personaje). Cada punto aumenta la Salud en 1.
*   **Inteligencia:** Los puntos en Inteligencia aumentan el Maná (recurso utilizado por los hechizos de Arcano, Vil, Naturaleza, Sombras y Nigromancia). Cada punto aumenta el Maná en 1.
*   **Voluntad:** Los puntos en Voluntad aumentan el Espíritu (recurso utilizado por los hechizos de Fe, Elemental y Chi). Cada punto aumenta el Espíritu en 1.

### Destreza
*   **Precisión:** Destreza en el uso de armas a distancia ligeras y lanzar objetos ligeros o armas arrojadizas (dagas, hachas de mano).
*   **Combate Ágil:** Destreza en el uso de armas rápidas y ligeras (estoques, espadas cortas, dagas).
*   **Acrobacias:** Capacidad de realizar maniobras acrobáticas (volteretas, mantener equilibrio).
*   **Sigilo:** Capacidad de moverse sin ser detectado. Algunos ataques sin armas se benefician de este talento.
*   **Juego de Manos:** Destreza para robar, usar ganzúas/trucos, desarmar a tu oponente o evitar ser desarmado.
*   **Defensa Ágil:** Capacidad de evitar ataques esquivando o desviando.

### Fuerza
*   **Combate a 2 Manos:** Uso de armas grandes y pesadas (espadas a dos manos, mazas, hachas de guerra).
*   **Combate a 1 Mano:** Uso de armas ligeras y rápidas (espadas, hachas, mazas de una mano) así como escudos.
*   **Atletismo:** Capacidad para realizar actividades físicas como correr, saltar o nadar.
*   **Brutalidad:** Capacidad de realizar acciones brutales (romper puertas, destruir objetos, volcar/levantar/mover pesos grandes). Los ataques desarmados y lanzar armas de 1/2 manos se benefician de esto. Útil para forcejear o robar armas.
*   **Defensa Robusta:** Capacidad de defenderse bloqueando ataques con escudo o parando ataques.

### Inteligencia (Conocimientos Mágicos)
*   **Arcano, Vil, Naturaleza, Sombras, Nigromancia:** Conocimiento sobre los distintos tipos de magia y sus respectivos usos.

### Voluntad
*   **Resistencia Mágica:** Aumenta la capacidad de resistir daño mágico. Cada 1 punto reduce en 1 el daño recibido (mínimo 1 de daño). No tiene efecto si el daño es mitigado por armadura. Puntos negativos implican recibir daño extra.
*   **Resistencia a la Pérdida de Control:** Capacidad de resistir efectos que alteren el control del personaje.
*   **Fe:** Capacidad de contactar con la Luz o Elune y que ésta responda. Habilita hechizos de la Luz o de Elune.
*   **Conexión Elemental:** Capacidad de contactar con los elementos para que respondan y usar sus poderes.
*   **Chi:** Capacidad de usar el espíritu interior y beneficiarse de los elementos para potenciar capacidades físicas.
*   **Regeneración de Maná:** Aumenta la regeneración de maná por turnos.

### Constitución (Resistencias)
*   **Resiliencia:** Resistencia a venenos y enfermedades naturales. Un -5 hace al personaje débil ante esto.
*   **Resistencia a Aturdimientos:** Resiste efectos que aturden. Un +5 anula aturdimientos de 1 turno y reduce a la mitad el resto. Un -5 hace al personaje débil.
*   **Resistencia a Derribos:** Resiste efectos que derriban. Un +5 permite incorporarse sin gastar acción. Un -5 hace al personaje débil.
*   **Resistencia al Frío / Calor:** Resistencia al clima ambiental y hechizos relacionados. Un +3 anula daños climáticos correspondientes. Un -5 hace al personaje débil ante ese clima.
*   **Fortaleza:** Resistencia al daño directo. Cada 1 punto reduce 1 de daño (mínimo 1). No aplica si la armadura mitigó el daño. Puntos negativos implican recibir daño extra.

### Sabiduría
*   **Conexión con los animales:** Capacidad para comprender y comunicarse con la fauna de forma no mágica.
*   **Supervivencia:** Orientación, distinguir rastros, pesca, primeros auxilios, encender fuego, preparar trampas de caza.
*   **Percepción:** Obtener información usando sentidos (oído, vista, olfato, gusto).

### Carisma
*   **Persuasión:** Inducir, obligar o convencer a un NPC con razones.
*   **Diplomacia:** Construir y mantener relaciones / negociaciones con tacto y respeto mutuo.
*   **Comercio:** Obtener mejores resultados en compras, ventas o intercambios.
*   **Provocación:** Inducir a un NPC para que ataque al personaje.
*   **Seducción:** Atraer a los NPCs o enamorarlos.
*   **Interpretación:** Actuar, cantar, recitar poesía y atraer la atención.

## 4. Armaduras y Escudos
* Resistencia de armaduras según el tipo de daño (Perforante, Cortante y Contundente): 
*   **Vulnerable:** Sin reducción física. Durabilidad baja el doble.
*   **Débil:** La reducción física tiene la mitad de efecto.
*   **Normal:** Sin alteración.
*   **Resistente:** La reducción tiene la mitad de efecto adicional. (e.g. Reducción física 4 -> 6)
*   **Muy Resistente:** El daño es siempre 0 y no pierde durabilidad.
* Si llevas una armadura para la que no tienes puntos suficientes requeridos, la penalización de cada pieza se duplica.
* Los requisitos se suman por cada tipo que quieras llevar, es decir, si quieres llevar un peto de placas, necesitarás 2 Brutalidad, pero si quieres llevar el peto y unos guantes de placas, será 2 de Brutalidad del peto MÁS el 1 de Brutalidad de los guantes, por lo que, necesitarás, en total, 3 de Brutalidad.
* Los refuerzos son mejoras que se pueden añadir a cada pieza de armadura. A cada pieza se puede añadir un único recubrimiento como máximo.
* Otra forma de llevar armadura es **combinando** tipos de armadura para una misma pieza (cabeza, pecho, piernas, etc), ganando así la bonificación de ambos tipos. Sin embargo, hay una limitación de que, si llevas dos tipos de armadura para una misma pieza, estas armaduras no podrán tener recubrimiento. Y el límite de piezas combinables es de 2. Se aplicarán ciertas desventajas por combinar piezas.
* Las Placas y las Mallas no se pueden combinar entre sí.  No puedes combinar dos piezas del mismo tipo.
| Tipo | Tela | Cuero | Malla | Placa |
|---|---|---|---|---|
| **Tela** | No permitido | Sin penalización | Sin penalización | Sin penalización |
| **Cuero** | Sin penalización | No permitido | Duplica efectos negativos | Duplica efectos negativos |
| **Malla** | Sin penalización | Duplica efectos negativos | No permitido | Duplica efectos negativos y requerimientos |
| **Placa** | Sin penalización | Duplica efectos negativos | Duplica efectos negativos y requerimientos | No permitido |

