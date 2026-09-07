# =============================================================================
# PRÁCTICA 2. Análisis exploratorio de datos (EDA) de punta a punta
# Ciencia de Datos para Economía y Negocios — FCE-UBA
#
# Objetivo: recorrer el flujo completo de un EDA sobre una base nueva, que es
# exactamente lo que se pide en la INSTANCIA 1 del Trabajo Práctico:
# entender la base, describir las variables y presentar los primeros
# descriptivos.
#
# Contenidos
#   1. Carga de datos y diccionario de variables
#   2. Primer vistazo: dimensiones, tipos, faltantes
#   3. summary() y skimr::skim()
#   4. Tablas de frecuencia (simples, cruzadas, con márgenes)
#   5. Histogramas con gráficos base
#   6. Boxplots con gráficos base y detección de outliers
#   7. Percentiles y ratios entre percentiles (p90/p10, p75/p25, top10/bottom40)
#   8. Matriz de correlaciones (Pearson y Spearman)
#   9. Checklist de la primera entrega del TP
#
# Datos: World Development Indicators (Banco Mundial), vía el paquete WDI.
# Tema: la brecha digital. ¿Qué tan desigual es el acceso a conectividad
# entre países, y con qué otras dimensiones del desarrollo se relaciona?
# =============================================================================


# =============================================================================
# 0. PAQUETES
# =============================================================================

# install.packages(c("tidyverse", "WDI", "skimr"))

library(tidyverse)
library(WDI)
library(skimr)

# Gráficos base: dos filas x dos columnas cuando lo necesitemos.
# Guardamos la configuración original para poder volver.
par_original <- par(no.readonly = TRUE)


# =============================================================================
# 1. CARGA DE DATOS Y DICCIONARIO DE VARIABLES
# =============================================================================

# --- 1.1. Elección de los indicadores ----------------------------------------

# Un EDA no arranca por el código, arranca por la pregunta. La nuestra es:
# ¿cómo se distribuye el acceso a la conectividad entre países y qué otras
# variables acompañan esa distribución?
#
# Indicadores elegidos (código del Banco Mundial : significado)
#   IT.NET.USER.ZS   % de la población que usa internet
#   IT.CEL.SETS.P2   suscripciones a telefonía móvil cada 100 habitantes
#   IT.NET.BBND.P2   suscripciones a banda ancha fija cada 100 habitantes
#   EG.ELC.ACCS.ZS   % de la población con acceso a electricidad
#   SP.URB.TOTL.IN.ZS % de la población que vive en zonas urbanas
#   SE.SEC.ENRR      tasa bruta de matriculación en secundaria
#   SL.TLF.CACT.FE.ZS tasa de actividad femenina (15+)
#   SP.POP.TOTL      población total (la usamos como ponderador y como escala)
#
# Nota: si quieren buscar otros indicadores, WDIsearch() busca por palabra clave.
# WDIsearch("broadband")

anio <- 2022

wdi_raw <- WDI(
  indicator = c(
    internet   = "IT.NET.USER.ZS",
    movil      = "IT.CEL.SETS.P2",
    banda_ancha = "IT.NET.BBND.P2",
    electricidad = "EG.ELC.ACCS.ZS",
    urbano     = "SP.URB.TOTL.IN.ZS",
    secundaria = "SE.SEC.ENRR",
    activ_fem  = "SL.TLF.CACT.FE.ZS",
    poblacion  = "SP.POP.TOTL"
  ),
  start = anio, end = anio,
  extra = TRUE          # trae región, grupo de ingreso, coordenadas, etc.
)

# La descarga tarda. Conviene guardarse una copia local para no depender de
# la conexión cada vez que corren el script (y para que el trabajo sea
# reproducible: en el TP, la base cruda va en la carpeta raw/).
# write_csv(wdi_raw, "datos/wdi_brecha_digital_2022.csv")
# wdi_raw <- read_csv("datos/wdi_brecha_digital_2022.csv")


# --- 1.2. Filtrado de agregados ----------------------------------------------

# WDI devuelve países PERO TAMBIÉN agregados regionales ("América Latina y el
# Caribe", "Ingreso alto", "Mundo"). Si no los sacamos, estaríamos mezclando
# unidades de observación distintas: un error clásico y grave en el TP.
# Los agregados tienen region == "Aggregates".

wdi <- wdi_raw |>
  filter(region != "Aggregates", !is.na(region), region != "") |>
  select(
    pais = country, iso3c, region, ingreso = income,
    internet, movil, banda_ancha, electricidad,
    urbano, secundaria, activ_fem, poblacion
  ) |>
  mutate(
    # Las categóricas como factor, con las categorías de ingreso ordenadas
    # de menor a mayor. Esto importa para que los boxplots y las tablas
    # salgan en un orden que se pueda leer.
    ingreso = factor(
      ingreso,
      levels = c("Low income", "Lower middle income",
                 "Upper middle income", "High income", "Not classified"),
      labels = c("Ingreso bajo", "Ingreso medio-bajo",
                 "Ingreso medio-alto", "Ingreso alto", "Sin clasificar")
    ),
    region = factor(region),
    # Variable derivada: población en millones, más legible.
    poblacion_mill = poblacion / 1e6
  )


# --- 1.3. Diccionario de variables -------------------------------------------

# La consigna de la entrega 1 pide describir qué significa cada variable, qué
# valores puede tomar y de qué tipo es. Conviene armar el diccionario COMO
# OBJETO DE R, no como texto suelto en la PPT: así se actualiza solo y se
# exporta a la presentación.

diccionario <- tribble(
  ~variable,        ~descripcion,                                          ~tipo,        ~unidad,          ~rango_teorico,
  "pais",           "Nombre del país",                                     "Categórica", "-",              "-",
  "iso3c",          "Código ISO de 3 letras (identificador único)",        "Categórica", "-",              "-",
  "region",         "Región geográfica del Banco Mundial",                 "Categórica", "-",              "7 categorías",
  "ingreso",        "Grupo de ingreso del Banco Mundial",                  "Ordinal",    "-",              "4 categorías",
  "internet",       "Población que usa internet",                          "Numérica",   "% de población", "0 a 100",
  "movil",          "Suscripciones a telefonía móvil",                     "Numérica",   "cada 100 hab.",  "0 a +200",
  "banda_ancha",    "Suscripciones a banda ancha fija",                    "Numérica",   "cada 100 hab.",  "0 a ~50",
  "electricidad",   "Población con acceso a electricidad",                 "Numérica",   "% de población", "0 a 100",
  "urbano",         "Población que vive en zonas urbanas",                 "Numérica",   "% de población", "0 a 100",
  "secundaria",     "Tasa bruta de matriculación en secundaria",           "Numérica",   "%",              "0 a +100",
  "activ_fem",      "Tasa de actividad femenina (15 años y más)",          "Numérica",   "% de mujeres",   "0 a 100",
  "poblacion",      "Población total",                                     "Numérica",   "personas",       "> 0"
)

print(diccionario, n = Inf)

# Ojo con "movil" y "secundaria": pueden superar 100 y NO es un error.
# Móvil, porque una persona puede tener más de una línea. Secundaria, porque
# la tasa bruta incluye a quienes están fuera de la edad teórica del nivel.
# Saber esto ANTES de ver el histograma evita "corregir" datos que están bien.
# Ese chequeo contra la documentación de la fuente es parte del EDA.


# =============================================================================
# 2. PRIMER VISTAZO: DIMENSIONES, TIPOS Y FALTANTES
# =============================================================================

# --- 2.1. Dimensiones y estructura -------------------------------------------

dim(wdi)          # filas (países) y columnas (variables)
nrow(wdi)
ncol(wdi)
names(wdi)

glimpse(wdi)      # tipo y primeros valores de cada columna
head(wdi)
str(wdi)          # equivalente de base R a glimpse()

# ¿La unidad de observación es única? Si hay iso3c repetidos, algo está mal.
sum(duplicated(wdi$iso3c))
n_distinct(wdi$iso3c) == nrow(wdi)


# --- 2.2. Tipos de variable ---------------------------------------------------

# Una forma rápida de listar el tipo de cada columna, útil para la PPT.
sapply(wdi, class)

tipos <- tibble(
  variable = names(wdi),
  tipo_r   = sapply(wdi, function(x) class(x)[1])
)
tipos


# --- 2.3. Valores faltantes ---------------------------------------------------

# Los NA no son un detalle: definen sobre qué países realmente podemos hablar.
# En la entrega final se pide explícitamente el análisis de faltantes, pero
# conviene mirarlo desde el principio.

# Cantidad de NA por variable
colSums(is.na(wdi))

# En porcentaje, ordenado de peor a mejor
faltantes <- wdi |>
  summarise(across(everything(), ~ mean(is.na(.x)) * 100)) |>
  pivot_longer(everything(), names_to = "variable", values_to = "pct_na") |>
  arrange(desc(pct_na))

faltantes

# ¿Cuántos países tienen la información completa en las variables numéricas?
vars_num <- c("internet", "movil", "banda_ancha", "electricidad",
              "urbano", "secundaria", "activ_fem", "poblacion")

wdi |>
  mutate(n_na = rowSums(is.na(across(all_of(vars_num))))) |>
  count(n_na)

# ¿Los faltantes se reparten al azar o se concentran en algún grupo?
# Esta pregunta es clave: si los NA se concentran en los países de ingreso bajo,
# cualquier promedio que calculemos va a estar sesgado hacia arriba.
wdi |>
  group_by(ingreso) |>
  summarise(
    n = n(),
    na_internet    = sum(is.na(internet)),
    na_banda_ancha = sum(is.na(banda_ancha)),
    na_secundaria  = sum(is.na(secundaria)),
    .groups = "drop"
  )

# Para el resto del análisis trabajamos con una base que tiene la variable
# central (internet) observada. No borramos los NA de las demás: los vamos a
# manejar variable por variable, que es lo honesto.
wdi_analisis <- wdi |> filter(!is.na(internet))

nrow(wdi_analisis)   # cuántos países quedan
setdiff(wdi$pais, wdi_analisis$pais)   # cuáles quedaron afuera


# =============================================================================
# 3. summary() Y skimr::skim()
# =============================================================================

# --- 3.1. summary() -----------------------------------------------------------

# summary() sobre un data.frame da, para cada variable numérica: mínimo, primer
# cuartil, mediana, media, tercer cuartil, máximo y cantidad de NA. Para las
# categóricas (factor) da el conteo por categoría.

summary(wdi_analisis)

# Sobre una sola variable
summary(wdi_analisis$internet)

# summary() guarda un objeto con nombres, se puede extraer un valor puntual
resumen_internet <- summary(wdi_analisis$internet)
resumen_internet["Median"]
resumen_internet["Mean"]

# Lectura rápida: si la media es bastante menor que la mediana, la distribución
# tiene cola a la izquierda; si es mayor, cola a la derecha. Comparar las dos
# es el diagnóstico de asimetría más barato que existe.
mean(wdi_analisis$internet) - median(wdi_analisis$internet)


# --- 3.2. skimr::skim() -------------------------------------------------------

# skim() es summary() con esteroides: agrega desvío estándar, porcentaje de
# completitud y un mini histograma de texto. Es la mejor primera foto de una
# base que uno no conoce.

skim(wdi_analisis)

# Solo algunas variables
wdi_analisis |>
  select(internet, movil, banda_ancha, electricidad) |>
  skim()

# skim() por grupo: acá empieza a aparecer la historia del trabajo.
wdi_analisis |>
  group_by(ingreso) |>
  skim(internet, banda_ancha)

# skim() devuelve un data.frame, así que se puede filtrar y exportar.
# Esto sirve para armar la tabla de descriptivas de la PPT sin copiar a mano.
tabla_skim <- wdi_analisis |>
  select(all_of(vars_num)) |>
  skim() |>
  as_tibble() |>
  select(variable = skim_variable,
         n_faltantes = n_missing,
         completitud = complete_rate,
         media = numeric.mean,
         sd = numeric.sd,
         p0 = numeric.p0, p25 = numeric.p25, p50 = numeric.p50,
         p75 = numeric.p75, p100 = numeric.p100) |>
  mutate(across(where(is.numeric), ~ round(.x, 2)))

tabla_skim

# write_csv(tabla_skim, "output/tablas/descriptivas_wdi.csv")


# --- 3.3. Descriptivas a mano, para controlar --------------------------------

# Conviene saber reproducir a mano lo que devuelven estas funciones. Además,
# así se agregan medidas que summary() no trae: desvío, coeficiente de
# variación (dispersión relativa, comparable entre variables con distinta
# unidad) y rango intercuartílico.

descriptivas <- wdi_analisis |>
  summarise(across(
    all_of(vars_num),
    list(
      n      = ~ sum(!is.na(.x)),
      media  = ~ mean(.x, na.rm = TRUE),
      mediana = ~ median(.x, na.rm = TRUE),
      sd     = ~ sd(.x, na.rm = TRUE),
      cv     = ~ sd(.x, na.rm = TRUE) / mean(.x, na.rm = TRUE),
      min    = ~ min(.x, na.rm = TRUE),
      max    = ~ max(.x, na.rm = TRUE),
      iqr    = ~ IQR(.x, na.rm = TRUE)
    ),
    .names = "{.col}__{.fn}"
  )) |>
  pivot_longer(everything(),
               names_to = c("variable", "estadistico"),
               names_sep = "__") |>
  pivot_wider(names_from = estadistico, values_from = value) |>
  mutate(across(where(is.numeric), ~ round(.x, 2)))

descriptivas

# El coeficiente de variación permite comparar dispersión entre variables con
# unidades distintas. ¿Cuál de nuestras variables es la más desigual entre países?
descriptivas |> arrange(desc(cv)) |> select(variable, media, sd, cv)


# =============================================================================
# 4. TABLAS DE FRECUENCIA
# =============================================================================

# --- 4.1. Frecuencias simples -------------------------------------------------

# Frecuencia absoluta con table()
table(wdi_analisis$region)
table(wdi_analisis$ingreso)

# useNA = "ifany" muestra los NA como una categoría más. Por defecto table()
# los esconde, y eso engaña.
table(wdi_analisis$ingreso, useNA = "ifany")

# Frecuencia relativa con prop.table()
prop.table(table(wdi_analisis$region))
round(prop.table(table(wdi_analisis$region)) * 100, 1)

# Frecuencias ordenadas de mayor a menor
sort(table(wdi_analisis$region), decreasing = TRUE)

# La misma tabla con tidyverse, que devuelve un data.frame listo para exportar
wdi_analisis |>
  count(region, name = "paises") |>
  mutate(
    porcentaje = round(100 * paises / sum(paises), 1),
    acumulado  = cumsum(porcentaje)
  ) |>
  arrange(desc(paises))


# --- 4.2. Tablas cruzadas -----------------------------------------------------

# Región por grupo de ingreso: la tabla de doble entrada básica.
tabla_cruzada <- table(wdi_analisis$region, wdi_analisis$ingreso)
tabla_cruzada

# Con totales de fila y columna
addmargins(tabla_cruzada)

# Proporciones: el margin define respecto de qué se calcula el 100%
prop.table(tabla_cruzada, margin = 1)   # perfil de filas: dentro de cada región
prop.table(tabla_cruzada, margin = 2)   # perfil de columnas: dentro de cada ingreso

round(prop.table(tabla_cruzada, margin = 1) * 100, 1)

# Versión tidyverse de la tabla cruzada
wdi_analisis |>
  count(region, ingreso) |>
  pivot_wider(names_from = ingreso, values_from = n, values_fill = 0)


# --- 4.3. Convertir una numérica en categórica para tabular -------------------

# Muchas veces la variable de interés es continua, pero para comunicar conviene
# agruparla en categorías. cut() hace exactamente eso.

# Cortes definidos por criterio propio (tercios "redondos" de conectividad)
wdi_analisis <- wdi_analisis |>
  mutate(
    nivel_conectividad = cut(
      internet,
      breaks = c(-Inf, 40, 75, Inf),
      labels = c("Baja (<40%)", "Media (40-75%)", "Alta (>75%)")
    ),
    # Cortes definidos por los propios datos: cuartiles
    cuartil_internet = cut(
      internet,
      breaks = quantile(internet, probs = seq(0, 1, 0.25), na.rm = TRUE),
      labels = c("Q1", "Q2", "Q3", "Q4"),
      include.lowest = TRUE
    )
  )

table(wdi_analisis$nivel_conectividad)
table(wdi_analisis$cuartil_internet)   # por construcción, casi uniforme

# Y ahora la tabla que interesa de verdad: nivel de conectividad por ingreso
tabla_conect <- table(wdi_analisis$ingreso, wdi_analisis$nivel_conectividad)
addmargins(tabla_conect)
round(prop.table(tabla_conect, margin = 1) * 100, 1)

# Interpretación (escribirla siempre, la tabla sola no dice nada):
# entre los países de ingreso bajo, casi ninguno alcanza conectividad alta;
# entre los de ingreso alto, prácticamente todos. Esta tabla es el punto de
# partida natural para un test chi-cuadrado en la entrega 2.


# =============================================================================
# 5. HISTOGRAMAS (GRÁFICOS BASE)
# =============================================================================

# --- 5.1. Histograma básico ---------------------------------------------------

hist(wdi_analisis$internet)

# Con etiquetas en castellano. Un gráfico sin título ni ejes rotulados no se
# presenta nunca.
hist(
  wdi_analisis$internet,
  main = "Uso de internet, países del mundo (2022)",
  xlab = "% de la población que usa internet",
  ylab = "Cantidad de países",
  col  = "steelblue",
  border = "white"
)


# --- 5.2. El ancho de los intervalos cambia lo que uno ve ---------------------

# breaks es una sugerencia, no una orden: R redondea a cortes "lindos".
par(mfrow = c(2, 2))
for (b in c(5, 10, 20, 50)) {
  hist(wdi_analisis$internet,
       breaks = b,
       main = paste("breaks =", b),
       xlab = "% usa internet", ylab = "Países",
       col = "grey80", border = "white")
}
par(par_original)

# Moraleja: con pocos intervalos se pierde la forma, con demasiados se ve ruido.
# Hay que elegir uno y justificarlo, no dejar el default sin mirarlo.


# --- 5.3. Histograma de densidad y curva superpuesta --------------------------

# freq = FALSE pone densidad en el eje y, de modo que el área total sea 1.
# Eso permite superponer una curva de densidad estimada.
hist(
  wdi_analisis$internet,
  breaks = 20, freq = FALSE,
  main = "Distribución del uso de internet",
  xlab = "% de la población que usa internet", ylab = "Densidad",
  col = "grey90", border = "white"
)
lines(density(wdi_analisis$internet, na.rm = TRUE), lwd = 2, col = "darkred")
rug(wdi_analisis$internet)   # marca cada observación sobre el eje
abline(v = mean(wdi_analisis$internet), col = "blue", lwd = 2, lty = 2)
abline(v = median(wdi_analisis$internet), col = "darkgreen", lwd = 2, lty = 3)
legend("topleft",
       legend = c("Densidad", "Media", "Mediana"),
       col = c("darkred", "blue", "darkgreen"),
       lwd = 2, lty = c(1, 2, 3), bty = "n")


# --- 5.4. Distribuciones asimétricas y transformación logarítmica ------------

# Banda ancha fija y población son fuertemente asimétricas a derecha: muchos
# valores chicos y unos pocos enormes. En estos casos el histograma en niveles
# se ve como una sola barra pegada al cero y no informa nada.

par(mfrow = c(2, 2))

hist(wdi_analisis$banda_ancha, breaks = 25,
     main = "Banda ancha fija (niveles)",
     xlab = "Suscripciones cada 100 hab.", ylab = "Países",
     col = "grey80", border = "white")

hist(log10(wdi_analisis$banda_ancha + 0.01), breaks = 25,
     main = "Banda ancha fija (log10)",
     xlab = "log10(suscripciones cada 100 hab.)", ylab = "Países",
     col = "steelblue", border = "white")

hist(wdi_analisis$poblacion_mill, breaks = 40,
     main = "Población (niveles)",
     xlab = "Millones de habitantes", ylab = "Países",
     col = "grey80", border = "white")

hist(log10(wdi_analisis$poblacion_mill), breaks = 25,
     main = "Población (log10)",
     xlab = "log10(millones de habitantes)", ylab = "Países",
     col = "steelblue", border = "white")

par(par_original)

# La transformación no "arregla" los datos: cambia la escala en la que los
# miramos. Si se usa en el TP, hay que decirlo en el eje y explicarlo.


# --- 5.5. Comparar distribuciones con histogramas superpuestos ---------------

# rgb() con el cuarto argumento (alpha) da colores semitransparentes.
alta  <- wdi_analisis$internet[wdi_analisis$ingreso == "Ingreso alto"]
baja  <- wdi_analisis$internet[wdi_analisis$ingreso %in%
                                 c("Ingreso bajo", "Ingreso medio-bajo")]

hist(baja, breaks = 15, col = rgb(1, 0, 0, 0.5), border = "white",
     xlim = c(0, 100),
     main = "Uso de internet según grupo de ingreso",
     xlab = "% de la población que usa internet", ylab = "Cantidad de países")
hist(alta, breaks = 15, col = rgb(0, 0, 1, 0.5), border = "white", add = TRUE)
legend("topleft",
       legend = c("Ingreso bajo y medio-bajo", "Ingreso alto"),
       fill = c(rgb(1, 0, 0, 0.5), rgb(0, 0, 1, 0.5)), bty = "n")

# Cuidado: cuando los grupos tienen tamaños muy distintos, el histograma de
# frecuencias absolutas confunde. Ahí conviene freq = FALSE o directamente
# comparar con boxplots, que es lo que sigue.


# =============================================================================
# 6. BOXPLOTS (GRÁFICOS BASE) Y OUTLIERS
# =============================================================================

# --- 6.1. Boxplot de una variable --------------------------------------------

# El boxplot resume cinco números: mínimo dentro del bigote, Q1, mediana, Q3 y
# máximo dentro del bigote. Los puntos sueltos son valores atípicos según la
# regla de 1,5 veces el rango intercuartílico.

boxplot(
  wdi_analisis$banda_ancha,
  main = "Banda ancha fija por país (2022)",
  ylab = "Suscripciones cada 100 habitantes",
  col = "lightblue"
)

# horizontal = TRUE suele leerse mejor cuando es una sola variable
boxplot(wdi_analisis$banda_ancha, horizontal = TRUE,
        main = "Banda ancha fija por país (2022)",
        xlab = "Suscripciones cada 100 habitantes",
        col = "lightblue")


# --- 6.2. Qué hay adentro del boxplot ----------------------------------------

# boxplot.stats() devuelve los números exactos que el gráfico dibuja.
bp <- boxplot.stats(wdi_analisis$banda_ancha)
bp$stats   # bigote inferior, Q1, mediana, Q3, bigote superior
bp$n       # observaciones no NA
bp$out     # los valores atípicos

# Reconstruir la regla a mano
q1  <- quantile(wdi_analisis$banda_ancha, 0.25, na.rm = TRUE)
q3  <- quantile(wdi_analisis$banda_ancha, 0.75, na.rm = TRUE)
iqr <- q3 - q1
limite_inf <- q1 - 1.5 * iqr
limite_sup <- q3 + 1.5 * iqr
c(q1 = q1, q3 = q3, iqr = iqr, inf = limite_inf, sup = limite_sup)

# ¿Qué países son los atípicos? Nunca se los descarta sin mirarlos: en datos de
# países, un outlier suele ser un caso interesante, no un error de carga.
wdi_analisis |>
  filter(banda_ancha > limite_sup | banda_ancha < limite_inf) |>
  select(pais, region, ingreso, banda_ancha, internet) |>
  arrange(desc(banda_ancha))


# --- 6.3. Boxplot por grupo con fórmula ---------------------------------------

# La sintaxis de fórmula (variable ~ grupo) es la forma natural de comparar.
par(mar = c(8, 4, 4, 2))   # más margen abajo para las etiquetas

boxplot(
  internet ~ ingreso,
  data = wdi_analisis,
  main = "Uso de internet según grupo de ingreso (2022)",
  xlab = "", ylab = "% de la población que usa internet",
  col = c("#d73027", "#fc8d59", "#91bfdb", "#4575b4"),
  las = 2      # etiquetas del eje x en vertical
)

par(par_original)

# Por región, ordenando por mediana: un boxplot ordenado se lee mucho mejor.
orden <- wdi_analisis |>
  group_by(region) |>
  summarise(m = median(internet, na.rm = TRUE)) |>
  arrange(m) |>
  pull(region) |>
  as.character()

wdi_analisis <- wdi_analisis |>
  mutate(region_ord = factor(region, levels = orden))

par(mar = c(12, 4, 4, 2))
boxplot(
  internet ~ region_ord,
  data = wdi_analisis,
  main = "Uso de internet por región (ordenado por mediana)",
  xlab = "", ylab = "% usa internet",
  col = "lightsteelblue",
  las = 2,
  cex.axis = 0.8
)
par(par_original)


# --- 6.4. Variantes útiles ----------------------------------------------------

# varwidth = TRUE hace el ancho de cada caja proporcional a la raíz del n:
# se ve de un vistazo qué grupos tienen pocos casos.
# notch = TRUE dibuja una muesca alrededor de la mediana; si las muescas de dos
# grupos no se solapan, hay evidencia informal de que las medianas difieren.
par(mar = c(8, 4, 4, 2))
boxplot(
  internet ~ ingreso,
  data = wdi_analisis,
  varwidth = TRUE, notch = TRUE,
  main = "Uso de internet por ingreso (ancho ~ n, con muesca)",
  xlab = "", ylab = "% usa internet",
  col = "lightgreen", las = 2
)
par(par_original)

# Varias variables en un mismo boxplot: solo tiene sentido si comparten unidad.
# Acá sí: las tres están en porcentaje de población.
boxplot(
  wdi_analisis |> select(internet, electricidad, urbano),
  main = "Tres indicadores en % de población",
  ylab = "%",
  col = c("steelblue", "orange", "seagreen")
)


# =============================================================================
# 7. PERCENTILES Y RATIOS ENTRE PERCENTILES
# =============================================================================

# --- 7.1. Cálculo de percentiles ----------------------------------------------

# quantile() es la función clave. Por defecto devuelve los cuartiles.
quantile(wdi_analisis$internet, na.rm = TRUE)

# Percentiles a pedido
quantile(wdi_analisis$internet, probs = c(0.10, 0.25, 0.50, 0.75, 0.90),
         na.rm = TRUE)

# Deciles: seq() arma la secuencia de probabilidades
deciles_internet <- quantile(wdi_analisis$internet,
                             probs = seq(0, 1, 0.10), na.rm = TRUE)
round(deciles_internet, 1)

# Percentiles de todas las variables numéricas, en una tabla
percentiles_tabla <- wdi_analisis |>
  select(all_of(vars_num)) |>
  pivot_longer(everything(), names_to = "variable", values_to = "valor") |>
  filter(!is.na(valor)) |>
  group_by(variable) |>
  summarise(
    p10 = quantile(valor, 0.10),
    p25 = quantile(valor, 0.25),
    p50 = quantile(valor, 0.50),
    p75 = quantile(valor, 0.75),
    p90 = quantile(valor, 0.90),
    .groups = "drop"
  ) |>
  mutate(across(where(is.numeric), ~ round(.x, 2)))

percentiles_tabla


# --- 7.2. Ratios entre percentiles: medir desigualdad -------------------------

# Un percentil solo dice poco. La comparación ENTRE percentiles es la que mide
# desigualdad, y es una herramienta central del análisis económico aplicado.
#
#   p90/p10 : cuántas veces el país del percentil 90 tiene lo que el del 10.
#             Es el ratio de desigualdad más usado (en ingresos, salarios, etc.).
#   p75/p25 : ratio intercuartílico, más robusto porque ignora las colas.
#   p50/p10 : cuánto se aleja la mediana del piso (desigualdad "de abajo").
#   p90/p50 : cuánto se despega el techo de la mediana (desigualdad "de arriba").
#
# Descomponer p90/p10 en (p90/p50) x (p50/p10) muestra de qué lado está la
# desigualdad: si el trecho de arriba pesa más que el de abajo, o al revés.

ratio_percentiles <- function(x) {
  x <- x[!is.na(x) & x > 0]   # los ratios necesitan valores positivos
  p <- quantile(x, probs = c(0.10, 0.25, 0.50, 0.75, 0.90))
  tibble(
    p10 = p[[1]], p25 = p[[2]], p50 = p[[3]], p75 = p[[4]], p90 = p[[5]],
    ratio_90_10 = p[[5]] / p[[1]],
    ratio_75_25 = p[[4]] / p[[2]],
    ratio_50_10 = p[[3]] / p[[1]],
    ratio_90_50 = p[[5]] / p[[3]]
  )
}

ratio_percentiles(wdi_analisis$internet)
ratio_percentiles(wdi_analisis$banda_ancha)

# Comparación entre variables: ¿qué dimensión de la brecha digital es la más
# desigual entre países?
ratios_todas <- wdi_analisis |>
  select(all_of(vars_num)) |>
  pivot_longer(everything(), names_to = "variable", values_to = "valor") |>
  group_by(variable) |>
  group_modify(~ ratio_percentiles(.x$valor)) |>
  ungroup() |>
  mutate(across(where(is.numeric), ~ round(.x, 2))) |>
  arrange(desc(ratio_90_10))

ratios_todas

# Lectura esperable: banda ancha fija es muchísimo más desigual que el acceso a
# electricidad o el uso de internet. La conectividad "de calidad" está mucho
# más concentrada que la conectividad "básica". Ese contraste es el tipo de
# hallazgo que sostiene una hipótesis de trabajo.


# --- 7.3. Ratios entre percentiles por grupo ---------------------------------

# El mismo ratio calculado dentro de cada región responde otra pregunta:
# ¿dónde la brecha interna es más grande?
ratios_por_region <- wdi_analisis |>
  filter(!is.na(internet)) |>
  group_by(region) |>
  filter(n() >= 8) |>          # con muy pocos países el p90 y el p10 no son fiables
  group_modify(~ ratio_percentiles(.x$internet)) |>
  ungroup() |>
  mutate(across(where(is.numeric), ~ round(.x, 2))) |>
  arrange(desc(ratio_90_10))

ratios_por_region

# Advertencia importante: con n chico, los percentiles extremos son muy
# inestables. Por eso filtramos regiones con menos de 8 países. En el TP,
# si calculan ratios por grupo, informen siempre el n de cada grupo.


# --- 7.4. Participación de los grupos: el ratio de Palma ----------------------

# En economía se usa mucho el ratio de Palma: lo que concentra el 10% de arriba
# sobre lo que concentra el 40% de abajo. Acá lo adaptamos a países, ponderando
# por población, para responder: ¿qué porción de los usuarios de internet del
# mundo vive en el 10% de países más conectados?

palma <- wdi_analisis |>
  filter(!is.na(internet), !is.na(poblacion)) |>
  mutate(usuarios = internet / 100 * poblacion) |>   # usuarios estimados
  arrange(internet) |>
  mutate(
    rank_pct = row_number() / n(),
    grupo = case_when(
      rank_pct <= 0.40 ~ "40% menos conectado",
      rank_pct >= 0.90 ~ "10% más conectado",
      TRUE ~ "50% intermedio"
    )
  ) |>
  group_by(grupo) |>
  summarise(
    paises = n(),
    poblacion_mill = round(sum(poblacion) / 1e6, 1),
    usuarios_mill  = round(sum(usuarios) / 1e6, 1),
    .groups = "drop"
  ) |>
  mutate(share_usuarios = round(100 * usuarios_mill / sum(usuarios_mill), 1))

palma

ratio_palma <- palma$usuarios_mill[palma$grupo == "10% más conectado"] /
  palma$usuarios_mill[palma$grupo == "40% menos conectado"]
round(ratio_palma, 2)

# El resultado es contraintuitivo y por eso es tan útil: el ratio da MENOS que 1.
# El 10% de países más conectados concentra una porción chiquísima de los
# usuarios del mundo, simplemente porque son países muy chicos (nórdicos,
# petroleros del Golfo, islas), mientras que el 40% menos conectado incluye
# países enormes.
#
# Ojo entonces con la interpretación: acá el 10% "de arriba" son países, no
# personas. Confundir "10% de los países" con "10% de la gente" es un error muy
# común y muy caro en un TP. Cuando la unidad de observación es el país, todo
# indicador de desigualdad hay que aclararlo: ¿desigualdad entre países o entre
# personas? Son dos preguntas distintas y dan resultados distintos.


# =============================================================================
# 8. MATRIZ DE CORRELACIONES
# =============================================================================

# --- 8.1. Correlación entre dos variables ------------------------------------

cor(wdi_analisis$internet, wdi_analisis$electricidad,
    use = "complete.obs")

# cor.test() agrega el test de significatividad y el intervalo de confianza
cor.test(wdi_analisis$internet, wdi_analisis$electricidad)


# --- 8.2. La matriz completa --------------------------------------------------

# use = "pairwise.complete.obs" calcula cada correlación con los casos completos
# de ese par de variables. La alternativa, "complete.obs", descarta todo país al
# que le falte cualquier variable, y puede dejarnos con muy pocos casos.
# Las dos decisiones son defendibles, pero hay que saber cuál se tomó.

datos_cor <- wdi_analisis |>
  select(internet, movil, banda_ancha, electricidad,
         urbano, secundaria, activ_fem)

mat_cor <- cor(datos_cor, use = "pairwise.complete.obs")
round(mat_cor, 2)

# Cuántas observaciones sostienen cada correlación (no siempre son las mismas)
n_pares <- crossprod(!is.na(as.matrix(datos_cor)))
n_pares


# --- 8.3. Pearson contra Spearman --------------------------------------------

# Pearson mide relación LINEAL y es sensible a outliers y a la asimetría.
# Spearman trabaja sobre los rangos: capta cualquier relación monótona y es
# robusto. Cuando difieren mucho, es señal de no linealidad o de outliers
# influyentes, y conviene mirar el diagrama de dispersión.

mat_spearman <- cor(datos_cor, use = "pairwise.complete.obs", method = "spearman")
round(mat_spearman, 2)

# Diferencia entre ambas matrices
round(mat_spearman - mat_cor, 2)

# Caso concreto: banda ancha contra internet
cor(wdi_analisis$banda_ancha, wdi_analisis$internet,
    use = "complete.obs")
cor(wdi_analisis$banda_ancha, wdi_analisis$internet,
    use = "complete.obs", method = "spearman")


# --- 8.4. Ver la matriz -------------------------------------------------------

# Una matriz de correlaciones se lee mejor como imagen que como números.
# Con gráficos base alcanza image(), poniendo la escala de color centrada en 0.

par(mar = c(9, 9, 4, 2))
image(
  x = seq_len(ncol(mat_cor)),
  y = seq_len(ncol(mat_cor)),
  z = t(mat_cor)[, ncol(mat_cor):1],
  col = colorRampPalette(c("#d73027", "white", "#4575b4"))(21),
  zlim = c(-1, 1),
  axes = FALSE, xlab = "", ylab = "",
  main = "Matriz de correlaciones (Pearson)"
)
axis(1, at = seq_len(ncol(mat_cor)), labels = colnames(mat_cor), las = 2)
axis(2, at = seq_len(ncol(mat_cor)), labels = rev(colnames(mat_cor)), las = 2)
# Los valores encima de cada celda
for (i in seq_len(ncol(mat_cor))) {
  for (j in seq_len(ncol(mat_cor))) {
    text(i, ncol(mat_cor) - j + 1, round(mat_cor[j, i], 2), cex = 0.7)
  }
}
par(par_original)

# Alternativa con un paquete, más prolija:
# install.packages("corrplot")
# corrplot::corrplot(mat_cor, method = "color", type = "upper",
#                    addCoef.col = "black", tl.col = "black", tl.srt = 45)


# --- 8.5. Del número al gráfico de dispersión --------------------------------

# Una correlación alta puede esconder no linealidad, agrupamientos o un par de
# puntos que la generan solos. Siempre hay que mirar la nube de puntos.

pairs(datos_cor, pch = 19, cex = 0.5, col = rgb(0, 0, 0, 0.4),
      main = "Diagramas de dispersión de a pares")

# Un par en detalle, con la recta de mínimos cuadrados
plot(
  wdi_analisis$electricidad, wdi_analisis$internet,
  pch = 19, col = rgb(0.2, 0.4, 0.7, 0.6),
  main = "Acceso a electricidad y uso de internet (2022)",
  xlab = "% con acceso a electricidad",
  ylab = "% que usa internet"
)
abline(lm(internet ~ electricidad, data = wdi_analisis), col = "darkred", lwd = 2)
r <- cor(wdi_analisis$electricidad, wdi_analisis$internet, use = "complete.obs")
legend("topleft", legend = paste("r =", round(r, 2)), bty = "n")

# La relación es claramente no lineal: por debajo de 100% de electrificación
# casi no hay uso de internet, y recién después despega. Un solo número (r)
# nunca describe bien una relación como esta. En la entrega 2 esto justifica,
# por ejemplo, trabajar con transformaciones o con variables categorizadas.

# Ranking de las correlaciones más fuertes, para ordenar la lectura
cor_largo <- as.data.frame(as.table(mat_cor)) |>
  as_tibble() |>
  rename(var1 = Var1, var2 = Var2, r = Freq) |>
  filter(var1 != var2) |>
  mutate(par = map2_chr(as.character(var1), as.character(var2),
                        ~ paste(sort(c(.x, .y)), collapse = " - "))) |>
  distinct(par, .keep_all = TRUE) |>
  arrange(desc(abs(r))) |>
  mutate(r = round(r, 2)) |>
  select(par, r)

cor_largo


# =============================================================================
# 9. CIERRE: CHECKLIST DE LA PRIMERA ENTREGA DEL TP
# =============================================================================

# Todo lo que hicimos acá es, punto por punto, lo que pide la instancia 1:
#
#  [ ] Dimensiones de la base            -> dim(), nrow(), ncol()          (2.1)
#  [ ] Unidad de observación             -> duplicated(), n_distinct()     (2.1)
#  [ ] Descripción de cada variable      -> diccionario                    (1.3)
#  [ ] Tipo de cada variable             -> glimpse(), tipos               (2.2)
#  [ ] Valores faltantes                 -> colSums(is.na()), faltantes    (2.3)
#  [ ] Estadísticas descriptivas         -> summary(), skim(), descriptivas (3)
#  [ ] Distribución de las categóricas   -> table(), prop.table()          (4)
#  [ ] Forma de las distribuciones       -> hist()                         (5)
#  [ ] Dispersión y atípicos             -> boxplot(), boxplot.stats()     (6)
#  [ ] Medidas de posición y desigualdad -> quantile(), ratios             (7)
#  [ ] Relación entre variables          -> cor(), pairs()                 (8)
#  [ ] Periodicidad de la fuente         -> anual (WDI se actualiza ~2 veces al año)
#
# Tres advertencias finales, que son las que más se ven en las entregas:
#
# 1. Ninguna tabla ni gráfico se presenta sin una frase que lo interprete.
#    El output de R es el insumo, no el resultado.
# 2. Los NA y los outliers se explican, no se borran en silencio. Decir cuántos
#    son, dónde se concentran y qué se hizo con ellos.
# 3. Correlación no es causalidad, y el TP no es causal. Las relaciones que
#    encontramos acá describen asociaciones entre países en un año, nada más.


# --- Guardado de resultados (descomentar y adaptar rutas en el TP) -----------

# write_csv(diccionario,       "output/tablas/diccionario_variables.csv")
# write_csv(tabla_skim,        "output/tablas/descriptivas.csv")
# write_csv(percentiles_tabla, "output/tablas/percentiles.csv")
# write_csv(ratios_todas,      "output/tablas/ratios_percentiles.csv")
# write_csv(as.data.frame(mat_cor) |> rownames_to_column("variable"),
#           "output/tablas/matriz_correlaciones.csv")

# png("output/graficos/boxplot_internet_ingreso.png", width = 900, height = 600)
# par(mar = c(8, 4, 4, 2))
# boxplot(internet ~ ingreso, data = wdi_analisis,
#         main = "Uso de internet según grupo de ingreso (2022)",
#         xlab = "", ylab = "% usa internet", col = "lightblue", las = 2)
# dev.off()
