# =============================================================================
# PRÁCTICA 3. Desigualdad: Gini y Theil
# Ciencia de Datos para Economía y Negocios — FCE-UBA
#
# Práctica de la clase 12. Aplica en R los índices de desigualdad de la
# teórica de la clase 11 (láminas 27 a 31).
#
# Contenidos
#   1. El Gini no es "un índice de ingresos": arrancamos con exportaciones
#   2. Gini y HHI sobre la misma distribución: ¿ordenan igual?
#   3. La misma fórmula, otra distribución: ingresos de la EPH
#   4. La curva de Lorenz
#   5. Theil y su descomposición entre grupos / dentro de grupos
#   6. Lo que el número no dice: no respuesta y elección de la variable
#
# En la clase 10 usaron el Gini del Banco Mundial como una variable ya
# calculada. Esta es la primera vez que lo calculan ustedes.
# =============================================================================


# =============================================================================
# 0. PAQUETES
# =============================================================================

# install.packages(c("tidyverse", "fst", "eph", "scales"))

library(tidyverse)
library(fst)
library(scales)
library(eph)        # descarga de microdatos de la EPH-INDEC

options(scipen = 999)
theme_set(theme_minimal(base_size = 12))


# =============================================================================
# 1. EL GINI NO ES "UN ÍNDICE DE INGRESOS"
# =============================================================================
#
# El Gini mide qué tan desigual está repartida CUALQUIER magnitud entre
# cualquier conjunto de unidades (lámina 27). Se hizo famoso con el ingreso
# entre personas, pero la fórmula no sabe nada de ingresos.
#
# Para que quede claro, lo estrenamos sobre algo que ya conocen de las dos
# prácticas anteriores: cómo se reparten las exportaciones de un país entre
# los productos de su canasta.

# ---- 1.1 La función --------------------------------------------------------
#
# Calculamos el Gini como el área entre la curva de Lorenz y la diagonal:
#
#   Gini = 1 - 2 * (área bajo la curva de Lorenz)
#
# El procedimiento es el de la lámina 28:
#   1. Ordenar de menor a mayor.
#   2. Acumular la proporción de unidades y la proporción de la magnitud.
#   3. Integrar por trapecios.
#
# El argumento w son los ponderadores. Si no se pasan, todas las unidades
# pesan igual. Lo vamos a necesitar en el punto 3, porque la EPH es una
# muestra y cada caso representa a una cantidad distinta de personas.

calcular_gini <- function(x, w = NULL) {

  # Forzamos a numeric antes de multiplicar. En R, integer * integer devuelve
  # integer, y si el producto supera 2.147.483.647 el resultado es NA con un
  # warning fácil de pasar por alto. Con ingresos por ponderadores eso pasa.
  x <- as.numeric(x)
  if (is.null(w)) w <- rep(1, length(x))
  w <- as.numeric(w)

  ok <- !is.na(x) & !is.na(w) & w > 0
  x <- x[ok]; w <- w[ok]

  orden <- order(x)
  x <- x[orden]; w <- w[orden]

  prop_unidades <- cumsum(w) / sum(w)
  prop_magnitud <- cumsum(x * w) / sum(x * w)

  # Área por trapecios: base * (altura_anterior + altura_actual) / 2
  area <- sum(diff(c(0, prop_unidades)) *
                (c(0, head(prop_magnitud, -1)) + prop_magnitud) / 2)

  1 - 2 * area
}


# ---- 1.2 Probarla con casos que sabemos de antemano ------------------------

tibble(
  caso = c("Reparto perfectamente igual",
           "Casi todo en una sola unidad",
           "Mitad de las unidades tiene todo"),
  gini = c(calcular_gini(rep(10, 100)),
           calcular_gini(c(rep(0.001, 99), 1000)),
           calcular_gini(c(rep(0, 50), rep(10, 50))))
)

# El primero da 0 (igualdad perfecta). El segundo, casi 1. El tercero da 0,5,
# que es el resultado conocido cuando la mitad de la población concentra todo.


# =============================================================================
# 2. GINI Y HHI SOBRE LA MISMA DISTRIBUCIÓN: ¿ORDENAN IGUAL?
# =============================================================================
#
# Los dos miden concentración sobre el mismo vector de participaciones. Pero
# no miden lo mismo, y conviene verlo antes de pasar a ingresos.

baci_path <- "datos/baci"

baci <- read_fst(file.path(baci_path, "baci_2024.fst")) |>
  filter(!is.na(v), v > 0)

paises <- read_csv(file.path(baci_path, "country_codes_V202601.csv"),
                   show_col_types = FALSE) |>
  # Igual que en la práctica 1: el catálogo repite el ISO3 en códigos
  # históricos (BEL, DEU, SDN). Nos quedamos con los que están en los datos.
  filter(country_code %in% union(baci$i, baci$j))

expo_productos <- baci |>
  group_by(i, k) |>
  summarise(valor = sum(v), .groups = "drop") |>
  mutate(hs4 = str_sub(str_pad(k, 6, "left", "0"), 1, 4)) |>
  group_by(i, hs4) |>
  summarise(valor = sum(valor), .groups = "drop")

calcular_hhi <- function(shares) sum(shares^2)

conc_canasta <- expo_productos |>
  group_by(i) |>
  summarise(
    n_partidas = n(),
    total      = sum(valor),
    gini       = calcular_gini(valor),
    hhi        = calcular_hhi(valor / sum(valor)),
    .groups    = "drop"
  ) |>
  filter(total >= 1e6) |>              # mismo umbral que la práctica 1
  left_join(paises, by = c("i" = "country_code"))

# Los 10 más concentrados según cada índice:
conc_canasta |> arrange(desc(hhi))  |> select(country_iso3, n_partidas, hhi, gini) |> head(10)
conc_canasta |> arrange(desc(gini)) |> select(country_iso3, n_partidas, hhi, gini) |> head(10)

# Los dos rankings se parecen mucho. Pero miren los RANGOS de cada índice:

conc_canasta |>
  summarise(
    hhi_min = min(hhi),   hhi_max = max(hhi),
    gini_min = min(gini), gini_max = max(gini),
    correlacion_lineal = cor(hhi, gini),
    correlacion_rangos = cor(hhi, gini, method = "spearman")
  )

# ---- 2.1 Ordenan casi igual, pero no dicen lo mismo ------------------------
#
# El HHI va de 0,009 a 0,89: un factor de casi cien entre el país más
# diversificado y el más concentrado.
# El Gini va de 0,81 a 0,998: TODOS los países dan "muy desigual".
#
# La correlación de rangos es 0,94 (ordenan casi igual) pero la correlación
# lineal es apenas 0,64 (la relación no es para nada lineal).

grafico_gini_hhi <- conc_canasta |>
  ggplot(aes(x = hhi, y = gini)) +
  geom_point(alpha = 0.4, color = "steelblue", size = 2) +
  geom_text(data = ~ filter(.x, country_iso3 %in%
                              c("ARG", "DEU", "NGA", "SAU", "CHN", "IRQ")),
            aes(label = country_iso3), vjust = -1, size = 3.5) +
  scale_x_continuous(transform = "log10") +
  scale_y_continuous(limits = c(0.75, 1)) +
  labs(x = "HHI de la canasta exportadora (escala log)",
       y = "Gini de la canasta exportadora",
       title = "Dos índices que ordenan igual y miden distinto",
       subtitle = paste0("Cada punto es un país. HS4, 2024. ",
                         "El Gini se satura cerca de 1; el HHI no."),
       caption = "Fuente: elaboración propia en base a BACI HS22, CEPII.")

grafico_gini_hhi

# ¿Por qué el Gini se satura? Porque hay 1.228 partidas posibles y cualquier
# país, incluso Alemania, exporta montos irrisorios en la mayoría de ellas. Es
# decir: TODA canasta exportadora es extremadamente desigual, y la diferencia
# entre un país diversificado y uno petrolero se juega en el último 20% del
# recorrido del índice.
#
# El HHI, al elevar al cuadrado, le da casi todo el peso a las participaciones
# grandes y básicamente ignora la cola de partidas chicas. Por eso separa bien.
#
# LA LECCIÓN: que dos índices ordenen igual no significa que sean
# intercambiables. Si el Gini de exportaciones de Argentina pasa de 0,948 a
# 0,952, ¿es mucho o poco? Con ese rango comprimido, no hay forma de saberlo
# sin la distribución completa. El HHI, en cambio, tiene una interpretación
# directa (el número equivalente de la práctica 1).
#
# Esto también explica por qué el Gini funciona bien con ingresos: ahí la
# distribución real ocupa buena parte del rango del índice, entre 0,25 y 0,65.
# Un índice sirve cuando su rango útil coincide con la variación del fenómeno.

# Ejercicio 2.1 --------------------------------------------------------------
# a) Tomen España (el Gini más bajo) e Irak (el más alto) y grafiquen la
#    distribución de sus exportaciones por partida en escala logarítmica.
#    ¿Se parece a lo que esperaban viendo solo los dos números?
# b) Recalculen el Gini de la canasta quedándose únicamente con las partidas
#    que superen el 0,1% de las exportaciones del país. ¿El rango se despliega?
#    ¿Qué perdimos al filtrar?


# =============================================================================
# 3. LA MISMA FÓRMULA, OTRA DISTRIBUCIÓN: INGRESOS DE LA EPH
# =============================================================================
#
# Cambiamos de dataset, no de herramienta. La función calcular_gini() es la
# misma; lo que cambia es qué son las unidades (antes productos, ahora
# personas) y qué es la magnitud (antes dólares exportados, ahora ingresos).

# ---- 3.1 Cargar la EPH -----------------------------------------------------
#
# El paquete eph descarga los microdatos del INDEC, pero eso necesita internet
# y que el servidor del INDEC responda. Para que la clase no dependa de eso,
# el archivo ya está en datos/. Este bloque usa la copia local si existe y
# solo descarga si hace falta.
#
# Cuando trabajen con esto para el TP: revisen cuál es el último trimestre
# publicado y actualicen estas dos líneas.

anio      <- 2025
trimestre <- 3

archivo_local <- "datos/usu_individual_T325.txt"

# ATENCIÓN AL LOCALE. Los archivos de texto del INDEC usan COMA como separador
# decimal: el ingreso 139111,11 se escribe así, con coma.
#
# readr, por defecto, asume el formato anglosajón: punto decimal y coma como
# separador de miles. Entonces lee "139111,11" y entiende 13911111, o sea cien
# veces más. Y no avisa nada: la columna queda numeric, el script corre y los
# resultados salen mal.
#
# Es un error grave y silencioso. Con el locale mal, el Gini del ingreso per
# cápita familiar da 0,835 en vez de 0,428.

locale_indec <- locale(decimal_mark = ",", grouping_mark = ".")

if (file.exists(archivo_local)) {
  eph_individual <- read_delim(archivo_local, delim = ";",
                               locale = locale_indec,
                               show_col_types = FALSE)
} else {
  # get_microdata() ya resuelve el parseo por dentro
  eph_individual <- get_microdata(year = anio, period = trimestre,
                                  type = "individual")
}

dim(eph_individual)

# Control rápido: ¿los ingresos tienen magnitudes verosímiles?
summary(eph_individual$IPCF[eph_individual$IPCF > 0])

# La mediana del ingreso per cápita familiar tiene que dar algo del orden de
# unos cientos de miles de pesos. Si diera decenas de millones, el locale está
# mal. Este tipo de control de orden de magnitud lleva diez segundos y es la
# diferencia entre un resultado y un disparate.


# ---- 3.2 Elegir la variable de ingreso: una decisión, no un detalle --------
#
# La EPH tiene varias variables de ingreso y NO dan lo mismo:
#
#   P21   : ingreso de la ocupación principal. Es individual y laboral. Su
#           ponderador es PONDIIO.
#   IPCF  : ingreso per cápita familiar. Reparte el ingreso total del hogar
#           entre sus miembros. Su ponderador es PONDIH.
#
# El Gini que publica el INDEC en su informe de ingresos se calcula sobre
# IPCF, no sobre P21. Vamos a usar P21 porque la pregunta que nos interesa es
# sobre el mercado de trabajo, pero el número que salga NO es comparable con
# el del INDEC. Al final del script los comparamos.

base <- eph_individual |>
  filter(
    ESTADO == 1,        # ocupados
    P21 > 0,            # con ingreso declarado positivo
    PONDIIO > 0         # con ponderador válido
  ) |>
  transmute(
    ingreso   = as.numeric(P21),
    pondera   = as.numeric(PONDIIO),
    region    = factor(REGION,
                       levels = c(1, 40, 41, 42, 43, 44),
                       labels = c("GBA", "NOA", "NEA", "Cuyo",
                                  "Pampeana", "Patagonia")),
    sexo      = factor(CH04, levels = c(1, 2), labels = c("Varón", "Mujer")),
    edad      = CH06,
    nivel_ed  = factor(NIVEL_ED,
                       levels = 1:7,
                       labels = c("Primario incompleto", "Primario completo",
                                  "Secundario incompleto", "Secundario completo",
                                  "Superior incompleto", "Superior completo",
                                  "Sin instrucción"))
  )

# OJO con los filtros. PONDIIO > 0 no es lo mismo que !is.na(PONDIIO): el
# INDEC marca la no respuesta con CERO, no con NA. Un filtro escrito con
# is.na() no saca nada y da la falsa sensación de estar cubierto.

nrow(base)
summary(base$ingreso)


# ---- 3.3 El Gini del ingreso laboral ---------------------------------------

gini_nacional <- calcular_gini(base$ingreso, base$pondera)
gini_nacional


# ---- 3.4 Por región --------------------------------------------------------

gini_region <- base |>
  filter(!is.na(region)) |>
  group_by(region) |>
  summarise(
    casos         = n(),
    poblacion     = sum(pondera),
    ingreso_medio = weighted.mean(ingreso, pondera),
    gini          = calcular_gini(ingreso, pondera),
    .groups       = "drop"
  ) |>
  arrange(desc(gini))

gini_region

grafico_gini_region <- gini_region |>
  ggplot(aes(x = reorder(region, gini), y = gini)) +
  geom_col(fill = "steelblue") +
  geom_hline(yintercept = gini_nacional, color = "tomato",
             linetype = "dashed", linewidth = 0.8) +
  geom_text(aes(label = number(gini, accuracy = 0.001, decimal.mark = ",")),
            hjust = -0.2, size = 4) +
  annotate("text", x = 0.7, y = gini_nacional,
           label = paste0("Total país = ",
                          number(gini_nacional, accuracy = 0.001,
                                 decimal.mark = ",")),
           color = "tomato", size = 3.5, hjust = 0) +
  coord_flip() +
  scale_y_continuous(limits = c(0, max(gini_region$gini) * 1.2)) +
  labs(x = NULL, y = "Coeficiente de Gini",
       title = "Desigualdad del ingreso de la ocupación principal",
       subtitle = paste0("Ocupados con ingreso declarado positivo. EPH ",
                         anio, "T", trimestre, "."),
       caption = paste0("Fuente: elaboración propia en base a EPH-INDEC.\n",
                        "No comparable con el Gini publicado por INDEC, ",
                        "que se calcula sobre ingreso per cápita familiar."))

grafico_gini_region

# Fíjense en el subtítulo y en el pie: dicen exactamente qué población y qué
# variable de ingreso hay detrás del número. Sin eso, el gráfico invita a la
# comparación equivocada.


# =============================================================================
# 4. LA CURVA DE LORENZ
# =============================================================================
#
# Es el objeto del que sale el Gini. Vale la pena dibujarla porque muestra
# algo que el índice resume en un número y por lo tanto esconde: DÓNDE de la
# distribución está la desigualdad.

lorenz <- base |>
  arrange(ingreso) |>
  mutate(
    prop_poblacion = cumsum(pondera) / sum(pondera),
    prop_ingreso   = cumsum(ingreso * pondera) / sum(ingreso * pondera)
  )

# Para graficar no necesitamos los 15.000 puntos: con 200 alcanza y el
# gráfico pesa mucho menos.
lorenz_grafico <- lorenz |>
  mutate(tramo = ntile(prop_poblacion, 200)) |>
  group_by(tramo) |>
  summarise(prop_poblacion = max(prop_poblacion),
            prop_ingreso   = max(prop_ingreso), .groups = "drop") |>
  add_row(prop_poblacion = 0, prop_ingreso = 0, .before = 1)

# Los deciles, para poder leer el gráfico
deciles <- lorenz_grafico |>
  slice(which.min(abs(prop_poblacion - 0.1)),
        which.min(abs(prop_poblacion - 0.5)),
        which.min(abs(prop_poblacion - 0.9)))

grafico_lorenz <- ggplot(lorenz_grafico,
                         aes(x = prop_poblacion, y = prop_ingreso)) +
  geom_ribbon(aes(ymin = prop_ingreso, ymax = prop_poblacion),
              fill = "steelblue", alpha = 0.25) +
  geom_abline(slope = 1, intercept = 0, color = "tomato", linetype = "dashed") +
  geom_line(color = "steelblue", linewidth = 1) +
  geom_point(data = deciles, color = "steelblue", size = 2.5) +
  geom_text(data = deciles,
            aes(label = paste0(percent(prop_poblacion, accuracy = 1),
                               " -> ",
                               percent(prop_ingreso, accuracy = 1))),
            hjust = -0.1, vjust = 1.4, size = 3.2) +
  annotate("text", x = 0.63, y = 0.28,
           label = paste("Gini =", number(gini_nacional, accuracy = 0.001,
                                          decimal.mark = ",")),
           size = 5, fontface = "bold") +
  scale_x_continuous(labels = percent_format()) +
  scale_y_continuous(labels = percent_format()) +
  labs(x = "Proporción acumulada de ocupados",
       y = "Proporción acumulada del ingreso",
       title = "Curva de Lorenz del ingreso de la ocupación principal",
       subtitle = paste0("EPH ", anio, "T", trimestre,
                         ". El área sombreada es lo que mide el Gini."),
       caption = "Fuente: elaboración propia en base a EPH-INDEC.")

grafico_lorenz

# Ejercicio 4 ----------------------------------------------------------------
# Superpongan las curvas de Lorenz de dos regiones con Gini parecido. ¿Se
# cruzan? Cuando dos curvas se cruzan, el Gini las ordena igual pero la
# desigualdad está en lugares distintos de la distribución. Es la limitación
# central del índice y no se ve mirando el número.


# =============================================================================
# 5. THEIL Y SU DESCOMPOSICIÓN
# =============================================================================
#
#   T = sum_i [ w_i * (y_i / mu) * ln(y_i / mu) ]     con sum w_i = 1
#
# La propiedad que lo hace interesante (lámina 30) es que se puede partir
# exactamente en dos:
#
#   T_total = T_entre + T_dentro
#
# Eso permite responder: ¿la desigualdad viene de que unas regiones son más
# ricas que otras, o de que adentro de cada región hay mucha dispersión?

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

theil_nacional <- calcular_theil(base$ingreso, base$pondera)
theil_nacional


# ---- 5.1 La descomposición -------------------------------------------------
#
#   T_entre  = sum_g [ s_g * (mu_g / mu) * log(mu_g / mu) ]
#   T_dentro = sum_g [ s_g * (mu_g / mu) * T_g ]
#
# donde s_g es la participación del grupo g en la población, mu_g su ingreso
# medio y T_g el Theil calculado dentro del grupo.

descomponer_theil <- function(x, w, grupo) {
  x <- as.numeric(x)
  w <- as.numeric(w)

  ok <- !is.na(x) & !is.na(w) & !is.na(grupo) & w > 0 & x > 0
  x <- x[ok]; w <- w[ok]; grupo <- grupo[ok]

  mu_total  <- weighted.mean(x, w)
  pob_total <- sum(w)

  detalle <- tibble(grupo = grupo, x = x, w = w) |>
    group_by(grupo) |>
    summarise(
      s_g     = sum(w) / pob_total,
      mu_g    = weighted.mean(x, w),
      theil_g = calcular_theil(x, w),
      .groups = "drop"
    ) |>
    mutate(
      aporte_entre  = s_g * (mu_g / mu_total) * log(mu_g / mu_total),
      aporte_dentro = s_g * (mu_g / mu_total) * theil_g
    )

  list(
    # OJO: T_observado se calcula APARTE, sobre la misma muestra filtrada.
    # No es la suma de los componentes. Si lo definiéramos como la suma, la
    # verificación de abajo sería una tautología y no probaría nada.
    T_observado = calcular_theil(x, w),
    T_entre     = sum(detalle$aporte_entre),
    T_dentro    = sum(detalle$aporte_dentro),
    detalle     = detalle
  )
}


# ---- 5.2 ¿La descomposición realmente cierra? ------------------------------

theil_region <- descomponer_theil(base$ingreso, base$pondera, base$region)

tibble(
  concepto = c("T observado (calculado directo)",
               "T entre regiones",
               "T dentro de regiones",
               "T entre + T dentro"),
  valor = c(theil_region$T_observado,
            theil_region$T_entre,
            theil_region$T_dentro,
            theil_region$T_entre + theil_region$T_dentro)
)

# La verificación de verdad: comparar el Theil calculado directamente sobre
# toda la muestra contra la suma de los dos componentes.
all.equal(theil_region$T_observado,
          theil_region$T_entre + theil_region$T_dentro)

# Si esto da TRUE, la aditividad de la lámina 30 quedó demostrada con datos.
# Y si alguna vez les da FALSE, es señal de que los componentes se están
# calculando sobre una muestra distinta de la del total.


# ---- 5.3 Qué dice el resultado ---------------------------------------------

theil_region$detalle |>
  mutate(peso_entre  = aporte_entre  / theil_region$T_observado,
         peso_dentro = aporte_dentro / theil_region$T_observado) |>
  arrange(desc(aporte_dentro))


# ---- 5.4 Comparar dos particiones (con la misma muestra) -------------------
#
# ¿Qué separa mejor a la población: la región o el nivel educativo?
#
# CUIDADO: para que la comparación sea válida, las dos descomposiciones tienen
# que correr sobre EXACTAMENTE las mismas personas. Si una descarta los casos
# sin nivel educativo declarado y la otra no, los totales son distintos y las
# barras no son comparables.

base_comparacion <- base |>
  filter(!is.na(region), !is.na(nivel_ed))

nrow(base)               # muestra original
nrow(base_comparacion)   # muestra común a las dos particiones

# En este trimestre los dos números coinciden: no hay ocupados con región o
# nivel educativo sin declarar. No siempre es así, y sobre todo no es así con
# otras variables (rama de actividad, calificación). El chequeo se hace igual,
# aunque esta vez no haya cambiado nada: por eso imprimimos los dos números en
# vez de suponer.

theil_region_c <- descomponer_theil(base_comparacion$ingreso,
                                    base_comparacion$pondera,
                                    base_comparacion$region)

theil_educ_c   <- descomponer_theil(base_comparacion$ingreso,
                                    base_comparacion$pondera,
                                    base_comparacion$nivel_ed)

# Los dos totales ahora tienen que coincidir:
tibble(
  particion   = c("Por región", "Por nivel educativo"),
  T_observado = c(theil_region_c$T_observado, theil_educ_c$T_observado),
  T_entre     = c(theil_region_c$T_entre,     theil_educ_c$T_entre),
  T_dentro    = c(theil_region_c$T_dentro,    theil_educ_c$T_dentro)
) |>
  mutate(pct_entre = percent(T_entre / T_observado, accuracy = 0.1))

comparacion <- bind_rows(
  tibble(particion = "Por región",
         componente = c("Entre grupos", "Dentro de los grupos"),
         valor = c(theil_region_c$T_entre, theil_region_c$T_dentro)),
  tibble(particion = "Por nivel educativo",
         componente = c("Entre grupos", "Dentro de los grupos"),
         valor = c(theil_educ_c$T_entre, theil_educ_c$T_dentro))
)

grafico_descomposicion <- comparacion |>
  group_by(particion) |>
  mutate(porcentaje = valor / sum(valor)) |>
  ungroup() |>
  ggplot(aes(x = particion, y = valor, fill = componente)) +
  geom_col(width = 0.6) +
  geom_text(aes(label = percent(porcentaje, accuracy = 0.1)),
            position = position_stack(vjust = 0.5),
            color = "white", size = 4.5, fontface = "bold") +
  scale_fill_manual(values = c("Entre grupos"         = "tomato",
                               "Dentro de los grupos" = "steelblue")) +
  labs(x = NULL, y = "Índice de Theil", fill = NULL,
       title = "¿Qué partición de la población explica más desigualdad?",
       subtitle = paste0("Ingreso de la ocupación principal. EPH ", anio, "T",
                         trimestre, ". Misma muestra en ambas columnas."),
       caption = "Fuente: elaboración propia en base a EPH-INDEC.") +
  theme(legend.position = "bottom")

grafico_descomposicion

# Interpreten ustedes el gráfico antes de seguir leyendo. Las preguntas:
#   - ¿Qué componente domina en los dos casos?
#   - ¿Qué quiere decir que el componente "entre grupos" sea chico?
#   - Si el "entre" de una partición es casi nulo, ¿sirve esa variable para
#     explicar la desigualdad de ingresos?
#
# Una advertencia sobre cómo se lee esto: que el componente "entre" de una
# partición sea mayor que el de otra NO quiere decir que esa variable "cause"
# más desigualdad. Quiere decir que separa grupos con medias más distintas.
# Son cosas distintas (lámina 42, punto 4).

# Ejercicio 5.4 --------------------------------------------------------------
# Agreguen una tercera partición: por sexo (la variable sexo ya está en base).
# ¿El componente entre grupos es mayor o menor que el de región? Comparen ese
# resultado con la brecha de ingresos entre varones y mujeres que pueden
# calcular con weighted.mean(). ¿Por qué una brecha grande puede convivir con
# un componente "entre" chico?


# =============================================================================
# 6. LO QUE EL NÚMERO NO DICE
# =============================================================================
#
# Los dos índices están bien calculados. Eso no alcanza.

# ---- 6.1 La no respuesta de ingresos ---------------------------------------
#
# Cuántos ocupados quedaron afuera por no declarar ingreso:

cobertura <- eph_individual |>
  filter(ESTADO == 1) |>
  summarise(
    ocupados          = n(),
    con_ingreso       = sum(P21 > 0, na.rm = TRUE),
    pct_con_ingreso   = mean(P21 > 0, na.rm = TRUE)
  )

cobertura

# Alrededor del 21% de los ocupados no declara ingreso de la ocupación
# principal, y los estamos descartando. El problema no es el tamaño del
# descarte: es que la no respuesta NO es aleatoria. Está concentrada en los
# extremos de la distribución, sobre todo en los ingresos altos.
#
# Si los que no responden ganan sistemáticamente más que los que sí responden,
# nuestro Gini SUBESTIMA la desigualdad. El INDEC trabaja este problema con
# procedimientos de imputación; nosotros, con este filtro, no.
#
# Esto se reporta. No se corrige con una nota al pie, pero tampoco se omite.


# ---- 6.2 La elección de la variable ----------------------------------------
#
# Comparemos nuestro Gini con el que sale de la variable que usa el INDEC.

gini_ipcf <- eph_individual |>
  filter(IPCF > 0, PONDIH > 0) |>
  summarise(gini = calcular_gini(IPCF, PONDIH)) |>
  pull(gini)

tibble(
  variable = c("P21 - ingreso de la ocupación principal",
               "IPCF - ingreso per cápita familiar"),
  poblacion = c("Ocupados con ingreso declarado",
                "Personas en hogares con ingreso declarado"),
  ponderador = c("PONDIIO", "PONDIH"),
  gini = c(gini_nacional, gini_ipcf)
)

# Son dos números distintos de la misma encuesta, el mismo trimestre y el
# mismo país. Ninguno está mal. Miden cosas diferentes:
#
#   P21 mira el MERCADO DE TRABAJO: cuán desigual paga. Excluye a jubilados,
#   desocupados e inactivos, y no toma en cuenta con cuánta gente se comparte
#   ese ingreso.
#
#   IPCF mira el BIENESTAR DE LOS HOGARES: incluye todas las fuentes de
#   ingreso y reparte el total entre los miembros del hogar.
#
# El Gini que aparece en los diarios es el del IPCF. Si en el TP reportan un
# Gini, tienen que decir cuál de los dos es.

# Ejercicio 6.2 --------------------------------------------------------------
# Calculen el Gini del IPCF por región y compárenlo con el de P21 por región.
# ¿Las regiones se ordenan igual con las dos variables? Si no, ¿cuál cambia de
# lugar y por qué podría ser?


# =============================================================================
# EJERCICIOS INTEGRADORES
# =============================================================================
#
# 1. La serie en el tiempo. Bajen cuatro trimestres con get_microdata() y
#    calculen el Gini de P21 en cada uno. ¿Se mueve? Antes de interpretar
#    cualquier cambio, verifiquen si el porcentaje de no respuesta de ingresos
#    también se movió: un salto en el Gini puede ser un salto en quién
#    contesta.
#
# 2. Gini y Theil no ordenan igual. Calculen los dos índices por región y
#    comparen los rankings. Donde difieran, miren la distribución: el Theil
#    (GE(1)) es más sensible a lo que pasa en la parte alta de la distribución
#    que el Gini, que es más sensible al centro.
#
# 3. El Gini como variable vs. el Gini calculado. En la clase 10 usaron
#    SI.POV.GINI del Banco Mundial para Argentina. Búsquenlo para el año más
#    cercano y compárenlo con los dos que calcularon acá. ¿A cuál se parece
#    más? Revisen la metodología que declara el Banco Mundial para ese dato.
#
# 4. Volver a las exportaciones. Con lo que aprendieron del Theil, descompongan
#    la desigualdad de las exportaciones mundiales entre países: agrupen por
#    continente o por nivel de ingreso y vean cuánto del total se explica entre
#    grupos. Es la misma función, otra distribución.
