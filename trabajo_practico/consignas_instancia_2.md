# Trabajo Práctico de Ciencia de Datos

## Segunda entrega: Métodos estadísticos y cuantitativos

**Fecha límite de entrega: lunes 26/10 hasta las 23:59 hs.**

### Objetivo

El objetivo de esta segunda entrega es **profundizar el análisis** iniciado en la primera instancia, incorporando herramientas de inferencia estadística y de análisis cuantitativo vistas en el curso.

Esta segunda etapa busca que los grupos:

* retomen el trabajo de la primera entrega e incorporen la devolución del docente;
* definan cómo tratar los valores faltantes y los valores atípicos (outliers) de su base y justifiquen esas decisiones;
* apliquen al menos un método de inferencia estadística;
* apliquen al menos un método de análisis cuantitativo;
* expliquen qué hicieron, por qué lo hicieron y qué significan los resultados obtenidos.

La entrega es **incremental**: no se trata de un trabajo nuevo, sino de la continuación del anterior. Los métodos elegidos deben estar vinculados con la hipótesis de trabajo y con las preguntas que surgieron en la primera entrega.

---

## 1. Retomar la primera entrega

Incluir una breve síntesis (1 o 2 diapositivas) de lo presentado en la primera instancia:

* **base de datos** utilizada y unidad de observación;
* **hipótesis de trabajo** y/o preguntas que guían el análisis;
* **principales hallazgos** de la exploración.

Además, indicar **qué cambios realizaron a partir de la devolución del docente**. Por ejemplo: correcciones en la descripción de variables, cambios en la hipótesis, nuevos filtros aplicados a la base, gráficos rehechos, etc.

Si alguna observación de la devolución no fue incorporada, explicar brevemente por qué.

---

## 2. Tratamiento de valores faltantes y outliers

### 2.1. Valores faltantes

Indicar **qué van a hacer con los valores faltantes (missing)** de las variables que utilizan en el análisis y **justificar la decisión**.

Se deberá presentar:

* **cuántos valores faltantes** tiene cada variable relevante (pueden retomar la tabla de la primera entrega);
* **dónde se concentran** los faltantes (en ciertos años, países, provincias, categorías, etc.), si corresponde;
* **qué estrategia adoptan** y **por qué**.

Algunas de las alternativas posibles:

| Estrategia | ¿Cuándo puede tener sentido? |
| --- | --- |
| Eliminar observaciones con faltantes | Cuando son pocos y no se concentran en un grupo en particular |
| Eliminar una variable | Cuando la proporción de faltantes es muy alta y no es central para el análisis |
| Imputar con media / mediana (general o por grupo) | Cuando son pocos y la variable no tiene una estructura temporal |
| Interpolación (lineal u otra) | **Series de tiempo**: cuando faltan valores intermedios de una serie y es razonable suponer una evolución gradual entre los datos disponibles |
| Utilizar el valor completo más cercano en el tiempo | Cuando la variable mantiene cierta estabilidad a lo largo del tiempo (por ejemplo, estructuras productivas o demográficas que cambian lentamente) y el dato disponible está a una distancia temporal corta |
| Restringir el período o la muestra | Cuando los faltantes se concentran en un tramo de la serie o en un subconjunto de unidades |
| Mantener los faltantes | Cuando el método utilizado los admite o cuando el faltante en sí mismo es informativo |

**No hay una única respuesta correcta.** Lo que se evaluará es que la decisión sea coherente con los datos y con el análisis que realizan, y que expliquen **qué consecuencias podría tener** sobre los resultados (por ejemplo, perder representatividad de ciertos grupos, subestimar la dispersión, suavizar artificialmente una serie, etc.).

Si trabajan con una **serie de tiempo**, pueden aplicar una **interpolación** para completar los valores faltantes si lo consideran la mejor alternativa. En ese caso, indicar qué tipo de interpolación usaron y en qué períodos/unidades se aplicó. No se recomienda interpolar al inicio o al final de la serie (extrapolación) ni tramos muy largos sin datos.

Si optan por **utilizar el valor completo más cercano en el tiempo**, deberán justificar por qué consideran que la variable es relativamente estable a lo largo del tiempo y aclarar **qué consideraron como una distancia corta** (por ejemplo, hasta uno o dos años de diferencia) y **por qué**. Indicar también para qué unidades y períodos se aplicó.

### 2.2. Detección y tratamiento de outliers

Identificar si las variables relevantes para el análisis presentan **valores atípicos (outliers)** e indicar **qué van a hacer con ellos**, justificando la decisión.

Se deberá presentar:

* **qué criterio utilizaron para detectarlos** (por ejemplo, rango intercuartílico / boxplot, z-score, percentiles extremos, inspección gráfica) y por qué ese criterio es adecuado para la distribución de la variable;
* **cuántos y cuáles** son los outliers detectados (qué unidades, años o categorías);
* **si se trata de errores o de valores genuinos**: un valor extremo puede ser un error de carga o de unidad de medida, o bien reflejar una característica real del fenómeno (por ejemplo, un país muy grande, una provincia petrolera, un año de crisis);
* **qué estrategia adoptan** y **por qué**.

Algunas de las alternativas posibles:

| Estrategia | ¿Cuándo puede tener sentido? |
| --- | --- |
| Corregir el valor | Cuando se trata de un error identificable (de carga, de unidad, de escala) |
| Eliminar la observación | Cuando es un error que no puede corregirse o una unidad que no corresponde a la población estudiada |
| Mantenerlo | Cuando es un valor genuino que forma parte del fenómeno que se quiere analizar |
| Transformar la variable (logaritmo, raíz, etc.) | Cuando la distribución es muy asimétrica y los valores extremos son genuinos |
| Acotar los valores extremos (winsorizar) | Cuando se quiere reducir la influencia de los extremos sin perder observaciones |
| Analizar con y sin outliers | Cuando los resultados pueden ser muy sensibles a pocas observaciones |

Tener en cuenta que varios de los métodos de las secciones 3 y 4 (ANOVA, regresión, clustering, PCA, índices compuestos) son **sensibles a los valores extremos**, por lo que la decisión que tomen puede modificar los resultados. Indicar qué consecuencias podría tener la estrategia elegida.

---

## 3. Método de inferencia estadística

Aplicar **al menos un método de inferencia estadística** vinculado con la hipótesis o las preguntas del trabajo. Por ejemplo:

* **Test Chi Cuadrado** de independencia entre dos variables categóricas;
* **ANOVA** (o su alternativa no paramétrica, Kruskal-Wallis) para comparar medias entre tres o más grupos;
* **Regresión lineal**, para quienes quieran avanzar en esa dirección.

Para el método elegido se deberá presentar:

1. **Pregunta que se busca responder** y por qué el método elegido es adecuado para responderla (según el tipo de variables involucradas).
2. **Hipótesis nula y alternativa**, explicitadas en términos del problema (no solo en notación).
3. **Verificación de supuestos** (normalidad, homogeneidad de varianzas, frecuencias esperadas mínimas, independencia, etc., según corresponda). Si algún supuesto no se cumple, indicar qué hicieron al respecto (transformación de variables, test alternativo, agrupación de categorías, etc.).
4. **Resultados**: estadístico, grados de libertad (si corresponde) y p-valor. Cuando corresponda, incluir también una medida del tamaño del efecto (por ejemplo, V de Cramér o eta cuadrado) o las comparaciones posteriores (post-hoc).
5. **Interpretación** de los resultados en el contexto del problema: ¿qué nos dice sobre la hipótesis de trabajo?
6. **Limitaciones** o posibles problemas del análisis.

Recuerden que **rechazar la hipótesis nula no implica causalidad**, y que una diferencia estadísticamente significativa no necesariamente es relevante en términos económicos.

---

## 4. Método de análisis cuantitativo

Aplicar **al menos un método de análisis cuantitativo** de los vistos en el curso (u otro similar, consultándolo previamente con el docente). Por ejemplo:

* **índices** vistos en clase: concentración (HHI, CR4), ventajas comparativas reveladas, desigualdad (Gini, Theil), indexaciones a un año base;
* **índice compuesto**, construido a partir de varias variables (indicando normalización, ponderación y agregación);
* **clustering** (k-means o jerárquico);
* **análisis de componentes principales (PCA)** o análisis de correspondencias múltiples (MCA);
* **descomposición de la varianza** (por ejemplo, entre grupos y dentro de grupos, o descomposición del índice de Theil).

Para el método elegido se deberá presentar:

1. **Justificación**: por qué eligieron este método y qué aporta a la hipótesis o a las preguntas del trabajo.
2. **Decisiones metodológicas** tomadas. Por ejemplo: qué variables se incluyeron, si fueron estandarizadas, qué ponderadores se utilizaron, cómo se eligió la cantidad de clusters o de componentes, qué año base se tomó, etc.
3. **Resultados**, presentados mediante tablas y/o gráficos adecuados.
4. **Interpretación** de los resultados: ¿qué significan los valores obtenidos? ¿qué caracteriza a cada grupo o componente? ¿qué unidades se destacan?
5. **Limitaciones** o posibles problemas del método aplicado (sensibilidad a la escala, a los ponderadores, a los outliers, a la cantidad de grupos elegida, etc.).

---

## 5. Síntesis y próximos pasos

Cerrar la presentación con una diapositiva que integre lo realizado:

* ¿Qué aportan los resultados obtenidos a la hipótesis de trabajo? ¿La apoyan, la matizan o la contradicen?
* ¿Cómo se relacionan entre sí los resultados de ambos métodos?
* ¿Qué nuevas preguntas surgieron y qué piensan incorporar en las siguientes entregas?

Los resultados de esta entrega **no son definitivos**. Para la entrega final podrán incorporar filtros, descartar observaciones, cambiar decisiones sobre los faltantes o sumar otros métodos, por lo que los resultados podrán cambiar.

---

## 6. Formato de entrega

La entrega deberá realizarse **exclusivamente en formato PDF**, para garantizar que la presentación se vea tal como la armaron (sin cambios de formato por diferencias entre programas).

**En esta instancia no es necesario entregar los códigos.** Se evalúa únicamente la presentación. De todas maneras, se recomienda ir ordenando los scripts según la estructura de repositorio solicitada para la entrega final.

**Extensión sugerida: 10 a 15 diapositivas** (sin contar carátula y cierre). Pueden agregar un anexo con tablas o gráficos complementarios.

La presentación debe permitir seguir el análisis desde:

> **¿De dónde venimos? → ¿Qué hicimos con los faltantes y los outliers? → ¿Qué método aplicamos y por qué? → ¿Qué encontramos? → ¿Qué significa para nuestra hipótesis?**

### Envío

* **Enviar a:** nsidicaro.fce@gmail.com
* **Asunto:** `curso_2c_2026_grupo_XX_instancia_2` (reemplazando `XX` por el número de grupo, por ejemplo `curso_2c_2026_grupo_04_instancia_2`)
* **Archivo adjunto:** la presentación en PDF.
* **Fecha límite:** lunes 26/10, hasta las 23:59 hs.

Un solo integrante del grupo debe realizar el envío, con el resto de los integrantes en copia.

---

## Evaluación

La **única entrega a evaluar será la presentación en PDF**. Esta instancia representa el **20% de la nota final**.

Se tendrán en cuenta:

* **Continuidad con la primera entrega:** incorporación de la devolución del docente y coherencia con la hipótesis planteada.
* **Tratamiento de faltantes y outliers:** diagnóstico, criterio de detección, decisión adoptada y justificación.
* **Método de inferencia estadística:** elección adecuada, planteo de hipótesis, verificación de supuestos y correcta lectura de los resultados.
* **Método de análisis cuantitativo:** elección adecuada, decisiones metodológicas explicitadas y correcta lectura de los resultados.
* **Interpretación:** capacidad para explicar qué se hizo, por qué y qué significan los resultados en el contexto del problema.
* **Limitaciones:** identificación de los posibles problemas de los métodos aplicados.
* **Presentación:** claridad, orden, legibilidad y existencia de un hilo conductor entre las diapositivas.

Recuerden que el trabajo **no tiene carácter causal**. Los métodos aplicados permiten describir, comparar y agrupar, pero no explicar las causas del fenómeno estudiado.
