# =============================================================================
# Ciencia de Datos para Economía y Negocios — FCE-UBA
# Clase 5 — Script resuelto (para lectura autónoma)
#
# Tema: Estadística descriptiva y manipulación de datos con la EPH
# Datos: Encuesta Permanente de Hogares, 3er trimestre de 2025 (base Hogar)
# Fuente: INDEC — https://www.indec.gob.ar/indec/web/Institucional-Indec-BasesDeDatos
# =============================================================================

# --- 0. Paquetes necesarios ---------------------------------------------------

library(tidyverse)

# Si no los tienen instalados:
# install.packages("tidyverse")


# =============================================================================
# PARTE I: CARGA Y EXPLORACIÓN DE LOS DATOS
# =============================================================================

# --- 1.1. Lectura de la base -------------------------------------------------

# La base de hogares de la EPH viene en formato texto, separada por punto y coma.
# Usamos read_delim() de readr (parte de tidyverse) indicando el delimitador.

hogares <- read_delim(r"(E:\Docencia\materiales_docencia\ciencia_de_datos\cdd_1c26\diapositivas\datos\usu_hogar_T325.txt)", delim = ";")

# --- 1.2. Primer vistazo a los datos -----------------------------------------

# ¿Cuántas filas y columnas tiene la base?
dim(hogares)

# Estructura general: nombre de cada variable, tipo y primeros valores
glimpse(hogares)

# Las primeras filas como tabla
head(hogares)

# --- 1.3. Seleccionar las variables con las que vamos a trabajar --------------

# La base tiene casi 100 columnas. Para trabajar más cómodos, nos quedamos
# con un subconjunto de variables relevantes.

hogares <- hogares |>
  select(
    CODUSU,          # Identificador de vivienda
    AGLOMERADO,      # Código del aglomerado urbano
    REGION,          # Código de región estadística
    MAS_500,         # Aglomerado de 500.000+ hab. (S/N)
    PONDERA,         # Factor de expansión (para estimar población)
    IV1,             # Tipo de vivienda (1=Casa, 2=Depto, ...)
    II7,             # Régimen de tenencia (1=Propietario, 3=Inquilino, ...)
    IX_TOT,          # Cantidad de miembros del hogar
    IX_MEN10,        # Miembros menores de 10 años
    ITF,             # Ingreso total familiar
    IPCF,            # Ingreso per cápita familiar
    PONDIH           # Ponderador corregido por no respuesta de ingresos
  )


# =============================================================================
# PARTE II: JOINS — Agregar nombres a los códigos
# =============================================================================

# La base usa códigos numéricos para aglomerados y regiones. Para hacer los
# resultados más legibles, creamos tablas auxiliares con los nombres y las
# unimos a la base principal con left_join().

# --- 2.1. Tabla auxiliar de aglomerados ---------------------------------------

# Armamos un tibble (tabla de tidyverse) con los códigos y nombres de cada
# aglomerado, tal como figuran en el diseño de registros del INDEC.

aglomerados <- tibble(
  AGLOMERADO = c(2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 13, 14, 15, 17,
                 18, 19, 20, 22, 23, 25, 26, 27, 29, 30, 31, 32,
                 33, 34, 36, 38, 91, 93),
  nombre_aglo = c(
    "Gran La Plata", "Bahía Blanca-Cerri", "Gran Rosario",
    "Gran Santa Fe", "Gran Paraná", "Posadas", "Gran Resistencia",
    "Comodoro Rivadavia-Rada Tilly", "Gran Mendoza", "Corrientes",
    "Gran Córdoba", "Concordia", "Formosa", "Neuquén-Plottier",
    "Sgo. del Estero-La Banda", "Jujuy-Palpalá", "Río Gallegos",
    "Gran Catamarca", "Gran Salta", "La Rioja", "Gran San Luis",
    "Gran San Juan", "Gran Tucumán-Tafí Viejo", "Santa Rosa-Toay",
    "Ushuaia-Río Grande", "CABA", "Partidos del GBA", "Mar del Plata",
    "Río Cuarto", "San Nicolás-Villa Constitución",
    "Rawson-Trelew", "Viedma-Carmen de Patagones"
  )
)

# --- 2.2. Tabla auxiliar de regiones ------------------------------------------

regiones <- tibble(
  REGION = c(1, 40, 41, 42, 43, 44),
  nombre_region = c(
    "Gran Buenos Aires", "Noroeste", "Noreste",
    "Cuyo", "Pampeana", "Patagonia"
  )
)

# --- 2.3. Left join: unir nombres a la base principal -------------------------

# left_join() conserva TODAS las filas de la tabla de la izquierda (hogares)
# y agrega las columnas de la tabla de la derecha donde haya coincidencia
# en la columna clave (AGLOMERADO o REGION).

hogares <- hogares |>
  left_join(aglomerados, by = "AGLOMERADO") |>
  left_join(regiones,     by = "REGION")

# Verificamos que no haya NAs inesperados en los nombres
# (significaría que algún código de la base no está en nuestra tabla auxiliar)
hogares |>
  filter(is.na(nombre_aglo)) |>
  nrow()

# --- 2.4. Anti join: verificación de cobertura --------------------------------

# ¿Hay algún código de aglomerado en la base que NO esté en nuestra tabla auxiliar?
# anti_join() devuelve las filas de la izquierda SIN match en la derecha.

hogares |>
  distinct(AGLOMERADO) |>
  anti_join(aglomerados, by = "AGLOMERADO")

# Si el resultado tiene 0 filas, nuestra tabla auxiliar cubre todos los casos.


# =============================================================================
# PARTE III: RECATEGORIZACIÓN — if_else() y case_when()
# =============================================================================

# Muchas variables de la EPH vienen codificadas con números. Para el análisis
# conviene crear nuevas variables con etiquetas descriptivas.

hogares <- hogares |>
  mutate(

    # --- 3.1. if_else(): condición binaria (dos opciones) ---------------------

    # Clasificar según tamaño del aglomerado.
    # MAS_500 ya viene como "S" o "N" en la base, pero lo recodificamos
    # para que sea más claro.

    tamano_aglo = if_else(
      MAS_500 == "S",
      "500.000 o más hab.",
      "Menos de 500.000 hab."
    ),

    # --- 3.2. case_when(): condición múltiple (más de dos opciones) -----------

    # Tipo de vivienda (IV1): asignar etiquetas descriptivas.
    # Las condiciones se evalúan en orden; la primera que se cumple "gana".

    tipo_vivienda = case_when(
      IV1 == 1 ~ "Casa",
      IV1 == 2 ~ "Departamento",
      IV1 == 3 ~ "Pieza en inquilinato",
      IV1 == 4 ~ "Pieza en hotel/pensión",
      IV1 == 5 ~ "Local no habitacional",
      .default  = "Otro"
    ),

    # Régimen de tenencia (II7)
    tenencia = case_when(
      II7 == 1 ~ "Propietario (viv. y terreno)",
      II7 == 2 ~ "Propietario (solo vivienda)",
      II7 == 3 ~ "Inquilino/arrendatario",
      II7 == 4 ~ "Ocupante por préstamo",
      II7 == 5 ~ "Ocupante de hecho",
      II7 == 6 ~ "Otra situación",
      .default  = "Sin dato"
    ),

    # Tramo de ingreso per cápita familiar: clasificación propia.
    # Usamos case_when() porque hay más de dos categorías.
    # IMPORTANTE: las condiciones se evalúan de arriba hacia abajo.
    # Si IPCF >= 2000000 ya fue capturado, los siguientes no lo ven.

    tramo_ipcf = case_when(
      IPCF <= 0            ~ "Sin ingreso",
      IPCF <  500000       ~ "Hasta $500.000",
      IPCF <  1000000      ~ "$500.000 a $1.000.000",
      IPCF <  2000000      ~ "$1.000.000 a $2.000.000",
      IPCF >= 2000000      ~ "$2.000.000 o más",
      .default              = "Sin dato"
    ),

    # Tamaño del hogar: condición binaria simple
    hogar_numeroso = if_else(IX_TOT >= 5, "5 o más miembros", "Hasta 4 miembros")
  )

# Verificamos las nuevas columnas
hogares |>
  count(tipo_vivienda, sort = TRUE)

hogares |>
  count(tenencia, sort = TRUE)


# =============================================================================
# PARTE IV: ESTADÍSTICA DESCRIPTIVA — Medidas con ponderador
# =============================================================================

# La EPH es una encuesta por muestreo: cada hogar de la base "representa"
# a varios hogares de la población. El ponderador PONDERA indica cuántos.
# Para estimar correctamente el total poblacional, debemos usar siempre
# el factor de expansión.

# --- 4.1. Total de hogares estimado -------------------------------------------

# La cantidad de filas en la base es el tamaño muestral (n).
# El total poblacional estimado se obtiene sumando PONDERA.

n_muestral   <- nrow(hogares)
n_poblacional <- sum(hogares$PONDERA)

cat("Hogares en la muestra:", n_muestral, "\n")
cat("Hogares estimados en la población:", n_poblacional, "\n")

# --- 4.2. Filtrar hogares con ingreso ----------------------------------------

# Para calcular estadísticas sobre el ingreso, nos quedamos con los hogares
# que declararon ingreso positivo (ITF > 0).
# Nota: en la EPH, ITF == 0 puede indicar que no hay ingresos declarados
# o que la entrevista no se completó.

hogares_con_ingreso <- hogares |>
  filter(ITF > 0)

cat("Hogares con ingreso (muestra):", nrow(hogares_con_ingreso), "\n")
cat("Hogares con ingreso (población):", sum(hogares_con_ingreso$PONDERA), "\n")

# --- 4.3. Media ponderada del ITF ---------------------------------------------

# La función weighted.mean() calcula la media ponderada:
# cada valor se multiplica por su peso antes de promediar.

media_itf <- weighted.mean(hogares_con_ingreso$ITF,
                           w = hogares_con_ingreso$PONDERA)

cat("Media ponderada del ITF:", round(media_itf, 0), "\n")

# --- 4.4. Mediana ponderada ---------------------------------------------------

# R base no tiene una función de mediana ponderada, pero podemos calcularla
# ordenando los datos y buscando el valor donde se acumula el 50% del peso.

mediana_ponderada <- function(x, w) {
  # Ordenar por x
  orden <- order(x)
  x_ord <- x[orden]
  w_ord <- w[orden]

  # Acumular los pesos y buscar dónde se llega al 50%
  w_acum <- cumsum(w_ord) / sum(w_ord)
  x_ord[which(w_acum >= 0.5)[1]]
}

mediana_itf <- mediana_ponderada(hogares_con_ingreso$ITF,
                                 hogares_con_ingreso$PONDERA)

cat("Mediana ponderada del ITF:", round(mediana_itf, 0), "\n")
cat("Diferencia media - mediana:", round(media_itf - mediana_itf, 0), "\n")

# La media es mayor que la mediana => asimetría positiva,
# consistente con lo que sabemos sobre la distribución del ingreso.

# --- 4.5. Desvío estándar ponderado -------------------------------------------

# El desvío estándar ponderado mide la dispersión teniendo en cuenta
# que cada observación tiene un peso distinto.

desvio_ponderado <- function(x, w) {
  mu <- weighted.mean(x, w)
  sqrt(sum(w * (x - mu)^2) / sum(w))
}

sd_itf <- desvio_ponderado(hogares_con_ingreso$ITF,
                           hogares_con_ingreso$PONDERA)

cat("Desvío estándar ponderado del ITF:", round(sd_itf, 0), "\n")

# --- 4.6. Coeficiente de variación (CV) ---------------------------------------

# CV = desvío / media * 100. Permite comparar la dispersión entre grupos
# con medias distintas, porque es un porcentaje.

cv_itf <- sd_itf / media_itf * 100

cat("CV del ITF:", round(cv_itf, 1), "%\n")

# --- 4.7. Rango e IQR --------------------------------------------------------

# Rango: diferencia entre el máximo y el mínimo
rango_itf <- max(hogares_con_ingreso$ITF) - min(hogares_con_ingreso$ITF)
cat("Rango del ITF:", round(rango_itf, 0), "\n")

# IQR ponderado: Q3 - Q1
# Generalizamos la función de mediana para obtener cualquier percentil.

percentil_ponderado <- function(x, w, p) {
  orden <- order(x)
  x_ord <- x[orden]
  w_ord <- w[orden]
  w_acum <- cumsum(w_ord) / sum(w_ord)
  x_ord[which(w_acum >= p)[1]]
}

q1_itf <- percentil_ponderado(hogares_con_ingreso$ITF, hogares_con_ingreso$PONDERA, 0.25)
q3_itf <- percentil_ponderado(hogares_con_ingreso$ITF, hogares_con_ingreso$PONDERA, 0.75)
iqr_itf <- q3_itf - q1_itf

cat("Q1:", round(q1_itf, 0), "\n")
cat("Q3:", round(q3_itf, 0), "\n")
cat("IQR:", round(iqr_itf, 0), "\n")

# Para evitar la notacion cientifica podemos definir options(scipen=999)
# Esto conviene hacerlo arriba de todo al cargar las librerias para que quede ordenado
options(scipen=999)
# Volver a correr los tres codigos anteriores para ver bien el Q1

# --- 4.8. Asimetría y curtosis (ponderadas) -----------------------------------

# Coeficiente de asimetría (skewness): mide si la distribución tiene
# una cola más larga hacia la izquierda (g1 < 0) o la derecha (g1 > 0).

asimetria_ponderada <- function(x, w) {
  mu <- weighted.mean(x, w)
  s  <- desvio_ponderado(x, w)
  n  <- sum(w)
  sum(w * ((x - mu) / s)^3) / n
}

g1_itf <- asimetria_ponderada(hogares_con_ingreso$ITF, hogares_con_ingreso$PONDERA)
cat("Asimetría (g1) del ITF:", round(g1_itf, 2), "\n")

# Curtosis (exceso): mide el peso de las colas de la distribución.
# Se resta 3 para que una distribución normal tenga curtosis = 0.

curtosis_ponderada <- function(x, w) {
  mu <- weighted.mean(x, w)
  s  <- desvio_ponderado(x, w)
  n  <- sum(w)
  sum(w * ((x - mu) / s)^4) / n - 3
}

g2_itf <- curtosis_ponderada(hogares_con_ingreso$ITF, hogares_con_ingreso$PONDERA)
cat("Curtosis (g2) del ITF:", round(g2_itf, 2), "\n")

# g1 > 0 => cola derecha (ingresos altos tiran la media hacia arriba)
# g2 > 0 => leptocúrtica (más eventos extremos de lo esperado)

# --- 4.9. Deciles del IPCF (distribución completa) ----------------------------

# Los deciles dividen la distribución en 10 partes iguales.
# Son clave para analizar desigualdad: ¿cuánto gana el 10% más rico
# respecto del 10% más pobre?

valores <- numeric(9)
for (i in 1:9) {
  valores[i] <- percentil_ponderado(
    hogares_con_ingreso$IPCF,
    hogares_con_ingreso$PONDERA,
    i / 10
  )
}
deciles_ipcf <- tibble(decil = 1:9, valor = valores)

# Ratio decil 9 / decil 1: indicador simple de desigualdad
ratio_d9_d1 <- deciles_ipcf$valor[9] / deciles_ipcf$valor[1]
cat("Ratio D9/D1 del IPCF:", round(ratio_d9_d1, 1), "\n")


# =============================================================================
# PARTE V: ESTADÍSTICAS POR GRUPO — group_by() + summarise()
# =============================================================================

# --- 5.1. Ingreso medio por región --------------------------------------------

# group_by() agrupa los datos; summarise() colapsa cada grupo en una fila
# con las estadísticas que pidamos.

resumen_region <- hogares_con_ingreso |>
  group_by(nombre_region) |>
  summarise(
    hogares_muestra   = n(),
    hogares_poblacion = sum(PONDERA),
    media_itf         = round(weighted.mean(ITF, w = PONDERA), 0),
    mediana_itf       = mediana_ponderada(ITF, PONDERA),
    sd_itf            = round(desvio_ponderado(ITF, PONDERA), 0),
    cv_itf            = round(desvio_ponderado(ITF, PONDERA) /
                                weighted.mean(ITF, w = PONDERA) * 100, 1)
  ) |>
  arrange(desc(media_itf))

print(resumen_region)

# --- 5.2. Ingreso medio por aglomerado (top 10) ------------------------------

resumen_aglo <- hogares_con_ingreso |>
  group_by(nombre_aglo) |>
  summarise(
    hogares_poblacion = sum(PONDERA),
    media_ipcf        = round(weighted.mean(IPCF, w = PONDERA), 0),
    mediana_ipcf      = mediana_ponderada(IPCF, PONDERA),
    g1_ipcf           = round(asimetria_ponderada(IPCF, PONDERA), 2)
  ) |>
  arrange(desc(media_ipcf)) |>
  head(10)

print(resumen_aglo)

# --- 5.3. Distribución del tipo de vivienda por región ------------------------

vivienda_region <- hogares |>
  group_by(nombre_region, tipo_vivienda) |>
  summarise(
    hogares = sum(PONDERA),
    .groups = "drop"
  )

print(vivienda_region)

# --- 5.4. group_by() + mutate(): participación en el total --------------------

# A diferencia de summarise() (que colapsa a una fila por grupo),
# mutate() conserva todas las filas y agrega la estadística grupal.

vivienda_region <- vivienda_region |>
  group_by(nombre_region) |>
  mutate(
    total_region  = sum(hogares),
    participacion = round(hogares / total_region * 100, 1)
  ) |>
  ungroup()

# Resultado: cada fila mantiene sus columnas originales, pero ahora también
# tiene el total de su grupo y su participación porcentual.

vivienda_region |>
  filter(tipo_vivienda %in% c("Casa", "Departamento")) |>
  select(nombre_region, tipo_vivienda, hogares, participacion) |>
  arrange(nombre_region)


# =============================================================================
# PARTE VI: PIVOTS — Reestructurar tablas
# =============================================================================

# --- 6.1. Crear un resumen en formato largo -----------------------------------

# Primero generamos una tabla con el ingreso medio por región y
# tipo de vivienda (solo Casa y Departamento para simplificar).

ingreso_viv_region <- hogares_con_ingreso |>
  filter(tipo_vivienda %in% c("Casa", "Departamento")) |>
  group_by(nombre_region, tipo_vivienda) |>
  summarise(
    media_itf = round(weighted.mean(ITF, w = PONDERA), 0),
    .groups = "drop"
  )

# Esta tabla está en formato largo (tidy): cada fila es una combinación
# región × tipo de vivienda.
print(ingreso_viv_region)

# --- 6.2. pivot_wider(): de largo a ancho -------------------------------------

# Para presentar la tabla como una "planilla" más legible, pasamos el
# tipo de vivienda a columnas.

ingreso_ancho <- ingreso_viv_region |>
  pivot_wider(
    names_from  = tipo_vivienda,
    values_from = media_itf,
    names_prefix = "itf_"
  )

print(ingreso_ancho)

# --- 6.3. pivot_longer(): de ancho a largo ------------------------------------

# La operación inversa: volver al formato tidy. Esto es necesario si
# queremos usar los datos para gráficos con ggplot2 o para hacer
# cálculos con group_by().

ingreso_largo <- ingreso_ancho |>
  pivot_longer(
    cols      = starts_with("itf_"),
    names_to  = "tipo_vivienda",
    names_prefix = "itf_",
    values_to = "media_itf"
  )

print(ingreso_largo)

# --- 6.4. Caso práctico: tabla de estadísticas múltiples ----------------------

# Preparamos un resumen con varias medidas por región, en formato largo,
# y luego lo pivoteamos a formato ancho para presentar.

resumen_largo <- hogares_con_ingreso |>
  group_by(nombre_region) |>
  summarise(
    Media   = round(weighted.mean(ITF, w = PONDERA), 0),
    Mediana = mediana_ponderada(ITF, PONDERA),
    CV      = round(desvio_ponderado(ITF, PONDERA) /
                      weighted.mean(ITF, w = PONDERA) * 100, 1),
    .groups = "drop"
  ) |>
  pivot_longer(
    cols      = c(Media, Mediana, CV),
    names_to  = "estadistico",
    values_to = "valor"
  )

# Ahora pivoteamos para que las regiones sean las columnas
resumen_presentacion <- resumen_largo |>
  pivot_wider(
    names_from  = nombre_region,
    values_from = valor
  )

print(resumen_presentacion)


# =============================================================================
# PARTE VII: RESUMEN GENERAL — Todo junto
# =============================================================================

# Tabla final: estadísticas descriptivas completas por región,
# combinando todo lo visto en la clase.

resumen_final <- hogares_con_ingreso |>
  group_by(nombre_region) |>
  summarise(
    n_hogares = sum(PONDERA),
    media     = round(weighted.mean(IPCF, w = PONDERA), 0),
    mediana   = mediana_ponderada(IPCF, PONDERA),
    desvio    = round(desvio_ponderado(IPCF, PONDERA), 0),
    cv        = round(desvio_ponderado(IPCF, PONDERA) /
                        weighted.mean(IPCF, w = PONDERA) * 100, 1),
    q1        = percentil_ponderado(IPCF, PONDERA, 0.25),
    q3        = percentil_ponderado(IPCF, PONDERA, 0.75),
    iqr       = q3 - q1,
    asimetria = round(asimetria_ponderada(IPCF, PONDERA), 2),
    .groups   = "drop"
  ) |>
  arrange(desc(media))

print(resumen_final)

# --- Comparación de un aglomerado vs. el resto --------------------------------

# Elegir el aglomerado a comparar
aglo_elegido <- "CABA"

hogares_con_ingreso |>
  mutate(
    grupo = if_else(nombre_aglo == aglo_elegido, aglo_elegido, "Resto del país")
  ) |>
  group_by(grupo) |>
  summarise(
    hogares   = sum(PONDERA),
    media     = round(weighted.mean(IPCF, w = PONDERA), 0),
    mediana   = mediana_ponderada(IPCF, PONDERA),
    cv        = round(desvio_ponderado(IPCF, PONDERA) /
                        weighted.mean(IPCF, w = PONDERA) * 100, 1),
    asimetria = round(asimetria_ponderada(IPCF, PONDERA), 2),
    .groups   = "drop"
  )

# --- Comparación de todos los aglomerados vs. uno de referencia ---------------

aglo_referencia <- "CABA"

# Calcular estadísticas de cada aglomerado
stats_aglo <- hogares_con_ingreso |>
  filter(!is.na(nombre_aglo), nombre_aglo != aglo_referencia) |>
  group_by(nombre_aglo) |>
  summarise(
    hogares   = sum(PONDERA),
    media     = round(weighted.mean(IPCF, w = PONDERA), 0),
    mediana   = mediana_ponderada(IPCF, PONDERA),
    cv        = round(desvio_ponderado(IPCF, PONDERA) /
                        weighted.mean(IPCF, w = PONDERA) * 100, 1),
    .groups   = "drop"
  ) |>
  arrange(desc(media))

# Obtener la media del aglomerado de referencia para comparar
media_ref <- hogares_con_ingreso |>
  filter(nombre_aglo == aglo_referencia) |>
  summarise(m = weighted.mean(IPCF, w = PONDERA)) |>
  pull(m)

# Agregar la diferencia porcentual respecto del aglomerado de referencia
stats_aglo <- stats_aglo |>
  mutate(
    diff_vs_ref = round((media / media_ref - 1) * 100, 1)
  )

stats_aglo


# ¿Qué podemos concluir?
# - Todas las regiones muestran asimetría positiva en el IPCF.
# - La media siempre supera a la mediana: la distribución del ingreso
#   tiene cola derecha en todos los casos.
# - El CV permite comparar la dispersión entre regiones que tienen
#   niveles de ingreso muy distintos.
