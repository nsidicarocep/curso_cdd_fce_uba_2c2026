# Trabajo Práctico de Ciencia de Datos

## Tercera entrega: Visualización y comunicación de resultados

**Fecha límite de entrega: jueves 12/11 hasta las 23:59 hs.**

### Objetivo

La tercera instancia de evaluación consiste en el armado de **dos imágenes en formato JPG/JPEG** (son lo mismo) **utilizando R**.

Las dos imágenes deben guardar relación con los análisis que estén realizando en el marco del Trabajo Práctico y deberán servir para **contar la historia del trabajo**. No se trata de hacer gráficos nuevos sobre temas nuevos: son los gráficos de *este* TP, los que van a usar en la entrega final y en la presentación oral.

Uno de los gráficos debe ser **exploratorio** y el otro **comunicativo**. Son dos lógicas distintas y se evalúan con criterios distintos:

| | Gráfico exploratorio | Gráfico comunicativo |
| --- | --- | --- |
| ¿Para quién es? | Para ustedes y para el equipo docente | Para alguien que no conoce el trabajo |
| ¿Qué busca? | Encontrar patrones, comparar, detectar casos raros | Transmitir **un** mensaje ya encontrado |
| Lectura | No es obvia: requiere que alguien la explique | Se entiende sola, en pocos segundos |
| Complejidad | Técnica (muchas dimensiones a la vez) | Técnica, pero **reducida** con recursos visuales |

---

## 1. El punto de partida: ¿cuál es la historia?

Antes de abrir R, escriban en una o dos oraciones **cuál es el hallazgo principal del trabajo hasta ahora**, a partir de lo que vienen haciendo en las dos primeras entregas y de las devoluciones recibidas.

Ese hallazgo es el que tiene que quedar comunicado en el segundo gráfico. El primero, el exploratorio, es el que les permite (o les permitió) llegar hasta ahí.

Si todavía no tienen un hallazgo claro, el gráfico exploratorio es justamente la herramienta para buscarlo. Pero para la entrega tienen que poder nombrarlo.

Esta oración no se entrega: es para ustedes, para no empezar a graficar sin saber qué quieren mostrar.

---

## 2. Gráfico exploratorio

Debe ser un gráfico de **relativa dificultad técnica** que sirva para analizar alguno de los fenómenos tratados en el TP.

### Cómo saber si sirve como gráfico exploratorio

Háganse esta pregunta:

> ¿Lo que muestra el gráfico lleva a una conclusión obvia, sin necesidad de estar editorializado o de tener formato comunicativo?

**Si la respuesta es afirmativa, entonces no se trata de un gráfico exploratorio.**

Por ejemplo, un gráfico de barras descendentes que muestra el valor de una variable para cada grupo es un gráfico bastante obvio: no sirve para explorar, en el sentido que se pide en esta instancia. Por el contrario, un gráfico que muestre boxplots por grupo para cada una de las etiquetas posibles sí puede ser exploratorio, ya que no resulta obvia su lectura. Otro ejemplo claro: un gráfico de dispersión con colores y cuadrantes marcados no necesariamente lleva a una conclusión obvia.

### Qué suele funcionar

* **Boxplots o violines por grupo**, abiertos por una segunda variable categórica.
* **Scatterplot con cuadrantes marcados** (líneas en la media o la mediana de cada eje), color por grupo y tamaño por una tercera variable.
* **Small multiples / facetado**: el mismo gráfico repetido para muchas unidades, para comparar formas y no solo niveles.
* **Matriz de correlaciones** o gráfico de pares entre las variables del análisis.
* **ECDF superpuestas** para varios grupos o varios años: muestran cambios de forma y no solo de nivel.
* **Heatmap** de una variable por dos dimensiones (por ejemplo, unidad × año).
* **Resultados de los métodos de la instancia 2**: biplot de PCA, mapa de MCA, dendrograma, clusters proyectados sobre dos componentes, curva de Lorenz por grupo, descomposición de un índice.

### Qué no alcanza

* Barras ordenadas de mayor a menor de una sola variable.
* Una serie de tiempo de una sola variable para una sola unidad.
* Un gráfico de torta (en ningún caso, en esta materia).
* Un gráfico bonito pero que no se usa para nada en el análisis.

### Qué se evalúa

Que el gráfico **muestre más de lo que se puede decir en una oración** y que se vea para qué sirve dentro del análisis. Puede ser un gráfico denso: está permitido que requiera trabajo leerlo. Lo que no está permitido es que sea ilegible (ejes sin nombre, categorías superpuestas, colores indistinguibles). Como no hay texto que lo acompañe, el título y los rótulos tienen que dejar claro qué variables están mirando y sobre qué universo.

---

## 3. Gráfico comunicativo

Debe **revestir de complejidad**, pero esa complejidad debe reducirse a través de **elementos visuales que dirijan el mensaje** hacia aquello que les interesa mostrar.

La idea es que el gráfico no sea simple por tener pocos datos, sino que sea **legible a pesar de tener muchos**. La diferencia la hacen las decisiones de diseño.

### Recursos para dirigir el mensaje

* **Color como jerarquía**, no como decoración: destacar una o dos series y mandar el resto a gris. Si todo está resaltado, nada está resaltado.
* **Título que afirme el hallazgo**, no que describa el gráfico. "El empleo industrial cayó en todas las provincias menos tres" comunica; "Empleo industrial por provincia, 2010-2024" solo rotula.
* **Subtítulo o bajada** que aclare la unidad de medida, el universo y el período.
* **Anotaciones dentro del área del gráfico**: flechas, etiquetas sobre los puntos que importan, texto que explique un salto o un quiebre de la serie.
* **Recuadros, sombreados o líneas de referencia** para marcar un período, un umbral o un promedio.
* **Etiquetas directas en lugar de leyenda**, cuando son pocas series.
* **Nota al pie con la fuente** y con las aclaraciones metodológicas.
* **Sacar todo lo que no aporta**: grillas pesadas, bordes, decimales de más, ejes redundantes.

Se recomienda seguir las ideas que aparecen en [**Our World in Data — Data Insights**](https://ourworldindata.org/data-insights). Miren varios y observen cómo resuelven el título, el color y las anotaciones.

### Qué se evalúa

Que una persona que no leyó el trabajo entienda **qué le están queriendo decir** en menos de diez segundos, y que lo que entienda sea efectivamente lo que ustedes quisieron decir.

---

## 4. Requisitos técnicos

* Los dos gráficos deben estar hechos **en R**. Se espera el uso de `ggplot2`; está permitido (y bienvenido) usar paquetes complementarios vistos en clase, como `scales`, `ggrepel`, `patchwork` o `factoextra`.
* **Exportar con `ggsave()` en formato `.jpg`**, no con la función "Export" de RStudio ni con capturas de pantalla.
* **Resolución mínima: 300 dpi.** Tamaño sugerido: entre 20 y 25 cm de ancho.
* El texto del gráfico tiene que ser **legible al tamaño exportado**. Abran el JPG y mírenlo: si tienen que hacer zoom para leer un eje, el tamaño de fuente está mal.
* Guarden el script que genera los gráficos: en esta instancia no se entrega, pero lo van a necesitar para la entrega final.

```r
library(tidyverse)

grafico <- ggplot(datos, aes(x = variable_x, y = variable_y)) +
  geom_point() +
  labs(
    title    = "El hallazgo, afirmado",
    subtitle = "Unidad de medida, universo y período",
    caption  = "Fuente: elaboración propia en base a ...",
    x = "Nombre de la variable X",
    y = "Nombre de la variable Y"
  ) +
  theme_minimal(base_size = 13)

ggsave(
  filename = "grupo_XX_comunicativo.jpg",
  plot     = grafico,
  width    = 22,
  height   = 14,
  units    = "cm",
  dpi      = 300
)
```

### Decisiones que hay que cuidar en los dos gráficos

* **Ejes con nombre en castellano** y con unidad de medida.
* **Números formateados**: separador de miles, cantidad razonable de decimales, porcentajes como porcentajes (`scales::label_number()`, `label_percent()`, `label_comma()`).
* **Fuente del dato siempre**, en el `caption`.
* **Escalas honestas**: si cortan el eje y, hay que decirlo. Si usan escala logarítmica, también.
* **Paleta accesible**: evitar que el rojo y el verde sean la única diferencia y chequear que los colores se distingan en escala de grises.

---

## 5. Formato de entrega

Se entregan **únicamente los dos archivos JPG/JPEG**, nombrados `grupo_XX_exploratorio.jpg` y `grupo_XX_comunicativo.jpg`.

En esta instancia **no se entrega presentación, ni el código de R, ni ningún texto que acompañe a los gráficos**. Los gráficos tienen que sostenerse solos.

### Envío

* **Enviar a:** nsidicaro.fce@gmail.com
* **Asunto:** `curso_2c_2026_grupo_XX_instancia_3` (reemplazando `XX` por el número de grupo, por ejemplo `curso_2c_2026_grupo_04_instancia_3`)
* **Archivos adjuntos:** los dos JPG.
* **Fecha límite:** jueves 12/11, hasta las 23:59 hs.

Un solo integrante del grupo debe realizar el envío, con el resto de los integrantes en copia. **No enviar los gráficos pegados dentro de un Word o un PowerPoint:** se evalúan las imágenes tal como las exportaron.

---

## Evaluación

Esta instancia representa el **10% de la nota final** y se califica del 1 al 10.

Se tendrán en cuenta:

* **Pertinencia:** los dos gráficos se desprenden del análisis del TP y sirven para contar su historia.
* **Carácter exploratorio del primer gráfico:** tiene complejidad técnica real y su lectura no es obvia.
* **Carácter comunicativo del segundo gráfico:** tiene complejidad, pero el diseño la reduce y dirige la atención hacia un mensaje único.
* **Decisiones de diseño:** color, título, anotaciones, leyendas, orden de las categorías, eliminación de elementos innecesarios.
* **Prolijidad técnica:** ejes nombrados, números formateados, fuente citada, resolución y legibilidad del archivo exportado.
* **Autonomía de las imágenes:** cada gráfico se entiende sin explicación oral ni texto de apoyo, porque el título, la bajada, las etiquetas y la nota de fuente alcanzan.

Los gráficos de esta instancia **no son definitivos**: la devolución apunta a que lleguen mejorados a la entrega final y a la presentación oral.

---

## Checklist antes de enviar

* [ ] ¿El gráfico exploratorio pasa la pregunta del punto 2? ¿O es obvio?
* [ ] ¿El comunicativo tiene un título que afirma algo?
* [ ] ¿Se entiende el mensaje del comunicativo sin que ustedes lo expliquen?
* [ ] ¿Los dos ejes tienen nombre y unidad de medida?
* [ ] ¿Está la fuente del dato?
* [ ] ¿Abrieron los JPG y los miraron al tamaño real?
* [ ] ¿Los archivos están nombrados como pide el punto 5?

---

## Material de apoyo

| Recurso | Dónde está |
| --- | --- |
| Introducción a la visualización | `clases/clase21/viz_clase01_introduccion_visualizacion.pdf` |
| Visualización con `ggplot2` | `clases/clase22/clase22_visualizacion_ggplot2.pdf` |
| Galería de gráficos con código | `clases/clase22/clase22_graficos_varios.R` |
| Schwabish — *Better Data Visualizations* | `bibliografia/Visualización/` |
| Wilke — *Fundamentals of Data Visualization* | `bibliografia/Visualización/dataviz-en.pdf` |
| Our World in Data — Data Insights | https://ourworldindata.org/data-insights |
| Referencia de `ggplot2` | https://ggplot2.tidyverse.org/reference/ |
