# ============================================================================
# CLASE 2 — Introducción a R: entorno y sintaxis
# Ciencia de Datos para Economía y Negocios | FCE-UBA | Nicolás Sidicaro
# ============================================================================
# Este script repasa todos los conceptos vistos en la clase 2.
# Ejecutalo línea por línea (Ctrl + Enter) para ir viendo los resultados.
# ============================================================================


# ----------------------------------------------------------------------------
# 1. VARIABLES Y ASIGNACIÓN
# ----------------------------------------------------------------------------

# En R, asignamos valores a variables con el operador <-
# Atajo de teclado en RStudio: Alt + -

nombre <- "Argentina"
pbi <- 632.8
poblacion <- 46
es_latam <- TRUE

# Para ver el valor de una variable, simplemente escribimos su nombre
nombre
pbi

# También funciona el operador =, pero la convención en R es usar <-
inflacion = 211.4

# R es sensible a mayúsculas: estas son tres variables distintas
pais <- "Argentina"
Pais <- "Brasil"
PAIS <- "Chile"

# Buenas prácticas para nombres de variables:
#   - Usar snake_case (palabras separadas con guión bajo)
#   - No empezar con números
#   - No usar tildes, eñes ni espacios
#   - Elegir nombres descriptivos

pbi_per_capita <- pbi / poblacion * 1000  # en dólares
pbi_per_capita


# Tipos de datos básicos
# R tiene cuatro tipos principales:

mi_numero    <- 42.5       # numeric  (números reales)
mi_entero    <- 42L        # integer  (números enteros, notar la L)
mi_texto     <- "hola"     # character (texto, siempre entre comillas)
mi_logico    <- TRUE       # logical  (TRUE o FALSE)

# Para saber el tipo de dato de una variable usamos class()
class(mi_numero)    # "numeric"
class(mi_texto)     # "character"
class(mi_logico)    # "logical"


# ----------------------------------------------------------------------------
# 2. VECTORES
# ----------------------------------------------------------------------------

# Un vector es una secuencia de elementos del MISMO tipo.
# Se crean con la función c() (de "combine" o "concatenate").

provincias <- c("CABA", "Buenos Aires", "Córdoba", "Santa Fe", "Mendoza")
poblaciones <- c(3.1, 17.5, 3.8, 3.5, 2.0)   # en millones
pbi_provincial <- c(215, 180, 95, 78, 52)      # en miles de millones

# Secuencias numéricas
anios <- 2015:2024                  # del 2015 al 2024
meses <- seq(1, 12, by = 1)        # 1, 2, 3, ..., 12
trimestres <- seq(0, 1, by = 0.25) # 0, 0.25, 0.50, 0.75, 1.00

# Repeticiones
unos <- rep(1, times = 5)          # 1 1 1 1 1
patron <- rep(c("T1", "T2"), times = 3)  # T1 T2 T1 T2 T1 T2


# ACCEDER A ELEMENTOS
# En R, los índices empiezan en 1 (no en 0 como en Python)

provincias[1]       # "CABA"
provincias[3]       # "Córdoba"
provincias[c(1,3)]  # "CABA" y "Córdoba"
provincias[2:4]     # "Buenos Aires", "Córdoba", "Santa Fe"

# Excluir elementos con índices negativos
provincias[-1]      # todas menos "CABA"


# VECTORIZACIÓN
# Las operaciones aritméticas se aplican elemento a elemento

pbi_en_millones <- pbi_provincial * 1000
pbi_en_millones

# Esto también funciona con comparaciones
provincias_grandes <- poblaciones > 3
provincias_grandes   # TRUE TRUE TRUE TRUE FALSE

# Filtrar usando condiciones lógicas
provincias[poblaciones > 3]   # provincias con más de 3 millones de habitantes


# IMPORTANTE: todos los elementos de un vector deben ser del mismo tipo.
# Si mezclás tipos, R convierte todo al tipo más general (coerción).

mezcla <- c(1, "dos", TRUE)
mezcla        # "1" "dos" "TRUE" — todo se convirtió a character
class(mezcla) # "character"


# ----------------------------------------------------------------------------
# 3. LISTAS
# ----------------------------------------------------------------------------

# Una lista puede contener elementos de distintos tipos y tamaños.
# Es como una caja con compartimentos etiquetados.

pais_info <- list(
  nombre    = "Argentina",
  pbi       = 632.8,
  poblacion = 46,
  vecinos   = c("Brasil", "Chile", "Uruguay", "Paraguay", "Bolivia"),
  es_latam  = TRUE
)

# Acceder a elementos con $
pais_info$nombre       # "Argentina"
pais_info$vecinos      # el vector completo de vecinos
pais_info$vecinos[1]   # "Brasil"

# También se puede acceder con [[ ]]
pais_info[["pbi"]]     # 632.8

# Ver la estructura de una lista
str(pais_info)


# ----------------------------------------------------------------------------
# 4. DATA FRAMES
# ----------------------------------------------------------------------------

# Un data.frame es lo más parecido a una hoja de Excel en R.
# Es una tabla donde:
#   - Cada columna es un vector (una variable)
#   - Cada fila es una observación
#   - Todas las columnas tienen la misma cantidad de filas

datos <- data.frame(
  provincia  = c("CABA", "Buenos Aires", "Córdoba", "Santa Fe", "Mendoza"),
  poblacion  = c(3.1, 17.5, 3.8, 3.5, 2.0),
  pbi        = c(215, 180, 95, 78, 52),
  region     = c("Pampeana", "Pampeana", "Pampeana", "Pampeana", "Cuyo")
)

# Ver el data frame completo
datos

# Funciones útiles para explorar un data frame
nrow(datos)     # cantidad de filas
ncol(datos)     # cantidad de columnas
head(datos, 3)  # primeras 3 filas
str(datos)      # estructura: tipos de cada columna
summary(datos)  # resumen estadístico

# Acceder a una columna (devuelve un vector)
datos$poblacion
datos$provincia

# Acceder a una fila
datos[1, ]      # primera fila (todas las columnas)

# Acceder a una celda específica
datos[2, 3]     # fila 2, columna 3 (PBI de Buenos Aires)

# Filtrar filas con una condición
datos[datos$poblacion > 3, ]   # provincias con más de 3M de habitantes


# ----------------------------------------------------------------------------
# 5. OPERADORES
# ----------------------------------------------------------------------------

# --- Aritméticos ---
10 + 3     # 13       suma
10 - 3     # 7        resta
10 * 3     # 30       multiplicación
10 / 3     # 3.333... división
10 ^ 2     # 100      potencia
10 %% 3    # 1        módulo (resto de la división)
10 %/% 3   # 3        división entera

# --- De comparación (devuelven TRUE o FALSE) ---
10 == 10   # TRUE     igual a
10 != 5    # TRUE     distinto de
10 > 5     # TRUE     mayor que
10 < 5     # FALSE    menor que
10 >= 10   # TRUE     mayor o igual
10 <= 9    # FALSE    menor o igual

# --- Lógicos ---
TRUE & FALSE    # FALSE    Y (AND): ambos deben ser TRUE
TRUE | FALSE    # TRUE     O (OR): al menos uno debe ser TRUE
!TRUE           # FALSE    Negación (NOT)

# --- Pertenencia ---
"CABA" %in% provincias          # TRUE
"Tucumán" %in% provincias       # FALSE

# --- Ejemplo combinado ---
# ¿Qué provincias tienen PBI > 80 Y población > 3?
datos$provincia[datos$pbi > 80 & datos$poblacion > 3]


# ----------------------------------------------------------------------------
# 6. FUNCIONES BÁSICAS
# ----------------------------------------------------------------------------

# La estructura de una función es: nombre(argumento1, argumento2, ...)

numeros <- c(10, 25, 30, 15, 20, 50, 5)

sum(numeros)       # 155     — suma de todos los elementos
mean(numeros)      # 22.14   — promedio aritmético
length(numeros)    # 7       — cantidad de elementos
class(numeros)     # "numeric" — tipo de dato

# Otras funciones útiles
max(numeros)       # 50      — valor máximo
min(numeros)       # 5       — valor mínimo
sd(numeros)        # 14.96   — desvío estándar
median(numeros)    # 20      — mediana
range(numeros)     # 5 50    — mínimo y máximo

round(mean(numeros), 2)   # 22.14 — redondear a 2 decimales
sort(numeros)              # ordenar de menor a mayor
sort(numeros, decreasing = TRUE)  # de mayor a menor

# Funciones para texto
nchar("Argentina")              # 9 — cantidad de caracteres
paste("Hola", "mundo")          # "Hola mundo" — concatenar
paste0("PBI_", 2024)            # "PBI_2024" — concatenar sin espacio
toupper("argentina")            # "ARGENTINA"
tolower("ARGENTINA")            # "argentina"

# Funciones de inspección
head(numeros, 3)        # primeros 3 elementos
tail(numeros, 3)        # últimos 3 elementos
is.na(NA)               # TRUE — ¿es un valor faltante?
is.numeric(numeros)     # TRUE — ¿es numérico?

# Valores faltantes (NA)
datos_con_na <- c(10, NA, 30, NA, 50)
mean(datos_con_na)                # NA — por defecto, NA contamina
mean(datos_con_na, na.rm = TRUE)  # 30 — na.rm = TRUE ignora los NA
sum(is.na(datos_con_na))          # 2  — contar cuántos NA hay


# ----------------------------------------------------------------------------
# 7. TIPOS DE ARCHIVOS
# ----------------------------------------------------------------------------

# .R   → Script de R. Texto plano con código. Lo que estás leyendo ahora.
#         Se ejecuta línea por línea o por bloque.
#         Se comenta con #
#
# .Rmd → R Markdown. Mezcla código R con texto narrativo.
#         Genera reportes en HTML, PDF o Word.
#         El código va dentro de "chunks" delimitados por ```{r} y ```
#         Útil para el trabajo final de la materia.


# ----------------------------------------------------------------------------
# 8. CÓMO PEDIR AYUDA
# ----------------------------------------------------------------------------

# Desde R:
?mean               # abre la documentación de mean()
help(sum)            # equivalente a ?sum
example(mean)        # ejecuta los ejemplos de la documentación

# Buscar en toda la ayuda:
??regression         # busca "regression" en todos los paquetes

# Recursos online:
#   - Stack Overflow con tag [r]
#   - R for Data Science: r4ds.hadley.nz
#   - Cheatsheets de RStudio: posit.co/resources/cheatsheets
#
# Tip: cuando te aparezca un error, copialo textual y buscalo en Google
# entre comillas. Casi seguro alguien ya tuvo el mismo problema.

