# ============================================================================
# Clase 16 - Práctica 3: Gini y Theil con la EPH
# ----------------------------------------------------------------------------
# Autor: Nicolás Sidicaro
# Curso: Ciencia de Datos para Economía y Negocios | FCE-UBA
#
# Objetivos:
#   (A) Coeficiente de Gini aplicado a ingresos (EPH)
#       - Curva de Lorenz
#       - Gini ponderado a nivel nacional
#       - Gini por región
#   (B) Índice de Theil
#       - Theil total
#       - Descomposición: Theil entre grupos + Theil dentro de grupos
#       - Aplicación: ¿la desigualdad argentina es entre regiones o dentro?
#
# Datos: EPH-INDEC, descarga vía paquete `eph`
#        - Base individual (no hogares) porque trabajamos con ingreso individual
#        - Ponderador PONDIIO (para variables de la ocupación) o PONDIH (hogares)
#
# Notas metodológicas:
#   - Usamos ingreso de la ocupación principal (P21) para activos ocupados.
#   - Alternativa: ingreso per cápita familiar (IPCF) si querés medir desigualdad
#     en la distribución del bienestar del hogar.
# ============================================================================

# ---- 0. Paquetes -----------------------------------------------------------

# install.packages("eph")        # si no lo tenés instalado
# install.packages("acid")       # gini y theil ponderados (alternativa)
# install.packages("dineq")      # descomposición de Theil

library(eph)
library(dplyr)
library(tidyr)
library(ggplot2)
library(scales)
library(dineq)        # para descomponer Theil


# ---- 1. Descarga de la EPH -------------------------------------------------

# Bajamos el último trimestre disponible. Ajustar según corresponda.
anio <- 2025
trimestre <- 3

eph_ind <- get_microdata(year = anio,
                         period = trimestre,
                         type = "individual")

# ---- 2. Preparación de la base ---------------------------------------------

# Nos quedamos con ocupados con ingreso positivo (P21 > 0)
# y filtramos valores no respondidos (-9 y 0 con problemas de declaración)

base <- eph_ind |>
  filter(
    ESTADO == 1,      # ocupado
    P21 > 0,          # ingreso de ocupación principal positivo
    !is.na(P21),
    !is.na(PONDIIO)   # ponderador para variables de ingreso laboral
  ) |>
  mutate(
    ingreso = P21,
    pondera = PONDIIO,
    region = factor(REGION,
                    levels = c(1, 40, 41, 42, 43, 44),
                    labels = c("GBA", "NOA", "NEA", "Cuyo",
                               "Pampeana", "Patagonia"))
  ) |>
  select(ingreso, pondera, region, AGLOMERADO, CH04, CH06, NIVEL_ED) |>
  filter(!is.na(region))

# ============================================================================
# (A) COEFICIENTE DE GINI
# ============================================================================
#
# Definición (versión por área bajo la curva de Lorenz):
#   Gini = 1 - 2 * área bajo la curva de Lorenz
#
# Para una muestra con ponderadores, calculamos:
#   1. Ordenamos por ingreso ascendente.
#   2. Acumulamos población (proporción) y acumulamos ingreso (proporción).
#   3. Esos pares son los puntos de la curva de Lorenz.
#   4. Gini se calcula como 1 - 2 * trapezoide bajo la curva.
# ----------------------------------------------------------------------------

# ---- A.1 Función de Gini ponderado -----------------------------------------

calcular_gini <- function(x, w = NULL) {
  # Forzar a numeric para evitar integer overflow:
  # ingreso * ponderador puede superar el límite de enteros (~2.1e9) en R.
  x <- as.numeric(x)
  if (is.null(w)) w <- rep(1, length(x))
  w <- as.numeric(w)
  # quitar NA
  ok <- !is.na(x) & !is.na(w) & w > 0
  x <- x[ok]; w <- w[ok]
  # ordenar
  ord <- order(x)
  x <- x[ord]; w <- w[ord]
  # acumulados
  pob_acum <- cumsum(w) / sum(w)
  ing_acum <- cumsum(x * w) / sum(x * w)
  # área bajo la curva de Lorenz (trapezoides)
  area <- sum(diff(c(0, pob_acum)) * (c(0, ing_acum[-length(ing_acum)]) + ing_acum) / 2)
  1 - 2 * area
}


# ---- A.2 Gini nacional ------------------------------------------------------

gini_nac <- calcular_gini(base$ingreso, base$pondera)
gini_nac


# ---- A.3 Curva de Lorenz ---------------------------------------------------

curva_lorenz <- base |>
  arrange(ingreso) |>
  mutate(
    pob_acum = cumsum(pondera) / sum(pondera),
    ing_acum = cumsum(as.numeric(ingreso) * pondera) / sum(as.numeric(ingreso) * pondera)
  )

ggplot(curva_lorenz, aes(x = pob_acum, y = ing_acum)) +
  geom_ribbon(aes(ymin = ing_acum, ymax = pob_acum),
              fill = "steelblue", alpha = 0.25) +
  geom_line(color = "steelblue", linewidth = 1) +
  geom_abline(slope = 1, intercept = 0,
              color = "tomato", linetype = "dashed") +
  scale_x_continuous(labels = percent_format()) +
  scale_y_continuous(labels = percent_format()) +
  annotate("text", x = 0.65, y = 0.30,
           label = paste("Gini =", round(gini_nac, 3)),
           size = 5, fontface = "bold") +
  labs(x = "Proporción acumulada de población",
       y = "Proporción acumulada de ingreso",
       title = "Curva de Lorenz - Ingreso de la ocupación principal",
       subtitle = paste0("EPH ", anio, "T", trimestre,
                         " | Argentina"),
       caption = "Fuente: EPH-INDEC. Ocupados con ingreso > 0.") +
  theme_minimal(base_size = 12)


# ---- A.4 Gini por región ---------------------------------------------------

gini_region <- base |>
  group_by(region) |>
  summarise(
    gini = calcular_gini(as.numeric(ingreso), pondera),
    n    = n(),
    pob  = sum(pondera),
    ingreso_medio = weighted.mean(as.numeric(ingreso), pondera)
  ) |>
  arrange(desc(gini))

gini_region

gini_region |>
  ggplot(aes(x = reorder(region, gini), y = gini)) +
  geom_col(fill = "steelblue") +
  geom_hline(yintercept = gini_nac, color = "tomato",
             linetype = "dashed", linewidth = 0.8) +
  geom_text(aes(label = round(gini, 3)),
            hjust = -0.2, size = 4) +
  annotate("text", x = 1.5, y = gini_nac + 0.005,
           label = paste("Gini nacional =", round(gini_nac, 3)),
           color = "tomato", size = 3.5, hjust = 0) +
  coord_flip() +
  scale_y_continuous(limits = c(0, max(gini_region$gini) * 1.15)) +
  labs(x = NULL, y = "Coeficiente de Gini",
       title = "Desigualdad del ingreso por región",
       subtitle = paste0("EPH ", anio, "T", trimestre),
       caption = "Fuente: EPH-INDEC. Ingreso de la ocupación principal.") +
  theme_minimal(base_size = 11)


# ============================================================================
# (B) ÍNDICE DE THEIL
# ============================================================================
#
# Theil (T_1) pertenece a la familia de entropía generalizada (GE(1)):
#
#   T = (1/N) * sum_i [ (y_i / mean_y) * ln(y_i / mean_y) ]
#
# Con ponderadores:
#
#   T = sum_i [ w_i * (y_i / mean_y) * ln(y_i / mean_y) ]  (con sum w_i = 1)
#
# Ventaja clave: es ADITIVAMENTE DESCOMPONIBLE.
#
#   T_total = T_entre + T_dentro
#
# Donde:
#   T_entre  = desigualdad explicada por diferencias en los promedios de los grupos
#   T_dentro = desigualdad explicada por diferencias dentro de cada grupo (promedio
#              ponderado de los Theil internos)
# ----------------------------------------------------------------------------

# ---- B.1 Función de Theil ponderado ----------------------------------------

calcular_theil <- function(x, w = NULL) {
  x <- as.numeric(x)
  if (is.null(w)) w <- rep(1, length(x))
  w <- as.numeric(w)
  ok <- !is.na(x) & !is.na(w) & w > 0 & x > 0
  x <- x[ok]; w <- w[ok]
  w_rel <- w / sum(w)
  media <- sum(x * w_rel)
  ratio <- x / media
  sum(w_rel * ratio * log(ratio))
}


# ---- B.2 Theil nacional ----------------------------------------------------

theil_nac <- calcular_theil(base$ingreso, base$pondera)
theil_nac


# ---- B.3 Descomposición de Theil entre/dentro de regiones ------------------
#
# Componente ENTRE:
#   T_entre = sum_g [ s_g * (mu_g / mu) * log(mu_g / mu) ]
#   donde s_g = participación del grupo g en la población
#         mu_g = media del grupo g
#         mu = media total
#
# Componente DENTRO:
#   T_dentro = sum_g [ s_g * (mu_g / mu) * T_g ]
#   donde T_g = Theil interno del grupo g
# ----------------------------------------------------------------------------

descomponer_theil <- function(x, w, grupo) {
  x <- as.numeric(x)
  w <- as.numeric(w)
  ok <- !is.na(x) & !is.na(w) & !is.na(grupo) & w > 0 & x > 0
  x <- x[ok]; w <- w[ok]; grupo <- grupo[ok]
  
  mu_total <- weighted.mean(x, w)
  pob_total <- sum(w)
  
  grupos_unicos <- unique(grupo)
  componentes <- lapply(grupos_unicos, function(g) {
    idx <- grupo == g
    s_g  <- sum(w[idx]) / pob_total
    mu_g <- weighted.mean(x[idx], w[idx])
    T_g  <- calcular_theil(x[idx], w[idx])
    
    list(
      grupo = g,
      s_g = s_g,
      mu_g = mu_g,
      T_g = T_g,
      contribucion_entre = s_g * (mu_g / mu_total) * log(mu_g / mu_total),
      contribucion_dentro = s_g * (mu_g / mu_total) * T_g
    )
  })
  
  detalles <- do.call(rbind, lapply(componentes, as.data.frame))
  
  list(
    T_total = sum(detalles$contribucion_entre) +
      sum(detalles$contribucion_dentro),
    T_entre = sum(detalles$contribucion_entre),
    T_dentro = sum(detalles$contribucion_dentro),
    detalles = detalles
  )
}


# ---- B.4 Aplicación a EPH por región ---------------------------------------

theil_desc <- descomponer_theil(base$ingreso, base$pondera, base$region)

theil_desc$T_total
theil_desc$T_entre
theil_desc$T_dentro

# Verificación: ¿T_entre + T_dentro = T_total?
all.equal(theil_desc$T_total, theil_desc$T_entre + theil_desc$T_dentro)

# Detalle por región
theil_desc$detalles


# ---- B.5 Visualización: ¿de dónde viene la desigualdad? --------------------

descomp_df <- tibble(
  componente = c("Entre regiones", "Dentro de regiones"),
  valor = c(theil_desc$T_entre, theil_desc$T_dentro),
  porcentaje = valor / theil_desc$T_total
)

descomp_df |>
  ggplot(aes(x = "", y = valor, fill = componente)) +
  geom_col(width = 0.5) +
  geom_text(aes(label = paste0(round(porcentaje * 100, 1), "%")),
            position = position_stack(vjust = 0.5),
            color = "white", size = 5, fontface = "bold") +
  scale_fill_manual(values = c("Entre regiones" = "tomato",
                               "Dentro de regiones" = "steelblue")) +
  labs(x = NULL, y = "Índice de Theil",
       fill = NULL,
       title = "Descomposición del Theil: entre vs dentro de regiones",
       subtitle = paste0("EPH ", anio, "T", trimestre,
                         " | Theil total = ",
                         round(theil_desc$T_total, 3)),
       caption = "Fuente: EPH-INDEC.") +
  theme_minimal(base_size = 12) +
  theme(legend.position = "bottom")


# ---- B.6 Descomposición alternativa: por nivel educativo -------------------

# Recodear NIVEL_ED a etiquetas claras
base <- base |>
  mutate(
    nivel_ed = case_when(
      NIVEL_ED == 1 ~ "Primario incompleto",
      NIVEL_ED == 2 ~ "Primario completo",
      NIVEL_ED == 3 ~ "Secundario incompleto",
      NIVEL_ED == 4 ~ "Secundario completo",
      NIVEL_ED == 5 ~ "Superior incompleto",
      NIVEL_ED == 6 ~ "Superior completo",
      NIVEL_ED == 7 ~ "Sin instrucción",
      TRUE ~ NA_character_
    )
  )

theil_educ <- descomponer_theil(base$ingreso, base$pondera, base$nivel_ed)

cat("\n--- Descomposición por NIVEL EDUCATIVO ---\n")
cat("T_total :", round(theil_educ$T_total, 4), "\n")
cat("T_entre :", round(theil_educ$T_entre, 4),
    " (", round(100 * theil_educ$T_entre / theil_educ$T_total, 1), "%)\n")
cat("T_dentro:", round(theil_educ$T_dentro, 4),
    " (", round(100 * theil_educ$T_dentro / theil_educ$T_total, 1), "%)\n")


# ---- B.7 Comparar las dos descomposiciones ---------------------------------

comparacion <- tibble(
  particion = c("Por región", "Por región",
                "Por nivel educativo", "Por nivel educativo"),
  componente = c("Entre", "Dentro",
                 "Entre", "Dentro"),
  valor = c(theil_desc$T_entre, theil_desc$T_dentro,
            theil_educ$T_entre, theil_educ$T_dentro)
)

comparacion |>
  group_by(particion) |>
  mutate(porcentaje = valor / sum(valor)) |>
  ggplot(aes(x = particion, y = valor, fill = componente)) +
  geom_col(position = "stack", width = 0.6) +
  geom_text(aes(label = paste0(round(porcentaje * 100, 1), "%")),
            position = position_stack(vjust = 0.5),
            color = "white", size = 4, fontface = "bold") +
  scale_fill_manual(values = c("Entre" = "tomato",
                               "Dentro" = "steelblue")) +
  labs(x = NULL, y = "Índice de Theil", fill = "Componente",
       title = "Theil: qué partición captura más desigualdad",
       subtitle = "Nivel educativo separa mejor a la población que la región",
       caption = "Fuente: EPH-INDEC.") +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom")

