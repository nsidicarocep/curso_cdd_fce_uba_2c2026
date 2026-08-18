# Trabajo Práctico Integrador

## Ciencia de Datos para Economía y Negocios — FCE-UBA

La evaluación de la materia consiste en un **Trabajo Práctico grupal** que se desarrolla a lo largo del cuatrimestre. El trabajo tiene tres instancias intermedias de validación y una entrega final.

Los estudiantes eligen una base de datos de un [listado de 20 fuentes disponibles](https://docs.google.com/spreadsheets/d/1vlUwVtV9uuOB-9Sxx9zMwfloQc3jgI1N1ZVSjjOtKXs/edit?gid=0#gid=0), qque incluye datos de INDEC, BACI-CEPII, Banco Mundial, BA Data, entre otros.
Si ninguna de las fuentes posibles convence a los integrantes del grupo, podrán presentar una alternativa en las primeras 2 semanas del curso (hasta el 1ro de septiembre) para que los docentes confirmen si cumple con los requisitos de la materia. Esto puede ocurrir, por ejemplo, si los alumnos están más interesados en realizar un análisis de mercado de algo en particular. De todas maneras, se recomienda hacer uso de las bases propuestas por el equipo docente, ya que en la práctica profesional deberán tener plasticidad para hablar de muchos temas. 

Entre el 29/08 y el 01/09 deberán cargar la base de datos elegida para trabajar. De forma tal de que el profesor de el ok. Podrán elegir dos bases, de forma tal de que el docente elija con cuál podrán trabajar, en función de la cantidad de grupos que hayan elegido la misma base de datos. 

---

## Contenido esperado en la entrega final

El trabajo deberá tener como mínimo los siguientes puntos: 

- planteo de una hipótesis de trabajo. Por ejemplo, Argentina es un país relativamente más caro que el resto de la región latinoamericana y más barato que los países desarrollados. Esta hipótesis deberá ser apoyada por todo lo que se realice a lo largo del trabajo. 
- presentación de la base de datos con la que se trabaja, descripción de las variables (qué significan, qué valores puede tomar, qué tipo de variables son), dimensiones de la base de datos, periodicidad de la publicación de la base de datos 
- estadísticas descriptivas de las principales variables presentadas, junto con visualizaciones y tablas para mostrar dichas estadísticas
- métodos estadísticos más complejos aplicados (al menos uno). Puede ser ANOVA, Test Chi, regresión lineal, algún test T de diferencia de medias. Deberán corroborar los supuestos y corregirlos, en caso de que no puedan realizarse de esa manera
- herramientas de análisis económico/cuantitativo (al menos un método). Puede ser el armado de un índice compuesto, indexaciones, índices de concentración o ventajas comparativas, otros vistos en clase. 
- En total deberán usar al menos tres métodos, adicional a la presentación de las estadísticas descriptivas
- Las visualizaciones de la tercera entrega (una orientada a la comunicación y otra al análisis exploratorio)
- Conclusiones y próximos pasos
- Todo método y visualización debe ser claramente interpretado

Recuerden que el trabajo no tiene carácter causal. Es una aproximación al fenómeno que quieran estudiar desde la perspectiva del análisis de datos. Los pasos que realicen deben tener lógica y estar entrelazados para construir una historia, pero no se busca dar una explicación causal ni mucho menos. 

El **formato de entrega** es una PPT (puede ser en formato PDF o PPTX) de entre 15 y 20 diapositivas, más un anexo con todas los gráficos y tablas que consideren relevantes, pero que no se encuentran en la historia principal a contar. Adicionalmente, deberán entregar el repositorio de Github con la estructura solicitada, los datos cargados, scripts, outputs (gráficos y tablas que hayan realizado), un Readme inicial. 

--- 

# Características del grupo 

El trabajo debe realizarse en grupos de dos o tres integrantes. El grupo será el mismo durante todo el cuatrimestre, tenganlo en cuenta a la hora de elegir a sus compañeros. 
Los casos particulares deberán ser charlados presencialmente con el docente y confirmados vía mail. 
Los grupos se deberán informar el día que se envía la base de datos elegida (hasta el 01/09). 
Si algún compañero del grupo se da de baja, deberán informarlo por mail. 
Si algún compañero del grupo no participa en las entregas del trabajo, se sugiere informarlo al docente para que tome parte en la decisión. Con esto se busca que haya la menor cantidad de free-riders posibles.   

---

## Fechas importantes

| Fecha | Evento |
|---|---|
| 14/08 | Inicio de clases — Presentación del curso |
| 18/09 | **Instancia 1** — Estructura de base de datos y primeros descriptivos | 
| 27/10 | **Instancia 2** — Métodos cuantitativos |
| 13/11 | **Instancia 3** — Validación de visualizaciones |
| 24/11 | **Entrega final del TP** |
| 24/11 al 01/12 | **Presentaciones orales** |

---

## Instancias intermedias

Las tres instancias intermedias son de carácter formativo: permiten recibir devolución del docente y corregir el rumbo antes de la entrega final. Son obligatorias y forman parte de la nota final.

### Instancia 1 — Base de datos e hipótesis

En esta primera entrega se espera que cada grupo presente una PPT con:

1. **Integrantes del grupo.**
2. **Base de datos seleccionada** del listado de fuentes disponibles.
3. **Temática a desarrollar.** Por ejemplo, si eligen el PBG Provincial podrían plantearse explorar la divergencia económica entre provincias o realizar un análisis comparativo entre dos provincias con características similares.
4. **Hipótesis de trabajo.** Una conjetura sobre lo que esperan encontrar al finalizar el análisis. Esta hipótesis debe servir como guía para las etapas sucesivas del trabajo.
5. **Variables principales** que planean utilizar, indicando el tipo de cada una (numérica, categórica, temporal, etc.), qué significan esas variables (describirlas). Se deberá incorporar a su vez la dimensión de la base de datos con la que van a trabajar
6. **Bases de datos complementarias**, si consideran que pueden enriquecer el análisis.
7. **Estadísticas descriptivas**: presentar las estadísticas básicas de las variables de interés.

No se esperan gráficos en esta instancia, pero pueden presentarlos sin problema. En caso de hacerlo, luego deberán acomodarlos a las recomendaciones que se vean para gráficos en la unidad correspondiente. 


### Instancia 2 — Métodos estadísticos

La segunda entrega deberá ser incremental a la primera. Es decir, en base a lo entregado en la primera instancia, se deberán incorporar contenidos referidos a las unidades 2 y 3 (al menos un método por unidad). Por ejemplo, se podrá realizar un Test de independencia Chi Cuadrado y un análisis de clusters.

Se deberá mostrar el resultado obtenido, la justificación del método utilizado, la interpretación de los valores obtenidos y los posibles problemas que podrían tener. 

Los resultados en esta entrega no impiden que la entrega final tenga resultados distintos. Por ejemplo, para la entrega final quizás incorporan un filtro en el análisis o descartan algunas observaciones antes de implementar estos métodos, por lo que los resultados cambiarán.

### Instancia 3 — Visualizaciones

En esta tercera entrega cada grupo debe presentar **al menos dos visualizaciones de datos** que incorporen los elementos de storytelling vistos en el curso. Para cada visualización se debe indicar:

- **Qué rol cumple dentro del trabajo.** ¿Describe la relación entre dos o más variables? ¿Presenta el resultado de una herramienta estadística? ¿Apoya las conclusiones? ¿Sirve para mostrar el tratamiento de valores nulos u outliers?
- **En qué parte de la presentación final se ubicará** y cómo colabora en la construcción del argumento.

Las visualizaciones deben ser funcionales al análisis, no meramente decorativas.

---

## Entrega final + presentación oral

La entrega final consta de dos componentes:

### PPT

Un archivo en formato **PowerPoint (.pptx) o PDF** con la presentación del trabajo completo.

Además de los contenidos de la instancia 1, 2 y 3, se deberán incorporar análisis sobre las distribuciones de las principales variables (en caso de poder hacerlo), análisis de los elementos faltantes y de los outliers, el tercer método de las unidades 2 y 3 que falte (o que falten, en caso de utilizar más de tres métodos), las visualizaciones correspondientes (cumpliendo en todos los casos las buenas prácticas que se verán en la unidad 4), las conclusiones del trabajo y un anexo con gráficos y tablas, en caso de que lo consideren necesario. 

La PPT deberá tener entre 15 y 20 diapositivas (sin considerar la carátula y la diapositiva de cierre al final), sin considerar lo que vaya en el anexo. 

### Repositorio

Un repositorio en **GitHub** con los códigos, datos y resultados del trabajo. El repositorio debe respetar la siguiente estructura de carpetas:

```
proyecto/
├── raw/            # Datos originales tal como fueron descargados, sin modificar
├── auxiliar/        # Bases de datos complementarias o archivos de apoyo
├── input/           # Datos procesados y listos para el análisis
├── output/
│   ├── tablas/      # Tablas de resultados generadas por los scripts
│   └── graficos/    # Visualizaciones generadas por los scripts
├── script/          # Scripts de R, cada uno con un objetivo específico
├── utils/           # Funciones propias (un script por función)
└── README.md        # Descripción del proyecto y guía del repositorio
```

**Sobre los scripts:** cada script debe tener un objetivo específico y claro, tal como se trabajó en las primeras clases del curso. Se deben utilizar todas las carpetas de la estructura (tomar datos de raw, guardar los preprocesados en input y guardar los finales en output).

**Sobre las funciones propias:** en caso de crear funciones para automatizar tareas repetitivas, cada función debe alojarse en un script separado dentro de la carpeta `utils/`.

**Sobre el README:** debe estar escrito en formato Markdown e incluir el objetivo del trabajo, la justificación de la base de datos elegida, una descripción de lo realizado, la estructura de carpetas y cualquier instrucción necesaria para reproducir el análisis.

### Presentación oral

Los integrantes del grupo tendrán que hacer una presentación oral de la PPT en formato virtual de forma sincrónica. Todos los integrantes del grupo deben participar sin excepción. En caso de no poder ese día, se puede reprogramar para la siguiente clase. 

Los días de las presentaciones serán compartidos una semana antes, para que los estudiantes puedan tener una suficiente cantidad de días para preparar la presentación oral. 

Por tal motivo, se recomienda mucho que realicen avances a conciencia antes de las últimas semanas, ya que la parte final de la materia -pese a no tener mucho contenido teórico nuevo- sí tiene la entrega de la tercera instancia, la entrega final y la presentación oral. 

---

## Composición de la nota

| Componente | Peso |
|---|---|
| Instancia 1 | 10% |
| Instancia 2 | 20% |
| Instancia 3 | 10% |
| Entrega final | 60% |

Se considerará como parte de la entrega final la presentación oral que realicen. 

---

## Reglas generales

- **Todas las entregas son obligatorias** y deben estar aprobadas para aprobar la materia.
- En caso de obtener una calificación no aprobada en una entrega intermedia, se podrá recuperar **una sola** de las tres instancias en las fechas de recuperatorio.
- Todas las entregas recibirán **devolución del docente** en los días siguientes a su envío.
- La entrega final tendrá su devolución en formato de **grilla de evaluación**, detallando cada punto de interés y si se evidenció un proceso de mejora entre las entregas intermedias y el resultado final. En las últimas semanas se compartirán los puntos a evaluar en la grilla para que puedan utilizarla de checklist para ver si algo puede modificarse para mejorar la nota. 
- El uso de herramientas de IA está permitido, tanto para el armado de los scripts como para las interpretaciones de los resultados. Limitar su uso en el armado de la PPT. El uso responsable de la IA implica que deben entender qué es lo que hacen los códigos y las decisiones adoptadas, por lo que en la presentación oral se hará especial foco en estos puntos.  
