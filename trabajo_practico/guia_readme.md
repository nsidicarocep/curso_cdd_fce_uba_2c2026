# Guía para escribir un buen README en GitHub

## Ciencia de Datos para Economía y Negocios — FCE-UBA

---

## ¿Qué es un README?

Un archivo `README.md` es el punto de entrada a cualquier repositorio. Es lo primero que ve una persona al acceder al proyecto en GitHub y cumple una función similar a la introducción de un informe: presenta el trabajo, explica su propósito y orienta al lector sobre cómo está organizado el contenido.

En el contexto de esta materia, el README debe permitir que cualquier persona (el docente, un compañero, o ustedes mismos en el futuro) entienda de qué se trata el proyecto, qué datos utiliza, qué análisis realiza y cómo navegar el repositorio.

---

## ¿Qué debe incluir el README del Trabajo Práctico?

El README de su proyecto final debe cubrir, como mínimo, los siguientes puntos:

**1. Título del proyecto.** Un nombre claro y descriptivo.

**2. Integrantes del grupo.** Nombres completos.

**3. Objetivo del trabajo.** ¿Qué pregunta buscan responder? ¿Cuál es la hipótesis que guía el análisis?

**4. Base de datos utilizada.** ¿De dónde provienen los datos? ¿Qué período cubren? Incluir un link a la fuente original.

**5. Descripción del análisis realizado.** Un resumen breve de los pasos seguidos: limpieza, exploración, métodos aplicados, visualizaciones.

**6. Estructura del repositorio.** Una descripción de las carpetas y archivos principales para que el lector sepa dónde encontrar cada cosa.

**7. Instrucciones de reproducción.** ¿Qué paquetes de R se necesitan? ¿En qué orden se deben ejecutar los scripts? ¿Hay algún paso manual necesario (como descargar un archivo)?

**8. Conclusiones principales.** Un párrafo breve con los hallazgos más relevantes.

---

## Markdown: sintaxis básica

Los archivos `.md` utilizan Markdown, un lenguaje de marcado ligero que GitHub renderiza automáticamente. A continuación se presentan los elementos más comunes.

### Encabezados

Se crean con el símbolo `#`. Cuantos más `#`, menor es la jerarquía:

```markdown
# Título principal
## Sección
### Subsección
```

Usar los encabezados de forma consistente permite que el documento tenga una estructura clara y navegable.

### Texto con formato

```markdown
**texto en negrita**
*texto en cursiva*
~~texto tachado~~
`código en línea`
```

Resultado: **texto en negrita**, *texto en cursiva*, ~~texto tachado~~, `código en línea`.

### Listas

Listas sin orden:

```markdown
- Primer elemento
- Segundo elemento
  - Sub-elemento
```

Listas numeradas:

```markdown
1. Primer paso
2. Segundo paso
3. Tercer paso
```

### Links

```markdown
[texto visible](https://url-destino.com)
```

Por ejemplo: `[INDEC](https://www.indec.gob.ar)` se ve como [INDEC](https://www.indec.gob.ar).

### Imágenes

```markdown
![texto alternativo](ruta/a/la/imagen.png)
```

Se pueden usar imágenes alojadas en el propio repositorio (por ejemplo, un gráfico guardado en `output/graficos/`) o URLs externas.

### Bloques de código

Para mostrar código de R u otros lenguajes, usar tres acentos graves y el nombre del lenguaje:

````markdown
```r
library(tidyverse)
datos <- read_csv("input/datos_procesados.csv")
```
````

### Tablas

```markdown
| Columna 1 | Columna 2 | Columna 3 |
|---|---|---|
| Valor A | Valor B | Valor C |
| Valor D | Valor E | Valor F |
```

Resultado:

| Columna 1 | Columna 2 | Columna 3 |
|---|---|---|
| Valor A | Valor B | Valor C |
| Valor D | Valor E | Valor F |

### Líneas de separación

Tres guiones generan una línea horizontal:

```markdown
---
```

### Citas

```markdown
> Este es un bloque de cita.
```

> Este es un bloque de cita.

---

## Ejemplo de README para el Trabajo Práctico

A continuación se presenta un ejemplo completo que pueden usar como punto de partida. Reemplacen el contenido con la información de su propio proyecto.

---

````markdown
# Divergencia económica entre provincias argentinas

## Integrantes

- María López
- Juan Pérez
- Ana García

## Objetivo

Explorar la evolución del Producto Bruto Geográfico (PBG) provincial entre 2004
y 2023 para analizar si las economías provinciales tienden a converger o divergir
en términos de producto per cápita. La hipótesis de trabajo es que las provincias
con mayor base industrial presentan una trayectoria de crecimiento más estable
que aquellas dependientes de actividades extractivas.

## Datos

- **Fuente principal:**
  [PBG Provincial — INDEC](https://www.indec.gob.ar)
- **Fuente complementaria:**
  [Proyecciones de población — INDEC](https://www.indec.gob.ar)
- **Período:** 2004–2023
- **Unidad de análisis:** provincias argentinas

## Análisis realizado

1. Limpieza y reestructuración de las bases originales (formatos
   heterogéneos entre provincias).
2. Construcción de la variable PBG per cápita combinando datos de producto
   y población.
3. Análisis exploratorio: distribución, valores faltantes, outliers.
4. Cálculo de tasas de crecimiento y coeficiente de variación interprovincial.
5. Visualizaciones de la evolución temporal y de la dispersión entre provincias.

## Estructura del repositorio

```
proyecto/
├── raw/              # Bases originales descargadas de INDEC
├── auxiliar/          # Proyecciones de población
├── input/             # Bases procesadas y listas para el análisis
├── output/
│   ├── tablas/        # Tablas de resultados exportadas
│   └── graficos/      # Visualizaciones generadas
├── script/
│   ├── 01_limpieza.R
│   ├── 02_exploratorio.R
│   ├── 03_analisis.R
│   └── 04_visualizaciones.R
├── utils/
│   └── calcular_tasa_crecimiento.R
└── README.md
```

## Reproducción

### Paquetes necesarios

```r
install.packages(c("tidyverse", "readxl", "scales"))
```

### Orden de ejecución

1. `script/01_limpieza.R` — Lee las bases de `raw/` y `auxiliar/`, genera
   los archivos en `input/`.
2. `script/02_exploratorio.R` — Análisis descriptivo inicial.
3. `script/03_analisis.R` — Cálculos principales.
4. `script/04_visualizaciones.R` — Genera los gráficos en `output/graficos/`.

## Conclusiones principales

El análisis muestra que la dispersión del PBG per cápita entre provincias
se mantuvo estable en el período estudiado, sin evidencia clara de convergencia.
Las provincias con perfil extractivo presentaron mayor volatilidad,
consistente con la hipótesis inicial.
```
````

---

## Consejos finales

- **Escriban el README como si la persona que lo lee no los conociera.** Toda la información necesaria para entender y reproducir el trabajo debe estar en el documento.
- **Mantengan el README actualizado.** Si cambian la estructura del repositorio, los scripts o el enfoque del análisis, actualicen el README en consecuencia.
- **Sean concisos.** El README no es el trabajo en sí, sino una guía para navegarlo. No es necesario copiar el contenido de la presentación final.
- **Revisen cómo se ve.** Después de subir el archivo a GitHub, abran el repositorio en el navegador y verifiquen que el Markdown se renderice correctamente.
