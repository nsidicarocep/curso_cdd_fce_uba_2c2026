# Ciencia de Datos para Economía y Negocios

**Facultad de Ciencias Económicas — Universidad de Buenos Aires**

Docente: Nicolás Sidicaro
Ayudate: Maida Beltrán
2do cuatrimestre 2026

---

## 📋 Presentación del curso

Este curso introduce a estudiantes de la Licenciatura en Economía en las herramientas y conceptos fundamentales de la ciencia de datos, con un enfoque orientado a la aplicación en problemas económicos reales. No busca ser exhaustivo en formalismos matemáticos, sino brindar una base sólida de programación, análisis estadístico y visualización que permita a los estudiantes trabajar con datos de manera autónoma y rigurosa.

El lenguaje de programación utilizado es **R**, elegido por su fortaleza en estadística, econometría y visualización de datos (especialmente `ggplot2`), y por su amplia adopción en investigación económica.

Las clases se organizan en dos instancias semanales:

- **Martes**: clases teóricas (presencial)
- **Viernes**: clases prácticas de programación y código (virtual)

---

## 🔗 Links relevantes

| Recurso | Link |
|---|---|
| Cronograma del curso | [Link al cronograma](https://docs.google.com/spreadsheets/d/1vlUwVtV9uuOB-9Sxx9zMwfloQc3jgI1N1ZVSjjOtKXs/edit?gid=1145842825#gid=1145842825) |
| Consignas del Trabajo Práctico | [Link al TP](...) |
| Bibliografía completa | [Link a bibliografía](https://docs.google.com/spreadsheets/d/1vlUwVtV9uuOB-9Sxx9zMwfloQc3jgI1N1ZVSjjOtKXs/edit?gid=1145842825#gid=1145842825) |
| Clase virtual de los viernes | [Link a la clase](https://meet.google.com/kii-coes-vco) |
| Clases grabadas  | [Link a las clases](https://drive.google.com/drive/u/0/folders/1PD8WfYa_1xUaYj9tJCJqr7lCWyB5rnjH) |
| Recursos adicionales | [Link a los recursos](https://docs.google.com/spreadsheets/d/1vlUwVtV9uuOB-9Sxx9zMwfloQc3jgI1N1ZVSjjOtKXs/edit?gid=1735927625#gid=1735927625) |
| Ejemplo de códigos y carpetas | [Útil para TP](https://github.com/nsidicarocep/ejemplo_datos_empleo) |
| Guía para el Readme | [Útil para TP](https://github.com/nsidicarocep/curso_cdd_fce_uba_2c2026/blob/main/trabajo_practico/guia_readme.md) |
| Guía para instalar R | [Link](https://github.com/nsidicarocep/curso_cdd_fce_uba_2c2026/blob/main/materiales_utiles/GUIA_INSTALACION_R.md) |

### Materiales por clase

Cada clase tiene su propia carpeta dentro de `/clases/` con los siguientes archivos:

| Archivo | Descripción |
|---|---|
| `Clase_XX_Slides.pptx` | Diapositivas de la clase teórica |
| `Clase_XX_Practica.pdf` | Consigna de la práctica |
| `Clase_XX_Codigo_Completo.R` | Script completo de referencia |
| `Clase_XX_Codigo_EnVivo.R` | Script que se completa durante la clase en vivo |

---

## 📁 Estructura de carpetas

```
├── README.md
├── clases/
│   ├── clase_00_presentacion/
│   │   └── Clase_00_Presentacion.pptx
│   ├── clase_01_logica_pseudocodigo/
│   │   ├── Clase_01_Slides.pptx
│   │   └── Clase_01_Ejercicios.pdf
│   ├── clase_02_intro_R/
│   │   ├── Clase_02_Slides.pptx
│   │   ├── Clase_02_Practica.pdf
│   │   ├── Clase_02_Codigo_Completo.R
│   │   └── Clase_02_Codigo_EnVivo.R
│   ├── clase_03_.../
│   │   └── ...
│   └── ...
├── datos/
│   └── (datasets utilizados en clase)
├── trabajo_practico/
│   ├── Consignas_TP.md
│   └── Bases_de_Datos_Disponibles.md
└── bibliografia y links de interes/
    └── Bibliografia.md
```

---

## 📅 Fechas importantes

| Fecha | Evento | Link |
|---|---|---|
| 14/08 | Inicio de clases — Presentación del curso | |
| 18/09 | **Instancia 1** — Estructura de base de datos y primeros descriptivos | | 
| 27/10 | **Instancia 2** — Métodos cuantitativos | |
| 13/11 | **Instancia 3** — Validación de visualizaciones | |
| 24/11 | **Entrega final del TP** | |
| 24/11 al 01/12 | **Presentaciones orales** | |
| :( | Feriados | |

Las tres instancias intermedias son de carácter formativo: permiten recibir devolución y corregir el rumbo antes de la entrega final.
Son obligatorias las entregas y forman parte de la nota final con la siguiente ponderación: 10%, 10% y 10%. Tendrán las tres una nota del 1 al 10.

---

## 📚 Unidades temáticas

### Unidad 1 — Programación en R

Introducción al pensamiento computacional y a la programación. Se trabaja primero con lógica y pseudocódigo (sin computadora) para luego pasar a R: tipos de datos, estructuras, funciones, condicionales, loops, y manipulación de datos con `tidyverse` (`dplyr`, `tidyr`, `readr`). Incluye también joins, manejo de strings, fechas, funciones propias y organización de proyectos.

### Unidad 2 — Estadística para Ciencia de Datos

Estadística descriptiva (medidas de tendencia central, dispersión, distribuciones) e inferencial (muestreo, intervalos de confianza, tests de hipótesis). Se ven técnicas de remuestreo y test no paramétricos. Incluye también tratamiento de datos faltantes, outliers y transformaciones.
Regresión lineal: queda por fuera de las clases, pero se compartirá un documento para quienes hayan cursado econometría y deseen aplicar los conocimientos en el TP. 

### Unidad 3 — Herramientas cuantitativas para economistas

Índices y medidas de uso frecuente en economía: Herfindahl-Hirschman (HHI) y ratios de concentración (CR4/CR8), coeficiente de Gini y curva de Lorenz, Ventajas Comparativas Reveladas (RCA de Balassa), índice de Grubel-Lloyd, e índices de precios (Laspeyres, Paasche, Fisher). Índices complejos para formulación de datos combinados. También se trabajan operaciones habituales como deflactar variables nominales, calcular tasas de variación e indexar series. Clustering. 

### Unidad 4 — Visualización de datos

Principios de diseño gráfico y comunicación visual. Uso de `ggplot2` para la construcción de gráficos estáticos y la gramática de gráficos. Se trabaja sobre customización avanzada (temas, paletas, anotaciones) y narrativa con datos (data storytelling). Incluye un taller práctico de visualización con datos reales.


---

## 🛠️ Software

- [R](https://cran.r-project.org/) + [RStudio](https://posit.co/download/rstudio-desktop/) (entorno principal)
- [Google Colab](https://colab.research.google.com/) (alternativa en la nube, no requiere instalación)

---

## 📖 Bibliografía principal

- Wickham, H., Çetinkaya-Rundel, M., & Grolemund, G. (2023). *R for Data Science* (2nd ed.). O'Reilly. Disponible en [r4ds.hadley.nz](https://r4ds.hadley.nz/) — **Gratuito**
- Diez, D. M., Çetinkaya-Rundel, M., & Barr, C. D. (2019). *OpenIntro Statistics* (4th ed.). OpenIntro. Disponible en [openintro.org](https://www.openintro.org/book/os/) — **Gratuito**

La bibliografía completa se encuentra en el [documento de bibliografía](https://docs.google.com/spreadsheets/d/1iKuWU7Yc_EEUsqabAkBizfgksrgC1FhG1uCD0RJZB-Q/edit?gid=283594947#gid=283594947).

---

## 📊 Evaluación

La evaluación consiste en un **Trabajo Práctico grupal** que se desarrolla a lo largo del cuatrimestre, con tres instancias intermedias de validación y una entrega final:

| Instancia | Qué se evalúa |
|---|---|
| Instancia 1 | Base de datos seleccionada, hipótesis de trabajo y estadísticos iniciales |
| Instancia 2 | Métodos cuantitativos |
| Instancia 3 | Visualizaciones y comunicación de resultados |
| Entrega final | Trabajo Práctico integrador completo |

Los estudiantes eligen una base de datos de un [listado de 22 fuentes disponibles](https://docs.google.com/spreadsheets/d/1vlUwVtV9uuOB-9Sxx9zMwfloQc3jgI1N1ZVSjjOtKXs/edit?gid=0#gid=0), que incluye datos de INDEC, BACI-CEPII, Banco Mundial, BA Data, entre otros.
Si ninguna de las fuentes posibles convence a los integrantes del grupo, podrán presentar una alternativa en las primeras 2 semanas del curso (hasta el 1ro de septiembre) para que los docentes confirmen si cumple con los requisitos de la materia. Esto puede ocurrir, por ejemplo, si los alumnos están más interesados en realizar un análisis de mercado de algo en particular. De todas maneras, se recomienda hacer uso de las bases propuestas por el equipo docente, ya que en la práctica profesional deberán tener plasticidad para hablar de muchos temas. 

---

## 🤖 Uso de herramientas de IA

El curso no prohíbe el uso de herramientas de IA (ChatGPT, Claude, Copilot, etc.), sino que lo enmarca con criterios claros. Se provee una [guía de uso](URL_GUIA_IA) que distingue entre niveles de utilización apropiados según la actividad del curso. El criterio general: la IA es una herramienta, no un sustituto del aprendizaje.

---

## 📬 Contacto

Nicolás Sidicaro — [EMAIL](mailto:nsidicaro.fce@gmail.com)
Maida Beltrán - [EMAIL](maidabeltran0@gmail.com)
