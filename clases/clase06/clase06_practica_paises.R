# =========================================================
# Ciencia de Datos para Economía y Negocios - FCE-UBA
# Clase 5 - Práctica: Estadística descriptiva a nivel país
#
# Objetivo: aplicar todos los conceptos de la clase
# (tendencia central, dispersión, forma, posición,
# variación, relación) a variables país:
#   - PIB per cápita PPP  (Banco Mundial)
#   - Esperanza de vida al nacer (Banco Mundial)
#   - Tasa de fecundidad (Banco Mundial)
#   - Altura media de hombres adultos (NCD-RisC / OWID)
#   - Población (como ponderador)
#
# =========================================================


# ---------------------------------------------------------
# 0. Paquetes
# ---------------------------------------------------------

# Si quiero borrar todo lo que tengo en el ambiente de trabajo 
# rm(list=ls())
# Si quiero borrar todo menos algunas cosas  
rm(list=setdiff(ls(),ls()[ls() %in% c('wdi_raw','otro_elemento')]))
# No borro wdi_raw porque tarda bastante en cargarse 
library(tidyverse)
# install.packages('WDI')
library(WDI)

# Cargar las funciones hechas a mano
source('utils/estadisticas_descriptivas_ponderadas.R')

# ---------------------------------------------------------
# 2. Descarga de datos del Banco Mundial (WDI)
# ---------------------------------------------------------
# Indicadores:
#   NY.GDP.PCAP.PP.CD : PIB per cápita PPP (USD corrientes)
#   SP.DYN.LE00.IN    : Esperanza de vida al nacer (años)
#   SP.DYN.TFRT.IN    : Tasa de fecundidad (hijos por mujer)
#   SP.POP.TOTL       : Población total (ponderador)

wdi_raw <- WDI(
  indicator = c(gdp_pc   = "NY.GDP.PCAP.PP.CD",
                life_exp = "SP.DYN.LE00.IN",
                fert     = "SP.DYN.TFRT.IN",
                pop      = "SP.POP.TOTL"),
  start = 2022, end = 2022, extra = TRUE
)


wdi <- wdi_raw |>
  filter(region != "Aggregates", region != "",
         !is.na(gdp_pc), !is.na(life_exp),
         !is.na(fert),   !is.na(pop)) |>
  select(country, iso3c,income, region, gdp_pc, life_exp, fert, pop)


# ---------------------------------------------------------
# 3. Altura media de hombres adultos (NCD-RisC, vía OWID)
# ---------------------------------------------------------
# Fuente: NCD Risk Factor Collaboration, publicada en Our World in Data.
# Si la URL falla, bajen el CSV a mano y lean local.

url_altura <- "https://ourworldindata.org/grapher/average-height-of-men.csv?v=1&csvType=full&useColumnShortNames=true"

altura_raw <- read_csv(url_altura, show_col_types = FALSE)

# Nos quedamos con el último año disponible por país
altura <- altura_raw |>
  rename(iso3c = code,
         altura_cm = mean_male_height__cm) |>           # la 3ra columna es la altura
  filter(!is.na(iso3c), !is.na(altura_cm)) |>
  group_by(iso3c) |>
  slice_max(year, n = 1) |> 
  ungroup() |>
  select(iso3c, altura_cm)


# ---------------------------------------------------------
# 4. Base unificada a nivel país (aplicamos temas Clase 4)
# ---------------------------------------------------------

# 4.1 - Verificar claves primarias ANTES de joinear
# Regla: sin PK verificada, un join puede multiplicar filas sin aviso.
wdi    |> count(iso3c) |> filter(n > 1)   # debería estar vacío
altura |> count(iso3c) |> filter(n > 1)   # debería estar vacío


# 4.2 - Metadatos de grupo de ingreso del Banco Mundial
# Lo armamos aparte para tener una tabla auxiliar y practicar left_join.
meta_ingreso <- wdi_raw |>
  filter(region != "Aggregates", region != "") |>
  select(iso3c, income_group = income) |>
  distinct()

meta_ingreso |> count(iso3c) |> filter(n > 1)   # PK OK


# 4.3 - anti_join: diagnóstico de qué se pierde con altura
# ¿Cuántos países de WDI NO están en la base de altura?
wdi |>
  anti_join(altura, by = "iso3c") |>
  nrow()

# ¿Y al revés? (países de altura que no están en WDI)
altura |>
  anti_join(wdi, by = "iso3c") |>
  nrow()


# 4.4 - Base unificada con left_join + inner_join explícitos
# Estrategia: arrancamos de WDI (tabla principal), enriquecemos con
# metadatos de ingreso (left_join, no queremos perder países) y - ya agregado antes
# cruzamos con altura (left_join, porque necesitamos la variable).
paises <- wdi |>
  left_join(altura, by = "iso3c") %>% 
  filter(!is.na(altura_cm))

glimpse(paises)
nrow(paises)


# 4.5 - case_when: clasificar países en grupos de desarrollo
# Usamos cortes aproximados del Banco Mundial para PIB pc PPP.
paises <- paises |>
  mutate(
    grupo_pib = case_when(
      gdp_pc <  5000             ~ "1. Bajo",
      gdp_pc >= 5000  & gdp_pc < 15000 ~ "2. Medio-bajo",
      gdp_pc >= 15000 & gdp_pc < 35000 ~ "3. Medio-alto",
      gdp_pc >= 35000            ~ "4. Alto",
      .default = '5. SACAR'
    )
  )

paises |> count(grupo_pib)


# 4.6 - if_else: una flag binaria simple
# Marcamos países con fecundidad "alta" (>= 3 hijos por mujer)
paises <- paises |>
  mutate(
    alta_fecundidad = if_else(fert >= 3, "Sí", "No")
  )

paises |> count(alta_fecundidad)


# =========================================================
# BLOQUE A - TENDENCIA CENTRAL
# =========================================================

# A.1 - Media, mediana, min, max (sin ponderar: cada país vale uno)
paises |>
  summarise(
    n        = n(),
    media    = mean(gdp_pc),
    mediana  = median(gdp_pc),
    minimo   = min(gdp_pc),
    maximo   = max(gdp_pc)
  )

# ¿Por qué media > mediana? Pista: pocos países muy ricos.
# Es exactamente la misma lógica que el ITF de Santa Fe.


# A.2 - Media ponderada por POBLACIÓN
# "El habitante promedio del mundo vive en un país con PIB pc de..."
paises |>
  summarise(
    media_simple      = mean(gdp_pc),
    media_ponderada   = weighted.mean(gdp_pc, pop),
    mediana_simple    = median(gdp_pc),
    mediana_ponderada = mediana_ponderada(gdp_pc, pop)
  )
# OJO: la media simple trata igual a Luxemburgo y a India.
# La ponderada responde a "¿cuánto produce en promedio una persona del mundo?".


# A.3 - Moda: no tiene sentido para continuas, pero sí por REGIÓN
paises |>
  count(region, sort = TRUE)   # la "región modal" en cantidad de países


# =========================================================
# BLOQUE B - DISPERSIÓN
# =========================================================

# B.1 - Varianza, desvío, rango, IQR, CV del PIB pc
paises |>
  summarise(
    varianza = var(gdp_pc),
    desvio   = sd(gdp_pc),
    rango    = max(gdp_pc) - min(gdp_pc),
    iqr      = IQR(gdp_pc),
    cv_pct   = sd(gdp_pc) / mean(gdp_pc) * 100
  )

# B.2 - CV para comparar variables con escalas distintas
# (acá el CV brilla: no podríamos comparar desvíos en USD vs años vs cm)
paises |>
  summarise(
    cv_gdp      = sd(gdp_pc)   / mean(gdp_pc)   * 100,
    cv_life_exp = sd(life_exp) / mean(life_exp) * 100,
    cv_fert     = sd(fert)     / mean(fert)     * 100,
    cv_altura   = sd(altura_cm)/ mean(altura_cm)* 100
  )
# ¿Qué variable es la más homogénea entre países? ¿Y la más dispersa?


# B.3 - El mismo resumen con pivot_longer
# En vez de repetir mean/sd/cv para cada variable, pasamos a formato
# largo y hacemos group_by(variable) + summarise(). Mucho más compacto
# y fácil de extender a más variables.
paises |>
  select(iso3c, gdp_pc, life_exp, fert, altura_cm) |>
  pivot_longer(
    cols      = c(gdp_pc, life_exp, fert, altura_cm),
    names_to  = "variable",
    values_to = "valor"
  ) |>
  group_by(variable) |>
  summarise(
    n       = n(),
    media   = mean(valor),
    mediana = median(valor),
    desvio  = sd(valor),
    cv_pct  = sd(valor) / mean(valor) * 100,
    .groups = "drop"
  ) |>
  arrange(desc(cv_pct))


# =========================================================
# BLOQUE C - FORMA (asimetría y curtosis)
# =========================================================

# Definimos las funciones sin ponderar (idénticas a la clase)
asimetria <- function(x) {
  n <- length(x); m <- mean(x); s <- sd(x)
  (n / ((n - 1) * (n - 2))) * sum(((x - m) / s)^3)
}
curtosis_exc <- function(x) {
  n <- length(x); m <- mean(x); s <- sd(x)
  ((n * (n + 1)) / ((n - 1) * (n - 2) * (n - 3))) * sum(((x - m) / s)^4) -
    (3 * (n - 1)^2) / ((n - 2) * (n - 3))
}

paises |>
  summarise(
    asim_gdp      = asimetria(gdp_pc),
    asim_life_exp = asimetria(life_exp),
    asim_fert     = asimetria(fert),
    asim_altura   = asimetria(altura_cm),
    kurt_gdp      = curtosis_exc(gdp_pc),
    kurt_life_exp = curtosis_exc(life_exp),
    kurt_fert     = curtosis_exc(fert),
    kurt_altura   = curtosis_exc(altura_cm)
  )
# Esperable: PIB pc con asimetría positiva fuerte (cola a la derecha).
# Esperanza de vida con asimetría negativa (cola a la izquierda).
# Altura: la más simétrica, más cerca de una normal.


# =========================================================
# BLOQUE D - POSICIÓN (cuantiles y desigualdad entre países)
# =========================================================

# D.1 - Deciles del PIB per cápita
deciles_gdp <- quantile(paises$gdp_pc, probs = seq(0.1, 0.9, 0.1))
round(deciles_gdp)

# Ratio D9/D1: ¿cuántas veces más produce el país del percentil 90
# que el del percentil 10?
ratio_d9_d1 <- deciles_gdp[9] / deciles_gdp[1]
round(ratio_d9_d1, 1)


# D.2 - Ratio de Palma entre países
# D10 (10% más rico) vs D1-D4 (40% más pobre), ponderando por población
# Acá el ponderador importa: un decil de países = un decil de habitantes
paises_palma <- paises |>
  arrange(gdp_pc) |>
  mutate(
    pop_acum = cumsum(pop) / sum(pop),
    decil    = ceiling(pop_acum * 10),
    decil    = pmin(decil, 10)
  )

pib_d10  <- paises_palma |> filter(decil == 10) |>
  summarise(s = sum(gdp_pc * pop)) |> pull(s)
pib_d1a4 <- paises_palma |> filter(decil <= 4)  |>
  summarise(s = sum(gdp_pc * pop)) |> pull(s)

palma_mundo <- pib_d10 / pib_d1a4
round(palma_mundo, 2)

# D.3 - Mismo ejercicio con esperanza de vida (debería ser mucho menor)
deciles_life <- quantile(paises$life_exp, probs = seq(0.1, 0.9, 0.1))
round(deciles_life, 1)
round(deciles_life[9] / deciles_life[1], 2)


# =========================================================
# BLOQUE E - AGREGACIÓN REGIONAL PONDERADA POR POBLACIÓN
# =========================================================
# REGLA: cada vez que colapsamos países a regiones, ponderamos por población.
# Es el equivalente a usar PONDERA cuando colapsamos hogares a aglomerados.

tabla_region <- paises |>
  group_by(region) |>
  summarise(
    n_paises         = n(),
    poblacion        = sum(pop),
    # --- simple (cada país pesa 1) ---
    gdp_media_simple = mean(gdp_pc),
    # --- ponderadas por población ---
    gdp_media        = weighted.mean(gdp_pc,   pop),
    gdp_mediana      = mediana_ponderada(gdp_pc, pop),
    gdp_desvio       = desvio_ponderado(gdp_pc, pop),
    gdp_cv           = desvio_ponderado(gdp_pc, pop) /
                       weighted.mean(gdp_pc,    pop) * 100,
    life_exp_media   = weighted.mean(life_exp, pop),
    fert_media       = weighted.mean(fert,     pop),
    altura_media     = weighted.mean(altura_cm, pop),
    .groups = "drop"
  ) |>
  arrange(desc(gdp_media))

tabla_region

# Ojo: comparar gdp_media_simple vs gdp_media. ¿donde diverge más?


# E.2 - group_by() + mutate(): cada país relativo a SU región
# No colapsamos: conservamos una fila por país, pero agregamos
# columnas calculadas DENTRO del grupo.
paises_rel <- paises |>
  group_by(region) |>
  mutate(
    gdp_max_region  = max(gdp_pc),
    ratio_vs_max    = round(gdp_pc / gdp_max_region, 2),
    pob_region      = sum(pop),
    share_poblacion = round(pop / pob_region * 100, 1)
  ) |>
  ungroup() |>
  select(country, region, gdp_pc, ratio_vs_max, share_poblacion) |>
  arrange(region, desc(share_poblacion))

paises_rel
# Lectura: ratio_vs_max = 1.00 es el país más rico de su región.
# share_poblacion muestra qué países concentran la población regional
# (y por lo tanto arrastran más fuerte cualquier promedio ponderado).


# E.3 - group_by() por DOS variables: región x grupo de PIB
# Cruce de dos categorías. Fijarse el uso de .groups = "drop".
paises |>
  group_by(region, grupo_pib) |>
  summarise(
    n_paises  = n(),
    poblacion = sum(pop),
    gdp_media = round(weighted.mean(gdp_pc, pop)),
    .groups   = "drop"
  ) |>
  arrange(region, grupo_pib)


# =========================================================
# BLOQUE F - CAMBIO EN EL TIEMPO: variación % y CAGR
# =========================================================
# Serie de PIB pc PPP a precios constantes (KD) para comparar crecimiento
paises_serie <- c("AR", "BR", "CL", "CN", "IN", "US")

wdi_ts_raw <- WDI(
  indicator = c(gdp_pc = "NY.GDP.PCAP.PP.KD"),
  country = paises_serie,
  start = 2012, end = 2022
)

wdi_ts <- wdi_ts_raw |>
  filter(!is.na(gdp_pc)) |>
  select(country, iso3c, year, gdp_pc) |>
  arrange(iso3c, year)

# F.1 - Variaciones porcentuales año a año
wdi_crec <- wdi_ts |>
  group_by(iso3c, country) |>
  arrange(year) |>
  mutate(
    var_pct = (gdp_pc / lag(gdp_pc) - 1) * 100
  ) |>
  filter(!is.na(var_pct)) |>
  ungroup()

# F.2 - CAGR (media geométrica de factores de crecimiento)
wdi_cagr <- wdi_ts |>
  group_by(iso3c, country) |>
  summarise(
    pib_inicio = first(gdp_pc),
    pib_fin    = last(gdp_pc),
    anios      = n() - 1,
    media_arit = mean((gdp_pc / lag(gdp_pc) - 1) * 100, na.rm = TRUE),
    cagr       = ((last(gdp_pc) / first(gdp_pc))^(1 / (n() - 1)) - 1) * 100,
    .groups = "drop"
  ) |>
  mutate(
    media_arit = round(media_arit, 2),
    cagr       = round(cagr, 2)
  )

wdi_cagr
# Recordar: media aritmética >= CAGR, y la brecha crece con la volatilidad.
# Argentina debería mostrar la mayor brecha del grupo.


# F.3 - pivot_wider: la serie temporal en formato tabla
# wdi_ts está en formato LARGO (una fila por país-año).
# Para presentarla como tabla legible (años en columnas) usamos pivot_wider.
wdi_ts_ancho <- wdi_ts |>
  mutate(gdp_pc = round(gdp_pc)) |>
  select(country, year, gdp_pc) |>
  pivot_wider(
    names_from  = year,
    values_from = gdp_pc,
    names_prefix = "pib_"
  )

wdi_ts_ancho

# Y la vuelta: pivot_longer para volver al formato tidy
wdi_ts_ancho |>
  pivot_longer(
    cols         = starts_with("pib_"),
    names_to     = "anio",
    names_prefix = "pib_",
    values_to    = "gdp_pc"
  ) |>
  mutate(anio = as.integer(anio))


# =========================================================
# BLOQUE G - RELACIÓN ENTRE VARIABLES
# =========================================================

# G.1 - Covarianzas (dependen de las unidades, sirven poco para comparar)
cov(paises$gdp_pc, paises$life_exp)
cov(paises$gdp_pc, paises$fert)
cov(paises$gdp_pc, paises$altura_cm)

# G.2 - Correlación de Pearson (asociación lineal)
cor(paises$gdp_pc,      paises$life_exp)
cor(paises$gdp_pc,      paises$fert)
cor(paises$gdp_pc,      paises$altura_cm)
cor(paises$life_exp,    paises$fert)
cor(paises$altura_cm,   paises$life_exp)

# G.3 - Pearson con log(PIB pc)
# La relación PIB-esperanza de vida es cóncava: mejora mucho con log.
cor(log(paises$gdp_pc), paises$life_exp)

# G.4 - Spearman (asociación monótona, robusta a no-linealidad)
cor(paises$gdp_pc, paises$life_exp, method = "spearman")
cor(paises$gdp_pc, paises$fert,     method = "spearman")

# Matriz completa
paises |>
  select(gdp_pc, life_exp, fert, altura_cm) |>
  cor() |>
  round(2)


# =========================================================
# BLOQUE H - VISUALIZACIÓN
# =========================================================

# H.1 - Boxplots de PIB pc por región (log para que se vea algo)
ggplot(paises, aes(x = fct_reorder(region, gdp_pc, median),
                   y = gdp_pc, fill = region)) +
  geom_boxplot(alpha = 0.8, show.legend = FALSE) +
  scale_y_log10(labels = scales::dollar_format()) +
  coord_flip() +
  labs(title = "PIB per cápita PPP por región (2022)",
       subtitle = "Escala logarítmica - cada punto es un país",
       x = NULL, y = "PIB per cápita PPP (USD)") +
  theme_minimal(base_size = 12)

# H.2 - Scatter PIB pc vs esperanza de vida, con tamaño = población
ggplot(paises, aes(x = gdp_pc, y = life_exp,
                   size = pop, color = region)) +
  geom_point(alpha = 0.7) +
  scale_x_log10(labels = scales::dollar_format()) +
  scale_size_continuous(range = c(1, 12), guide = "none") +
  labs(title = "PIB per cápita y esperanza de vida (2022)",
       subtitle = "Tamaño proporcional a la población",
       x = "PIB per cápita PPP (USD, log)",
       y = "Esperanza de vida (años)",
       color = "Región") +
  theme_minimal(base_size = 12)

# H.3 - Scatter PIB pc vs fecundidad (relación negativa clásica)
ggplot(paises, aes(x = gdp_pc, y = fert, size = pop, color = region)) +
  geom_point(alpha = 0.7) +
  scale_x_log10(labels = scales::dollar_format()) +
  scale_size_continuous(range = c(1, 12), guide = "none") +
  labs(title = "PIB per cápita y tasa de fecundidad (2022)",
       x = "PIB per cápita PPP (USD, log)",
       y = "Hijos por mujer",
       color = "Región") +
  theme_minimal(base_size = 12)

# H.4 - Scatter altura vs esperanza de vida
ggplot(paises, aes(x = altura_cm, y = life_exp,
                   size = pop, color = region)) +
  geom_point(alpha = 0.7) +
  scale_size_continuous(range = c(1, 12), guide = "none") +
  labs(title = "Altura media (hombres) y esperanza de vida",
       x = "Altura media, hombres adultos (cm)",
       y = "Esperanza de vida (años)",
       color = "Región") +
  theme_minimal(base_size = 12)


# =========================================================
# PREGUNTAS PARA PENSAR
# =========================================================
# 1. ¿Por qué la media del PIB pc mundial es tan distinta
#    cuando ponderamos por población?
# 2. ¿Qué región tiene mayor CV en PIB pc? ¿Por qué?
# 3. ¿La altura media tiene la asimetría que esperaban?
#    ¿Y el PIB pc? ¿Y la esperanza de vida?
# 4. ¿Por qué la correlación entre PIB pc y esperanza de vida
#    mejora tanto al pasar a log(PIB pc)?
# 5. ¿Cuánto más grande es el Palma entre países que el Palma
#    de ingresos dentro de Gran Santa Fe (clase)? ¿Qué implica?
# 6. Argentina vs Chile: ¿cuál tuvo mayor CAGR 2012-2022?
#    ¿Y mayor volatilidad (brecha entre media aritmética y CAGR)?
# 7. ¿Cuántos países "alto ingreso" hay en cada región?
#    ¿Hay alguna región sin ningún país de ingreso bajo?
# 8. ¿Qué país concentra más población dentro de su región?
#    ¿Ese país "arrastra" la media regional ponderada?
# 9. ¿Cuántos países de WDI no tenían dato de altura?
#    ¿Eso sesga los resultados hacia alguna región?
