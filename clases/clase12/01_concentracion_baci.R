# ============================================================================
# Clase 16 - Práctica 1: Concentración de mercado con BACI 2024
# ----------------------------------------------------------------------------
# Autor: Nicolás Sidicaro
# Curso: Ciencia de Datos para Economía y Negocios | FCE-UBA
#
# Objetivos:
#   (A) Concentración de DESTINOS por país (a quién le vende cada país)
#       - CR4, CR8 y HHI sobre la distribución de exportaciones por destino
#   (B) Concentración de PRODUCTOS por país (qué exporta cada país)
#       - CR4, CR8 a HS2 (capítulos)
#       - HHI a HS4 (partidas)
#       - HHI a HS6 (subpartidas)
#
# Datos: BACI HS22, año 2024 (versión 202601, CEPII)
#        - BACI_HS22_Y2024_V202601.csv
#        - country_codes_V202601.csv
#        - product_codes_HS22_V202601.csv
#
# Convención de columnas BACI:
#   t = año, i = exportador (code), j = importador (code),
#   k = producto HS6 (string con ceros a la izquierda),
#   v = valor en miles de USD, q = cantidad en toneladas.
# ============================================================================

# ---- 0. Paquetes y rutas ---------------------------------------------------

# library(data.table) # Por lo general usariamos este paquete para leer rapido
# Es un paquete optimizado para grandes bases de datos 
# Sin embargo, como la base BACI es muy grande la subí a Github en formato 
# fst con la libreria fst, que permite comprimir mucho los datos 
library(tidyverse)
library(fst)
options(scipen=999)

# Definir ruta 
baci_path <- "datos/baci"   # cambiar según corresponda

f_baci      <- file.path(baci_path, "baci_2024.fst")
f_paises    <- file.path(baci_path, "country_codes_V202601.csv")
f_productos <- file.path(baci_path, "product_codes_HS22_V202601.csv")


# ---- 1. Lectura de datos ---------------------------------------------------
baci <- read_fst(f_baci)
paises <- read_csv(f_paises)
productos <- read_csv(f_productos)

# Limpieza mínima: descartar filas con valor nulo o NA
baci <- baci %>% 
  filter(!is.na(v) & v > 0)

# ---- 2. Funciones auxiliares: CR y HHI -------------------------------------

# CR_k: suma de las k participaciones más grandes
calcular_cr <- function(shares, k = 4) {
  shares_ord <- sort(shares, decreasing = TRUE)
  sum(shares_ord[seq_len(min(k, length(shares_ord)))])
}

# HHI: suma de cuadrados de las participaciones (rango [1/N, 1])
calcular_hhi <- function(shares) {
  sum(shares^2)
}

# Versión "número equivalente de empresas/socios"
n_equiv <- function(hhi) 1 / hhi


# ============================================================================
# (A) CONCENTRACIÓN DE DESTINOS POR PAÍS
# ============================================================================
# Pregunta: ¿qué países venden a pocos socios y cuáles diversifican destinos?
# Para cada país exportador i, calculamos la participación de cada socio j
# en sus exportaciones totales, y luego CR4, CR8 y HHI.
# ----------------------------------------------------------------------------

# ---- A.1 Exportaciones por par (exportador, importador) --------------------

expo_dest <- baci %>% 
  group_by(i,j) %>% 
  summarize(valor = sum(v,na.rm=T))

# Participación de cada destino j en las exportaciones totales del país i
expo_dest <- expo_dest %>% 
  group_by(i) %>% 
  mutate(total_i = sum(valor),
         share = valor / total_i)

# ---- A.2 Concentración de destinos: CR4, CR8 y HHI -------------------------

conc_destinos <- expo_dest %>% 
  group_by(i) %>% 
  summarize(n_destinos = n(),
            cr1 = calcular_cr(share,1),
            cr4 = calcular_cr(share,4),
            cr8 = calcular_cr(share,8),
            hhi = calcular_hhi(share),
            total_expo = unique(total_i))

# Pegar nombre de país e ISO3
conc_destinos <- conc_destinos %>% 
  left_join(paises,by=c('i'='country_code'))

# Ordenar por HHI descendente (más concentrados primero)
conc_destinos <- conc_destinos %>% 
  arrange(desc(hhi))


# ---- A.3 top concentrados vs top diversificados -------------

# Filtro países con cierta escala mínima para evitar ruido (micro-exportadores)
umbral_expo <- 10000  # 100 millones de USD (recordar: v está en miles)

conc_filt <- conc_destinos %>% 
  filter(total_expo >= umbral_expo)

# Top 15 más concentrados y top 15 más diversificados
top_conc <- conc_filt %>% filter(row_number() < 16)
top_div  <- conc_filt %>% arrange(hhi) %>%filter(row_number() < 16)

# ---- A.4 Caso Argentina: ¿a quiénes le vende? ------------------------------

cod_arg <- 32

dest_arg <- expo_dest %>% filter(i == cod_arg)
dest_arg <- dest_arg %>% 
  left_join(paises,by=c('j'='country_code')) %>% 
  arrange(desc(share))

# Top 15 destinos de Argentina
dest_arg %>% 
  filter(row_number() < 16)


# ============================================================================
# (B) CONCENTRACIÓN DE PRODUCTOS POR PAÍS
# ============================================================================
# Pregunta: ¿cuán diversificada es la canasta exportadora de cada país?
# Calculamos a tres niveles de agregación del HS:
#   - CR4 y CR8 a 2 digitos (capítulos: ~97 grupos)
#   - HHI a 4 digitos (partidas: ~1.200 grupos)
#   - HHI a 6 digitos (subpartidas: ~5.300 grupos)
#
# Esperamos que el HHI baje al desagregar más fino: lo que parece concentrado
# a HS2 puede esconder variedad a HS6 (efecto similar al que advierte
# Grubel-Lloyd con el nivel de desagregación).
# ----------------------------------------------------------------------------

# ---- B.1 Exportaciones por (exportador, producto) --------------------------

expo_prod <- baci %>% 
  group_by(i,k) %>% 
  summarize(valor = sum(v))

# Generar niveles HS2 y HS4 a partir del HS6
expo_prod <- expo_prod %>% 
  mutate(k = str_pad(k,6,'left',pad='0'),
         hs2 = str_sub(k,1,2),
         hs4 = str_sub(k,1,4),
         hs6 = k)

# ---- B.2 CR a HS2 ----------------------------------------------------------

# Agregar a HS2 y calcular participación dentro del país
expo_hs2 <- expo_prod %>% 
  group_by(i,hs2) %>% 
  summarize(valor = sum(valor)) %>% 
  group_by(i) %>% 
  mutate(total_i = sum(valor),
         share = valor / total_i) 

conc_prod_hs2 <- expo_hs2 %>% 
  group_by(i) %>% 
  summarize(n_capitulos_hs2 = n(),
            cr4_hs2 = calcular_cr(share, 4),
            cr8_hs2 = calcular_cr(share, 8),
            hhi_hs2 = calcular_hhi(share),
            total_expo = unique(total_i))

# ---- B.3 HHI a HS4 ---------------------------------------------------------
expo_hs4 <- expo_prod %>% 
  group_by(i,hs4) %>% 
  summarize(valor = sum(valor)) %>% 
  group_by(i) %>% 
  mutate(total_i = sum(valor),
         share = valor / total_i) 

conc_prod_hs4 <- expo_hs4 %>% 
  group_by(i) %>% 
  summarize(n_capitulos_hs4 = n(),
            cr4_hs4 = calcular_cr(share, 4),
            cr8_hs4 = calcular_cr(share, 8),
            hhi_hs4 = calcular_hhi(share))

# ---- B.4 HHI a HS6 ---------------------------------------------------------

expo_hs6 <- expo_prod %>% 
  group_by(i,hs6) %>% 
  summarize(valor = sum(valor)) %>% 
  group_by(i) %>% 
  mutate(total_i = sum(valor),
         share = valor / total_i) 

conc_prod_hs6 <- expo_hs6 %>% 
  group_by(i) %>% 
  summarize(n_capitulos_hs6 = n(),
            cr4_hs6 = calcular_cr(share, 4),
            cr8_hs6 = calcular_cr(share, 8),
            hhi_hs6 = calcular_hhi(share))

# ---- B.5 Consolidar resultados por país ------------------------------------

conc_productos <- conc_prod_hs2 |>
  left_join(conc_prod_hs4, by = "i") |>
  left_join(conc_prod_hs6, by = "i") |>
  left_join(paises, by = c("i" = "country_code"))

conc_productos <- conc_productos %>% 
  arrange(desc(hhi_hs6))

# ---- B.6 Comparar el HHI según nivel de desagregación ----------------------

# Filtrar países con escala mínima
conc_prod_filt <- conc_productos %>% filter(total_expo >= umbral_expo)

# Países seleccionados para comparación
seleccion <- c("ARG", "BRA", "CHL", "MEX", "VEN", "DEU", "USA", "CHN",
               "KOR", "JPN", "AUS", "ZAF", "NGA", "SAU")

conc_prod_filt <- conc_prod_filt %>% 
  filter(country_iso3 %in% seleccion) |>
  select(country_iso3, hhi_hs2, hhi_hs4, hhi_hs6) |>
  pivot_longer(-country_iso3, names_to = "nivel", values_to = "hhi") |>
  mutate(
    nivel = recode(nivel,
                   "hhi_hs2" = "HS2 (capítulos)",
                   "hhi_hs4" = "HS4 (partidas)",
                   "hhi_hs6" = "HS6 (subpartidas)"),
    nivel = factor(nivel, levels = c("HS2 (capítulos)",
                                      "HS4 (partidas)",
                                      "HS6 (subpartidas)"))
  ) |>
  ggplot(aes(x = reorder(country_iso3, hhi), y = hhi, fill = nivel)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.7) +
  coord_flip() +
  scale_fill_brewer(palette = "Blues") +
  labs(x = NULL, y = "HHI de productos",
       fill = "Nivel de desagregación",
       title = "Concentración de la canasta exportadora según nivel HS",
       subtitle = "El HHI baja a medida que se desagrega más fino",
       caption = "Fuente: BACI HS22, CEPII (2024)") +
  theme_minimal(base_size = 11) +
  theme(legend.position = "bottom")
