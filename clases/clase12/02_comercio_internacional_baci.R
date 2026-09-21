# ============================================================================
# Clase 16 - Práctica 2: Comercio internacional con BACI 2024
# ----------------------------------------------------------------------------
# Autor: Nicolás Sidicaro
# Curso: Ciencia de Datos para Economía y Negocios | FCE-UBA
#
# Objetivos:
#   (A) Ventaja Comparativa Revelada (RCA) de Balassa
#       - RCA clásico y RCA simétrico (RSCA)
#       - Identificación de productos con VCR para Argentina y otros países
#       - Cálculo a HS4 y comparación con HS2
#   (B) Índice de Grubel-Lloyd (comercio intraindustrial)
#       - GL sectorial (por producto) para un país
#       - GL agregado para un país
#       - Efecto del nivel de desagregación: HS2 vs HS4 vs HS6
#       - Comparación entre países
#
# Datos: BACI HS22, año 2024 (versión 202601, CEPII)
#
# Convención de columnas BACI:
#   t = año, i = exportador (code), j = importador (code),
#   k = producto HS6 (string), v = valor en miles de USD, q = cantidad.
# ============================================================================

# ---- 0. Paquetes y rutas ---------------------------------------------------

library(data.table) # Para leer: https://atrebas.github.io/post/2020-06-17-datatable-introduction/ 
                    # https://cran.r-project.org/web/packages/data.table/vignettes/datatable-intro.html
library(tidyverse)
library(scales)
library(fst)
options(scipen=999)

# Definir ruta 
baci_path <- "datos/baci"   # cambiar según corresponda

f_baci      <- file.path(baci_path, "baci_2024.fst")
f_paises    <- file.path(baci_path, "country_codes_V202601.csv")
f_productos <- file.path(baci_path, "product_codes_HS22_V202601.csv")


# ---- 1. Lectura de datos ---------------------------------------------------

baci <- read_fst(f_baci)
paises    <- fread(f_paises, encoding = "UTF-8")
productos <- fread(f_productos,
                   encoding = "UTF-8")
setDT(baci)
baci <- baci[!is.na(v) & v > 0]
baci <- baci[,k := str_pad(k,6,'left',pad='0')]

# ============================================================================
# (A) VENTAJA COMPARATIVA REVELADA (RCA) DE BALASSA
# ============================================================================
#
# RCA_{ij} = (X_{ij} / X_{i.}) / (X_{.j} / X_{..})
#
#   X_{ij}: exportaciones del país i en el producto j
#   X_{i.}: exportaciones totales del país i
#   X_{.j}: exportaciones mundiales del producto j
#   X_{..}: exportaciones mundiales totales
#
# Lectura:
#   RCA > 1: ventaja comparativa revelada
#   RCA < 1: desventaja comparativa
#
# RSCA = (RCA - 1) / (RCA + 1)  ∈ [-1, 1]
# ----------------------------------------------------------------------------

# ---- A.1 Cálculo de RCA a HS4 -----------------------------------------------

# Trabajamos con HS4 (partidas) como nivel principal:
# es un buen compromiso entre granularidad y robustez estadística.

# Crear nivel HS4
baci[, hs4 := str_sub(k, 1, 4)]

# Exportaciones por país y producto (a HS4)
x_ij <- baci[, .(x_ij = sum(v)), by = .(i, hs4)]

# Totales
x_i_dot   <- x_ij[, .(x_i_dot = sum(x_ij)),  by = i]      # totales por país
x_dot_j   <- x_ij[, .(x_dot_j = sum(x_ij)),  by = hs4]    # totales por producto
x_dot_dot <- x_ij[, sum(x_ij)]                            # total mundial

# Unir y calcular RCA
rca <- x_ij |>
  merge(x_i_dot, by = "i") |>
  merge(x_dot_j, by = "hs4") |>
  mutate(
    rca  = (x_ij / x_i_dot) / (x_dot_j / x_dot_dot),
    rsca = (rca - 1) / (rca + 1)
  ) |>
  as.data.table()

head(rca)


# ---- A.2 Pegar nombres -----------------------------------------------------

# Descripción del HS4: tomar la descripción del HS6 con mayor valor mundial
# dentro de cada partida (representativo)
desc_hs4 <- baci[
  , .(valor_mundial = sum(v)), by = .(k)
][
  order(-valor_mundial)
][
  , .(hs4 = str_sub(k, 1, 4), k, valor_mundial)
] |>
  merge(productos %>% 
          mutate(code = str_pad(code,6,'left',pad='0'),
                 code = str_sub(code,1,4)) %>% 
          group_by(code) %>% 
          filter(row_number() == 1 )
        , by.x = "hs4", by.y = "code", all.x = TRUE) |>
  group_by(hs4) |>
  slice_max(valor_mundial, n = 1, with_ties = FALSE) |>
  select(hs4, descripcion_hs4 = description) |>
  as.data.table()

rca <- merge(rca, desc_hs4, by = "hs4", all.x = TRUE)
rca <- merge(rca, paises, by.x = "i", by.y = "country_code", all.x = TRUE)


# ---- A.3 Top productos con VCR para Argentina -----------------------------

cod_arg <- paises[country_iso3 == "ARG", country_code]

rca_arg <- rca[i == cod_arg & x_ij > 0][order(-rca)]

# Top 20 productos con mayor RCA en Argentina
# (filtramos por un valor exportado mínimo para evitar ruido de partidas chicas)
umbral_x_min <- 10e3   # 10 millones de USD (recordar: v en miles)

top_rca_arg <- rca_arg[x_ij >= umbral_x_min][1:20]

top_rca_arg[, etiqueta := paste0(hs4, " - ", str_trunc(descripcion_hs4, 45))]

top_rca_arg |>
  mutate(etiqueta = reorder(etiqueta, rca)) |>
  ggplot(aes(x = etiqueta, y = rca)) +
  geom_col(fill = "steelblue") +
  geom_hline(yintercept = 1, color = "tomato", linetype = "dashed") +
  coord_flip() +
  labs(x = NULL, y = "RCA de Balassa",
       title = "Top 20 productos con ventaja comparativa revelada — Argentina",
       subtitle = "HS4, 2024. Línea roja: RCA = 1",
       caption = "Fuente: BACI HS22, CEPII") +
  theme_minimal(base_size = 10)


# ---- A.4 Distribución de RCA: clásico vs simétrico --------------------------

# El problema del RCA clásico: es asimétrico (de 0 a 1 si no hay ventaja,
# de 1 a infinito si hay). El RSCA lo normaliza a [-1, 1].

rca_arg_pos <- rca_arg[x_ij >= umbral_x_min]

p1 <- rca_arg_pos |>
  ggplot(aes(x = rca)) +
  geom_histogram(bins = 50, fill = "steelblue", color = "white") +
  geom_vline(xintercept = 1, color = "tomato", linetype = "dashed") +
  scale_x_continuous(trans = "log10") +
  labs(x = "RCA (escala log)", y = "Cantidad de productos",
       title = "Distribución del RCA clásico — Argentina, HS4 2024") +
  theme_minimal(base_size = 10)

p2 <- rca_arg_pos |>
  ggplot(aes(x = rsca)) +
  geom_histogram(bins = 50, fill = "darkorange", color = "white") +
  geom_vline(xintercept = 0, color = "tomato", linetype = "dashed") +
  labs(x = "RSCA", y = "Cantidad de productos",
       title = "Distribución del RCA simétrico (RSCA) — Argentina, HS4 2024",
       caption = "Fuente: BACI HS22, CEPII") +
  theme_minimal(base_size = 10)

print(p1)
print(p2)


# ---- A.5 Cantidad de productos con VCR por país ----------------------------

# Diversidad: cuántos productos exporta cada país con RCA > 1
diversidad <- rca[
  rca > 1 & x_ij >= umbral_x_min,
  .(n_productos_vcr = .N),
  by = .(i)
] |>
  merge(paises, by.x = "i", by.y = "country_code")

setorder(diversidad, -n_productos_vcr)

head(diversidad[, .(country_iso3, country_name, n_productos_vcr)], 20)


# ---- A.6 Comparar RCA entre países seleccionados ---------------------------

# Tomamos un producto y vemos qué países tienen VCR
# Ejemplo: 1201 (porotos de soja) — debería dar muy alto en países sojeros

prod_ej <- "1201"  # porotos de soja
descripciones_ej <- desc_hs4[hs4 == prod_ej, descripcion_hs4]
descripciones_ej

rca_soja <- rca[hs4 == prod_ej & x_ij > 0][order(-rca)]
head(rca_soja[, .(country_iso3, country_name, x_ij, rca, rsca)], 15)


# ============================================================================
# (B) ÍNDICE DE GRUBEL-LLOYD (COMERCIO INTRAINDUSTRIAL)
# ============================================================================
#
# GL_j = 1 - |X_j - M_j| / (X_j + M_j)
#
#   GL = 1: comercio 100% intraindustrial (X = M)
#   GL = 0: comercio 100% interindustrial (sólo exporta o sólo importa)
#
# En BACI, para el país c y producto k:
#   X_{ck} = sum(v) cuando i == c (lo que c exporta al mundo)
#   M_{ck} = sum(v) cuando j == c (lo que el mundo exporta a c)
# ----------------------------------------------------------------------------

# ---- B.1 Construir flujos X y M por país-producto (HS6) --------------------

x_pais <- baci[, .(X = sum(v)), by = .(pais = i, k)]
m_pais <- baci[, .(M = sum(v)), by = .(pais = j, k)]

flujos <- merge(x_pais, m_pais, by = c("pais", "k"), all = TRUE)
flujos[is.na(X), X := 0]
flujos[is.na(M), M := 0]

flujos[, hs6 := k]
flujos[, hs4 := str_sub(k, 1, 4)]
flujos[, hs2 := str_sub(k, 1, 2)]


# ---- B.2 GL sectorial para Argentina a HS4 ---------------------------------

flujos_arg_hs4 <- flujos[pais == cod_arg, .(X = sum(X), M = sum(M)),
                          by = hs4]

flujos_arg_hs4[, comercio_total := X + M]
flujos_arg_hs4[, gl := 1 - abs(X - M) / (X + M)]

# Pegar descripción
flujos_arg_hs4 <- merge(flujos_arg_hs4, desc_hs4, by = "hs4", all.x = TRUE)


# Top 20 sectores con mayor comercio total y su GL
top_sectores_arg <- flujos_arg_hs4[order(-comercio_total)][1:20]

top_sectores_arg[, etiqueta := paste0(hs4, " - ", str_trunc(descripcion_hs4, 40))]

top_sectores_arg |>
  mutate(etiqueta = reorder(etiqueta, comercio_total)) |>
  ggplot(aes(x = etiqueta, y = gl, fill = gl)) +
  geom_col(show.legend = FALSE) +
  geom_text(aes(label = sprintf("%.2f", gl)), hjust = -0.1, size = 3) +
  scale_fill_gradient(low = "tomato", high = "steelblue", limits = c(0, 1)) +
  scale_y_continuous(limits = c(0, 1.1), breaks = seq(0, 1, 0.25)) +
  coord_flip() +
  labs(x = NULL, y = "Grubel-Lloyd",
       title = "GL sectorial — Argentina (top 20 sectores por comercio total)",
       subtitle = "HS4, 2024. Azul = intraindustrial, rojo = interindustrial",
       caption = "Fuente: BACI HS22, CEPII") +
  theme_minimal(base_size = 10)


# ---- B.3 GL agregado para un país ------------------------------------------
#
# GL_agregado = 1 - sum(|X_j - M_j|) / sum(X_j + M_j)
#
# Se puede calcular a distintos niveles de agregación.
# Esperamos: GL(HS2) > GL(HS4) > GL(HS6).
# Porque al desagregar más, se descubren asimetrías que la agregación oculta.
# ----------------------------------------------------------------------------

calcular_gl_agregado <- function(flujos_pais, nivel = "hs6") {
  agregado <- flujos_pais[, .(X = sum(X), M = sum(M)),
                           by = c(nivel)]
  numerador   <- sum(abs(agregado$X - agregado$M))
  denominador <- sum(agregado$X + agregado$M)
  1 - numerador / denominador
}

# Para Argentina a tres niveles
flujos_arg <- flujos[pais == cod_arg]

gl_arg_hs2 <- calcular_gl_agregado(flujos_arg, "hs2")
gl_arg_hs4 <- calcular_gl_agregado(flujos_arg, "hs4")
gl_arg_hs6 <- calcular_gl_agregado(flujos_arg, "hs6")

data.table(
  nivel = c("HS2", "HS4", "HS6"),
  gl    = c(gl_arg_hs2, gl_arg_hs4, gl_arg_hs6)
)
