# ==============================================================================
# Clase 21 · Gráficos para comunicar: el estilo de Our World in Data
# Ciencia de Datos para Economía y Negocios - FCE-UBA
# ==============================================================================

# Script para leer y correr de a partes: en RStudio, Ctrl+Enter ejecuta la
# línea donde está el cursor (o el bloque seleccionado). Con el índice del
# script (Ctrl+Shift+O) se salta de una sección a otra. La pregunta que ordena la
# clase: ¿qué hay que cambiarle a un gráfico de `ggplot2` para que cuente una
# sola idea y se entienda sin explicación?
#
# Para responderla copiamos el estilo de los Data Insights de Our World in Data
# (https://ourworldindata.org/data-insights) (OWID): gráficos cuadrados,
# pensados para redes, donde el título dice la conclusión y casi no hace falta
# leer nada más. No copiamos sus gráficos ni su marca: usamos sus datos públicos
# para hacer gráficos propios con el mismo lenguaje visual.
#
# 1. Anatomía de un gráfico OWID: tomamos un gráfico de líneas por defecto y lo
#    transformamos en cinco pasos.
# 2. Barras apiladas al 100%: la estructura por edades del país más joven, del
#    más viejo, del mundo y de Argentina.
# 3. Muchas líneas con etiquetas directas: la esperanza de vida en África
#    austral durante la epidemia de VIH.
# 4. Dos curvas y flechas: cuánta gente vive en países por debajo de distintos
#    umbrales de ingreso, en 2000 y hoy.
# 5. Muchos gráficos chicos: el PIB por habitante contra nueve indicadores de
#    bienestar, primero en versión exploratoria y después en versión para
#    publicar.
#
# La primera vez hace falta internet: los datos y las tipografías se bajan, y
# los datos quedan guardados en `datos_clase21/`. Los gráficos terminados se
# guardan en `graficos_clase21/`.
#
# Los gráficos aparecen en el panel Plots, con el tamaño que tenga el panel. Como
# el diseño está pensado para una imagen cuadrada de 8 x 8 pulgadas, la versión
# fiel es el PNG que guarda cada sección en `graficos_clase21/`.

# Paquetes: instala solo los que faltan
paquetes <- c("tidyverse", "ggtext", "showtext", "patchwork", "ggrepel", "scales")
faltan <- setdiff(paquetes, rownames(installed.packages()))
if (length(faltan) > 0) install.packages(faltan)

suppressWarnings(suppressPackageStartupMessages({
  library(tidyverse)
  library(ggtext)      # texto con formato (colores, negritas) en títulos y anotaciones
  library(showtext)    # tipografías de Google Fonts
  library(patchwork)   # juntar varios gráficos en uno
  library(ggrepel)     # etiquetas que no se pisan
}))


# Datos ------------------------------------------------------------------------
# Our World in Data publica cada gráfico de su sitio con un CSV detrás. La
# dirección siempre tiene la misma forma: `https://ourworldindata.org/grapher/`
# + el nombre del gráfico (el que aparece en la URL de la página) + `.csv`. Con
# el agregado `?csvType=full&useColumnShortNames=true` devuelve todos los países
# y años con nombres de columna cortos. Todos los CSV tienen las columnas
# `entity` (país o región), `code` (código ISO de tres letras), `year` y una o
# más columnas con los valores.
#
# La función `leer_owid()` arma esa dirección y lee el CSV. `indicador_owid()`
# se queda con la primera columna de valores y la llama `valor`, así todos los
# indicadores quedan con el mismo formato. Como siempre, `con_cache()` baja cada
# archivo una sola vez y lo guarda en `datos_clase21/`.

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

# Población por grandes grupos de edad (ONU, World Population Prospects)
edades <- con_cache("edades", \() leer_owid("population-young-working-elderly") |>
  select(pais = entity, codigo = code, anio = year,
         menores_15 = population__sex_all__age_0_14__variant_estimates,
         de_15_a_64 = population__sex_all__age_15_64__variant_estimates,
         mayores_65 = population__sex_all__age_65plus__variant_estimates))

# Población total (para ponderar países en la parte 4)
poblacion <- con_cache("poblacion", \() leer_owid("population") |>
  filter(year >= 1990) |>
  select(pais = entity, codigo = code, anio = year, poblacion = population_historical))

# PIB por habitante (Banco Mundial, dólares internacionales de 2021)
pib <- indicador_owid("gdp-per-capita-worldbank")

# Esperanza de vida al nacer (ONU)
esperanza <- indicador_owid("life-expectancy")

# Nueve indicadores de bienestar para la parte 5
indicadores <- tribble(
  ~grafico,                                               ~titulo,                     ~subtitulo,                                    ~log_y,
  "child-mortality",                                      "Mortalidad infantil",       "% que muere antes de los 5 años (eje log)",   TRUE,
  "maternal-mortality",                                   "Mortalidad materna",        "cada 100.000 nacimientos (eje log)",          TRUE,
  "share-of-children-younger-than-5-who-suffer-from-stunting", "Desnutrición",        "% de menores de 5 con baja talla para su edad", FALSE,
  "physicians-per-1000-people",                           "Médicos",                   "cada 1.000 habitantes",                       FALSE,
  "life-expectancy",                                      "Esperanza de vida",         "años, al nacer",                              FALSE,
  "mean-years-of-schooling-long-run",                     "Años de educación",         "promedio de la población de 15 a 64 años",    FALSE,
  "share-of-the-population-with-access-to-electricity",   "Electricidad",              "% de la población con acceso",                FALSE,
  "co-emissions-per-capita",                              "Emisiones de CO2",          "toneladas por persona (eje log)",             TRUE,
  "happiness-cantril-ladder",                             "Satisfacción con la vida",  "autodeclarada, escala de 0 a 10",             FALSE
)

bienestar <- indicadores |>
  mutate(datos = map(grafico, indicador_owid)) |>
  unnest(datos)

glimpse(bienestar)

# LECTURA. `bienestar` es una tabla larga: una fila por país, año e indicador,
# con el título y el subtítulo que va a llevar cada gráfico chico ya pegados.
# Armar los datos así, con la "metadata" del gráfico en columnas, simplifica
# mucho la parte 5.
#

# Tipografías, colores y tema --------------------------------------------------
# El estilo de OWID depende mucho de tres cosas que `ggplot2` no trae por
# defecto:
#
# - Tipografías: una con serifa para el título (Playfair Display) y una sin
#    serifa para todo lo demás (Lato). Las dos son gratuitas y están en Google
#    Fonts. El paquete `showtext` las baja y las usa en los gráficos. Si no hay
#    internet, se usan la serif y la sans del sistema.
# - Paleta: pocos colores, apagados, que se distinguen bien entre sí. Están
#    definidos en el vector `col`.
# - Tema: la función `theme_owid()` concentra todas las decisiones de diseño que
#    se repiten en todos los gráficos. Es la pieza más importante del script:
#    una vez escrita, cada gráfico nuevo la reusa con `+ theme_owid()`.

fuentes_ok <- tryCatch({
  font_add_google("Playfair Display", "playfair", regular.wt = 600, bold.wt = 700)
  font_add_google("Lato", "lato", regular.wt = 400, bold.wt = 700)
  TRUE
}, error = function(e) FALSE)

fuente_titulo <- if (fuentes_ok) "playfair" else "serif"
fuente_texto  <- if (fuentes_ok) "lato" else "sans"

showtext_auto()              # usar showtext en todos los gráficos
showtext_opts(dpi = 96)      # resolución del panel Plots de RStudio

# Paleta inspirada en la de OWID
col <- c(azul = "#4C6A9C", rojo = "#B13507", verde = "#2C8465", ocre = "#A2794A",
         bordo = "#970046", celeste = "#286BBB", verde_claro = "#38A57F",
         azul_gris = "#6D87B0", vino = "#A2565F", violeta = "#4B4B9B")
gris_titulo <- "#363636"
gris_texto  <- "#5B5B5B"
gris_suave  <- "#858585"

theme_owid <- function(base_size = 13) {
  theme_minimal(base_size = base_size, base_family = fuente_texto) +
    theme(
      # Título, subtítulo y fuente alineados con el borde izquierdo de la imagen
      plot.title.position   = "plot",
      plot.caption.position = "plot",
      # El título admite colores y negritas (element_markdown); el resto es texto común
      plot.title    = element_markdown(family = fuente_titulo, size = rel(1.75), color = gris_titulo,
                                       lineheight = 1.05, margin = margin(b = 8)),
      plot.subtitle = element_text(size = rel(1.15), color = gris_texto,
                                   lineheight = 1.15, margin = margin(b = 18)),
      plot.caption  = element_text(size = rel(0.95), color = gris_suave, hjust = 0,
                                   margin = margin(t = 18)),
      # Solo grilla horizontal, punteada y suave
      panel.grid.major.x = element_blank(),
      panel.grid.minor   = element_blank(),
      panel.grid.major.y = element_line(color = "#DDDDDD", linetype = "dashed", linewidth = 0.4),
      # Eje x con línea y marcas; sin títulos de ejes (el subtítulo dice qué se mide)
      axis.line.x  = element_line(color = "#999999", linewidth = 0.4),
      axis.ticks.x = element_line(color = "#999999", linewidth = 0.4),
      axis.ticks.length.x = unit(5, "pt"),
      axis.text    = element_text(color = "#666666", size = rel(1.05)),
      axis.title   = element_blank(),
      # Sin leyenda: los colores se explican en el título o con etiquetas directas
      legend.position = "none",
      plot.background = element_rect(fill = "white", color = NA),
      plot.margin = margin(20, 22, 15, 20)
    )
}

# Pinta un texto de un color, para usar dentro de títulos y anotaciones
pintar <- function(texto, color, negrita = TRUE) {
  if (negrita) texto <- paste0("<b>", texto, "</b>")
  sprintf("<span style='color:%s'>%s</span>", color, texto)
}

# Números con formato argentino: punto de miles y coma decimal
num <- function(x, dec = 0) formatC(x, format = "f", digits = dec, big.mark = ".", decimal.mark = ",")

# Guarda un gráfico en PNG (1.600 x 1.600 píxeles si es cuadrado)
carpeta_graficos <- "graficos_clase21"
dir.create(carpeta_graficos, showWarnings = FALSE)

guardar <- function(grafico, nombre, ancho = 8, alto = 8) {
  showtext_opts(dpi = 200)
  ggsave(file.path(carpeta_graficos, paste0(nombre, ".png")), grafico,
         width = ancho, height = alto, dpi = 200, bg = "white")
  showtext_opts(dpi = 96)
  invisible(grafico)
}

# ATENCIÓN. `showtext` dibuja el texto según una resolución (`dpi`) que tiene
# que coincidir con la del dispositivo donde sale el gráfico. Si no coincide,
# las letras salen gigantes o diminutas. Por eso fijamos `showtext_opts(dpi =
# 96)`, la resolución habitual del panel Plots, y la función `guardar()` la
# cambia a 200 mientras guarda el PNG y después la vuelve a poner en 96. Si el
# texto se ve mal en el panel (pasa con pantallas con zoom de Windows), mirar
# directamente el PNG guardado.
#
# Otro detalle: `element_markdown()` (el que permite colores) calcula mal los
# espacios entre palabras cuando se combina con `showtext`, y en textos chicos
# se nota (palabras pegadas). Por eso lo usamos solo en el título, que es
# grande. El subtítulo y la fuente son texto común: los cortes de línea van con
# `\n` y no admiten colores ni negritas.
#


# ==============================================================================
# PARTE 1. ANATOMÍA DE UN GRÁFICO OWID
# ==============================================================================
# Los Data Insights repiten siempre las mismas decisiones. Antes de escribir
# código conviene tenerlas en una lista:
#
# | Recurso | Para qué sirve |
# |:--|:--|
# | El título dice la conclusión | "La población envejece", no "Población por edad, 1950-2023". Quien solo lee el título ya se lleva la idea |
# | Subtítulo con la medida | Qué se mide, en qué unidad y para quién. Reemplaza los títulos de los ejes |
# | Colores en el título | Las palabras del título van del color de su serie. Reemplazan a la leyenda |
# | Etiquetas directas | Cuando hay más series, el nombre va pegado a cada línea o barra, no en una caja aparte |
# | Anotaciones con el dato | Una o dos frases que señalan el número clave, escritas en el propio gráfico |
# | Punto al final de la serie | Marca el último dato, que suele ser el que se comenta |
# | Grilla mínima | Solo líneas horizontales punteadas; sin fondo gris ni grilla vertical |
# | Pocos cortes en los ejes | El primer año, algunos intermedios redondos y el último |
# | Fuente abajo a la izquierda | Con la licencia de los datos |
# | Formato cuadrado | Se ve bien en el celular y en todas las redes |
#
# Vamos a aplicarlas una por una sobre un ejemplo: cómo cambió en Argentina la
# proporción de la población que tiene menos de 15 años y la que tiene 65 o más.
#

# 1.1 Los datos ----------------------------------------------------------------
# La tabla `edades` tiene la cantidad de personas de cada grupo. Calculamos los
# porcentajes sobre el total y pasamos la tabla a formato largo (una fila por
# año y grupo), que es lo que necesita `ggplot()` para dibujar una línea por
# grupo.

arg <- edades |>
  filter(pais == "Argentina") |>
  mutate(total = menores_15 + de_15_a_64 + mayores_65,
         `Menores de 15` = 100 * menores_15 / total,
         `65 años y más` = 100 * mayores_65 / total) |>
  select(anio, `Menores de 15`, `65 años y más`) |>
  pivot_longer(-anio, names_to = "grupo", values_to = "pct")

anio_ini <- min(arg$anio)
anio_fin <- max(arg$anio)

arg |> filter(anio %in% c(anio_ini, 1990, anio_fin))


# 1.2 Paso 1: el gráfico por defecto -------------------------------------------
# Este es el gráfico que sale con lo mínimo indispensable. Es correcto, pero no
# dice nada por sí solo: hay que leer la leyenda, adivinar qué mide el eje y
# sacar la conclusión uno mismo.

paso1 <- ggplot(arg, aes(anio, pct, color = grupo)) +
  geom_line()

paso1


# 1.3 Paso 2: tema, colores y ejes ---------------------------------------------
# Sumamos `theme_owid()`, líneas más gruesas, los colores de la paleta y ejes
# con pocos cortes. Tres detalles de las escalas:
#
# - En el eje y, `limits = c(0, 35)` hace que arranque en cero (en un gráfico de
#    porcentajes, empezar en otro valor exagera los cambios) y `expand = c(0,
#    0)` saca el margen que `ggplot` agrega por defecto, para que la línea del
#    eje x quede justo en el cero.
# - Los cortes del eje x son el primer año, algunos años redondos y el último,
#    que es el que vamos a comentar.
# - En el eje x, `expansion(mult = c(0.01, 0.02))` deja un poquito de aire a los
#    costados.

paso2 <- paso1 +
  geom_line(linewidth = 1.3) +
  scale_color_manual(values = c(`Menores de 15` = col[["azul"]], `65 años y más` = col[["rojo"]])) +
  scale_y_continuous(limits = c(0, 35), breaks = seq(0, 35, 5),
                     labels = \(x) paste0(x, "%"), expand = c(0, 0)) +
  scale_x_continuous(breaks = c(anio_ini, 1970, 1990, 2010, anio_fin),
                     expand = expansion(mult = c(0.01, 0.02))) +
  theme_owid()

paso2

# LECTURA. Sin cambiar los datos, el gráfico ya respira: desapareció el fondo
# gris, la grilla vertical y la leyenda. Pero ahora no hay forma de saber qué
# línea es cuál. Eso lo resuelve el título del próximo paso.
#

# 1.4 Paso 3: un título que dice la conclusión ---------------------------------
# El título se escribe con `labs(title = ...)`, pero como el tema usa
# `element_markdown()` (del paquete `ggtext`), el texto acepta un poco de HTML:
# `<span style='color:...'>` para pintar palabras, `<b>` para negrita y `<br>`
# para cortar la línea. La función `pintar()` que definimos arriba arma ese
# HTML.
#
# Los cortes de línea del título van a mano con `<br>`: conviene que cada línea
# sea una unidad de sentido y que ninguna quede mucho más larga que las otras.

paso3 <- paso2 +
  labs(
    title = paste0("Argentina envejece: la población de ", pintar("65 años<br>y más", col[["rojo"]]),
                   " casi se triplicó, mientras la ", pintar("menor de 15", col[["azul"]]),
                   "<br>se achica"),
    subtitle = paste0("Porcentaje de la población total en cada grupo de edad, Argentina, ",
                      anio_ini, "-", anio_fin, "."),
    caption = "Fuente: ONU, World Population Prospects (2024), vía Our World in Data · CC BY"
  )

paso3

# ATENCIÓN. El título afirma algo ("casi se triplicó") que hay que comprobar con
# los datos antes de publicarlo. En el próximo paso lo calculamos. Si el número
# no diera, se cambia el título, no los datos.
#

# 1.5 Paso 4: punto final y anotaciones con los números ------------------------
# Las anotaciones son el lugar para el dato concreto. En lugar de escribir los
# números a mano, los calculamos y los pegamos en el texto con `paste0()`: si
# mañana se actualizan los datos, las frases se actualizan solas.

dato <- function(grupo_, anio_) arg |> filter(grupo == grupo_, anio == anio_) |> pull(pct)

mayores_ini <- dato("65 años y más", anio_ini)
mayores_fin <- dato("65 años y más", anio_fin)
menores_ini <- dato("Menores de 15", anio_ini)
menores_fin <- dato("Menores de 15", anio_fin)

c(mayores_ini = mayores_ini, mayores_fin = mayores_fin, cociente = mayores_fin / mayores_ini,
  menores_ini = menores_ini, menores_fin = menores_fin)

# Ahora sí, el gráfico terminado. Para los puntos usamos `geom_point()` solo con
# los datos del último año. Las frases van con `annotate("richtext", ...)`, que
# acepta el mismo HTML que el título. Los argumentos que importan:
#
# - `x` e `y` dicen dónde va el texto, en las unidades de los datos (años y
#    porcentaje).
# - `hjust = 1` alinea el texto a la derecha de ese punto, para que termine
#    justo sobre el último dato; `vjust` hace lo mismo en vertical (0 = el texto
#    queda arriba del punto, 1 = queda abajo).
# - `fill = NA` y `label.color = NA` sacan el recuadro que `richtext` dibuja por
#    defecto.
#
# La ubicación de cada frase se elige mirando el gráfico: tiene que estar cerca
# de su línea y no tapar ninguna.

nota_mayores <- paste0("En ", anio_fin, ", el ", pintar(paste0(num(mayores_fin, 1), "%"), col[["rojo"]]),
                       " de la población<br>tenía 65 años o más, ",
                       num(mayores_fin / mayores_ini, 1), " veces<br>la proporción de ", anio_ini)
nota_menores <- paste0("Los ", pintar("menores de 15", col[["azul"]]), " pasaron de ser<br>el ",
                       num(menores_ini, 0), "% al ", num(menores_fin, 0), "% de la población")

grafico_arg <- paso3 +
  geom_point(data = filter(arg, anio == anio_fin), size = 3.5) +
  annotate("richtext", x = anio_fin, y = 15, label = nota_mayores, hjust = 1, vjust = 0,
           family = fuente_texto, size = 4.6, color = gris_texto, lineheight = 1.15,
           fill = NA, label.color = NA) +
  annotate("richtext", x = anio_fin, y = 33, label = nota_menores, hjust = 1, vjust = 1,
           family = fuente_texto, size = 4.6, color = gris_texto, lineheight = 1.15,
           fill = NA, label.color = NA)

grafico_arg

# LECTURA. Compará este gráfico con el del paso 1. Los datos son exactamente los
# mismos; cambió todo lo demás. Quien lo ve en el celular durante dos segundos
# se lleva la idea del título; quien se detiene encuentra los números en las
# anotaciones y la fuente abajo.
#

# 1.6 Paso 5: guardar ----------------------------------------------------------
# `guardar()` exporta el PNG a `graficos_clase21/`. El tamaño en pulgadas (8 x
# 8) es el mismo que usamos en pantalla, así el PNG se ve igual que lo que
# estuvimos mirando.

guardar(grafico_arg, "01_argentina_envejece")

# ATENCIÓN. En `ggplot2`, el tamaño de las letras es fijo en puntos, no relativo
# a la imagen. Si se guarda el mismo gráfico a 4 x 4 pulgadas, las letras ocupan
# el doble de lugar y todo se superpone; si se guarda a 16 x 16, quedan
# diminutas. Para cambiar el tamaño del PNG en píxeles, conviene cambiar el
# `dpi` y dejar fijos el ancho y el alto.
#


# ==============================================================================
# PARTE 2. BARRAS APILADAS AL 100%
# ==============================================================================
# Cuando cada caso se reparte en partes que suman 100%, la barra horizontal
# apilada es la forma más clara de mostrarlo. El estilo OWID le agrega tres
# cosas:
#
# - El nombre del caso arriba de cada barra, en lugar de un eje y. Lo logramos
#    con `facet_wrap(~ caso, ncol = 1)` y un tema que alinea los títulos de cada
#    panel a la izquierda.
# - Las etiquetas dentro de cada segmento, alineadas a la izquierda, en blanco.
#    Si el segmento es muy angosto, la etiqueta va abajo, del color del
#    segmento.
# - Separación blanca entre segmentos (el borde blanco de cada rectángulo).
#

# 2.1 Elegir los casos con los datos -------------------------------------------
# Queremos mostrar los extremos: el país con más proporción de menores de 15 y
# el país con más proporción de 65 y más. En lugar de buscarlos a ojo, los
# encontramos con `slice_max()`. Dejamos afuera los países de menos de un millón
# de habitantes (Mónaco, por ejemplo, tiene una población muy envejecida, pero
# es un caso muy particular) y las regiones, que en OWID tienen el código vacío
# o empezado con `OWID_`.

ultimo_anio <- max(edades$anio)

estructura <- edades |>
  filter(anio == ultimo_anio) |>
  mutate(total = menores_15 + de_15_a_64 + mayores_65,
         across(c(menores_15, de_15_a_64, mayores_65), \(x) 100 * x / total))

paises <- estructura |> filter(str_length(codigo) == 3, total > 1e6)
mas_joven <- paises |> slice_max(menores_15, n = 1)
mas_viejo <- paises |> slice_max(mayores_65, n = 1)

bind_rows(mas_joven, mas_viejo) |> select(pais, menores_15, de_15_a_64, mayores_65)


# 2.2 Preparar las barras ------------------------------------------------------
# Para dibujar cada segmento con `geom_rect()` necesitamos dónde empieza
# (`xmin`) y dónde termina (`xmax`). Si los porcentajes de un país son 49, 49 y
# 2, los segmentos van de 0 a 49, de 49 a 98 y de 98 a 100: `xmax` es la suma
# acumulada y `xmin` es la suma acumulada del segmento anterior.

nombres <- c("World" = "Promedio mundial", "Argentina" = "Argentina", "Japan" = "Japón",
             "Niger" = "Níger", "Chad" = "Chad", "Somalia" = "Somalia",
             "Central African Republic" = "República Centroafricana",
             "Democratic Republic of Congo" = "República Democrática del Congo",
             "Italy" = "Italia", "Hong Kong" = "Hong Kong", "Portugal" = "Portugal")

orden <- c(mas_joven$pais, "World", "Argentina", mas_viejo$pais)

barras <- estructura |>
  filter(pais %in% orden) |>
  pivot_longer(c(menores_15, de_15_a_64, mayores_65), names_to = "grupo", values_to = "pct") |>
  mutate(
    grupo = factor(grupo, levels = c("menores_15", "de_15_a_64", "mayores_65")),
    caso  = factor(coalesce(nombres[pais], pais), levels = coalesce(nombres[orden], orden))
  ) |>
  arrange(caso, grupo) |>
  group_by(caso) |>
  mutate(xmax = cumsum(pct), xmin = lag(xmax, default = 0)) |>
  ungroup()

barras |> select(caso, grupo, pct, xmin, xmax)

# Las etiquetas: en la primera barra y en la última agregamos el nombre del
# grupo (así nadie necesita leyenda), siempre que el segmento sea
# suficientemente ancho. En el resto, solo el porcentaje. Los segmentos de menos
# de 7% llevan la etiqueta afuera.

nombre_grupo <- c(menores_15 = "Menores de 15 años", de_15_a_64 = "15 a 64 años",
                  mayores_65 = "65 años y más")
colores_grupo <- c(menores_15 = col[["verde_claro"]], de_15_a_64 = col[["azul_gris"]],
                   mayores_65 = col[["vino"]])

con_nombre <- c(first(levels(barras$caso)), last(levels(barras$caso)))

barras <- barras |>
  mutate(
    adentro  = pct >= 7,
    etiqueta = if_else(caso %in% con_nombre & pct >= 25,
                       paste0("<b>", nombre_grupo[grupo], "</b><br>", num(pct), "%"),
                       paste0(num(pct), "%"))
  )


# 2.3 El gráfico ---------------------------------------------------------------

grafico_edades <- ggplot(barras) +
  geom_rect(aes(xmin = xmin, xmax = xmax, ymin = 0, ymax = 1, fill = grupo),
            color = "white", linewidth = 1.2) +
  # etiquetas adentro del segmento, alineadas a la izquierda
  geom_richtext(data = filter(barras, adentro),
                aes(x = xmin + 1.5, y = 0.5, label = etiqueta),
                hjust = 0, color = "white", size = 5.6, family = fuente_texto,
                lineheight = 1.1, fill = NA, label.color = NA) +
  # etiquetas de los segmentos angostos, abajo y a la derecha
  geom_text(data = filter(barras, !adentro),
            aes(x = xmax, y = -0.22, label = etiqueta, color = grupo),
            hjust = 1, size = 5.2, family = fuente_texto) +
  facet_wrap(~ caso, ncol = 1) +
  scale_fill_manual(values = colores_grupo) +
  scale_color_manual(values = colores_grupo) +
  scale_x_continuous(expand = c(0, 0)) +
  scale_y_continuous(limits = c(-0.4, 1), expand = c(0, 0)) +
  labs(
    title = "La estructura por edades cambia enormemente<br>entre el país más joven y el más viejo",
    subtitle = paste0("Porcentaje de la población en cada grupo de edad, ", ultimo_anio, "."),
    caption = "Fuente: ONU, World Population Prospects (2024), vía Our World in Data · CC BY"
  ) +
  theme_owid() +
  theme(
    panel.grid.major.y = element_blank(),
    axis.text = element_blank(), axis.line.x = element_blank(), axis.ticks.x = element_blank(),
    strip.text = element_text(hjust = 0, size = rel(1.45), face = "bold", color = gris_texto,
                              margin = margin(t = 6, b = 6)),
    panel.spacing.y = unit(10, "pt")
  )

grafico_edades
guardar(grafico_edades, "02_estructura_edades")

# LECTURA. En la República Centroafricana casi la mitad (49%) de la población
# tiene menos de 15 años; en Japón, casi un tercio (29%) tiene 65 o más.
# Argentina está cerca del promedio mundial en la proporción de jóvenes, pero ya
# tiene más personas mayores que el mundo en su conjunto. El orden de las
# barras, del país más joven al más viejo, hace que el gráfico se lea como una
# progresión.
#
# ATENCIÓN. El nombre de cada barra lo da `facet_wrap()`: es un truco para que
# cada barra tenga su "título". La otra opción, poner los países en el eje y con
# `geom_col()`, deja los nombres a la izquierda y le quita ancho a las barras,
# que es justo lo que queremos que se vea.
#


# ==============================================================================
# PARTE 3. MUCHAS LÍNEAS CON ETIQUETAS DIRECTAS
# ==============================================================================
# Con cuatro o cinco series ya no alcanza con pintar palabras del título. El
# recurso de OWID es escribir el nombre de cada serie pegado a su línea, del
# mismo color. Hay dos formas de hacerlo:
#
# 1. A mano, con `annotate()`, eligiendo la posición de cada etiqueta. Es lo que
#    hace OWID en sus gráficos más cuidados: ponen cada nombre donde hay lugar.
# 2. Automática, con `geom_text_repel()` del paquete `ggrepel`, que ubica las
#    etiquetas al final de cada línea y las separa si se pisan.
#
# Usamos la segunda, que funciona aunque cambien los datos, y una anotación con
# una flecha curva para señalar el dato clave.
#

# 3.1 Los datos y el dato clave ------------------------------------------------
# La esperanza de vida en cuatro países del sur de África muy golpeados por la
# epidemia de VIH/sida. Buscamos con los datos el peor momento de Zimbabue: el
# año de la esperanza de vida mínima y cuánto había caído desde su máximo
# anterior.

paises_vih <- c("Botswana" = "Botsuana", "Zimbabwe" = "Zimbabue",
                "South Africa" = "Sudáfrica", "Namibia" = "Namibia")

vih <- esperanza |>
  filter(pais %in% names(paises_vih), anio >= 1960) |>
  mutate(pais = paises_vih[pais])

zim <- vih |> filter(pais == "Zimbabue")
zim_min <- zim |> filter(anio >= 1990, anio <= 2015) |> slice_min(valor, n = 1)
zim_max <- zim |> filter(anio < zim_min$anio) |> slice_max(valor, n = 1)

bind_rows(zim_max, zim_min)


# 3.2 El gráfico ---------------------------------------------------------------
# Algunos detalles del código:
#
# - `etiquetas` tiene solo el último año de cada país: ahí van los nombres.
# - En `geom_text_repel()`, `direction = "y"` deja que las etiquetas se muevan
#    solo en vertical, `nudge_x` las corre hacia la derecha del final de la
#    línea, `xlim` les impide volver sobre el gráfico y `segment.color = NA`
#    saca la rayita que las une con su punto.
# - Para que las etiquetas entren a la derecha, el eje x se extiende con
#    `expansion(add = c(1, 10))` (diez años de aire) y `coord_cartesian(clip =
#    "off")` deja dibujar fuera del panel.
# - La flecha es `annotate("curve", ...)`: va de (`x`, `y`) a (`xend`, `yend`) y
#    `curvature` dice cuánto se curva (con signo negativo se curva hacia el otro
#    lado).

colores_vih <- c("Botsuana" = col[["azul"]], "Zimbabue" = col[["verde"]],
                 "Sudáfrica" = col[["ocre"]], "Namibia" = col[["rojo"]])

anio_max_vih <- max(vih$anio)
etiquetas <- vih |> filter(anio == anio_max_vih)

nota_zim <- paste0("En ", zim_min$anio, ", la esperanza de vida<br>en ",
                   pintar("Zimbabue", col[["verde"]]), " había caído a <b>",
                   num(zim_min$valor), " años</b>,<br>",
                   num(zim_max$valor - zim_min$valor), " años menos que en ", zim_max$anio)

nota_covid <- "La caída de 2021 refleja\nlas muertes por COVID-19"

grafico_vih <- ggplot(vih, aes(anio, valor, color = pais)) +
  geom_line(linewidth = 1.3) +
  geom_text_repel(data = etiquetas, aes(label = pais), family = fuente_texto, fontface = "bold",
                  size = 5.2, hjust = 0, direction = "y", nudge_x = 1.5,
                  xlim = c(anio_max_vih + 1, NA), segment.color = NA) +
  annotate("curve", x = 1989, y = 43.4, xend = zim_min$anio - 0.8, yend = zim_min$valor - 0.3,
           curvature = -0.25, color = "#777777", linewidth = 0.5,
           arrow = arrow(length = unit(7, "pt"), type = "closed")) +
  annotate("richtext", x = 1961, y = 44.5, label = nota_zim, hjust = 0, vjust = 1,
           family = fuente_texto, size = 4.6, color = gris_texto, lineheight = 1.15,
           fill = NA, label.color = NA) +
  annotate("text", x = anio_max_vih, y = 37, hjust = 1, vjust = 0, label = nota_covid,
           family = fuente_texto, size = 4.3, color = gris_texto, lineheight = 1.1) +
  scale_color_manual(values = colores_vih) +
  scale_y_continuous(limits = c(35, 70), breaks = seq(35, 70, 5),
                     labels = \(x) paste(x, "años"), expand = c(0, 0)) +
  scale_x_continuous(breaks = c(1960, 1980, 2000, 2010, anio_max_vih),
                     expand = expansion(add = c(1, 10))) +
  coord_cartesian(clip = "off") +
  labs(
    title = "La epidemia de VIH le quitó más de una década<br>de esperanza de vida al sur de África",
    subtitle = paste0("Esperanza de vida al nacer, en años, en cuatro países muy afectados\n",
                      "por el VIH/sida, 1960-", anio_max_vih, "."),
    caption = "Fuente: ONU, World Population Prospects (2024), vía Our World in Data · CC BY"
  ) +
  theme_owid()

grafico_vih
guardar(grafico_vih, "03_vih_esperanza_vida")

# LECTURA. Las cuatro líneas suben hasta fines de los ochenta, caen en picada
# durante los noventa y se recuperan desde mediados de los 2000, cuando se
# masificaron los tratamientos antirretrovirales. Zimbabue es el caso extremo:
# perdió 16 años de esperanza de vida entre 1986 y 2001: pasó de 61 a 45 años.
#
# ATENCIÓN. Este eje y no empieza en cero, y está bien: la esperanza de vida
# nunca está cerca de cero, y lo que importa son los cambios. La regla de
# empezar en cero vale para porcentajes, cantidades y barras, donde el largo de
# la barra representa el valor.
#


# ==============================================================================
# PARTE 4. DOS CURVAS Y FLECHAS
# ==============================================================================
# Este gráfico responde una pregunta del tipo "¿qué parte del mundo está por
# debajo de cierto umbral?", para muchos umbrales a la vez. La curva es una
# distribución acumulada: para cada valor del eje x (un nivel de ingreso), la
# altura de la curva dice qué porcentaje de la población está por debajo. Si
# dibujamos la curva de dos años, la distancia vertical entre ellas muestra
# cuánto cambió el porcentaje para cada umbral, y las flechas lo hacen
# explícito.
#

# 4.1 La distribución acumulada, ponderada por población -----------------------
# No tenemos el ingreso de cada persona del mundo, pero sí el PIB por habitante
# de cada país y su población. Hacemos una aproximación: le asignamos a cada
# habitante el PIB por habitante de su país, expresado por día (dividido 365).
# Así, el porcentaje de la población mundial por debajo de un umbral $u$ es
#
# $$F(u) = \frac{\sum_{\text{países con PIB diario} < u} \text{población}}{\sum_{\text{todos los países}} \text{población}} \times 100$$
#
# Usamos solo los países con datos en los dos años, para que la comparación sea
# con el mismo conjunto de países. Como último año tomamos el más reciente que
# tiene datos de población y de PIB para casi todos los países (los últimos años
# suelen tener menos cobertura).

cobertura <- pib |> filter(str_length(codigo) == 3) |> count(anio)
anio_fin_pib <- cobertura |> filter(n >= 170, anio <= max(poblacion$anio)) |> pull(anio) |> max()

mundo <- pib |>
  filter(str_length(codigo) == 3, anio %in% c(2000, anio_fin_pib)) |>
  inner_join(poblacion |> select(codigo, anio, poblacion), by = c("codigo", "anio")) |>
  mutate(diario = valor / 365) |>
  group_by(codigo) |> filter(n() == 2) |> ungroup()

# Porcentaje de la población por debajo de cada umbral
acumulada <- function(diario, poblacion, umbrales) {
  map_dbl(umbrales, \(u) 100 * sum(poblacion[diario < u]) / sum(poblacion))
}

grilla <- exp(seq(log(1), log(400), length.out = 500))   # umbrales equiespaciados en log
umbrales <- c(10, 20, 30, 50, 100)                      # los que vamos a marcar

curvas <- mundo |>
  group_by(anio) |>
  reframe(umbral = grilla, pct = acumulada(diario, poblacion, grilla))

puntos <- mundo |>
  group_by(anio) |>
  reframe(umbral = umbrales, pct = acumulada(diario, poblacion, umbrales))

puntos |> pivot_wider(names_from = anio, values_from = pct)

# ATENCIÓN. Esto no es una medida de pobreza. El PIB por habitante es mucho más
# alto que el ingreso de los hogares (incluye inversión, gasto público,
# ganancias de empresas) y el cálculo supone que todos los habitantes de un país
# tienen el mismo ingreso. Por eso la curva tiene saltos: cuando el umbral pasa
# el PIB por habitante de China o de India, de golpe se suman 1.400 millones de
# personas. OWID hace este gráfico con encuestas de hogares (Banco Mundial,
# PIP), que miden el ingreso de cada persona. La técnica de graficación es la
# misma.
#

# 4.2 El gráfico ---------------------------------------------------------------
# Las piezas:
#
# - Dos `geom_line()` con las curvas, sobre un eje x logarítmico
#    (`scale_x_log10()`): en un eje log, pasar de 5 a 10 dólares ocupa lo mismo
#    que pasar de 50 a 100, que es lo razonable para ingresos.
# - `geom_segment()` con `arrow()` para las flechas, que van del punto de 2000
#    al del último año. Les restamos un poco a la punta para que no tape el
#    punto de llegada.
# - Las etiquetas de porcentaje de 2000 van arriba de cada punto (`vjust =
#    -0.8`) y las del último año, abajo (`vjust = 1.8`).
# - Los nombres de las curvas van con `annotate("richtext", ...)`, del color de
#    cada curva.
# - Este gráfico sí lleva título en el eje x, porque el subtítulo no alcanza
#    para explicar el eje logarítmico.

colores_anio <- setNames(c(col[["bordo"]], col[["celeste"]]), c(2000, anio_fin_pib))

flechas <- puntos |>
  pivot_wider(names_from = anio, values_from = pct, names_prefix = "a") |>
  rename(desde = 2, hasta = 3) |>
  filter(desde - hasta > 3)          # solo donde hay lugar para la flecha

p_ini <- puntos |> filter(anio == 2000, umbral == 10) |> pull(pct)
p_fin <- puntos |> filter(anio == anio_fin_pib, umbral == 10) |> pull(pct)

grafico_cdf <- ggplot() +
  geom_line(data = curvas, aes(umbral, pct, color = factor(anio)), linewidth = 1.3) +
  geom_segment(data = flechas, aes(x = umbral, xend = umbral, y = desde - 1.5, yend = hasta + 2.5),
               color = "#666666", linewidth = 0.5,
               arrow = arrow(length = unit(6, "pt"), type = "closed")) +
  geom_point(data = puntos, aes(umbral, pct, color = factor(anio)), size = 3) +
  geom_text(data = filter(puntos, anio == 2000), aes(umbral, pct, label = paste0(num(pct), "%")),
            color = col[["bordo"]], vjust = -0.8, hjust = 1, nudge_x = -0.01,
            family = fuente_texto, fontface = "bold", size = 4.6) +
  geom_text(data = filter(puntos, anio == anio_fin_pib), aes(umbral, pct, label = paste0(num(pct), "%")),
            color = col[["celeste"]], vjust = 1.8, hjust = 0, nudge_x = 0.01,
            family = fuente_texto, fontface = "bold", size = 4.6) +
  annotate("richtext", x = 1.3, y = 72, hjust = 0, family = fuente_texto, size = 5.4,
           fill = NA, label.color = NA, lineheight = 1.1,
           label = pintar("La población mundial<br>en 2000", col[["bordo"]])) +
  annotate("richtext", x = 60, y = 30, hjust = 0, family = fuente_texto, size = 5.4,
           fill = NA, label.color = NA, lineheight = 1.1,
           label = pintar(paste0("La población mundial<br>en ", anio_fin_pib), col[["celeste"]])) +
  scale_color_manual(values = colores_anio) +
  scale_x_log10(breaks = c(1, 2, 5, 10, 20, 50, 100, 200),
                labels = \(x) paste0("US$", x), expand = c(0, 0)) +
  scale_y_continuous(limits = c(0, 100), breaks = seq(0, 100, 25),
                     labels = \(x) paste0(x, "%"), expand = expansion(add = c(0, 2))) +
  coord_cartesian(xlim = c(1, 400), clip = "off") +
  labs(
    title = "Elijas el umbral que elijas, hoy una parte menor<br>del mundo vive en países por debajo de él",
    subtitle = paste0("Porcentaje de la población mundial que vive en países con un PIB por habitante\n",
                      "menor a cada umbral. Dólares por día, ajustados por inflación y por diferencias\n",
                      "de precios entre países."),
    x = "PIB por habitante por día, en eje logarítmico",
    caption = "Fuente: Banco Mundial y ONU, vía Our World in Data · CC BY"
  ) +
  theme_owid() +
  theme(axis.title.x = element_text(color = gris_texto, face = "bold", margin = margin(t = 10)))

grafico_cdf
guardar(grafico_cdf, "04_distribucion_acumulada")

# LECTURA. En 2000, el 31% de la población mundial vivía en países con un PIB
# por habitante menor a 10 dólares por día; en 2023, ese porcentaje era 9%. La
# curva de 2023 está por debajo de la de 2000 en prácticamente todos los
# umbrales: no importa dónde se trace la línea, la proporción por debajo cayó.
# Esa es la ventaja de este gráfico frente a mostrar un solo umbral: la
# conclusión no depende de una elección arbitraria.
#


# ==============================================================================
# PARTE 5. MUCHOS GRÁFICOS CHICOS
# ==============================================================================
# Cuando queremos mostrar la misma relación para muchas variables, la solución
# son los múltiplos pequeños (small multiples): muchos gráficos chicos con el
# mismo diseño, uno al lado del otro. El ojo compara las formas sin tener que
# leer cada uno.
#
# Este tipo de gráfico tiene dos usos muy distintos, y vamos a hacer los dos:
#
# 1. Exploratorio: para mirar los datos uno mismo. Se hace en un minuto con
#    `facet_wrap()`, sin preocuparse por el diseño.
# 2. Para publicar: el mismo contenido, cuidando cada panel. Ahí conviene
#    escribir una función que arme un panel y juntarlos con `patchwork`.
#

# 5.1 Los datos ----------------------------------------------------------------
# Para cada país e indicador nos quedamos con el último dato desde 2010, y lo
# cruzamos con el PIB por habitante de ese mismo país en el mismo año. Cada
# punto va a ser un país.

pib_paises <- pib |> filter(str_length(codigo) == 3) |> select(codigo, anio, pib = valor)

dispersion <- bienestar |>
  filter(str_length(codigo) == 3, anio >= 2010, anio <= 2025) |>
  inner_join(pib_paises, by = c("codigo", "anio")) |>
  group_by(titulo, codigo) |>
  slice_max(anio, n = 1) |>
  ungroup() |>
  mutate(titulo = factor(titulo, levels = indicadores$titulo))

dispersion |> count(titulo, name = "paises")


# 5.2 Versión exploratoria -----------------------------------------------------
# `facet_wrap(~ titulo, scales = "free_y")` arma un panel por indicador, cada
# uno con su propia escala en y. El eje x es logarítmico: el PIB por habitante
# va de unos 1.000 a más de 100.000 dólares, y en escala lineal casi todos los
# países quedarían amontonados a la izquierda.

ggplot(dispersion, aes(pib, valor)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "loess", formula = y ~ x, se = FALSE, color = "red") +
  scale_x_log10(labels = scales::label_dollar()) +
  facet_wrap(~ titulo, scales = "free_y")

# LECTURA. Para explorar, esto alcanza: en todos los indicadores hay una
# relación clara con el PIB por habitante. La mortalidad infantil, la materna y
# la desnutrición caen con el ingreso; los médicos, la esperanza de vida, la
# educación, el acceso a la electricidad, las emisiones y la satisfacción con la
# vida suben. Pero tiene problemas para publicar: en mortalidad infantil y
# materna casi todos los puntos se amontonan abajo (necesitan eje logarítmico),
# los títulos de los paneles son chicos y no dicen las unidades, y la línea roja
# distrae.
#

# 5.3 Versión para publicar ----------------------------------------------------
# Escribimos una función `panel_owid()` que recibe los datos de un indicador y
# devuelve un gráfico chico con el estilo OWID: título y unidad arriba, puntos
# circulares con relleno suave, eje y logarítmico si hace falta y un fondo gris
# muy claro con borde, como una tarjeta.

panel_owid <- function(datos) {
  log_y <- datos$log_y[1]
  escala_y <- if (log_y) {
    scale_y_log10(labels = scales::label_number(big.mark = ".", decimal.mark = ","),
                  breaks = scales::breaks_log(n = 5))
  } else {
    scale_y_continuous(labels = scales::label_number(big.mark = ".", decimal.mark = ","), breaks = scales::breaks_extended(n = 4))
  }

  ggplot(datos, aes(pib, valor)) +
    geom_point(shape = 21, size = 1.8, stroke = 0.4, color = col[["violeta"]],
               fill = alpha(col[["violeta"]], 0.25)) +
    escala_y +
    scale_x_log10(breaks = c(1e3, 1e4, 1e5), labels = c("$1.000", "$10.000", "$100.000"),
                  limits = c(500, 2e5)) +
    labs(title = datos$titulo[1], subtitle = datos$subtitulo[1]) +
    theme_owid(base_size = 9.5) %+replace%
    theme(
      plot.title    = element_text(family = fuente_texto, face = "bold", size = rel(1.35),
                                   color = gris_titulo, hjust = 0, margin = margin(b = 2)),
      plot.subtitle = element_text(size = rel(0.95), color = gris_texto, hjust = 0,
                                   margin = margin(b = 8)),
      panel.grid.major.x = element_line(color = "#E5E5E5", linetype = "dashed", linewidth = 0.3),
      axis.line.x = element_blank(), axis.ticks.x = element_blank(),
      plot.background = element_rect(fill = "#FAFAFA", color = "#E3E3E3"),
      plot.margin = margin(8, 10, 8, 8)
    )
}

# Probamos la función con un solo indicador
dispersion |> filter(titulo == "Mortalidad infantil") |> panel_owid()

# Ahora aplicamos la función a cada indicador con `split()` (que divide la tabla
# en una lista, un elemento por indicador) y `map()`, y juntamos los nueve
# paneles con `wrap_plots()` de `patchwork`. El título general y la fuente se
# agregan con `plot_annotation()`, que acepta un tema propio.

paneles <- dispersion |>
  split(~ titulo) |>
  map(panel_owid)

grafico_bienestar <- wrap_plots(paneles, ncol = 3) +
  plot_annotation(
    title = "¿Cómo es la vida con distintos niveles de PIB por habitante?",
    subtitle = paste0("Cada círculo es un país. En el eje x, el PIB por habitante por año, ",
                      "en dólares ajustados por diferencias\nde precios entre países (eje logarítmico). ",
                      "Último dato disponible desde 2010."),
    caption = paste0("Fuente: Banco Mundial, ONU, OMS, UNICEF, Global Carbon Project, ",
                     "Gallup y Lee-Lee, vía Our World in Data · CC BY"),
    theme = theme_owid() + theme(plot.margin = margin(15, 15, 10, 15))
  )

grafico_bienestar
guardar(grafico_bienestar, "05_bienestar_pib", ancho = 10, alto = 12)

# LECTURA. El mensaje es el mismo que en la versión exploratoria, pero ahora
# cada panel se entiende solo: tiene su unidad, las mortalidades en eje
# logarítmico muestran que la relación con el ingreso es casi una recta, y el
# fondo de tarjeta separa los paneles sin necesidad de líneas. La forma de las
# nubes también dice algo: la electricidad llega al 100% alrededor de los 10.000
# dólares y después ya no puede crecer, mientras que la esperanza de vida y la
# satisfacción con la vida siguen subiendo, cada vez más despacio.
#
# ATENCIÓN. Estos gráficos muestran correlaciones entre países, no efectos. Que
# los países ricos tengan más médicos no quiere decir que crecer genere médicos
# por sí solo, ni al revés: la riqueza, las instituciones y la salud se mueven
# juntas. Un título como "Los países más ricos viven más" describe; "Crecer
# alarga la vida" afirma una causa que este gráfico no puede demostrar.
#


# ==============================================================================
# CIERRE
# ==============================================================================
# | Gráfico | Cuándo usarlo | Piezas de código clave |
# |:--|:--|:--|
# | Líneas con anotaciones | Una o dos series en el tiempo | `pintar()` en el título, `geom_point()` en el último año, `annotate("richtext")` |
# | Barras apiladas al 100% | Partes de un total, para pocos casos | `geom_rect()` con `xmin`/`xmax` acumulados, `facet_wrap(ncol = 1)` |
# | Muchas líneas | Tres a seis series en el tiempo | `geom_text_repel(direction = "y")`, `coord_cartesian(clip = "off")`, `annotate("curve")` |
# | Curvas con flechas | Comparar dos distribuciones | Distribución acumulada, `scale_x_log10()`, `geom_segment(arrow = ...)` |
# | Múltiplos pequeños | La misma relación para muchas variables | Exploratorio: `facet_wrap()`. Para publicar: una función por panel + `patchwork` |
#
# Y la lista para revisar antes de publicar cualquier gráfico:
#
# 1. ¿El título dice la conclusión, y los datos la respaldan?
# 2. ¿El subtítulo dice qué se mide, en qué unidad, dónde y cuándo?
# 3. ¿Se entiende qué es cada color sin leyenda?
# 4. ¿Los números de las anotaciones salen del código, no escritos a mano?
# 5. ¿Está la fuente?
# 6. ¿Se lee en un celular? (abrir el PNG guardado y achicarlo)
