# Cómo organizar un proyecto de Ciencia de Datos en R

*Guía de referencia para los trabajos prácticos de Ciencia de Datos*

---

## Índice

1. [La lógica general](#1-la-lógica-general)
2. [Las carpetas del proyecto](#2-las-carpetas-del-proyecto)
3. [El problema del Environment](#3-el-problema-del-environment)
4. [Rutas relativas](#4-rutas-relativas)
5. [La carpeta `output/`](#5-la-carpeta-output)
6. [La carpeta `docs/`](#6-la-carpeta-docs)
7. [La carpeta `auxiliar/`](#7-la-carpeta-auxiliar)
8. [El README.md](#8-el-readmemd)
9. [Orden de ejecución de los scripts](#9-orden-de-ejecución-de-los-scripts)
10. [Una tarea por script](#10-una-tarea-por-script)
11. [Ejemplo completo](#11-ejemplo-completo)
12. [Checklist final](#12-checklist-final)

---

## 1. La lógica general

Todos los proyectos de esta materia van a usar la misma estructura de carpetas.

```
proyecto/
│
├── raw/
├── input/
├── output/
│   ├── bases/
│   ├── tablas/
│   ├── graficos/
│   └── modelos/
├── scripts/
├── docs/
├── auxiliar/
└── README.md
```

Memorizar estos nombres sirve de poco si no se entiende para qué están. La estructura es una herramienta, y su valor está en los problemas que resuelve. Una organización clara permite

- **separar** los datos originales, los datos procesados y los resultados;
- **saber dónde está cada archivo** sin tener que buscarlo;
- **evitar sobrescribir información** por accidente;
- que el proyecto sea **reproducible**, es decir, que se pueda volver a ejecutar y obtener los mismos resultados;
- que **otra persona** pueda entender y ejecutar el proyecto;
- **retomar el proyecto** después de varios meses sin tener que reconstruir de memoria qué hizo cada archivo;
- **no depender de la computadora** de quien desarrolló el análisis, ni de sus rutas ni de sus archivos sueltos.

Una buena forma de pensarlo es imaginar que la persona que va a retomar el proyecto sos vos dentro de seis meses. Esa persona no va a recordar qué archivo era el bueno, qué script había que correr primero ni por qué se descartaron ciertas observaciones. La estructura y la documentación están para responderle esas preguntas.

### El flujo de datos

La idea central detrás de la estructura es que los datos **recorren un camino** dentro del proyecto.

```
raw  →  input  →  scripts  →  output
                     ↓
                    docs
```

1. Los datos llegan al proyecto tal como fueron obtenidos y se guardan en `raw/`.
2. Los scripts los limpian y preparan, y guardan esas versiones en `input/`.
3. Otros scripts toman esos datos preparados y producen tablas, gráficos y modelos que se guardan en `output/`.
4. Con esos resultados se arman los documentos que leen las personas, que van en `docs/`.

Este diagrama es **conceptual**. En la práctica el recorrido puede variar según el proyecto. Puede haber un script que lea directamente desde `raw/` y genere un gráfico en `output/`, o proyectos donde `input/` casi no se usa. Lo importante es la dirección del flujo. Los datos van de lo original a lo procesado y de lo procesado a los resultados, y **nunca en sentido inverso**. Un script jamás debería escribir sobre `raw/`.

---

## 2. Las carpetas del proyecto

### `raw/`

Contiene los **datos originales**, tal como fueron descargados, recibidos o recolectados.

```
raw/
├── EPH_2025_T4.xlsx
├── empresas_2024.csv
└── datos_api_2026.json
```

**Reglas de `raw/`**

- No modificar manualmente los archivos. Nada de abrir el Excel, borrar una columna y guardar.
- No sobrescribirlos, ni a mano ni desde un script.
- Conservarlos como fuente original del proyecto.
- Usar, si es posible, nombres de archivo informativos que indiquen fuente y período (`EPH_2025_T4.xlsx` dice mucho más que `datos.xlsx`).
- Documentar de dónde provienen y cuándo fueron descargados.

Para lo último alcanza con un archivo de texto dentro de la misma carpeta.

```
raw/README_fuentes.txt

EPH_2025_T4.xlsx
  Fuente       INDEC, Encuesta Permanente de Hogares, base de individuos
  URL          https://www.indec.gob.ar/indec/web/Institucional-Indec-BasesDeDatos
  Descargado   2026-03-15
  Observación  Se descargó la versión en Excel
```

**¿Por qué es tan importante conservar los originales?**

Porque son el punto de partida de todo el análisis. Si un dato procesado tiene un error, siempre se puede volver a `raw/`, corregir el script y regenerar todo. Si el original fue modificado a mano, ese camino se pierde. Ya no hay forma de saber qué cambió, ni de volver atrás, ni de que otra persona llegue a los mismos resultados partiendo de la fuente pública.

Además, las fuentes cambian. Un organismo puede revisar una serie o dar de baja un archivo. Tener guardada la versión exacta que se usó garantiza que el análisis siga siendo reproducible.

> **Regla práctica.** Tratá `raw/` como si fuera de solo lectura. Los scripts leen de ahí, pero nunca escriben ahí.

---

### `input/`

Contiene **datos preparados** para ser usados por los scripts de análisis. Por ejemplo

- datos limpios;
- bases combinadas a partir de varias fuentes;
- variables recodificadas;
- archivos intermedios que usan varios análisis distintos.

**Diferencia entre `raw/` e `input/`**

| | `raw/` | `input/` |
|---|---|---|
| Origen | Descargado o recibido de afuera | Generado por un script del proyecto |
| ¿Se modifica? | Nunca | Se regenera cada vez que se corre el script que lo crea |
| ¿Se puede borrar? | No, se perdería la fuente | Sí, porque se puede volver a generar |
| Formato | El que venga (xlsx, csv, json, dta) | Siempre `.csv` |

El recorrido típico es este.

```
raw/EPH_2025_T4.xlsx
        ↓
scripts/02_limpiar_datos.R
        ↓
input/EPH_2025_T4_limpia.csv
```

Una forma de distinguir ambas carpetas es preguntarse qué pasa si se borra el archivo. Si se borra algo de `raw/`, se pierde información. Si se borra algo de `input/`, alcanza con volver a correr el script correspondiente.

**¿Todos los proyectos necesitan `input/`?**

No necesariamente. Si los datos originales son chicos y la limpieza es breve, un script puede leer directamente de `raw/`, limpiar y analizar en el mismo paso. `input/` se vuelve útil cuando

- la limpieza es larga o lenta y conviene hacerla una sola vez;
- varios scripts usan la misma base preparada;
- se combinan varias fuentes y el resultado se usa en más de un lugar.

#### Formato de los archivos generados

Todos los archivos que generan los scripts, tanto en `input/` como en `output/`, se guardan en formato **CSV**. Un CSV es un archivo de texto plano donde cada fila es una observación y las columnas se separan con comas. Su gran ventaja es que lo lee cualquier programa. R, Stata, Python, Excel o un simple editor de texto pueden abrirlo sin paquetes especiales.

Esto permite que distintas partes del proyecto usen distintos lenguajes. La limpieza puede hacerse en R, la estimación econométrica en Stata y un modelo de machine learning en Python, y todos se comunican a través de los mismos archivos. Los formatos propios de un programa, como `.rds` de R o `.dta` de Stata, obligan a que quien lea el archivo use ese mismo programa.

```r
library(tidyverse)

write_csv(base_limpia, "input/base_limpia.csv")   # guardar
base <- read_csv("input/base_limpia.csv")         # leer
```

**El costo de usar CSV.** El archivo guarda solamente texto y números, así que se pierde la información sobre el tipo de cada variable. Un factor de R vuelve como texto o como número, y una fecha puede volver como texto. Por eso, después de leer un CSV, hay que volver a declarar los tipos que el análisis necesita. La sección 11 muestra un caso concreto.

**Convenciones para que los CSV se lean igual en cualquier programa**

- Escribir con `write_csv()` y leer con `read_csv()`, del paquete `readr` (incluido en `tidyverse`). Usan coma como separador, punto como separador decimal y codificación UTF-8.
- Evitar `write.csv2()` y evitar guardar CSV desde Excel con configuración regional en español, porque usan punto y coma y coma decimal, y otros programas pueden leer mal los números.
- Usar nombres de columnas sin espacios, tildes ni caracteres especiales (`salario_medio` en lugar de `Salario medio`). Stata, en particular, no admite espacios en los nombres de variables.

---

### `scripts/`

Es una de las carpetas más importantes del proyecto. Contiene el **código que transforma los datos y produce los resultados**. Si el proyecto fuera una receta, `raw/` serían los ingredientes, `output/` el plato terminado y `scripts/` la receta misma.

```
scripts/
├── 01_importar_datos.R
├── 02_limpiar_datos.R
├── 03_generar_base_analisis.R
├── 04_analisis_descriptivo.R
├── 05_modelos.R
└── 06_graficos_tablas.R
```

Cuando existe un orden lógico de ejecución, conviene **numerar los scripts**. El número comunica el orden a quien abre la carpeta y además hace que el explorador de archivos los muestre ordenados. Usar dos dígitos (`01`, `02`...) evita que `10_` aparezca antes que `2_`.

#### Proyectos con más de un lenguaje

Como las bases intermedias se guardan en CSV, `scripts/` puede combinar archivos de distintos lenguajes. La numeración sigue indicando el orden, cualquiera sea la extensión.

```
scripts/
├── 01_importar_datos.R
├── 02_limpiar_datos.R
├── 03_analisis_descriptivo.R
├── 04_modelos.do              (Stata)
└── 05_clasificacion.py        (Python)
```

Cada script lee sus entradas desde un CSV y escribe sus salidas en otro. Lo que produce `02_limpiar_datos.R` se lee igual desde Stata o desde Python.

```stata
* 04_modelos.do
import delimited "input/base_limpia.csv", clear
```

```python
# 05_clasificacion.py
import pandas as pd

base = pd.read_csv("input/base_limpia.csv")
```

Las reglas de esta guía valen para todos los lenguajes. Rutas relativas, entradas y salidas explícitas, y posibilidad de ejecutar el script desde una sesión nueva. En Stata y en Python también hay que trabajar desde la carpeta raíz del proyecto para que las rutas relativas funcionen.

#### Concepto fundamental: scripts autocontenidos

Un script es **autocontenido** cuando tiene todo lo que necesita para funcionar escrito dentro de sí mismo. Se puede abrir en una sesión nueva de R, ejecutar de principio a fin y obtener el resultado esperado, sin haber hecho nada antes.

Un script autocontenido cumple estas condiciones.

1. Indica claramente qué archivos necesita.
2. Usa rutas relativas al proyecto.
3. Carga los paquetes que necesita.
4. Define las variables o parámetros que usa.
5. Ejecuta todas las transformaciones necesarias.
6. Genera explícitamente sus archivos de salida.
7. No depende de objetos creados manualmente en otro script.
8. No depende de objetos que quedaron guardados en el Environment de R.
9. Puede ejecutarse desde una sesión nueva de R.

**Un script mal estructurado**

```r
# Esto solamente funciona porque previamente ejecuté otro script
# y tengo una base llamada "base_final" en el Environment

modelo <- lm(salario ~ edad + educacion, data = base_final)
```

Este script tiene varios problemas.

- ¿Qué es `base_final`? El script no lo dice. Hay que adivinar de dónde sale.
- Si se abre R de cero, falla con `object 'base_final' not found`.
- Si `base_final` en el Environment es una versión vieja o modificada a mano, el modelo se estima sobre datos incorrectos **sin ningún error visible**. Este es el caso más peligroso.
- El modelo se calcula y queda solo en memoria. Al cerrar R, se pierde.

**Un script mejor**

```r
library(tidyverse)
library(broom)

base <- read_csv("input/base_final.csv")

modelo <- lm(salario ~ edad + educacion, data = base)

write_csv(tidy(modelo), "output/modelos/modelo_coeficientes.csv")
```

Este script deja explícito

- **qué paquetes** necesita (`tidyverse` y `broom`);
- **qué archivo** usa (`input/base_final.csv`);
- **qué análisis** realiza (una regresión lineal de salario sobre edad y educación);
- **dónde guarda** el resultado (`output/modelos/modelo_coeficientes.csv`).

La función `tidy()` del paquete `broom` convierte el modelo en una tabla de coeficientes, que se puede guardar como CSV. La sección 5 lo explica con más detalle.

Cualquier persona puede leerlo de arriba a abajo y entender qué entra, qué pasa y qué sale.

#### Un encabezado útil

Una práctica recomendable es empezar cada script con un bloque de comentarios que resuma entradas y salidas.

```r
# -----------------------------------------------------------------
# Script      05_modelos.R
# Objetivo    Estimar el modelo de salarios por edad y educación
# Entrada     input/base_final.csv
# Salida      output/modelos/modelo_coeficientes.csv
# -----------------------------------------------------------------

library(tidyverse)
library(broom)

base <- read_csv("input/base_final.csv")

modelo <- lm(salario ~ edad + educacion, data = base)

write_csv(tidy(modelo), "output/modelos/modelo_coeficientes.csv")
```

Con este encabezado, alguien que abre el script sabe en diez segundos qué hace, sin leer el código.

---

## 3. El problema del Environment

El **Environment** es el panel de RStudio que muestra los objetos que existen en la sesión actual. Es muy cómodo para trabajar, y justamente por eso es fuente de uno de los errores más comunes.

La situación típica es esta.

> «"El script funciona porque antes ejecuté estas cinco líneas manualmente."»

Mientras se trabaja, es normal probar cosas en la consola, correr líneas sueltas, crear objetos de prueba. El problema aparece cuando el script **termina dependiendo** de esos objetos sin que nadie lo note.

```r
# script_analisis.R

resultado <- base2 %>%
  group_by(region) %>%
  summarise(salario_medio = mean(salario))
```

¿De dónde salió `base2`? Quizás se creó en la consola, quizás en otro script, quizás en una línea que después se borró. Mientras la sesión siga abierta, el script "funciona". Cuando se reinicia R o lo abre otra persona, deja de funcionar. Y lo que es peor, nadie sabe cómo reconstruir `base2`.

Lo mismo ocurre con secuencias como

```r
base <- ...
base2 <- ...
resultado <- ...
```

cuando alguno de esos objetos no se crea dentro del propio script.

### El test de reproducibilidad

Otra persona debería poder

1. abrir una sesión nueva de R;
2. abrir el proyecto;
3. ejecutar el script;
4. obtener el mismo resultado.

Si alguno de esos pasos falla, el script depende de algo que no está escrito en él.

### Cómo hacerse el test a uno mismo

La forma más simple es **reiniciar R** antes de ejecutar el script completo. En RStudio, `Session > Restart R` (atajo `Ctrl + Shift + F10`). Después se ejecuta todo el script con `Ctrl + Shift + Enter`. Si corre sin errores, el script no depende del Environment.

Además, conviene configurar RStudio para que **no guarde ni recupere el Environment** entre sesiones. En `Tools > Global Options > General`

- desmarcar *Restore .RData into workspace at startup*;
- en *Save workspace to .RData on exit*, elegir *Never*.

Así, cada vez que se abre RStudio se empieza de cero, y cualquier dependencia oculta aparece de inmediato.

### ¿Por qué importa tanto en equipos?

Cuando se trabaja en grupo, cada integrante tiene su propia sesión de R con su propio Environment. Un script que funciona en la computadora de quien lo escribió puede fallar en la de sus compañeros, o peor, dar resultados distintos. Si los scripts leen y escriben todo desde archivos, el proyecto funciona igual para todos, porque lo que se comparte son los archivos y el código, y eso es lo mismo en todas las computadoras.

---

## 4. Rutas relativas

Una **ruta** es la dirección de un archivo en la computadora. Hay dos formas de escribirla.

**Ruta absoluta**, que describe la ubicación completa desde la raíz del disco.

```r
read.csv("C:/Users/Nicolas/Desktop/proyecto/base.csv")
```

**Ruta relativa**, que describe la ubicación a partir de la carpeta del proyecto.

```r
read.csv("input/base.csv")
```

### ¿Por qué las rutas absolutas son un problema?

La ruta `C:/Users/Nicolas/Desktop/...` existe únicamente en la computadora de Nicolás. En cualquier otra máquina el script falla. También falla si Nicolás mueve el proyecto a otra carpeta, lo pasa a un pendrive o cambia de computadora. Y en Mac o Linux la estructura de rutas es directamente diferente.

| | Ruta absoluta | Ruta relativa |
|---|---|---|
| Ejemplo | `C:/Users/Nicolas/Desktop/proyecto/input/base.csv` | `input/base.csv` |
| ¿Funciona en otra computadora? | No | Sí |
| ¿Funciona si se mueve la carpeta? | No | Sí |
| ¿Funciona en otro sistema operativo? | No | Sí |

### Cómo indicarle a R cuál es la carpeta del proyecto

Una ruta relativa se interpreta a partir del **directorio de trabajo**, que es la carpeta desde donde R busca y guarda archivos. Para que `input/base.csv` funcione, el directorio de trabajo tiene que ser la carpeta raíz del proyecto. En cualquier momento se puede consultar cuál es con `getwd()`.

Hay dos formas de fijarlo.

#### Opción 1. `setwd()` desde la consola

Es la forma en que trabaja el docente de la materia. Al empezar cada sesión, se fija el directorio de trabajo escribiendo `setwd()` en la **consola**, fuera de cualquier script.

```r
# En la consola, una vez por sesión
setwd("C:/Users/Nicolas/Desktop/proyecto_salarios")
```

A partir de ahí, todos los scripts usan rutas relativas como `input/base.csv`.

La clave es que esa línea **nunca quede escrita en un script**. La ruta que recibe `setwd()` es absoluta y existe únicamente en la computadora de quien la escribió. Si queda dentro del script, el script falla en cualquier otra máquina. Si se corre en la consola, cada persona fija su propia ruta y el script queda limpio, solo con rutas relativas que funcionan en todas las computadoras.

En RStudio se puede hacer lo mismo desde el menú `Session > Set Working Directory > Choose Directory...`, que escribe el `setwd()` en la consola automáticamente.

Esta forma funciona igual en cualquier entorno donde se use R (RStudio, VS Code, Positron o la terminal). Stata sigue la misma lógica con `cd "C:/.../proyecto_salarios"` en la ventana de comandos.

#### Opción 2. Proyectos de RStudio (`.Rproj`)

1. `File > New Project > Existing Directory` y elegir la carpeta `proyecto/`.
2. RStudio crea un archivo `proyecto.Rproj`.
3. De ahí en adelante, se abre el proyecto haciendo doble clic en ese archivo.

Al abrir el `.Rproj`, RStudio fija automáticamente la carpeta del proyecto como directorio de trabajo. Es la opción más cómoda, porque no hay que acordarse de hacer nada al empezar. La contrapartida es que depende de RStudio. Si el proyecto se abre desde otro programa, el archivo `.Rproj` no tiene ningún efecto y hay que fijar el directorio de trabajo de otra manera.

| | `setwd()` en la consola | Proyecto `.Rproj` |
|---|---|---|
| ¿Hay que hacer algo al empezar? | Sí, correr `setwd()` una vez por sesión | No, alcanza con abrir el `.Rproj` |
| ¿Depende de RStudio? | No | Sí |
| ¿Qué queda escrito en los scripts? | Solo rutas relativas | Solo rutas relativas |

Las dos opciones son válidas para los trabajos prácticos. En ambos casos los scripts son idénticos.

> **Qué evitar siempre.** Dejar `setwd("C:/Users/...")` escrito al principio de un script. Es una ruta absoluta disfrazada y tiene exactamente el mismo problema que cualquier otra ruta absoluta.

### El paquete `here` (opcional)

Existe también el paquete `here`, que construye rutas a partir de la raíz del proyecto.

```r
library(here)

base <- read_csv(here("input", "base.csv"))
```

`here()` detecta la carpeta raíz del proyecto (por ejemplo, la que contiene el `.Rproj`) y arma la ruta desde ahí. Puede ser útil al trabajar con archivos R Markdown o Quarto guardados en subcarpetas, porque al renderizarlos el directorio de trabajo pasa a ser la carpeta del documento.

El docente de la materia no lo usa y no hace falta para los trabajos prácticos. Queda mencionado como una opción para quien quiera explorarlo.

---

## 5. La carpeta `output/`

Contiene los **productos generados por los scripts**, organizados en subcarpetas según el tipo de resultado.

```
output/
├── bases/
│   └── base_final.csv
├── tablas/
│   ├── tabla_descriptiva.csv
│   └── resultados_por_region.csv
├── graficos/
│   └── grafico_distribucion.png
└── modelos/
    ├── modelo_regresion_coeficientes.csv
    └── modelo_regresion_ajuste.csv
```

| Subcarpeta | Contenido | Formato |
|---|---|---|
| `bases/` | Bases finales listas para entregar o publicar | `.csv` |
| `tablas/` | Estadísticas descriptivas, cuadros de resultados | `.csv` |
| `graficos/` | Distribuciones, series de tiempo, mapas | `.png`, `.svg` |
| `modelos/` | Coeficientes y medidas de ajuste de los modelos estimados | `.csv` |

Separar por tipo evita que `output/` se convierta en una lista larga de archivos mezclados. Quien busca un gráfico va directo a `graficos/`, y quien quiere retomar los coeficientes de un modelo desde Stata o Python los encuentra en `modelos/`. Si el proyecto lo necesita, se pueden sumar otras subcarpetas con la misma lógica de agrupar por tipo de resultado.

**Los modelos también se guardan en CSV.** Un modelo estimado en R es un objeto complejo que no entra en una tabla, así que lo que se guarda son sus resultados. El paquete `broom` los convierte en tablas con dos funciones.

```r
library(tidyverse)
library(broom)

# Coeficientes, errores estándar y p-valores
write_csv(tidy(modelo), "output/modelos/modelo_regresion_coeficientes.csv")

# Medidas de ajuste (R², cantidad de observaciones, estadístico F)
write_csv(glance(modelo), "output/modelos/modelo_regresion_ajuste.csv")
```

**Las subcarpetas tienen que existir.** `write_csv()` y `ggsave()` no crean carpetas. Si `output/graficos/` no existe, el script falla con un error. Por eso las subcarpetas se crean al armar la estructura del proyecto, junto con las carpetas principales.

**¿`input/` u `output/bases/`?** A veces una misma base podría ir en cualquiera de los dos lugares. El criterio práctico es el uso. Si la base la va a leer otro script del proyecto, va en `input/`. Si es un resultado final que se entrega o se publica, va en `output/bases/`.

### Una idea clave

Los archivos de `output/` deberían ser, idealmente, **resultados que se pueden regenerar** ejecutando los scripts. Esto tiene una consecuencia práctica muy importante. Nunca hay que editar a mano un archivo de `output/`. Si un gráfico necesita otro color o una tabla necesita otra columna, se cambia el script y se vuelve a ejecutar. Si se edita el archivo directamente, la próxima vez que se corra el script el cambio se pierde, y además el resultado deja de coincidir con el código.

Una buena prueba es borrar todo el contenido de `output/` y volver a correr los scripts. Si todo reaparece igual, el proyecto está bien armado.

---

## 6. La carpeta `docs/`

Contiene la **documentación y los productos pensados para ser leídos por personas**.

```
docs/
├── informe_final.pdf
├── presentacion.pptx
├── metodologia.md
└── notas_proyecto.md
```

Acá van el informe del trabajo práctico, la presentación, las notas metodológicas, los documentos de referencia que se consultaron, etc.

La diferencia con las otras carpetas es de destinatario.

| Carpeta | Contenido | Lo lee o usa |
|---|---|---|
| `scripts/` | Código | R |
| `output/` | Resultados generados por el código | Otros scripts y los documentos finales |
| `docs/` | Documentos y productos finales | Personas |

Un gráfico recién generado va en `output/graficos/`. El informe que incluye ese gráfico junto con su interpretación va en `docs/`.

---

## 7. La carpeta `auxiliar/`

Sirve para **archivos de apoyo** que el proyecto necesita pero que no son la fuente de datos principal ni un resultado. Por ejemplo

- diccionarios de variables;
- tablas de correspondencias (entre clasificadores de actividad, entre códigos viejos y nuevos);
- códigos geográficos (provincias, departamentos, aglomerados);
- archivos de configuración;
- metadatos;
- pequeñas tablas auxiliares armadas a mano;
- información necesaria para realizar cruces entre bases.

Un ejemplo típico es una tabla que asigna a cada código de aglomerado de la EPH su nombre y su región. El análisis la necesita para hacer un cruce, pero no es el dato principal del proyecto.

> **Cuidado.** `auxiliar/` no es un cajón de sastre. Si un archivo termina ahí porque no se sabía dónde ponerlo, probablemente pertenece a otra carpeta o directamente no hace falta en el proyecto. Cada archivo de `auxiliar/` debería tener un uso concreto en algún script.

---

## 8. El README.md

El `README.md` es la **puerta de entrada al proyecto**. Es el primer archivo que alguien debería abrir, y muchas veces el único que lee antes de decidir qué hacer.

Una persona que nunca vio el proyecto debería poder abrir el README y entender

- qué es el proyecto;
- cuál es su objetivo;
- quién lo desarrolló;
- qué datos utiliza;
- de dónde provienen los datos;
- cómo está organizado el proyecto;
- qué scripts debe ejecutar;
- en qué orden debe ejecutarlos;
- qué resultados genera;
- qué paquetes necesita;
- qué decisiones metodológicas importantes se tomaron.

La idea central de esta sección es la siguiente.

> **Si otra persona recibe solamente la carpeta del proyecto, debería poder leer el README y entender cómo reproducir el análisis sin tener que preguntarle al autor qué hacer.**

### ¿Por qué Markdown?

El README se escribe en **Markdown** (`.md`), un formato de texto plano con marcas simples para títulos, listas y código. Se puede abrir con cualquier editor, se lee bien incluso sin formato, y plataformas como GitHub lo muestran automáticamente en la página del proyecto.

| Escribís | Se ve como |
|---|---|
| `# Título` | Título principal |
| `## Subtítulo` | Subtítulo |
| `- elemento` | Elemento de una lista |
| `**negrita**` | **negrita** |
| `` `codigo` `` | `codigo` |

### Estructura recomendada

```markdown
# Nombre del proyecto

## Objetivo

## Fuente de los datos

## Estructura del proyecto

## Requisitos

## Cómo ejecutar el proyecto

### Paso 1
### Paso 2
### Paso 3

## Descripción de los scripts

## Principales resultados

## Consideraciones metodológicas

## Autores

## Fecha
```

Qué va en cada sección.

- **Objetivo.** La pregunta que busca responder el proyecto, en uno o dos párrafos.
- **Fuente de los datos.** Qué datos se usan, quién los produce, dónde se descargan y cuándo se descargaron.
- **Estructura del proyecto.** El árbol de carpetas con una breve descripción de cada una.
- **Requisitos.** Versión de R y paquetes necesarios, idealmente con la línea para instalarlos.
- **Cómo ejecutar el proyecto.** Los pasos concretos, en orden, desde abrir el proyecto hasta obtener los resultados.
- **Descripción de los scripts.** Qué hace cada script, qué lee y qué genera.
- **Principales resultados.** Qué archivos produce el proyecto y dónde encontrarlos.
- **Consideraciones metodológicas.** Decisiones que afectan los resultados (filtros, definiciones de variables, tratamiento de valores faltantes, uso de ponderadores).
- **Autores y fecha.** Quiénes lo hicieron y cuándo, para saber a quién atribuirlo y qué tan actualizado está.

### Ejemplo de README

````markdown
# Brecha salarial por nivel educativo en Argentina (EPH 2025 T4)

## Objetivo

Estimar la relación entre el nivel educativo y el ingreso de la ocupación
principal de las personas asalariadas en los aglomerados urbanos relevados
por la EPH, controlando por edad y sexo.

## Fuente de los datos

- **Encuesta Permanente de Hogares (EPH)**, INDEC, base de individuos del
  cuarto trimestre de 2025. Descargada el 15/03/2026 desde el sitio de INDEC.
- El detalle de cada archivo está en `raw/README_fuentes.txt`.

## Estructura del proyecto

```
proyecto_salarios/
├── raw/        Datos originales de la EPH (no se modifican)
├── input/      Base limpia generada por los scripts
├── output/     Resultados, separados en tablas/, graficos/ y modelos/
├── scripts/    Código R, numerado según el orden de ejecución
├── docs/       Informe final
├── auxiliar/   Diccionario de variables
└── README.md
```

## Requisitos

- R 4.3 o superior
- Paquetes `tidyverse`, `readxl`, `broom`

```r
install.packages(c("tidyverse", "readxl", "broom"))
```

## Cómo ejecutar el proyecto

### Paso 1
Fijar la carpeta `proyecto_salarios/` como directorio de trabajo, ya sea
corriendo `setwd()` en la consola o abriendo `proyecto_salarios.Rproj` en RStudio.

### Paso 2
Ejecutar los scripts de `scripts/` en orden numérico, del `01` al `04`.
Cada script puede correrse desde una sesión nueva de R.

### Paso 3
Revisar los resultados en `output/`. El informe con la interpretación
está en `docs/informe_final.pdf`.

## Descripción de los scripts

| Script | Qué hace | Lee | Genera |
|---|---|---|---|
| `01_importar.R` | Importa la EPH y selecciona variables | `raw/EPH_2025_T4.xlsx` | `input/base_importada.csv` |
| `02_limpiar.R` | Filtra asalariados y recodifica variables | `input/base_importada.csv` | `input/base_limpia.csv` |
| `03_descriptivo.R` | Calcula estadísticas descriptivas y el gráfico | `input/base_limpia.csv` | `output/tablas/tabla_descriptiva.csv`, `output/graficos/grafico_salarios.png` |
| `04_modelo.R` | Estima el modelo de regresión | `input/base_limpia.csv` | `output/modelos/modelo_salarios_coeficientes.csv`, `output/modelos/modelo_salarios_ajuste.csv` |

## Principales resultados

- `output/tablas/tabla_descriptiva.csv` con el ingreso medio por nivel educativo.
- `output/graficos/grafico_salarios.png` con la distribución del ingreso por nivel educativo.
- `output/modelos/modelo_salarios_coeficientes.csv` y `output/modelos/modelo_salarios_ajuste.csv`
  con los coeficientes y las medidas de ajuste del modelo.

## Consideraciones metodológicas

- Se consideran solo personas asalariadas de 18 a 65 años con ingreso
  de la ocupación principal positivo.
- Se excluyen los casos sin respuesta de ingreso (código -9).
- El ingreso se analiza en logaritmo.
- Las estadísticas descriptivas usan el ponderador `PONDIIO`.
- Todos los archivos intermedios y resultados se guardan en CSV (UTF-8,
  separador coma), de modo que pueden leerse desde Stata o Python.

## Autores

Ana Pérez y Juan Gómez, Ciencia de Datos para Economía y Negocios.

## Fecha

Abril de 2026
````

Este README es corto, pero con él cualquier persona sabe qué hace el proyecto, de dónde salen los datos, qué tiene que instalar, qué tiene que correr y dónde buscar los resultados.

### Consejos para escribir un buen README

- **Escribirlo desde el principio**, e irlo actualizando a medida que avanza el proyecto. Dejarlo para el final suele terminar en un README incompleto o desactualizado.
- **Pensar en alguien que no sabe nada del proyecto.** Lo que para el autor es obvio (qué significa `P21`, por qué se filtró a los asalariados) para otra persona puede no serlo.
- **Ser concreto.** "Ejecutar los scripts" dice poco. "Ejecutar los scripts de `scripts/` en orden numérico, del `01` al `04`" dice exactamente qué hacer.
- **Registrar las decisiones**, especialmente las que cambian los resultados. Dentro de seis meses nadie va a recordar por qué se excluyó un grupo de observaciones.
- **Mantenerlo sincronizado con el proyecto.** Si se agrega un script o cambia una fuente, se actualiza el README. Un README desactualizado confunde más que uno inexistente.

---

## 9. Orden de ejecución de los scripts

Un proyecto suele tener una secuencia de scripts donde cada uno usa lo que produjo el anterior. Esa secuencia se llama **pipeline**.

```
01_importar_datos.R
        ↓
02_limpiar_datos.R
        ↓
03_generar_base_analisis.R
        ↓
04_analisis_descriptivo.R
        ↓
05_modelos.R
        ↓
06_generar_resultados.R
```

El número en el nombre del script comunica el orden lógico. Quien abre la carpeta `scripts/` entiende enseguida por dónde empezar.

Pero **numerar los scripts no alcanza para que el proyecto sea reproducible**. El número dice en qué orden correrlos. Lo que garantiza que funcionen es que cada script declare explícitamente sus entradas y salidas. Cada eslabón del pipeline se conecta con el siguiente **a través de archivos**, jamás a través de objetos en memoria.

```
01_importar.R  ──escribe──►  input/base_importada.csv
                                      │
                                     lee
                                      ▼
02_limpiar.R   ──escribe──►  input/base_limpia.csv
                                      │
                                     lee
                                      ▼
03_descriptivo.R  ──escribe──►  output/tablas/tabla_descriptiva.csv
```

Gracias a esto, si solo cambia el script `03`, alcanza con volver a correr el `03`. No hace falta repetir la importación y la limpieza.

### Un script para ejecutar todo (opcional)

En proyectos con muchos scripts, puede ser práctico agregar un script que los ejecute a todos en orden.

```r
# 00_ejecutar_todo.R

source("scripts/01_importar.R")
source("scripts/02_limpiar.R")
source("scripts/03_descriptivo.R")
source("scripts/04_modelo.R")
```

Esto es un atajo cómodo. Cada script tiene que seguir funcionando por su cuenta, desde una sesión nueva de R.

---

## 10. Una tarea por script

Un error habitual es escribir todo el análisis en un único archivo.

```
analisis.R      (2.000 líneas)
```

La alternativa es dividirlo en varios scripts, cada uno con una responsabilidad clara.

```
01_importar.R
02_limpiar.R
03_transformar.R
04_describir.R
05_modelar.R
06_resultados.R
```

**Ventajas de dividir**

| Un script gigante | Varios scripts con tareas claras |
|---|---|
| Difícil encontrar dónde está cada cosa | Cada tarea tiene su lugar |
| Para cambiar un gráfico hay que correr todo | Se corre solo el script que cambió |
| Un error en la línea 1.500 obliga a revisar todo | Los errores quedan acotados a un script |
| Difícil de repartir en un equipo | Cada integrante puede trabajar en un script distinto |
| Difícil de revisar | Cada script se lee y se entiende por separado |

Dividir tampoco significa fragmentar sin motivo. Treinta scripts de diez líneas cada uno son tan difíciles de seguir como uno solo de dos mil. El criterio es que **cada script tenga una responsabilidad clara**, que se pueda describir en una oración. "Limpia la base de la EPH" es una buena responsabilidad. "Hace cosas varias" indica que el script necesita reorganizarse.

---

## 11. Ejemplo completo

Supongamos un proyecto que estudia la relación entre salarios y nivel educativo con datos de la EPH.

```
proyecto_salarios/
│
├── raw/
│   ├── EPH_2025_T4.xlsx
│   └── README_fuentes.txt
│
├── input/
│   └── base_limpia.csv
│
├── output/
│   ├── tablas/
│   │   └── tabla_descriptiva.csv
│   ├── graficos/
│   │   └── grafico_salarios.png
│   └── modelos/
│       ├── modelo_salarios_coeficientes.csv
│       └── modelo_salarios_ajuste.csv
│
├── scripts/
│   ├── 01_importar.R
│   ├── 02_limpiar.R
│   ├── 03_descriptivo.R
│   └── 04_modelo.R
│
├── docs/
│   └── informe_final.pdf
│
├── auxiliar/
│   └── diccionario_variables.xlsx
│
├── proyecto_salarios.Rproj
└── README.md
```

> En la estructura aparece `input/base_limpia.csv`. El script `01` genera además `input/base_importada.csv`, que se omite del árbol para simplificar.

### Paso a paso

**1. Llegan los datos.** Se descarga la base de individuos de la EPH desde el sitio del INDEC y se guarda sin tocar en `raw/EPH_2025_T4.xlsx`. En `raw/README_fuentes.txt` se anota la fuente, la URL y la fecha de descarga.

**2. Se importan.** El script `01_importar.R` lee el Excel, se queda con las variables que interesan y guarda el resultado en CSV.

```r
# -----------------------------------------------------------------
# Script      01_importar.R
# Objetivo    Importar la EPH y seleccionar las variables de interés
# Entrada     raw/EPH_2025_T4.xlsx
# Salida      input/base_importada.csv
# -----------------------------------------------------------------

library(tidyverse)
library(readxl)

eph <- read_excel("raw/EPH_2025_T4.xlsx")

base <- eph %>%
  select(CODUSU, NRO_HOGAR, COMPONENTE, AGLOMERADO,
         CH04, CH06, NIVEL_ED, ESTADO, CAT_OCUP, P21, PONDIIO)

write_csv(base, "input/base_importada.csv")
```

**3. Se limpian.** El script `02_limpiar.R` filtra la población de interés, descarta los casos sin ingreso y recodifica las variables con nombres legibles. Para interpretar los códigos de la EPH se usa el diccionario guardado en `auxiliar/`.

```r
# -----------------------------------------------------------------
# Script      02_limpiar.R
# Objetivo    Filtrar asalariados y recodificar variables
# Entrada     input/base_importada.csv
# Salida      input/base_limpia.csv
# -----------------------------------------------------------------

library(tidyverse)

# Parámetros del análisis
edad_min <- 18
edad_max <- 65

base <- read_csv("input/base_importada.csv")

base_limpia <- base %>%
  filter(ESTADO == 1,              # ocupados
         CAT_OCUP == 3,            # asalariados
         CH06 >= edad_min,
         CH06 <= edad_max,
         P21 > 0) %>%              # excluye sin ingreso y no respuesta (-9)
  mutate(
    sexo      = if_else(CH04 == 1, "Varón", "Mujer"),
    edad      = CH06,
    educacion = NIVEL_ED,          # en el CSV queda como número del 1 al 7
    salario   = P21,
    log_salario = log(P21)
  )

write_csv(base_limpia, "input/base_limpia.csv")
```

Los parámetros `edad_min` y `edad_max` están definidos dentro del script. Si mañana se decide analizar otro rango de edades, se cambia en un solo lugar y queda registrado en el código.

**4. Se describen.** El script `03_descriptivo.R` lee la base limpia y genera una tabla y un gráfico.

```r
# -----------------------------------------------------------------
# Script      03_descriptivo.R
# Objetivo    Estadísticas descriptivas del salario por nivel educativo
# Entrada     input/base_limpia.csv
# Salidas     output/tablas/tabla_descriptiva.csv
#             output/graficos/grafico_salarios.png
# -----------------------------------------------------------------

library(tidyverse)

base <- read_csv("input/base_limpia.csv") %>%
  mutate(educacion = factor(educacion))   # el CSV no guarda el tipo factor

tabla <- base %>%
  group_by(educacion) %>%
  summarise(
    casos         = n(),
    salario_medio = weighted.mean(salario, w = PONDIIO)
  )

write_csv(tabla, "output/tablas/tabla_descriptiva.csv")

grafico <- ggplot(base, aes(x = educacion, y = salario)) +
  geom_boxplot() +
  scale_y_log10() +
  labs(x = "Nivel educativo", y = "Ingreso de la ocupación principal (escala log)")

ggsave("output/graficos/grafico_salarios.png", grafico, width = 8, height = 5, dpi = 300)
```

**5. Se modela.** El script `04_modelo.R` estima la regresión y guarda sus coeficientes y medidas de ajuste.

```r
# -----------------------------------------------------------------
# Script      04_modelo.R
# Objetivo    Estimar el modelo de salarios
# Entrada     input/base_limpia.csv
# Salidas     output/modelos/modelo_salarios_coeficientes.csv
#             output/modelos/modelo_salarios_ajuste.csv
# -----------------------------------------------------------------

library(tidyverse)
library(broom)

base <- read_csv("input/base_limpia.csv") %>%
  mutate(educacion = factor(educacion))   # el CSV no guarda el tipo factor

modelo <- lm(log_salario ~ educacion + edad + I(edad^2) + sexo, data = base)

write_csv(tidy(modelo),   "output/modelos/modelo_salarios_coeficientes.csv")
write_csv(glance(modelo), "output/modelos/modelo_salarios_ajuste.csv")
```

Prestá atención a la línea `mutate(educacion = factor(educacion))` de los scripts 03 y 04. En el CSV, el nivel educativo quedó guardado como un número del 1 al 7. Si no se lo vuelve a declarar como factor, `lm()` lo trata como una variable continua y estima una única pendiente para todos los niveles. El modelo corre sin ningún mensaje de error y los resultados son incorrectos. Este es el costo de usar un formato que entienden todos los programas, y se resuelve declarando los tipos apenas se lee el archivo.

Si el modelo se estimara en Stata, el script `04_modelos.do` leería el mismo `input/base_limpia.csv` y usaría `i.educacion` para tratar la variable como categórica.

**6. Se escribe el informe.** Con los archivos de `output/tablas/`, `output/graficos/` y `output/modelos/`, se redacta el informe con la interpretación de los resultados y se guarda en `docs/informe_final.pdf`.

**7. Se documenta.** El `README.md` explica todo lo anterior. Cualquier persona que reciba la carpeta puede fijarla como directorio de trabajo, correr los cuatro scripts en orden y obtener exactamente los mismos archivos de `output/`.

Observá que ninguno de los cuatro scripts usa objetos creados por otro. Todos leen de disco al principio y escriben a disco al final. Por eso cada uno funciona por su cuenta en una sesión nueva de R.

---

## 12. Checklist final

Antes de entregar un trabajo práctico, repasá esta lista.

### Organización

- [ ] Los datos originales están en `raw/`.
- [ ] Los datos procesados están en `input/`.
- [ ] Los resultados están en `output/`, separados en subcarpetas por tipo (`tablas/`, `graficos/`, `modelos/`).
- [ ] El código está en `scripts/`.
- [ ] La documentación está en `docs/`.
- [ ] Los archivos auxiliares están en `auxiliar/`.

### Reproducibilidad

- [ ] No hay rutas absolutas.
- [ ] Ningún script contiene `setwd()`.
- [ ] Los scripts cargan sus propios paquetes.
- [ ] Los scripts no dependen del Environment.
- [ ] Los archivos de entrada están explícitamente indicados.
- [ ] Los archivos de salida se generan explícitamente.
- [ ] Las bases intermedias y los resultados tabulares se guardan en CSV.
- [ ] Después de leer un CSV, se vuelven a declarar los tipos de variable necesarios.
- [ ] Los scripts pueden ejecutarse desde una sesión nueva de R.
- [ ] El orden de ejecución está documentado.

### Documentación

- [ ] Existe un `README.md`.
- [ ] El README explica el objetivo del proyecto.
- [ ] El README explica las fuentes de datos.
- [ ] El README explica la estructura de carpetas.
- [ ] El README explica cómo ejecutar el proyecto.
- [ ] El README identifica los principales scripts.
- [ ] Otra persona podría entender el proyecto sin consultar al autor.

### La prueba definitiva

Si tenés dudas sobre si el proyecto está bien armado, hacé esta prueba.

1. Copiá la carpeta del proyecto a otra ubicación (o pedile a un compañero que la abra en su computadora).
2. Borrá el contenido de `input/` y `output/`.
3. Reiniciá R y fijá la carpeta del proyecto como directorio de trabajo (con `setwd()` en la consola o abriendo el `.Rproj`).
4. Seguí únicamente las instrucciones del README.

Si al final `input/` y `output/` vuelven a tener los mismos archivos que antes, el proyecto es reproducible.
