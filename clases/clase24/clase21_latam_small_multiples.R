# =============================================================================
# Clase 21 · Anexo: América Latina en los gráficos chicos múltiples
# Ciencia de Datos para Economía y Negocios - FCE-UBA
#
# Retoma los nueve gráficos de dispersión de la clase (PIB por habitante contra
# indicadores de bienestar) y los transforma en tres pasos:
#   1. Destacar a los países de América Latina sobre el resto del mundo.
#   2. Agregar una curva de regresión: la "media condicionada" al ingreso.
#      Los países por encima de la curva tienen un valor más alto que el que
#      se espera para su PIB por habitante; los de abajo, más bajo.
#   3. Cambiar el título descriptivo por uno que diga la conclusión.
#
# Los tres gráficos se guardan en graficos_clase21/. Si ya corriste el notebook
# de la clase, los datos se leen de datos_clase21/ sin volver a bajarlos.
# =============================================================================

# Paquetes: instala solo los que faltan
paquetes <- c("tidyverse", "ggtext", "showtext", "patchwork", "ggrepel", "scales")
faltan <- setdiff(paquetes, rownames(installed.packages()))
if (length(faltan) > 0) install.packages(faltan)

suppressWarnings(suppressPackageStartupMessages({
  library(tidyverse)
  library(ggtext)
  library(showtext)
  library(patchwork)
  library(ggrepel)
  library(scales)      # formato de números en los ejes
}))


# -----------------------------------------------------------------------------
# 1. Datos
# -----------------------------------------------------------------------------

carpeta_datos <- "datos_clase21"
dir.create(carpeta_datos, showWarnings = FALSE)

con_cache <- function(nombre, crear) {
  archivo <- file.path(carpeta_datos, paste0(nombre, ".rds"))
  if (!file.exists(archivo)) saveRDS(crear(), archivo)
  readRDS(archivo)
}

leer_owid <- function(grafico) {
  url <- paste0("https://ourworldindata.org/grapher/", grafico,
                ".csv?v=1&csvType=full&useColumnShortNames=true")
  read_csv(url, show_col_types = FALSE)
}

indicador_owid <- function(grafico) {
  con_cache(grafico, \() leer_owid(grafico) |>
    select(pais = entity, codigo = code, anio = year, valor = 4) |>
    filter(!is.na(valor)))
}

# Además del título y la unidad, cada indicador dice qué dirección es "mejor":
# +1 si más es mejor (esperanza de vida), -1 si menos es mejor (mortalidad).
# Para las emisiones de CO2 tomamos "menos es mejor".
indicadores <- tribble(
  ~grafico,                                                     ~titulo,                    ~subtitulo,                                      ~log_y, ~mejor,
  "child-mortality",                                            "Mortalidad infantil",      "% que muere antes de los 5 años (eje log)",     TRUE,   -1,
  "maternal-mortality",                                         "Mortalidad materna",       "cada 100.000 nacimientos (eje log)",            TRUE,   -1,
  "share-of-children-younger-than-5-who-suffer-from-stunting",  "Desnutrición",             "% de menores de 5 con baja talla para su edad", FALSE,  -1,
  "physicians-per-1000-people",                                 "Médicos",                  "cada 1.000 habitantes",                         FALSE,   1,
  "life-expectancy",                                            "Esperanza de vida",        "años, al nacer",                                FALSE,   1,
  "mean-years-of-schooling-long-run",                           "Años de educación",        "promedio de la población de 15 a 64 años",      FALSE,   1,
  "share-of-the-population-with-access-to-electricity",         "Electricidad",             "% de la población con acceso",                  FALSE,   1,
  "co-emissions-per-capita",                                    "Emisiones de CO2",         "toneladas por persona (eje log)",               TRUE,   -1,
  "happiness-cantril-ladder",                                   "Satisfacción con la vida", "autodeclarada, escala de 0 a 10",               FALSE,   1
)

pib <- indicador_owid("gdp-per-capita-worldbank") |>
  filter(str_length(codigo) == 3) |>
  select(codigo, anio, pib = valor)

bienestar <- indicadores |>
  mutate(datos = map(grafico, indicador_owid)) |>
  unnest(datos)

# Países de América Latina (códigos ISO) y el nombre que mostramos
latam <- c(ARG = "Argentina", BOL = "Bolivia", BRA = "Brasil", CHL = "Chile",
           COL = "Colombia", CRI = "Costa Rica", CUB = "Cuba", DOM = "Rep. Dominicana",
           ECU = "Ecuador", SLV = "El Salvador", GTM = "Guatemala", HTI = "Haití",
           HND = "Honduras", MEX = "México", NIC = "Nicaragua", PAN = "Panamá",
           PRY = "Paraguay", PER = "Perú", URY = "Uruguay", VEN = "Venezuela")

# Países que llevan su nombre escrito en cada panel (se puede agregar otros)
destacar <- c("ARG")

# Último dato de cada país e indicador desde 2010, con el PIB del mismo año.
# En los paneles con eje logarítmico se descartan los ceros (su logaritmo no existe).
dispersion <- bienestar |>
  filter(str_length(codigo) == 3, anio >= 2010, anio <= 2025) |>
  filter(!(log_y & valor <= 0)) |>
  inner_join(pib, by = c("codigo", "anio")) |>
  group_by(titulo, codigo) |>
  slice_max(anio, n = 1) |>
  ungroup() |>
  mutate(es_latam = codigo %in% names(latam),
         nombre   = latam[codigo])

dispersion |> count(titulo, es_latam) |> pivot_wider(names_from = es_latam, values_from = n)


# -----------------------------------------------------------------------------
# 2. Estilo (el mismo de la clase)
# -----------------------------------------------------------------------------

fuentes_ok <- tryCatch({
  font_add_google("Playfair Display", "playfair", regular.wt = 600, bold.wt = 700)
  font_add_google("Lato", "lato", regular.wt = 400, bold.wt = 700)
  TRUE
}, error = function(e) FALSE)

fuente_titulo <- if (fuentes_ok) "playfair" else "serif"
fuente_texto  <- if (fuentes_ok) "lato" else "sans"
showtext_auto()
showtext_opts(dpi = 96)

col <- c(rojo = "#B13507", azul = "#286BBB", gris = "#BDBDBD")
gris_titulo <- "#363636"
gris_texto  <- "#5B5B5B"
gris_suave  <- "#858585"

theme_owid <- function(base_size = 13) {
  theme_minimal(base_size = base_size, base_family = fuente_texto) +
    theme(
      plot.title.position   = "plot",
      plot.caption.position = "plot",
      plot.title    = element_markdown(family = fuente_titulo, size = rel(1.75), color = gris_titulo,
                                       lineheight = 1.05, margin = margin(b = 8)),
      plot.subtitle = element_text(size = rel(1.15), color = gris_texto,
                                   lineheight = 1.15, margin = margin(b = 18)),
      plot.caption  = element_text(size = rel(0.95), color = gris_suave, hjust = 0,
                                   margin = margin(t = 18)),
      panel.grid.major.x = element_blank(),
      panel.grid.minor   = element_blank(),
      panel.grid.major.y = element_line(color = "#DDDDDD", linetype = "dashed", linewidth = 0.4),
      axis.line.x  = element_line(color = "#999999", linewidth = 0.4),
      axis.ticks.x = element_line(color = "#999999", linewidth = 0.4),
      axis.text    = element_text(color = "#666666", size = rel(1.05)),
      axis.title   = element_blank(),
      legend.position = "none",
      plot.background = element_rect(fill = "white", color = NA),
      plot.margin = margin(20, 22, 15, 20)
    )
}

pintar <- function(texto, color) sprintf("<span style='color:%s'><b>%s</b></span>", color, texto)

carpeta_graficos <- "graficos_clase21"
dir.create(carpeta_graficos, showWarnings = FALSE)

guardar <- function(grafico, nombre, ancho = 10, alto = 12) {
  showtext_opts(dpi = 200)
  ggsave(file.path(carpeta_graficos, paste0(nombre, ".png")), grafico,
         width = ancho, height = alto, dpi = 200, bg = "white")
  showtext_opts(dpi = 96)
  invisible(grafico)
}

fuente <- paste0("Fuente: Banco Mundial, ONU, OMS, UNICEF, Global Carbon Project, ",
                 "Gallup y Lee-Lee, vía Our World in Data · CC BY")


# -----------------------------------------------------------------------------
# 3. Una función que arma un panel
# -----------------------------------------------------------------------------
# Recibe los datos de un indicador y devuelve un gráfico chico. Los argumentos
# controlan lo que cambia entre pasos:
#   curva:      si dibuja la curva de regresión.
#   color_por:  "region" pinta a América Latina de un solo color;
#               "residuo" la pinta según quede mejor o peor que lo esperado.
#   subtitulo:  la segunda línea del panel (por defecto, solo la unidad).
#
# El orden de las capas importa: primero el resto del mundo en gris, después la
# curva y por último América Latina, para que quede arriba de todo.

panel_latam <- function(datos, curva = FALSE, color_por = "region",
                        subtitulo = datos$subtitulo[1]) {
  escala_y <- if (datos$log_y[1]) {
    scale_y_log10(labels = label_number(big.mark = ".", decimal.mark = ","),
                  breaks = breaks_log(n = 5))
  } else {
    scale_y_continuous(labels = label_number(big.mark = ".", decimal.mark = ","),
                       breaks = breaks_extended(n = 4))
  }

  resto <- filter(datos, !es_latam)
  region <- filter(datos, es_latam)
  if (color_por == "region") region$grupo <- "latam"

  ggplot(datos, aes(pib, valor)) +
    geom_point(data = resto, shape = 21, size = 1.6, stroke = 0.3,
               color = "#9E9E9E", fill = alpha(col[["gris"]], 0.35)) +
    (if (curva) geom_smooth(method = "loess", formula = y ~ x, se = FALSE,
                            color = gris_titulo, linewidth = 0.6)) +
    geom_point(data = region, aes(fill = grupo), shape = 21, size = 2.3,
               stroke = 0.5, color = "white") +
    geom_label_repel(data = filter(region, codigo %in% destacar), aes(label = nombre),
                    family = fuente_texto, fontface = "bold", size = 3.4,
                    fill = alpha("white", 0.85), label.size = 0, label.padding = unit(1.5, "pt"),
                    color = gris_titulo, min.segment.length = 0, segment.color = "#777777",
                    nudge_y = if (datos$log_y[1]) 0.25 else 0.08 * diff(range(datos$valor)),
                    seed = 1) +
    scale_fill_manual(values = c(latam = col[["rojo"]], mejor = col[["azul"]],
                                 peor = col[["rojo"]])) +
    escala_y +
    scale_x_log10(breaks = c(1e3, 1e4, 1e5), labels = c("$1.000", "$10.000", "$100.000"),
                  limits = c(500, 2e5)) +
    labs(title = datos$titulo[1], subtitle = subtitulo) +
    theme_owid(base_size = 9.5) %+replace%
    theme(
      plot.title    = element_text(family = fuente_texto, face = "bold", size = rel(1.35),
                                   color = gris_titulo, hjust = 0, margin = margin(b = 2)),
      plot.subtitle = element_text(size = rel(0.95), color = gris_texto, hjust = 0,
                                   lineheight = 1.15, margin = margin(b = 8)),
      panel.grid.major.x = element_line(color = "#E5E5E5", linetype = "dashed", linewidth = 0.3),
      axis.line.x = element_blank(), axis.ticks.x = element_blank(),
      plot.background = element_rect(fill = "#FAFAFA", color = "#E3E3E3"),
      plot.margin = margin(8, 10, 8, 8)
    )
}

# Junta una lista de paneles en una grilla de 3 columnas con título y fuente
juntar <- function(paneles, titulo, subtitulo) {
  wrap_plots(paneles, ncol = 3) +
    plot_annotation(title = titulo, subtitle = subtitulo, caption = fuente,
                    theme = theme_owid() + theme(plot.margin = margin(15, 15, 10, 15)))
}


# -----------------------------------------------------------------------------
# Paso 1. Destacar América Latina
# -----------------------------------------------------------------------------
# Mismo gráfico de la clase, con el resto del mundo en gris de fondo y la región
# en color. El gris sirve de contexto: no hace falta leerlo, solo ubica a la
# región dentro de la nube.

paneles_1 <- dispersion |>
  split(~ factor(titulo, levels = indicadores$titulo)) |>
  map(panel_latam)

grafico_1 <- juntar(
  paneles_1,
  titulo = paste0("¿Dónde está ", pintar("América Latina", col[["rojo"]]),
                  "<br>en la relación entre ingreso y bienestar?"),
  subtitulo = paste0("Cada círculo es un país. En el eje x, el PIB por habitante por año, en dólares ",
                     "ajustados por diferencias\nde precios entre países (eje logarítmico). ",
                     "Último dato disponible desde 2010.")
)

grafico_1
guardar(grafico_1, "06_latam_paso1_destacar")


# -----------------------------------------------------------------------------
# Paso 2. La curva de regresión: ¿por encima o por debajo de lo esperado?
# -----------------------------------------------------------------------------
# La curva es una regresión del indicador contra el log del PIB por habitante,
# estimada con todos los países del mundo. Para cada nivel de ingreso da el
# valor promedio esperado: la media condicionada.
#
# Usamos una regresión local (loess) y no una recta porque varios indicadores
# tienen techo o piso: el acceso a la electricidad no puede pasar de 100% y la
# desnutrición no puede bajar de 0%. Una recta atravesaría esos límites y
# ubicaría mal a los países cercanos a ellos. Loess estima pequeñas regresiones
# en cada tramo del eje x y las une en una curva que se dobla donde se doblan
# los datos.
#
# geom_smooth(method = "loess") la estima sobre las escalas ya transformadas:
# en los paneles con eje log en y, ajusta log(indicador) contra log(PIB). Para
# contar cuántos países quedan arriba estimamos el mismo modelo con loess() y
# miramos el signo del residuo (valor observado menos valor esperado).

dispersion <- dispersion |>
  mutate(y = if_else(log_y, log10(valor), valor),
         x = log10(pib)) |>
  group_by(titulo) |>
  mutate(residuo = residuals(loess(y ~ x))) |>
  ungroup() |>
  mutate(
    # "mejor" combina el residuo con la dirección deseada del indicador:
    # en mortalidad, quedar por debajo de la curva es quedar mejor de lo esperado
    grupo = if_else(residuo * mejor > 0, "mejor", "peor")
  )

resumen <- dispersion |>
  filter(es_latam) |>
  group_by(titulo, mejor) |>
  summarise(paises   = n(),
            encima   = sum(residuo > 0),
            n_mejor  = sum(grupo == "mejor"),
            pct_mejor = 100 * n_mejor / paises,
            arg      = grupo[codigo == "ARG"][1],
            .groups = "drop") |>
  arrange(desc(pct_mejor))

resumen

paneles_2 <- dispersion |>
  left_join(select(resumen, titulo, paises, encima), by = "titulo") |>
  mutate(sub_2 = paste0(subtitulo, "\nAmérica Latina: ", encima, " de ", paises,
                        " países por encima de la curva")) |>
  split(~ factor(titulo, levels = indicadores$titulo)) |>
  map(\(d) panel_latam(d, curva = TRUE, subtitulo = d$sub_2[1]))

grafico_2 <- juntar(
  paneles_2,
  titulo = paste0(pintar("América Latina", col[["rojo"]]),
                  " frente a lo esperado para su nivel de ingreso"),
  subtitulo = paste0("La curva es el valor promedio del indicador para cada nivel de PIB por habitante ",
                     "(regresión local\ncon todos los países del mundo). Los países por encima tienen ",
                     "un valor más alto que el esperado\npara su ingreso.")
)

grafico_2
guardar(grafico_2, "07_latam_paso2_curva")


# -----------------------------------------------------------------------------
# Paso 3. Un título que diga la conclusión
# -----------------------------------------------------------------------------
# "Por encima de la curva" no siempre es bueno: en mortalidad o desnutrición,
# lo bueno es quedar abajo. Por eso ahora pintamos cada país según quede
# MEJOR (azul) o PEOR (rojo) que lo esperado para su ingreso, y ordenamos los
# paneles de donde a la región le va mejor a donde le va peor. Los colores del
# título funcionan como leyenda.
#
# El título sale de leer `resumen`. Separamos los indicadores donde la región
# queda claramente mejor que lo esperado (3 de cada 4 países o más) de los que
# queda claramente peor (40% o menos). Los del medio son mixtos y no van al
# título: se ven en los paneles.
#
# Con los datos actuales quedan mejor la satisfacción con la vida, la esperanza
# de vida y las emisiones (16 o 17 de 18 países), y peor la mortalidad materna
# (13 de 18 peor que lo esperado) y los años de educación (11 de 18). Si se
# actualizan los datos, hay que revisar estas dos tablas y reescribir el título.

orden_paneles <- resumen$titulo
ind_mejor <- resumen |> filter(pct_mejor >= 75)
ind_peor  <- resumen |> filter(pct_mejor <= 40)
ind_mejor
ind_peor

paneles_3 <- dispersion |>
  left_join(select(resumen, titulo, paises, n_mejor), by = "titulo") |>
  mutate(sub_3 = paste0(subtitulo, "\nMejor que lo esperado: ", n_mejor, " de ", paises,
                        " países de la región")) |>
  split(~ factor(titulo, levels = orden_paneles)) |>
  map(\(d) panel_latam(d, curva = TRUE, color_por = "residuo", subtitulo = d$sub_3[1]))

titulo_3 <- paste0(
  "Para su nivel de ingreso, América Latina ",
  pintar("vive más, es más feliz<br>y emite menos CO2", col[["azul"]]), ", pero tiene ",
  pintar("más muertes maternas<br>y menos años de educación", col[["rojo"]])
)

grafico_3 <- juntar(
  paneles_3,
  titulo = titulo_3,
  subtitulo = paste0("Países de América Latina en azul si están mejor que lo esperado para su PIB ",
                     "por habitante, y en rojo\nsi están peor. La curva es el promedio mundial para ",
                     "cada nivel de ingreso. Los paneles van de donde\nla región está mejor a donde ",
                     "está peor. Sin Cuba ni Venezuela, que no tienen datos de PIB.")
)

grafico_3
guardar(grafico_3, "08_latam_paso3_titulo")
