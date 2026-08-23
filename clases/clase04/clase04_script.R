# =============================================================================
# Clase 04 — Tidyverse: lectura de datos y verbos principales
# Ciencia de Datos para Economía y Negocios | FCE-UBA
# =============================================================================
# 
# Dataset: Empleo registrado por departamento y actividad económica (establecimientos)
# Fuente: MECON (CEPXXI) + Trabajo 
# Variables principales:
#   - anio: año de referencia (2021, 2022)
#   - provincia: nombre de la provincia
#   - departamento: nombre del departamento/partido/comuna
#   - letra: sector de actividad económica (clasificación CLAE)
#   - clae2 / clae6: código de actividad (2 y 6 dígitos)
#   - Empleo: cantidad de empleados registrados
#   - Establecimientos: cantidad de establecimientos productivos
#   - empresas_exportadoras: cantidad de empresas que exportan
# =============================================================================

# --- 0. Setup ----------------------------------------------------------------

# install.packages("tidyverse")   # descomentar solo la primera vez
library(tidyverse)

# Definimos la ruta base del proyecto (modificar según cada usuario)
# Por ejemplo, en mi computadora lo tengo cargado en el siguiente lugar 
setwd(r'(D:/Docencia/UBA/Ciencia de datos/curso_cdd_fce_uba_1c2026/)')
instub <- "datos"   # Lugar donde estan cargadas las bases 
outstub <- "output"   # Lugar donde vamos a guardar el resultado 
# --- 1. Lectura de datos con read_csv() -------------------------------------

# Construimos el path con file.path() (funciona en Windows, Mac y Linux)
ruta_datos <- file.path(instub, "Datos_por_departamento_y_actividad.csv")

establecimientos <- read_csv(ruta_datos)

# --- 2. Exploración inicial --------------------------------------------------

# Estructura del dataset
glimpse(establecimientos)

# Primeras filas
head(establecimientos)

# Dimensiones
dim(establecimientos)    # filas x columnas

# Nombres de las columnas
names(establecimientos)

# --- 3. select() — Elegir columnas ------------------------------------------

# Nos quedamos con las columnas que vamos a usar
establecimientos_sel <- establecimientos |>
  select(anio, provincia, departamento, letra, Empleo, Establecimientos)

head(establecimientos_sel)

# --- 4. filter() — Filtrar filas ---------------------------------------------

# Empleo en la provincia de Buenos Aires, año 2022
establecimientos_sel |>
  filter(provincia == "Buenos Aires", anio == 2022)

# --- 5. mutate() — Crear nuevas columnas ------------------------------------

# Calcular el tamaño promedio de cada establecimiento (empleados / establec.)
establecimientos_sel <- establecimientos_sel |>
  mutate(
    emp_por_estab = round(Empleo / Establecimientos, 1)
  )

head(establecimientos_sel)

# --- 6. arrange() — Ordenar filas --------------------------------------------

# ¿Qué departamentos tienen los establecimientos más grandes (en promedio)?
establecimientos_sel |>
  filter(anio == 2022) |>
  arrange(desc(emp_por_estab))

# --- 7. summarise() + group_by() — Resumir por grupos -----------------------

# Empleo total por provincia, año 2022
empleo_provincia <- establecimientos_sel |>
  filter(anio == 2022) |>
  group_by(provincia) |>
  summarise(
    empleo_total = sum(Empleo, na.rm = TRUE)
  ) |>
  arrange(desc(empleo_total))

empleo_provincia

# --- 8. Guardar resultados ---------------------------------------------------

# Crear la carpeta de salida si no existe
dir.create(file.path(outstub, "clase03"), recursive = TRUE, showWarnings = FALSE)

# Exportar el resumen a CSV
write_csv(
  empleo_provincia,
  file.path(outstub, "clase03", "empleo_por_provincia_2022.csv")
)
