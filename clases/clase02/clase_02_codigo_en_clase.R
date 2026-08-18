# ============================================================================
# CLASE 2 — Ejercicios integradores (live coding en clase)
# Ciencia de Datos para Economía y Negocios | FCE-UBA | Nicolás Sidicaro
# ============================================================================
# Estos dos ejercicios están pensados para resolver en vivo con los
# estudiantes, mostrando paso a paso cómo se combinan las herramientas
# vistas en clase.
# ============================================================================


# ============================================================================
# EJERCICIO INTEGRADOR 1
# Análisis de la canasta básica alimentaria
# ============================================================================
#
# Contexto: tenemos datos (inventados) de precios de 8
# productos de la canasta básica alimentaria relevados en dos meses.
# Vamos a construir el análisis desde cero usando solo lo que vimos hoy.
#

# --- Paso 1: Crear los datos ---

productos <- c("Pan", "Leche", "Arroz", "Fideos",
               "Aceite", "Carne", "Huevos", "Yerba")

precios_enero <- c(1200, 950, 890, 750, 2100, 4500, 1800, 2300)
precios_febrero <- c(1350, 1020, 920, 810, 2250, 4900, 1950, 2500)

# --- Paso 2: Explorar los vectores ---

# ¿cuántos productos tenemos?
length(productos)
length(precios_enero)
length(precios_febrero)

# ¿qué tipo de dato es?
typeof(productos)
typeof(precios_enero)
typeof(precios_febrero)

# --- Paso 3: Estadísticas descriptivas de cada mes ---

# Enero
# precio promedio
mean(precios_enero)
# producto más barato
min(precios_enero)
# producto más caro
max(precios_enero)

# Febrero
# precio promedio
mean(precios_febrero)
# producto más barato
min(precios_febrero)
# producto más caro
max(precios_febrero)

# --- Paso 4: Calcular la variación de precios ---

# variación absoluta en pesos
mean(precios_febrero) - mean(precios_enero)
variacion_absoluta <- precios_febrero - precios_enero

# variación porcentual
(precios_febrero - precios_enero)/precios_enero * 100
variacion_porcentual <- variacion_absoluta / precios_enero * 100 # Puedo reutilizar un valor definido previamente

# redondeado a 1 decimal
variacion_porcentual_1 <- round(variacion_porcentual,digits = 2)

# --- Paso 5: ¿Qué producto subió más? ---

productos[which.max(variacion_porcentual)]    # nombre del producto

# porcentaje de suba
variacion_porcentual[which.max(variacion_porcentual)]

# ¿Y cuál subió menos?
productos[which.min(variacion_porcentual)]    # nombre del producto
productos[which.min(variacion_absoluta)]    # nombre del producto
variacion_porcentual[which.min(variacion_porcentual)]

# --- Paso 6: Armar un data frame con todo ---
tabla <- data.frame(producto = productos,
                    precio_enero = precios_enero,
                    precio_febrero = precios_febrero,
                    variacion_absoluta = variacion_absoluta,
                    variacion_porcentual = variacion_porcentual)

# ver la tabla completa
View(tabla)

# --- Paso 7: Filtrar productos que subieron más del 10% ---
tabla[variacion_porcentual > 10,]

# --- Paso 8: Costo total de la canasta en cada mes ---
costo_enero <- sum(tabla$precio_enero)
costo_febrero <- sum(tabla$precio_febrero)

# ¿Inflación?
inflacion_canasta <- (sum(tabla$precio_febrero) - sum(tabla$precio_enero))/sum(tabla$precio_enero) * 100
paste0("La canasta subió un ", round(inflacion_canasta, 1), "% en un mes")

# --- Paso 9: Guardar la info en una lista resumen ---

resumen <- list(
  periodo       = "Enero - Febrero 2026",
  n_productos   = length(productos),
  costo_enero   = costo_enero,
  costo_febrero = costo_febrero,
  inflacion_pct = round(inflacion_canasta, 1),
  producto_mas_suba = productos[which.max(variacion_porcentual)]
)

resumen$inflacion_pct
resumen$producto_mas_suba


# ============================================================================
# EJERCICIO INTEGRADOR 2
# Comparación de indicadores económicos entre países
# ============================================================================
#
# Contexto: armamos una tabla con indicadores de 6 países latinoamericanos
# y la analizamos usando todo lo visto: vectores, operadores, funciones,
# data frames, listas.
#

# --- Paso 1: Crear los vectores ---

pais       <- c("Argentina", "Brasil", "Chile", "Colombia", "México", "Perú")
pbi        <- c(632, 1920, 301, 344, 1322, 242)   # en miles de millones USD
poblacion  <- c(46, 214, 19, 51, 127, 33)          # en millones
inflacion  <- c(211, 4.6, 3.9, 9.3, 4.7, 6.5)     # porcentaje anual
desempleo  <- c(6.2, 7.9, 8.5, 10.2, 2.8, NA)     # porcentaje (Perú no tiene dato)

# --- Paso 2: Calcular PBI per cápita ---

# ¿Quién tiene el mayor PBI per cápita?

# --- Paso 3: Armar el data frame ---

# --- Paso 4: Explorar la tabla ---

str(latam)       # estructura
summary(latam)   # resumen estadístico — notar el NA en desempleo
nrow(latam)      # 6 países
ncol(latam)      # 6 variables

# --- Paso 5: Preguntas con operadores y funciones ---

# ¿Cuáles tienen inflación de un dígito (< 10)?

# ¿Cuáles tienen PBI per cápita mayor a 10.000 USD?

# ¿Cuál es el promedio de desempleo? (cuidado con el NA)

# ¿Cuántos países tienen dato de desempleo?

# --- Paso 6: Clasificar países ---

# Crear una columna que diga si el PBI es "Alto" (> 500) o "Bajo" (<= 500)

# --- Paso 7: Operaciones con texto ---

# Crear etiquetas combinando nombre y PBI per cápita

# --- Paso 8: Ranking de PBI per cápita ---

orden <- order(latam$pbi_pc, decreasing = TRUE)
latam_ordenado <- latam[orden, ]
latam_ordenado   # tabla ordenada de mayor a menor PBI per cápita

# --- Paso 9: Resumen final en una lista ---

resumen_latam <- list(
  n_paises          = nrow(latam),
  pbi_total         = sum(latam$pbi),
  poblacion_total   = sum(latam$poblacion),
  pbi_pc_promedio   = round(mean(latam$pbi_pc), 0),
  pais_mayor_pbi_pc = pais[which.max(pbi_pc)],
  pais_menor_pbi_pc = pais[which.min(pbi_pc)],
  inflacion_maxima  = paste0(pais[which.max(inflacion)], " (", max(inflacion), "%)")
)

# Mostrar el resumen

# --- Paso 10: Mensaje final ---

paste("En los", resumen_latam$n_paises, "países analizados,",
      "el PBI per cápita promedio es de USD", resumen_latam$pbi_pc_promedio,
      "y la población total es de", resumen_latam$poblacion_total, "millones.")
