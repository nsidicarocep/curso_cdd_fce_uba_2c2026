# =============================================================================
# Galería de gráficos con ggplot2 — estilo Clases 18/19 (FCE-UBA)
# Nicolás Sidicaro
# =============================================================================

library(tidyverse)
library(scales)
library(ggrepel)
library(jsonlite)   # para la API del Banco Mundial

# ---- Tema de la casa (como en la Clase 18) ----------------------------------
theme_set(
  theme_minimal(base_size = 12) +
    theme(
      plot.title       = element_text(face = "bold", size = 13),
      plot.subtitle    = element_text(color = "gray40", size = 10),
      plot.caption     = element_text(color = "gray50", hjust = 0),
      panel.grid.minor = element_blank(),
      legend.position  = "bottom"
    )
)

# Paleta para los 5 continentes (consistente en todos los gráficos)
paleta_cont <- c(
  "Americas" = "#d62728", "Europe" = "#2ca02c", "Asia" = "#1f77b4",
  "Africa"   = "#ff7f0e", "Oceania" = "#9467bd"
)

# =============================================================================
# CARGA BASE — OWID (PBI per cápita, población, CO2 y energía per cápita)
# =============================================================================
# co2-data trae PBI total (Maddison) y población; le sumamos el continente con
# un lookup ISO estándar (también en GitHub) para no depender de countrycode.

owid_raw <- read_csv(
  "https://raw.githubusercontent.com/owid/co2-data/master/owid-co2-data.csv",
  show_col_types = FALSE
)

iso <- read_csv(
  "https://raw.githubusercontent.com/lukes/ISO-3166-Countries-with-Regional-Codes/master/all/all.csv",
  show_col_types = FALSE
) |>
  select(iso_code = `alpha-3`, continente = region, subregion = `sub-region`)

owid <- owid_raw |>
  inner_join(iso, by = "iso_code") |>          # inner_join descarta agregados (World, Africa, ...)
  mutate(pbi_pc = gdp / population) |>          # PBI per cápita = PBI total / población
  transmute(
    pais       = country,
    iso_code, anio = year, continente, subregion,
    poblacion  = population,
    pbi_pc,
    co2_pc     = co2_per_capita,
    energia_pc = energy_per_capita
  )

# PBI
owid_2022 <- owid |> filter(anio == 2022)

# Países de América Latina para etiquetar
latam <- c("Argentina", "Brazil", "Chile", "Colombia", "Mexico", "Peru",
           "Uruguay", "Bolivia", "Venezuela", "Ecuador", "Paraguay")

# Países de Sudamérica para los gráficos de "pocas entidades"
sudamerica <- c("Argentina", "Brazil", "Chile", "Uruguay", "Bolivia",
                "Peru", "Colombia", "Paraguay", "Ecuador")


# =============================================================================
# 1) LÍNEAS CON BASE 100  —  Fuente: BANCO MUNDIAL (API REST, sin paquete WDI)
# =============================================================================

wb_get <- function(indicador,
                   paises = "all",
                   desde  = 1990,
                   hasta  = 2022) {
  url <- paste0(
    "https://api.worldbank.org/v2/country/",
    paste(paises, collapse = ";"),
    "/indicator/", indicador,
    "?format=json&per_page=20000&date=", desde, ":", hasta
  )
  resp <- fromJSON(url, flatten = TRUE)
  if (length(resp) < 2 || is.null(resp[[2]])) stop("La API no devolvió datos.")
  resp[[2]] |>
    as_tibble() |>
    transmute(
      pais  = country.value,
      iso   = countryiso3code,
      anio  = as.integer(date),
      valor = value
    ) |>
    filter(!is.na(valor)) |>
    arrange(pais, anio)
}

# PBI per cápita (USD constantes de 2015) para 5 países de niveles muy distintos
bm <- wb_get("NY.GDP.PCAP.KD",
             paises = c("ARG", "BRA", "CHL", "KOR", "MEX"),
             desde = 1990, hasta = 2022)

anio_base <- 1990
bm_idx <- bm |>
  group_by(pais) |>
  arrange(anio) |>
  mutate(indice = valor / valor[anio == anio_base] * 100) |>
  ungroup()

ggplot(bm_idx, aes(anio, indice, color = pais)) +
  geom_hline(yintercept = 100, linetype = "dashed", color = "gray50") +
  geom_line(linewidth = 0.9) +
  geom_point(size = 1.1) +
  scale_color_brewer(palette = "Set1") +
  labs(
    title    = "PBI per cápita en perspectiva (1990 = 100)",
    subtitle = "Misma base para todos: la pendiente es la tasa de crecimiento acumulado.",
    x = NULL, y = "Índice (1990 = 100)", color = NULL,
    caption  = "Fuente: Banco Mundial, NY.GDP.PCAP.KD (API REST, sin el paquete WDI)."
  )


# =============================================================================
# 2) BOXPLOT + VIOLÍN  —  Fuente: OWID
# =============================================================================

ggplot(owid_2022 |> filter(!is.na(co2_pc)),
       aes(continente, co2_pc, fill = continente)) +
  geom_violin(alpha = 0.5, color = NA, show.legend = FALSE) +
  geom_boxplot(width = 0.15, fill = "white", alpha = 0.8,
               outlier.alpha = 0.4, show.legend = FALSE) +
  scale_fill_manual(values = paleta_cont) +
  labs(
    title    = "Distribución de emisiones de CO2 per cápita por continente, 2022",
    subtitle = "El violín muestra la forma; el boxplot interno, los resúmenes.",
    x = NULL, y = "Toneladas de CO2 per cápita",
    caption  = "Fuente: Our World in Data (Global Carbon Project)."
  )


# =============================================================================
# 3) BARRAS HORIZONTALES ORDENADAS DESCENDENTE  —  Fuente: OWID
# =============================================================================

top20 <- owid_2022 |>
  filter(!is.na(co2_pc)) |>
  slice_max(co2_pc, n = 20) |>
  mutate(pais = fct_reorder(pais, co2_pc))   # ordena de menor a mayor -> arriba el mayor

ggplot(top20, aes(co2_pc, pais)) +
  geom_col(fill = "steelblue") +
  geom_text(aes(label = number(co2_pc, accuracy = 0.1)),
            hjust = -0.15, size = 3, color = "gray30") +
  scale_x_continuous(expand = expansion(mult = c(0, 0.08))) +
  labs(
    title    = "Los 20 países con mayores emisiones de CO2 per cápita, 2022",
    subtitle = "Barras horizontales ordenadas de mayor a menor.",
    x = "Toneladas de CO2 per cápita", y = NULL,
    caption  = "Fuente: Our World in Data."
  )


# =============================================================================
# 4) SCATTERPLOT estilo Clase 19  —  Fuente: OWID
# =============================================================================

scatter_2022 <- owid_2022 |> filter(!is.na(pbi_pc), !is.na(co2_pc), !is.na(poblacion))
promedio_mundo <- mean(scatter_2022$co2_pc, na.rm = TRUE)

ggplot(scatter_2022, aes(pbi_pc, co2_pc)) +
  geom_hline(yintercept = promedio_mundo,
             linetype = "dashed", color = "gray50", linewidth = 0.6) +
  geom_point(aes(color = continente, size = poblacion), alpha = 0.6) +
  geom_smooth(aes(group = 1), method = "loess", se = FALSE,
              color = "gray20", linewidth = 0.8, show.legend = FALSE) +
  geom_text_repel(
    data = scatter_2022 |> filter(pais %in% latam),
    aes(label = pais), size = 2.6, max.overlaps = 15, show.legend = FALSE
  ) +
  annotate("text", x = 900, y = promedio_mundo + 1.2, hjust = 0,
           label = "Promedio mundial", color = "gray40", size = 2.8) +
  scale_x_log10(labels = label_dollar()) +
  scale_size_continuous(range = c(1, 12), guide = "none") +
  scale_color_manual(values = paleta_cont) +
  labs(
    title    = "Más ricos, más emisiones: ingreso y CO2 per cápita (2022)",
    x = "PBI per cápita (USD, escala logarítmica)",
    y = "Toneladas de CO2 per cápita",
  ) + 
  theme(legend.title = element_blank())

# =============================================================================
# 5) SLOPECHART  —  Fuente: OWID
# =============================================================================

slope_df <- owid |>
  filter(pais %in% sudamerica, anio %in% c(2000, 2022), !is.na(co2_pc))

ggplot(slope_df, aes(factor(anio), co2_pc, group = pais)) +
  geom_line(color = "gray60", alpha = 0.6) +
  geom_point(size = 2, color = "steelblue") +
  geom_text_repel(
    data = slope_df |> filter(anio == 2022),
    aes(label = pais), hjust = 0, nudge_x = 0.08,
    direction = "y", size = 2.8, segment.color = NA
  ) +
  scale_x_discrete(expand = expansion(mult = c(0.08, 0.35))) +
  labs(
    title    = "Emisiones de CO2 per cápita en Sudamérica: 2000 vs 2022",
    subtitle = "Slope chart: foco en el cambio, no en el nivel.",
    x = NULL, y = "Toneladas de CO2 per cápita",
    caption  = "Fuente: Our World in Data."
  )


# =============================================================================
# 6) GRÁFICO DE BRECHAS (dumbbell)  —  Fuente: OWID
# =============================================================================

dumbbell_df <- owid |>
  filter(pais %in% sudamerica, anio %in% c(1990, 2022), !is.na(co2_pc)) |>
  select(pais, anio, co2_pc) |>
  pivot_wider(names_from = anio, values_from = co2_pc, names_prefix = "y") |>
  drop_na() |>
  mutate(pais = fct_reorder(pais, y2022))

ggplot(dumbbell_df, aes(y = pais)) +
  geom_segment(aes(x = y1990, xend = y2022, yend = pais),
               color = "gray60", linewidth = 1) +
  geom_point(aes(x = y1990, color = "1990"), size = 3) +
  geom_point(aes(x = y2022, color = "2022"), size = 3) +
  scale_color_manual(values = c("1990" = "tomato", "2022" = "steelblue"),
                     name = NULL) +
  labs(
    title    = "Brecha de emisiones per cápita 1990 -> 2022, Sudamérica",
    subtitle = "Cada segmento une el valor inicial (rojo) y el final (azul).",
    x = "Toneladas de CO2 per cápita", y = NULL,
    caption  = "Fuente: Our World in Data."
  )


# =============================================================================
# 7) ECDF CON TRES VARIABLES (tres grupos)  —  Fuente: OWID
# =============================================================================
# Función de distribución acumulada empírica superpuesta para tres años. Sin
# binning ni bandwidth. Curva corrida a la derecha = niveles más altos; cruces
# = cambios de forma, no solo de nivel (Clase 18).

ecdf_df <- owid |>
  filter(anio %in% c(1990, 2005, 2022), !is.na(co2_pc)) |>
  mutate(anio = factor(anio))

ggplot(ecdf_df, aes(co2_pc, color = anio)) +
  stat_ecdf(geom = "step", linewidth = 0.9) +
  scale_color_manual(values = c("1990" = "tomato", "2005" = "goldenrod",
                                "2022" = "steelblue"), name = NULL) +
  scale_y_continuous(labels = label_percent()) +
  coord_cartesian(xlim = c(0, 30)) +   # recorta la cola para leer mejor el cuerpo
  labs(
    title    = "Distribución de CO2 per cápita entre países: 1990, 2005, 2022",
    subtitle = "ECDF: cada punto es P(X <= x). Lee la mediana y los cuartiles del eje Y.",
    x = "Toneladas de CO2 per cápita", y = "F(x)",
    caption  = "Fuente: Our World in Data."
  )


# =============================================================================
# 8) EXTRA — LÍNEA  —  Fuente: INDEC (API de series de tiempo, datos.gob.ar)
# =============================================================================

indec_serie <- function(id, desde = "2004-01-01") {
  url <- paste0("https://apis.datos.gob.ar/series/api/series/?ids=", id,
                "&format=csv&start_date=", desde)
  read_csv(url, show_col_types = FALSE) |>
    rename(fecha = indice_tiempo) |>
    rename(valor = 2)            # la 2da columna es el valor de la serie
}

emae <- indec_serie("143.3_NO_PR_2004_A_21")   # EMAE nivel general, base 2004 = 100

ggplot(emae, aes(fecha, valor)) +
  geom_line(color = "steelblue", linewidth = 0.7) +
  geom_smooth(method = "loess", span = 0.2, se = FALSE,
              color = "tomato", linewidth = 0.6) +
  scale_x_date(date_breaks = "3 years", date_labels = "%Y") +
  labs(
    title    = "Actividad económica en Argentina (EMAE, nivel general)",
    subtitle = "Serie original, base 2004 = 100. En rojo, la tendencia suavizada.",
    x = NULL, y = "Índice (2004 = 100)",
    caption  = "Fuente: INDEC vía API de series de tiempo (datos.gob.ar)."
  )

# =============================================================================
# 9) EXTRA — LOLLIPOP  —  Fuente: OWID
# =============================================================================

top15_energia <- owid_2022 |>
  filter(!is.na(energia_pc)) |>
  slice_max(energia_pc, n = 15) |>
  mutate(pais = fct_reorder(pais, energia_pc))

ggplot(top15_energia, aes(energia_pc, pais)) +
  geom_segment(aes(x = 0, xend = energia_pc, yend = pais),
               color = "gray70", linewidth = 0.5) +
  geom_point(color = "steelblue", size = 3) +
  labs(
    title    = "Consumo de energía per cápita: top 15, 2022",
    subtitle = "Lollipop: ranking con menos tinta que las barras.",
    x = "kWh per cápita", y = NULL,
    caption  = "Fuente: Our World in Data."
  )


# =============================================================================
# 10) EXTRA — CONNECTED SCATTER (trayectoria de dos variables)  —  Fuente: OWID
# =============================================================================

arg_path <- owid |>
  filter(pais == "Argentina", anio >= 1960, !is.na(pbi_pc), !is.na(co2_pc))

ggplot(arg_path, aes(pbi_pc, co2_pc)) +
  geom_path(color = "gray60", linewidth = 0.6) +
  geom_point(aes(color = anio), size = 2) +
  geom_text_repel(
    data = arg_path |> filter(anio %in% c(1974,1989, 2001, 2011, 2022)),
    aes(label = anio), hjust = 0, nudge_x = 0.08,
    direction = "y", size = 2.8, segment.color = NA
  ) +
  scale_color_viridis_c(option = "plasma") +
  scale_x_continuous(labels = label_dollar()) +
  labs(
    title    = "Argentina: trayectoria PBI per cápita vs CO2 per cápita",
    subtitle = "Connected scatterplot: dos variables en el tiempo, juntas.",
    x = "PBI per cápita (USD)", y = "Toneladas de CO2 per cápita", color = "Año",
    caption  = "Fuente: Our World in Data; PBI de Maddison."
  )
