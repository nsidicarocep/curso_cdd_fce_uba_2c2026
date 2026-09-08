# =============================================================================
# PRÁCTICA 1. Inferencia por remuestreo con la EPH
# Ciencia de Datos para Economía y Negocios
#
# Contenidos
#   1. Estadísticas ponderadas con EPH
#   2. Densidades superpuestas y comparación de distribuciones
#   3. Cuantiles por grupo
#   4. Bootstrap a mano con sample() y loop
#   5. Bootstrap con el paquete boot
#   6. Permutation test, ingresos formales contra informales
# =============================================================================

library(tidyverse)
library(eph)
library(survey)
library(boot)

theme_set(theme_minimal(base_size = 12))
set.seed(1234)


# =============================================================================
# 0. DATOS
# =============================================================================

# Descarga del microdato individual. Si no hay conexión, usar la copia local
# guardada previamente con write_rds()

eph_raw <- get_microdata(year = 2025, period = 1, type = "individual")

# Filtro de ocupados asalariados con ingreso positivo declarado
#   ESTADO == 1        ocupado
#   CAT_OCUP == 3      asalariado
#   PP07H              descuento jubilatorio, 1 sí y 2 no, proxy de formalidad
#   P21                ingreso de la ocupación principal
#   PONDIIO            ponderador de ingreso de la ocupación principal

eph <- eph_raw %>%
  filter(
    ESTADO == 1,
    CAT_OCUP == 3,
    P21 > 0,
    !is.na(PONDIIO),
    PP07H %in% c(1, 2),
    CH06 >= 18, CH06 <= 65
  ) %>%
  mutate(
    formal   = if_else(PP07H == 1, "Formal", "Informal"),
    formal   = factor(formal, levels = c("Informal", "Formal")),
    sexo     = if_else(CH04 == 1, "Varón", "Mujer"),
    horas    = PP3E_TOT,
    ingreso  = P21,
    log_ing  = log(P21),
    region   = factor(REGION,
                      levels = c(1, 40, 41, 42, 43, 44),
                      labels = c("GBA", "NOA", "NEA", "Cuyo",
                                 "Pampeana", "Patagonia")),
    educ = case_when(
      NIVEL_ED %in% c(1, 7) ~ "Sin secundaria",
      NIVEL_ED %in% c(2, 3) ~ "Secundaria incompleta",
      NIVEL_ED == 4         ~ "Secundaria completa",
      NIVEL_ED == 5         ~ "Superior incompleto",
      NIVEL_ED == 6         ~ "Superior completo"
    ),
    educ = factor(educ, levels = c("Sin secundaria", "Secundaria incompleta",
                                   "Secundaria completa", "Superior incompleto",
                                   "Superior completo"))
  ) %>%
  select(CODUSU, NRO_HOGAR, COMPONENTE, AGLOMERADO, region, sexo, CH06,
         educ, formal, horas, ingreso, log_ing, PONDIIO, PONDERA)

glimpse(eph)
nrow(eph)


# =============================================================================
# 1. ESTADÍSTICAS PONDERADAS
# =============================================================================

# 1.1 Por qué importa el ponderador ----------------------------------------
# Cada registro de la EPH representa a una cantidad distinta de personas.
# Ignorar el ponderador sesga cualquier estimación poblacional

comparacion <- eph %>%
  summarise(
    media_sin_pond = mean(ingreso),
    media_con_pond = weighted.mean(ingreso, w = PONDIIO),
    n_muestral     = n(),
    n_poblacional  = sum(PONDIIO)
  )

comparacion

# Diferencia relativa entre ambas estimaciones
with(comparacion, (media_con_pond / media_sin_pond - 1) * 100)


# 1.2 Medias ponderadas por grupo ------------------------------------------

eph %>%
  group_by(formal) %>%
  summarise(
    n              = n(),
    poblacion      = sum(PONDIIO),
    media          = weighted.mean(ingreso, PONDIIO),
    mediana        = median(rep(ingreso, times = round(PONDIIO / 100))),
    .groups = "drop"
  )

# La mediana ponderada por expansión de vectores es ineficiente.
# Conviene una función propia

mediana_pond <- function(x, w, p = 0.5) {
  ord <- order(x)
  x   <- x[ord]
  w   <- w[ord]
  acum <- cumsum(w) / sum(w)
  x[which(acum >= p)[1]]
}

eph %>%
  group_by(formal) %>%
  summarise(
    media   = weighted.mean(ingreso, PONDIIO),
    mediana = mediana_pond(ingreso, PONDIIO),
    .groups = "drop"
  )


# 1.3 El diseño muestral con survey ----------------------------------------
# La EPH tiene un diseño complejo, estratificado y por conglomerados.
# La aproximación habitual en la práctica aplicada usa el aglomerado
# como estrato y el ponderador como peso

dis <- svydesign(
  ids     = ~1,
  strata  = ~AGLOMERADO,
  weights = ~PONDIIO,
  data    = eph
)

# Media con su error estándar, calculado por el paquete
svymean(~ingreso, dis)

# Media por grupo
svyby(~ingreso, ~formal, dis, svymean)

# Cuantiles con intervalo de confianza
svyquantile(~ingreso, dis, quantiles = c(0.1, 0.25, 0.5, 0.75, 0.9),
            ci = TRUE)

# EJERCICIO 1
# Comparar el error estándar que devuelve svymean con el que se obtiene
# de la fórmula simple sd(x)/sqrt(n) ignorando el diseño. Cuál es mayor
# y por qué


# =============================================================================
# 2. DENSIDADES SUPERPUESTAS Y COMPARACIÓN DE DISTRIBUCIONES
# =============================================================================

# 2.1 Ingreso en nivel, la asimetría domina el gráfico ---------------------

ggplot(eph, aes(x = ingreso, weight = PONDIIO, fill = formal)) +
  geom_density(alpha = 0.45, colour = NA) +
  scale_x_continuous(labels = scales::label_number(big.mark = ".")) +
  labs(title = "Ingreso de la ocupación principal",
       subtitle = "Densidad ponderada por PONDIIO",
       x = "Ingreso mensual", y = "Densidad", fill = NULL)

# 2.2 En logaritmo la comparación se vuelve legible ------------------------

ggplot(eph, aes(x = log_ing, weight = PONDIIO, fill = formal)) +
  geom_density(alpha = 0.45, colour = NA) +
  labs(title = "Ingreso en logaritmo",
       x = "log(ingreso)", y = "Densidad", fill = NULL)

# 2.3 Boxplots por región y condición de formalidad ------------------------

ggplot(eph, aes(x = region, y = ingreso, weight = PONDIIO, fill = formal)) +
  geom_boxplot(outlier.alpha = 0.1) +
  scale_y_continuous(trans = "log10",
                     labels = scales::label_number(big.mark = ".")) +
  labs(x = NULL, y = "Ingreso, escala log", fill = NULL) +
  theme(legend.position = "bottom")

# 2.4 Función de distribución acumulada empírica ---------------------------
# Herramienta subutilizada. Permite comparar distribuciones completas
# sin elegir un ancho de banda

ggplot(eph, aes(x = ingreso, colour = formal)) +
  stat_ecdf(linewidth = 0.9) +
  scale_x_continuous(trans = "log10",
                     labels = scales::label_number(big.mark = ".")) +
  labs(title = "Distribución acumulada del ingreso",
       x = "Ingreso, escala log", y = "Proporción acumulada", colour = NULL)

# EJERCICIO 2
# Agregar al gráfico de densidades una línea vertical en la mediana de
# cada grupo. Pista, calcular las medianas ponderadas y pasarlas con
# geom_vline en un data frame aparte


# =============================================================================
# 3. CUANTILES POR GRUPO
# =============================================================================

# 3.1 Tabla de cuantiles ponderados ----------------------------------------

cuantiles_pond <- function(x, w, probs = c(0.1, 0.25, 0.5, 0.75, 0.9)) {
  map_dbl(probs, ~ mediana_pond(x, w, p = .x)) %>%
    set_names(paste0("p", probs * 100))
}

tabla_cuantiles <- eph %>%
  group_by(formal) %>%
  summarise(as_tibble_row(cuantiles_pond(ingreso, PONDIIO)), .groups = "drop") %>%
  mutate(ratio_p90_p10 = p90 / p10)

tabla_cuantiles

# 3.2 Brecha por cuantil ---------------------------------------------------
# La brecha entre formales e informales no es constante a lo largo de
# la distribución. Este cálculo lo muestra

probs <- seq(0.05, 0.95, by = 0.05)

brecha <- eph %>%
  group_by(formal) %>%
  summarise(
    p = probs,
    q = map_dbl(probs, ~ mediana_pond(ingreso, PONDIIO, p = .x)),
    .groups = "drop"
  ) %>%
  pivot_wider(names_from = formal, values_from = q) %>%
  mutate(brecha = Formal / Informal - 1)

ggplot(brecha, aes(x = p, y = brecha)) +
  geom_line(linewidth = 0.9) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  scale_y_continuous(labels = scales::percent) +
  labs(title = "Brecha formal-informal a lo largo de la distribución",
       x = "Cuantil", y = "Brecha relativa")

# EJERCICIO 3
# Repetir el cálculo de brecha separando por sexo. La forma de la curva
# cambia entre varones y mujeres


# =============================================================================
# 4. BOOTSTRAP A MANO
# =============================================================================

# Estadístico de interés, la mediana del ingreso horario de los informales.
# No hay fórmula cerrada simple para su error estándar

datos_inf <- eph %>%
  filter(formal == "Informal", horas > 0) %>%
  mutate(ing_hora = ingreso / (horas * 4.33))

x <- datos_inf$ing_hora
w <- datos_inf$PONDIIO

est_obs <- mediana_pond(x, w)
est_obs

# 4.1 El loop explícito ----------------------------------------------------

B <- 2000
n <- length(x)
boot_medianas <- numeric(B)

for (b in 1:B) {
  idx <- sample(seq_len(n), size = n, replace = TRUE)
  boot_medianas[b] <- mediana_pond(x[idx], w[idx])
}

# Error estándar bootstrap
se_boot <- sd(boot_medianas)
se_boot

# Intervalo por el método percentil
ic_perc <- quantile(boot_medianas, c(0.025, 0.975))
ic_perc

# Intervalo por aproximación normal
c(est_obs - 1.96 * se_boot, est_obs + 1.96 * se_boot)

# Sesgo bootstrap
mean(boot_medianas) - est_obs

# 4.2 Visualización --------------------------------------------------------

tibble(mediana = boot_medianas) %>%
  ggplot(aes(x = mediana)) +
  geom_histogram(bins = 50, fill = "grey70", colour = "white") +
  geom_vline(xintercept = est_obs, linewidth = 1) +
  geom_vline(xintercept = ic_perc, linetype = "dashed") +
  labs(title = "Distribución bootstrap de la mediana del ingreso horario",
       subtitle = "Línea sólida en el valor observado, punteadas en el IC 95%",
       x = "Mediana del ingreso horario", y = "Frecuencia")

# 4.3 Bootstrap de un estadístico sin teoría, el Gini ----------------------

gini <- function(x, w = rep(1, length(x))) {
  ord <- order(x)
  x <- x[ord]; w <- w[ord]
  p  <- cumsum(w) / sum(w)
  wm <- weighted.mean(x, w)
  L  <- cumsum(w * x) / sum(w * x)
  1 - sum((p - lag(p, default = 0)) * (L + lag(L, default = 0)))
}

gini_obs <- gini(eph$ingreso, eph$PONDIIO)
gini_obs

B <- 1000
boot_gini <- numeric(B)
n <- nrow(eph)

for (b in 1:B) {
  idx <- sample(seq_len(n), size = n, replace = TRUE)
  boot_gini[b] <- gini(eph$ingreso[idx], eph$PONDIIO[idx])
}

quantile(boot_gini, c(0.025, 0.975))

# EJERCICIO 4
# Estimar por bootstrap el intervalo de confianza del ratio p90/p10
# calculado en la sección 3. Comparar el ancho del intervalo con el
# de la mediana. Cuál se estima con más precisión y por qué


# =============================================================================
# 5. BOOTSTRAP CON EL PAQUETE boot
# =============================================================================

# El paquete requiere una función con dos argumentos, los datos y un
# vector de índices que boot() genera internamente

f_mediana <- function(data, idx) {
  mediana_pond(data$ing_hora[idx], data$PONDIIO[idx])
}

set.seed(99)
res_boot <- boot(data = datos_inf, statistic = f_mediana, R = 2000)

res_boot
plot(res_boot)

# Cuatro tipos de intervalo sobre el mismo objeto
boot.ci(res_boot, type = c("norm", "basic", "perc", "bca"))

# Comparación con el cálculo a mano de la sección 4
tibble(
  metodo = c("A mano, percentil", "boot, percentil"),
  li = c(ic_perc[1], boot.ci(res_boot, type = "perc")$percent[4]),
  ls = c(ic_perc[2], boot.ci(res_boot, type = "perc")$percent[5])
)

# 5.1 Bootstrap de una diferencia entre grupos -----------------------------
# El estadístico devuelve la brecha de medianas entre formales e informales

datos_h <- eph %>%
  filter(horas > 0) %>%
  mutate(ing_hora = ingreso / (horas * 4.33))

f_brecha <- function(data, idx) {
  d <- data[idx, ]
  mf <- mediana_pond(d$ing_hora[d$formal == "Formal"],
                     d$PONDIIO[d$formal == "Formal"])
  mi <- mediana_pond(d$ing_hora[d$formal == "Informal"],
                     d$PONDIIO[d$formal == "Informal"])
  mf / mi - 1
}

res_brecha <- boot(datos_h, f_brecha, R = 1000)
boot.ci(res_brecha, type = c("perc", "bca"))

# EJERCICIO 5
# Repetir con strata = datos_h$formal en la llamada a boot(). El bootstrap
# estratificado mantiene fijo el tamaño de cada grupo en cada remuestra.
# Cambia mucho el intervalo


# =============================================================================
# 6. PERMUTATION TEST
# =============================================================================

# Pregunta. La diferencia observada en el ingreso horario entre formales
# e informales es compatible con la hipótesis de que la condición de
# formalidad no tiene relación con el ingreso

# 6.1 Estadístico observado ------------------------------------------------

dif_obs <- mean(datos_h$ing_hora[datos_h$formal == "Formal"]) -
           mean(datos_h$ing_hora[datos_h$formal == "Informal"])
dif_obs

# 6.2 El loop de permutación -----------------------------------------------
# Bajo H0 las etiquetas son intercambiables. Se mezcla el vector de
# etiquetas y se recalcula el estadístico

B <- 2000
dif_perm <- numeric(B)
etiquetas <- datos_h$formal
y <- datos_h$ing_hora

for (b in 1:B) {
  et_perm <- sample(etiquetas)
  dif_perm[b] <- mean(y[et_perm == "Formal"]) - mean(y[et_perm == "Informal"])
}

# p-valor bilateral, con la corrección de sumar 1 en numerador y denominador
p_perm <- (sum(abs(dif_perm) >= abs(dif_obs)) + 1) / (B + 1)
p_perm

# 6.3 El gráfico que resume la lógica del test -----------------------------

tibble(dif = dif_perm) %>%
  ggplot(aes(x = dif)) +
  geom_histogram(bins = 50, fill = "grey70", colour = "white") +
  geom_vline(xintercept = dif_obs, colour = "firebrick", linewidth = 1) +
  labs(title = "Distribución nula por permutación",
       subtitle = "En rojo, la diferencia efectivamente observada",
       x = "Diferencia de medias bajo H0", y = "Frecuencia")

# 6.4 Comparación con el t-test --------------------------------------------

t.test(ing_hora ~ formal, data = datos_h)

# Ambos p-valores coinciden en este caso, porque n es grande.
# El bloque siguiente muestra un caso donde no coinciden

# 6.5 Submuestra chica, donde la teoría empieza a fallar -------------------

set.seed(7)
chica <- datos_h %>% group_by(formal) %>% slice_sample(n = 15) %>% ungroup()

dif_chica <- mean(chica$ing_hora[chica$formal == "Formal"]) -
             mean(chica$ing_hora[chica$formal == "Informal"])

perm_chica <- replicate(5000, {
  et <- sample(chica$formal)
  mean(chica$ing_hora[et == "Formal"]) - mean(chica$ing_hora[et == "Informal"])
})

tibble(
  test = c("Permutación", "t-test"),
  p    = c((sum(abs(perm_chica) >= abs(dif_chica)) + 1) / 5001,
           t.test(ing_hora ~ formal, data = chica)$p.value)
)

# 6.6 Cambiar el estadístico sin cambiar el método -------------------------
# Ventaja central de la permutación. La distribución nula se construye
# igual sea cual sea el estadístico elegido

perm_generico <- function(y, g, estadistico, B = 2000) {
  obs <- estadistico(y, g)
  nulos <- replicate(B, estadistico(y, sample(g)))
  list(obs = obs, nulos = nulos,
       p = (sum(abs(nulos) >= abs(obs)) + 1) / (B + 1))
}

# Diferencia de medianas
est_mediana <- function(y, g) median(y[g == "Formal"]) - median(y[g == "Informal"])

# Diferencia de percentiles 90
est_p90 <- function(y, g) {
  quantile(y[g == "Formal"], 0.9) - quantile(y[g == "Informal"], 0.9)
}

r1 <- perm_generico(datos_h$ing_hora, datos_h$formal, est_mediana, B = 1000)
r2 <- perm_generico(datos_h$ing_hora, datos_h$formal, est_p90, B = 1000)

tibble(
  estadistico = c("Diferencia de medianas", "Diferencia de p90"),
  observado   = c(r1$obs, r2$obs),
  p_valor     = c(r1$p, r2$p)
)

# EJERCICIO 6
# Aplicar perm_generico() a la diferencia de coeficientes de Gini entre
# varones y mujeres dentro del grupo de asalariados formales. Interpretar
# el resultado en términos sustantivos

# EJERCICIO 7 (integrador)
# Elegir dos regiones de la EPH y responder tres preguntas.
#   a) Cuál es el intervalo de confianza bootstrap de la mediana de
#      ingreso horario en cada una
#   b) La diferencia entre ambas es compatible con H0 según un test de
#      permutación
#   c) El resultado cambia si en lugar de la media se compara el p90
