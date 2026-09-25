# =============================================================================
# PRÁCTICA 2. Comercio internacional: Balassa (RCA) y Grubel-Lloyd
# Ciencia de Datos para Economía y Negocios — FCE-UBA
#
# Práctica de la clase 12. Aplica en R los índices de comercio internacional de
# la teórica de la clase 11 (láminas 17 a 25).
#
# Contenidos
#   0. Datos y un problema de etiquetas que hay que resolver antes de graficar
#   1. Ventaja Comparativa Revelada (RCA) de Balassa
#   2. Por qué el RCA clásico engaña y qué hace el RSCA
#   3. Diversidad: cuántos productos exporta cada país con ventaja
#   4. Grubel-Lloyd: comercio intraindustrial
#   5. El nivel de desagregación, otra vez
#
# Requiere haber corrido antes 01_concentracion_baci.R, o al menos entender
# de dónde sale la base. Acá volvemos a leerla desde cero para que el script
# se pueda correr solo.
# =============================================================================


# =============================================================================
# 0. PAQUETES, DATOS Y ETIQUETAS
# =============================================================================

library(tidyverse)
library(fst)

options(scipen = 999)
theme_set(theme_minimal(base_size = 12))

baci_path <- "datos/baci"

baci      <- read_fst(file.path(baci_path, "baci_2024.fst"))
paises    <- read_csv(file.path(baci_path, "country_codes_V202601.csv"),
                      show_col_types = FALSE)
productos <- read_csv(file.path(baci_path, "product_codes_HS22_V202601.csv"),
                      col_types = cols(code = col_character(),
                                       description = col_character()))

baci <- baci |>
  filter(!is.na(v), v > 0)

# Igual que en la práctica 1: el catálogo trae códigos históricos que repiten
# el ISO3 (BEL, DEU, SDN). Nos quedamos con los que aparecen en los datos.
paises <- paises |>
  filter(country_code %in% union(baci$i, baci$j))

stopifnot(!any(duplicated(paises$country_iso3)))

cod_arg <- paises |> filter(country_iso3 == "ARG") |> pull(country_code)


# ---- 0.1 Exportaciones por país y producto, a HS4 --------------------------
#
# Trabajamos a HS4 (partidas): es el compromiso habitual entre tener suficiente
# detalle y no quedarnos con celdas minúsculas y ruidosas.
#
# Igual que en la práctica 1, el str_pad va después de agregar.

expo <- baci |>
  group_by(i, k) |>
  summarise(valor = sum(v), .groups = "drop") |>
  mutate(
    hs6 = str_pad(k, width = 6, side = "left", pad = "0"),
    hs4 = str_sub(hs6, 1, 4)
  )


# ---- 0.2 El problema de las etiquetas --------------------------------------
#
# El archivo de descripciones viene a HS6. Nosotros trabajamos a HS4, y una
# partida agrupa varias subpartidas. ¿Qué texto le ponemos a la partida?
#
# Miren el caso 8703, que son los automóviles de pasajeros:

productos |>
  filter(str_sub(code, 1, 4) == "8703") |>
  head(4)

# La PRIMERA subpartida (870310) son los autos de golf y los vehículos para
# nieve: un producto marginal que casualmente tiene el código más bajo. Si
# tomáramos la descripción de la primera subpartida, el gráfico de RCA de
# Alemania diría que su principal ventaja está en "carritos de golf".
#
# Lo razonable es quedarse con la descripción de la subpartida que MÁS PESA en
# el comercio mundial dentro de cada partida. Para eso hay que unir las
# descripciones a nivel HS6 y recién DESPUÉS elegir el máximo. Si primero se
# colapsa y después se ordena, el orden ya no sirve de nada.

valor_mundial_hs6 <- expo |>
  group_by(hs6, hs4) |>
  summarise(valor_mundial = sum(valor), .groups = "drop")

desc_hs4 <- valor_mundial_hs6 |>
  left_join(productos, by = c("hs6" = "code")) |>   # unir a HS6, no a HS4
  group_by(hs4) |>
  slice_max(valor_mundial, n = 1, with_ties = FALSE) |>   # recién ahora elegir
  ungroup() |>
  select(hs4, descripcion_hs4 = description)

# Verificación: ¿quedó bien el caso que nos preocupaba?
desc_hs4 |> filter(hs4 %in% c("8703", "1005", "1201", "2709", "0201"))

# Ahora 8703 dice "Vehicles: with only spark-ignition ... over 1500 but not
# over 3000cc", que es el auto de pasajeros típico. Y 1005 dice maíz en grano,
# no "semilla de maíz".
#
# LA LECCIÓN: las etiquetas de un gráfico son parte del resultado. Un índice
# bien calculado con una etiqueta mal asignada es un gráfico equivocado, y
# encima uno que nadie revisa porque los números están bien.


# =============================================================================
# 1. VENTAJA COMPARATIVA REVELADA (RCA) DE BALASSA
# =============================================================================
#
#   RCA_ij = (X_ij / X_i.) / (X_.j / X_..)
#
#     X_ij : exportaciones del país i en el producto j
#     X_i. : exportaciones totales del país i
#     X_.j : exportaciones mundiales del producto j
#     X_.. : exportaciones mundiales totales
#
# Es un cociente de cocientes: compara el peso del producto en la canasta del
# país contra el peso de ese producto en el comercio mundial.
#
#   RCA > 1 : el país está relativamente especializado -> ventaja revelada
#   RCA < 1 : desventaja comparativa
#   RCA = 1 : exactamente el promedio mundial
#
# CUIDADO (lámina 18): el RCA mide especialización relativa, NO eficiencia ni
# productividad. Un RCA alto puede venir de dotación de factores, pero también
# de subsidios, de protección o de que el país no exporta casi nada más.

# ---- 1.1 El cálculo --------------------------------------------------------

x_ij <- expo |>
  group_by(i, hs4) |>
  summarise(x_ij = sum(valor), .groups = "drop")

x_i_punto   <- x_ij |> group_by(i)   |> summarise(x_i_punto = sum(x_ij))
x_punto_j   <- x_ij |> group_by(hs4) |> summarise(x_punto_j = sum(x_ij))
x_punto_punto <- sum(x_ij$x_ij)

rca <- x_ij |>
  left_join(x_i_punto, by = "i") |>
  left_join(x_punto_j, by = "hs4") |>
  mutate(
    rca  = (x_ij / x_i_punto) / (x_punto_j / x_punto_punto),
    rsca = (rca - 1) / (rca + 1)
  ) |>
  left_join(desc_hs4, by = "hs4") |>
  left_join(paises,   by = c("i" = "country_code"))

rca |> select(country_iso3, hs4, descripcion_hs4, x_ij, rca, rsca)


# ---- 1.2 Control de sanidad: el ejemplo de la lámina 18 -------------------
#
# La teórica dice que si la soja es el 15% de las exportaciones argentinas y el
# 2% del comercio mundial, el RCA tiene que dar 7,5. Verifiquemos la mecánica
# con la soja real (partida 1201).

rca |>
  filter(hs4 == "1201") |>
  arrange(desc(rca)) |>
  select(country_iso3, country_name, x_ij, rca, rsca) |>
  head(15)

# Argentina da RCA = 7,4, prácticamente el 7,5 del ejemplo de la lámina 18.
# El ejemplo de la teórica estaba bien calibrado.
#
# Pero miren el orden: arriba de Argentina están Paraguay, Benín, Brasil, Togo
# y Níger. No son los que más soja exportan en dólares, sino aquellos para los
# que la soja pesa más DENTRO de su canasta. Estados Unidos exporta doce veces
# más soja que Argentina en valor y queda en el puesto 10, porque su canasta
# total es enorme.
#
# Es exactamente lo que el índice dice que mide, pero es contraintuitivo la
# primera vez que se lo ve: el RCA no mide quién es grande en un producto,
# mide para quién ese producto es grande.


# ---- 1.3 El umbral de valor, otra vez --------------------------------------
#
# Mismo problema que en la práctica 1: una partida donde el país exportó
# 30.000 dólares puede tener un RCA altísimo y no significar nada.
#
# Recordar: v está en miles de USD.

umbral_producto <- 10e3   # 10 millones de USD por partida

# Probémoslo con Argentina:

rca_arg <- rca |> filter(i == cod_arg)

rca_arg |>
  arrange(desc(rca)) |>
  select(hs4, descripcion_hs4, x_ij, rca) |>
  head(10)

rca_arg |>
  filter(x_ij >= umbral_producto) |>
  arrange(desc(rca)) |>
  select(hs4, descripcion_hs4, x_ij, rca) |>
  head(10)

# Sorpresa: el top 10 es IDÉNTICO. El filtro no cambió nada.
#
# Es un buen recordatorio de que las precauciones metodológicas no siempre
# muerden. Argentina exporta mucho en casi todas las partidas donde tiene
# ventaja, así que ninguna se cae con un piso de 10 millones.
#
# Ahora el mismo ejercicio con Nueva Caledonia:

cod_ncl <- paises |> filter(country_iso3 == "NCL") |> pull(country_code)

rca |>
  filter(i == cod_ncl) |>
  arrange(desc(rca)) |>
  select(hs4, descripcion_hs4, x_ij, rca) |>
  head(8)

rca |>
  filter(i == cod_ncl, x_ij >= umbral_producto) |>
  arrange(desc(rca)) |>
  select(hs4, descripcion_hs4, x_ij, rca)

# Acá cambia todo. Sin filtro, los puestos 4 a 8 son escoria metalúrgica,
# aceites esenciales, residuos químicos y ANTIGÜEDADES DE MÁS DE CIEN AÑOS,
# con exportaciones de algunos cientos de miles de dólares. Con filtro quedan
# solo tres partidas, las tres de níquel, que es lo que efectivamente exporta
# Nueva Caledonia.
#
# Pero miren el costo: quedaron TRES productos. Con ese país ya no se puede
# hacer un "top 20", y cualquier índice que cuente partidas lo va a ubicar
# como una economía extremadamente poco diversificada, en parte por el filtro
# que elegimos nosotros. Volvemos sobre esto en el punto 3.
#
# LA LECCIÓN: la sensibilidad a una decisión metodológica no se supone, se
# verifica caso por caso. Y cuando muerde, hay que decidir si el costo de
# aplicarla es menor que el de no hacerlo.


# ---- 1.4 El gráfico --------------------------------------------------------

top_rca_arg <- rca_arg |>
  filter(x_ij >= umbral_producto) |>
  arrange(desc(rca)) |>
  head(20) |>
  mutate(etiqueta = paste0(hs4, " - ", str_trunc(descripcion_hs4, 45)))

grafico_rca_arg <- top_rca_arg |>
  mutate(etiqueta = reorder(etiqueta, rca)) |>
  ggplot(aes(x = etiqueta, y = rca)) +
  geom_col(fill = "steelblue") +
  geom_hline(yintercept = 1, color = "tomato", linetype = "dashed") +
  coord_flip() +
  labs(x = NULL, y = "RCA de Balassa",
       title = "Los 20 productos con mayor ventaja comparativa revelada",
       subtitle = paste0("Argentina, HS4, 2024. Partidas con exportaciones ",
                         "sobre 10 millones de USD. Línea roja: RCA = 1"),
       caption = "Fuente: elaboración propia en base a BACI HS22, CEPII.") +
  theme(axis.text.y = element_text(size = 8))

grafico_rca_arg

# Ejercicio 1.4 --------------------------------------------------------------
# Rehagan el gráfico para Chile, Alemania y Vietnam. ¿Qué tipo de productos
# aparecen en cada caso? ¿Se puede leer el perfil productivo de un país mirando
# solo esta lista?


# =============================================================================
# 2. POR QUÉ EL RCA CLÁSICO ENGAÑA Y QUÉ HACE EL RSCA
# =============================================================================
#
# El RCA tiene un problema de forma (lámina 20): es asimétrico.
#
#   Si el país está por DEBAJO del promedio mundial, el RCA vive entre 0 y 1.
#   Si está por ENCIMA, el RCA vive entre 1 e infinito.
#
# O sea que el "espacio" para la desventaja es un intervalo de largo 1 y el de
# la ventaja es infinito. Eso rompe cualquier promedio, cualquier desvío
# estándar y cualquier regresión que use el RCA como variable.
#
# El RSCA lo arregla mapeando todo a [-1, 1]:
#
#   RSCA = (RCA - 1) / (RCA + 1)

rca_arg_filtrado <- rca_arg |> filter(x_ij >= umbral_producto)

# Miren las dos distribuciones. Fíjense que el RCA necesita escala
# logarítmica para poder verse; el RSCA no.

grafico_rca_clasico <- rca_arg_filtrado |>
  ggplot(aes(x = rca)) +
  geom_histogram(bins = 50, fill = "steelblue", color = "white") +
  geom_vline(xintercept = 1, color = "tomato", linetype = "dashed") +
  scale_x_continuous(transform = "log10") +
  labs(x = "RCA (escala logarítmica)", y = "Cantidad de partidas",
       title = "RCA clásico: asimétrico, necesita escala log para leerse",
       subtitle = "Argentina, HS4, 2024")

grafico_rsca <- rca_arg_filtrado |>
  ggplot(aes(x = rsca)) +
  geom_histogram(bins = 50, fill = "darkorange", color = "white") +
  geom_vline(xintercept = 0, color = "tomato", linetype = "dashed") +
  labs(x = "RSCA", y = "Cantidad de partidas",
       title = "RCA simétrico: acotado en [-1, 1], se lee en escala natural",
       subtitle = "Argentina, HS4, 2024",
       caption = "Fuente: elaboración propia en base a BACI HS22, CEPII.")

grafico_rca_clasico
grafico_rsca

# El promedio de cada uno cuenta historias distintas:

rca_arg_filtrado |>
  summarise(
    media_rca      = mean(rca),
    mediana_rca    = median(rca),
    media_rsca     = mean(rsca),
    mediana_rsca   = median(rsca)
  )

# La media del RCA está inflada por unas pocas partidas con valores enormes:
# queda muy por encima de la mediana. La del RSCA no tiene ese problema.
# Es el mismo argumento que vimos con la media y la mediana del ingreso.


# =============================================================================
# 3. DIVERSIDAD: CUÁNTOS PRODUCTOS EXPORTA CADA PAÍS CON VENTAJA
# =============================================================================
#
# Contar las partidas con RCA > 1 de un país da una medida de DIVERSIDAD: no
# cuánto exporta, sino en cuántas cosas distintas es relativamente fuerte.
#
# Es la primera pieza del enfoque de complejidad económica (lámina 35), que
# vamos a ver de forma cualitativa con el Atlas de Harvard.

diversidad <- rca |>
  filter(rca > 1) |>
  group_by(i, country_iso3, country_name) |>
  summarise(n_partidas_vcr = n(), .groups = "drop") |>
  arrange(desc(n_partidas_vcr))

diversidad |> head(20)


# ---- 3.1 Cuidado: acá el umbral SÍ cambia lo que se mide -------------------
#
# En los puntos anteriores el umbral servía para sacar ruido. Acá no es tan
# simple: un piso ABSOLUTO en dólares castiga sistemáticamente a los países
# chicos, que nunca van a llegar a 10 millones en una partida aunque estén
# perfectamente especializados en ella.
#
# Comparen los dos rankings:

diversidad_con_umbral <- rca |>
  filter(rca > 1, x_ij >= umbral_producto) |>
  group_by(i, country_iso3) |>
  summarise(n_con_umbral = n(), .groups = "drop")

comparacion_diversidad <- diversidad |>
  left_join(diversidad_con_umbral, by = c("i", "country_iso3")) |>
  mutate(n_con_umbral = replace_na(n_con_umbral, 0)) |>
  left_join(
    rca |> group_by(i) |> summarise(expo_total = sum(x_ij)),
    by = "i"
  )

comparacion_diversidad |>
  arrange(desc(n_partidas_vcr)) |>
  select(country_iso3, n_partidas_vcr, n_con_umbral, expo_total) |>
  head(15)

comparacion_diversidad |>
  arrange(desc(n_con_umbral)) |>
  select(country_iso3, n_partidas_vcr, n_con_umbral, expo_total) |>
  head(15)

# El segundo ranking está ordenado casi por tamaño de la economía. Es decir:
# al poner el piso absoluto dejamos de medir diversidad y empezamos a medir,
# en buena parte, tamaño.
#
# La definición original de diversidad (Hidalgo y Hausmann) NO lleva umbral de
# valor, justamente por esto. Si igual queremos limpiar ruido, conviene un
# criterio relativo (por ejemplo, que la partida pese al menos 0,01% de las
# exportaciones del país) en vez de uno absoluto.

# Ejercicio 3.1 --------------------------------------------------------------
# Implementen el criterio relativo: filtren las partidas que representen al
# menos el 0,01% de las exportaciones del propio país y recalculen la
# diversidad. ¿El ranking se parece más al primero o al segundo? ¿Cuál de los
# tres reportarían en un informe?


# =============================================================================
# 4. GRUBEL-LLOYD: COMERCIO INTRAINDUSTRIAL
# =============================================================================
#
#   GL_j = 1 - |X_j - M_j| / (X_j + M_j)
#
#   GL = 1 : comercio totalmente intraindustrial (exporta e importa lo mismo)
#   GL = 0 : comercio totalmente interindustrial (solo exporta o solo importa)
#
# La pregunta de fondo (lámina 23) es teórica: el modelo ricardiano predice
# comercio interindustrial, y el comercio intraindustrial solo se explica con
# economías de escala y diferenciación de producto.

# ---- 4.1 Construir los flujos X y M por país ------------------------------
#
# En BACI cada fila es "el país i le exportó a j". Entonces, para un país c:
#   X_c = lo que aparece con c en la columna i
#   M_c = lo que aparece con c en la columna j
#
# CUIDADO CON LA VALUACIÓN: las importaciones así calculadas están valuadas
# como las declaró el EXPORTADOR, es decir FOB. Los datos de importaciones
# publicados por las aduanas suelen estar en CIF, que incluye flete y seguro y
# por lo tanto es más alto.
#
# Esto es una VENTAJA de usar BACI: como X y M están en la misma valuación, el
# GL no se distorsiona. Si replicaran esto con datos crudos de COMTRADE o con
# estadísticas nacionales, el |X - M| estaría inflado por el flete y el GL les
# daría sistemáticamente más bajo.

exportaciones <- baci |>
  group_by(pais = i, k) |>
  summarise(X = sum(v), .groups = "drop")

importaciones <- baci |>
  group_by(pais = j, k) |>
  summarise(M = sum(v), .groups = "drop")

flujos <- full_join(exportaciones, importaciones, by = c("pais", "k")) |>
  mutate(
    X   = replace_na(X, 0),
    M   = replace_na(M, 0),
    hs6 = str_pad(k, width = 6, side = "left", pad = "0"),
    hs4 = str_sub(hs6, 1, 4),
    hs2 = str_sub(hs6, 1, 2)
  )

flujos


# ---- 4.2 GL sectorial para Argentina --------------------------------------

gl_arg_hs4 <- flujos |>
  filter(pais == cod_arg) |>
  group_by(hs4) |>
  summarise(X = sum(X), M = sum(M), .groups = "drop") |>
  mutate(
    comercio_total = X + M,
    gl             = 1 - abs(X - M) / (X + M)
  ) |>
  left_join(desc_hs4, by = "hs4")

top_sectores_arg <- gl_arg_hs4 |>
  arrange(desc(comercio_total)) |>
  head(20) |>
  mutate(etiqueta = paste0(hs4, " - ", str_trunc(descripcion_hs4, 40)))

grafico_gl_arg <- top_sectores_arg |>
  mutate(etiqueta = reorder(etiqueta, comercio_total)) |>
  ggplot(aes(x = etiqueta, y = gl, fill = gl)) +
  geom_col(show.legend = FALSE) +
  geom_text(aes(label = sprintf("%.2f", gl)), hjust = -0.15, size = 3) +
  scale_fill_gradient(low = "tomato", high = "steelblue", limits = c(0, 1)) +
  scale_y_continuous(limits = c(0, 1.12), breaks = seq(0, 1, 0.25)) +
  coord_flip() +
  labs(x = NULL, y = "Índice de Grubel-Lloyd",
       title = "Comercio intraindustrial por sector — Argentina",
       subtitle = paste0("Las 20 partidas de mayor comercio total. HS4, 2024.\n",
                         "Azul = intraindustrial, rojo = interindustrial"),
       caption = "Fuente: elaboración propia en base a BACI HS22, CEPII.") +
  theme(axis.text.y = element_text(size = 8))

grafico_gl_arg

# Se ve la predicción de la teórica: los sectores primarios (soja, maíz, carne)
# tienen GL cercano a 0 y los manufacturados diferenciados (automotriz,
# químicos) tienen GL alto.

# Ejercicio 4.2 --------------------------------------------------------------
# El sector automotriz argentino tiene GL alto. ¿Contra qué países? Vuelvan a
# la base bilateral y miren, para la partida 8703, cuánto exporta e importa
# Argentina con Brasil. ¿El GL alto refleja "diferenciación de producto" a la
# Krugman, o algo más específico del Mercosur?


# ---- 4.3 GL agregado -------------------------------------------------------
#
#   GL_agregado = 1 - sum_j |X_j - M_j| / sum_j (X_j + M_j)
#
# OJO: NO es el promedio de los GL sectoriales. Es un cociente de sumas, no una
# suma de cocientes. Las dos cosas dan distinto y la que se reporta es esta.

calcular_gl_agregado <- function(datos, nivel) {
  datos |>
    group_by(grupo = .data[[nivel]]) |>
    summarise(X = sum(X), M = sum(M), .groups = "drop") |>
    summarise(gl = 1 - sum(abs(X - M)) / sum(X + M)) |>
    pull(gl)
}

flujos_arg <- flujos |> filter(pais == cod_arg)

# Comparación entre el agregado correcto y el promedio simple de los GL:
tibble(
  metodo = c("GL agregado (cociente de sumas)",
             "Promedio simple de los GL sectoriales"),
  valor  = c(calcular_gl_agregado(flujos_arg, "hs4"),
             mean(gl_arg_hs4$gl))
)

# El promedio simple da bastante más alto, porque le da el mismo peso a una
# partida de 20.000 dólares que a la soja.


# =============================================================================
# 5. EL NIVEL DE DESAGREGACIÓN, OTRA VEZ
# =============================================================================
#
# La lámina 25 avisa que el GL agregado depende del nivel de desagregación, y
# que a mayor desagregación el GL tiende a bajar.
#
# Igual que con el HHI en la práctica 1, esto NO es una tendencia empírica: es
# una propiedad aritmética. Al agregar dos productos, las diferencias entre
# ellos se compensan dentro de la suma:
#
#     |(X1 + X2) - (M1 + M2)|  <=  |X1 - M1| + |X2 - M2|
#
# (es la desigualdad triangular). Como ese término va RESTANDO en la fórmula
# del GL, agregar hace subir el GL. Siempre.
#
# Entonces GL(HS2) >= GL(HS4) >= GL(HS6) para todo país, siempre.

gl_niveles_arg <- tibble(
  nivel = c("HS2 (capítulos)", "HS4 (partidas)", "HS6 (subpartidas)"),
  gl    = c(calcular_gl_agregado(flujos_arg, "hs2"),
            calcular_gl_agregado(flujos_arg, "hs4"),
            calcular_gl_agregado(flujos_arg, "hs6"))
)

gl_niveles_arg


# ---- 5.1 Verificarlo para varios países ------------------------------------

seleccion <- c("ARG", "BRA", "CHL", "MEX", "DEU", "USA", "CHN", "KOR",
               "JPN", "AUS", "NGA", "SAU")

codigos_seleccion <- paises |>
  filter(country_iso3 %in% seleccion) |>
  select(pais = country_code, country_iso3)

gl_comparado <- codigos_seleccion |>
  mutate(
    hs2 = map_dbl(pais, function(p) calcular_gl_agregado(filter(flujos, pais == p), "hs2")),
    hs4 = map_dbl(pais, function(p) calcular_gl_agregado(filter(flujos, pais == p), "hs4")),
    hs6 = map_dbl(pais, function(p) calcular_gl_agregado(filter(flujos, pais == p), "hs6"))
  )

# ¿Se cumple la monotonía en todos los casos?
gl_comparado |>
  mutate(cumple = hs2 >= hs4 & hs4 >= hs6) |>
  select(country_iso3, hs2, hs4, hs6, cumple)

grafico_gl_niveles <- gl_comparado |>
  pivot_longer(c(hs2, hs4, hs6), names_to = "nivel", values_to = "gl") |>
  mutate(nivel = factor(nivel,
                        levels = c("hs2", "hs4", "hs6"),
                        labels = c("HS2 (capítulos)",
                                   "HS4 (partidas)",
                                   "HS6 (subpartidas)"))) |>
  ggplot(aes(x = reorder(country_iso3, gl), y = gl, fill = nivel)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.7) +
  coord_flip() +
  scale_fill_brewer(palette = "Greens") +
  labs(x = NULL, y = "Grubel-Lloyd agregado",
       fill = "Nivel de desagregación",
       title = "El comercio intraindustrial depende de cómo se defina industria",
       subtitle = "El GL baja al desagregar más fino. Igual que el HHI, es aritmética.",
       caption = "Fuente: elaboración propia en base a BACI HS22, CEPII (2024).") +
  theme(legend.position = "bottom")

grafico_gl_niveles

# La conclusión práctica es incómoda y hay que decirla: la frase "el X% del
# comercio argentino es intraindustrial" no tiene sentido sin aclarar el nivel
# de desagregación. Y buena parte de la literatura sobre integración regional
# reporta GL a 2 o 3 dígitos, que es donde el índice da más alto.


# =============================================================================
# EJERCICIOS INTEGRADORES
# =============================================================================
#
# 1. RCA y GL juntos. Para Argentina, hagan un scatter con el RSCA de cada
#    partida en un eje y el GL de esa misma partida en el otro. ¿Hay relación?
#    ¿Qué tipo de sector cae en cada cuadrante? Piensen qué quiere decir un
#    sector con RSCA alto y GL alto.
#
# 2. GL bilateral. El GL de este script es contra el mundo entero. Calculen el
#    GL de Argentina contra Brasil solamente (filtrando la base bilateral por
#    los dos países) y compárenlo con el GL contra el mundo. ¿Por qué da tan
#    distinto?
#
# 3. El RCA de importaciones. La lámina 20 menciona la variante que reemplaza
#    exportaciones por importaciones para medir desventaja comparativa
#    revelada. Impleméntenla y busquen las 10 partidas donde Argentina tiene
#    mayor desventaja. ¿Coinciden con las de menor RCA? ¿Tendrían que coincidir?
#
# 4. Sensibilidad del umbral. Rehagan el top 20 de RCA de Argentina con
#    umbrales de 1, 10 y 100 millones de USD. ¿Cuántas partidas del top 20 se
#    mantienen en los tres casos? Ese número es una medida de qué tan robusto
#    es el resultado a una decisión nuestra.
