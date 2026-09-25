# =============================================================================
# PRÁCTICA 1. Concentración: CR4, CR8 y HHI con datos de comercio mundial
# Ciencia de Datos para Economía y Negocios — FCE-UBA
#
# Práctica de la clase 12. Aplica en R los índices de concentración de la
# teórica de la clase 11 (láminas 6 a 15).
#
# Contenidos
#   0. Los datos: BACI, y por qué el código de producto necesita cuidado
#   1. Las funciones: CR_k, HHI y número equivalente
#   2. Concentración de DESTINOS: ¿a cuántos países le vende cada país?
#   3. El umbral: cómo una decisión de filtrado cambia todo el ranking
#   4. Concentración de PRODUCTOS: ¿qué tan diversificada es la canasta?
#   5. El nivel de desagregación: una propiedad, no un hallazgo
#
# Los ejercicios aparecen como comentarios "Ejercicio" a lo largo del script.
# =============================================================================


# =============================================================================
# 0. PAQUETES Y DATOS
# =============================================================================

# Si falta algún paquete, instalarlo una sola vez:
# install.packages(c("tidyverse", "fst"))

library(tidyverse)   # manipulación de datos y gráficos
library(fst)         # lectura rápida de archivos grandes comprimidos

options(scipen = 999)          # sin notación científica
theme_set(theme_minimal(base_size = 12))


# ---- 0.1 Qué es BACI --------------------------------------------------------
#
# BACI (CEPII) es la base de comercio bilateral mundial: para cada año registra
# cuánto le exportó cada país a cada otro país en cada producto. La versión que
# usamos es HS22, año 2024.
#
# Son 11,25 millones de filas. Un CSV de ese tamaño pesa cientos de MB y tarda
# en abrirse, así que la subimos al repo en formato .fst, que comprime mucho
# más y se lee en menos de un segundo. La lectura devuelve un data.frame común
# y todo lo que sigue es dplyr, como siempre.
#
# Columnas:
#   t = año
#   i = país exportador (código numérico)
#   j = país importador (código numérico)
#   k = producto a 6 dígitos del Sistema Armonizado (HS6)
#   v = valor exportado, EN MILES DE DÓLARES
#   q = cantidad en toneladas
#
# La unidad de v importa y vamos a tropezar con eso en el punto 3.

baci_path <- "datos/baci"   # cambiar si su proyecto tiene otra estructura

baci      <- read_fst(file.path(baci_path, "baci_2024.fst"))
paises    <- read_csv(file.path(baci_path, "country_codes_V202601.csv"),
                      show_col_types = FALSE)
productos <- read_csv(file.path(baci_path, "product_codes_HS22_V202601.csv"),
                      col_types = cols(code = col_character(),
                                       description = col_character()))

glimpse(baci)


# ---- 0.2 Cuidado: el código de producto es un NÚMERO, no un texto -----------
#
# Miren la clase de la columna k:

class(baci$k)

# Es integer. Pero el HS6 es un código, no una cantidad: el capítulo 08
# (frutas) tiene códigos como 080810 (manzanas), que guardados como número
# pierden el cero inicial y quedan como 80810.

head(sort(unique(baci$k)))

# Si ahora cortáramos los dos primeros caracteres para sacar el capítulo,
# "80810" daría capítulo 80 (estaño) en vez de 08 (frutas). El error es
# silencioso: no falla, da mal.
#
# La solución es rellenar con ceros a la izquierda hasta 6 dígitos:

str_pad(80810, width = 6, side = "left", pad = "0")

# Lo mismo pasa con el archivo de descripciones si se lee sin avisar el tipo.
# Por eso arriba lo leímos con col_character().
#
# Regla general: todo lo que sea un CÓDIGO (CUIT, código postal, partida
# arancelaria, código de aglomerado) se guarda como texto, nunca como número.
#
# No hacemos el str_pad sobre los 11 millones de filas: lo hacemos recién
# después de agregar, cuando la tabla es veinte veces más chica.


# ---- 0.3 Limpieza mínima ----------------------------------------------------

baci <- baci |>
  filter(!is.na(v), v > 0)

nrow(baci)


# ---- 0.4 Cuidado: el catálogo de países tiene códigos repetidos ------------
#
# Vamos a usar country_iso3 para identificar países. Antes de confiar en esa
# columna, hay que verificar que sea única. No lo es:

paises |>
  group_by(country_iso3) |>
  filter(n() > 1) |>
  arrange(country_iso3)

# Aparecen tres ISO3 con dos códigos cada uno: BEL, DEU y SDN. Son entidades
# históricas que el catálogo conserva (la República Federal Alemana anterior a
# 1990, la unión aduanera Bélgica-Luxemburgo, el Sudán previo a la separación
# de Sudán del Sur) y que comparten la sigla con el país actual.
#
# Por qué importa: una línea tan inocente como
#
#     paises |> filter(country_iso3 == "DEU") |> pull(country_code)
#
# devuelve DOS códigos en vez de uno. Si después usamos eso en un filter(),
# R no falla: recicla el vector y devuelve un resultado silenciosamente mal.
#
# La solución es quedarse solo con los códigos que efectivamente aparecen en
# los datos del año que estamos usando.

codigos_en_datos <- union(baci$i, baci$j)

paises <- paises |>
  filter(country_code %in% codigos_en_datos)

# Verificar que ahora sí es única. Si esto no da cero, hay que revisar antes
# de seguir.
paises |> count(country_iso3) |> filter(n > 1) |> nrow()

# Esto es rutina y conviene que se les haga costumbre: cada vez que van a unir
# dos tablas por una clave, primero comprueben que la clave sea única del lado
# que hace de catálogo. Es el error de merge más común y el más difícil de
# detectar después, porque no rompe nada.


# =============================================================================
# 1. LAS FUNCIONES: CR_k, HHI Y NÚMERO EQUIVALENTE
# =============================================================================
#
# Los tres índices de la teórica operan sobre lo mismo: un vector de
# participaciones que suman 1. No importa si son empresas en un mercado,
# destinos de exportación o productos de una canasta: la cuenta es la misma.
# Por eso conviene escribirlos como funciones una sola vez.

# CR_k: suma de las k participaciones más grandes.  CR_k en [0, 1]
calcular_cr <- function(shares, k = 4) {
  shares_ord <- sort(shares, decreasing = TRUE)
  sum(shares_ord[seq_len(min(k, length(shares_ord)))])
}

# HHI: suma de los cuadrados de las participaciones.  HHI en [1/N, 1]
calcular_hhi <- function(shares) {
  sum(shares^2)
}

# Número equivalente: ¿cuántos competidores de igual tamaño darían este HHI?
# Es la forma más fácil de interpretar el número (lámina 13).
n_equivalente <- function(hhi) 1 / hhi


# ---- 1.1 Probarlas con los casos de la teórica ------------------------------
#
# Antes de soltarlas sobre 11 millones de filas, verificamos que dan lo que
# sabemos que tienen que dar.

casos <- list(
  "Monopolio (1 x 100%)"       = c(1),
  "Duopolio simétrico (2x50%)" = c(0.5, 0.5),
  "Oligopolio (4 x 25%)"       = rep(0.25, 4),
  "10 iguales (10 x 10%)"      = rep(0.10, 10),
  "Competencia (100 x 1%)"     = rep(0.01, 100)
)

tibble(
  estructura = names(casos),
  cr4        = map_dbl(casos, calcular_cr, k = 4),
  hhi        = map_dbl(casos, calcular_hhi),
  n_equiv    = map_dbl(casos, function(x) n_equivalente(calcular_hhi(x)))
)

# Da exactamente la lámina 11: 1, 0.5, 0.25, 0.1, 0.01. Y el número equivalente
# devuelve 1, 2, 4, 10, 100: por construcción, cuando todos son iguales, el
# número equivalente ES la cantidad de competidores.

# Ejercicio 1.1 --------------------------------------------------------------
# La lámina 9 dice que un mercado 40-20-20-20 y otro 70-10-10-10 tienen el
# mismo CR4. Verifíquenlo con calcular_cr() y después comparen los HHI.
# ¿Cuántas "empresas equivalentes" tiene cada uno?


# =============================================================================
# 2. CONCENTRACIÓN DE DESTINOS: ¿A CUÁNTOS PAÍSES LE VENDE CADA PAÍS?
# =============================================================================
#
# Primera aplicación. Acá las "empresas" son los países de destino, y la
# "participación de mercado" es qué fracción de las exportaciones de un país se
# va a cada destino.
#
# Un país con HHI alto vende casi todo a un puñado de socios: es vulnerable a
# lo que les pase a esos socios. Uno con HHI bajo tiene la demanda repartida.

# ---- 2.1 Exportaciones por par (exportador, importador) --------------------

expo_destinos <- baci |>
  group_by(i, j) |>
  summarise(valor = sum(v), .groups = "drop") |>
  group_by(i) |>
  mutate(total_i = sum(valor),
         share   = valor / total_i) |>
  ungroup()

expo_destinos


# ---- 2.2 Los índices, país por país ----------------------------------------

conc_destinos <- expo_destinos |>
  group_by(i) |>
  summarise(
    n_destinos = n(),
    cr1        = calcular_cr(share, 1),
    cr4        = calcular_cr(share, 4),
    cr8        = calcular_cr(share, 8),
    hhi        = calcular_hhi(share),
    total_expo = first(total_i),
    .groups    = "drop"
  ) |>
  mutate(n_equiv = n_equivalente(hhi)) |>
  left_join(paises, by = c("i" = "country_code")) |>
  arrange(desc(hhi))
conc_destinos <- conc_destinos %>% 
  filter(total_expo > 1000000)
conc_destinos |>
  select(country_iso3, country_name, n_destinos, cr4, hhi, n_equiv)


# ---- 2.3 El caso argentino -------------------------------------------------

cod_arg <- paises |> filter(country_iso3 == "ARG") |> pull(country_code)

conc_destinos |>
  filter(country_iso3 == "ARG") |>
  select(country_name, n_destinos, cr1, cr4, cr8, hhi, n_equiv)

# Argentina le vende a ~150 destinos, pero el número equivalente es mucho más
# chico: la mayor parte del valor se concentra en un grupo reducido.

top_destinos_arg <- expo_destinos |>
  filter(i == cod_arg) |>
  left_join(paises, by = c("j" = "country_code")) |>
  arrange(desc(share)) |>
  slice_head(n = 15) |>
  select(country_iso3, country_name, valor, share)

top_destinos_arg

# Ejercicio 2.3 --------------------------------------------------------------
# Repitan el bloque anterior para Brasil (BRA), México (MEX) y Alemania (DEU).
# ¿Cuál depende más de un solo socio? Relacionen el CR1 con lo que saben de la
# geografía comercial de cada uno.


# =============================================================================
# 3. EL UMBRAL: CÓMO UNA DECISIÓN DE FILTRADO CAMBIA TODO EL RANKING
# =============================================================================
#
# Si ordenamos el mundo entero por HHI, arriba de todo van a aparecer países
# que exportan casi nada: con dos o tres operaciones al año el HHI da altísimo,
# pero eso no es "concentración" en ningún sentido interesante.
#
# La solución habitual es poner un piso de exportaciones. El problema es que
# ese piso es una decisión nuestra, y no es inocua.
#
# ATENCIÓN A LA UNIDAD: v está en MILES de dólares. Entonces
#   umbral =    10.000  ->     10 millones de USD
#   umbral = 1.000.000  ->  1.000 millones de USD

top_concentrados <- function(datos, umbral, n = 15) {
  datos |>
    filter(total_expo >= umbral) |>
    arrange(desc(hhi)) |>
    slice_head(n = n) |>
    mutate(expo_mill_usd = total_expo / 1000) |>
    select(country_iso3, country_name, n_destinos, hhi, n_equiv, expo_mill_usd)
}

# Con piso de 10 millones de USD:
top_concentrados(conc_destinos, umbral = 10e3)

# Con piso de 1.000 millones de USD:
top_concentrados(conc_destinos, umbral = 1e6)

# La primera lista está llena de microestados: Tuvalu, Anguila, el Territorio
# Británico del Océano Índico (que exporta 14 millones de dólares en total).
# Son ciertos, pero no dicen nada sobre concentración comercial.
#
# La segunda tiene Mongolia, Surinam, Guinea y Turkmenistán (exportadores de un
# solo mineral o hidrocarburo) y, sobre todo, MÉXICO y CANADÁ: dos economías
# grandes cuya concentración sí es un hecho económico relevante, porque le
# venden casi todo a Estados Unidos.
#
# Cuántos países sobreviven a cada piso:

tibble(umbral_miles_usd = c(10e3, 1e5, 1e6)) |>
  mutate(paises = map_int(umbral_miles_usd,
                          function(u) sum(conc_destinos$total_expo >= u)))

# El piso de 10 millones deja pasar 218 de 226 países: no filtra nada.
#
# LA LECCIÓN (lámina 42, punto 3): el índice no cambió, la fórmula no cambió.
# Cambió un número que elegimos nosotros, y con él cambió la respuesta. Por eso
# un umbral se justifica y se reporta, nunca se esconde.

umbral_expo <- 1e6   # 1.000 millones de USD (v está en miles)

# Ejercicio 3 ----------------------------------------------------------------
# a) ¿A partir de qué umbral desaparecen los microestados del top 15? Prueben
#    varios valores y busquen el punto donde el ranking se estabiliza.
# b) En vez de un piso absoluto, filtren por cantidad mínima de destinos (por
#    ejemplo n_destinos >= 50). ¿Da el mismo top 15? ¿Cuál de los dos criterios
#    les parece más defendible y por qué?


# ---- 3.1 Los dos extremos, ya con el umbral decidido -----------------------

conc_filtrado <- conc_destinos |> filter(total_expo >= umbral_expo)

mas_concentrados   <- conc_filtrado |> arrange(desc(hhi)) |> slice_head(n = 15)
mas_diversificados <- conc_filtrado |> arrange(hhi)       |> slice_head(n = 15)

grafico_extremos <- bind_rows(
  mas_concentrados   |> mutate(grupo = "Más concentrados"),
  mas_diversificados |> mutate(grupo = "Más diversificados")
) |>
  ggplot(aes(x = reorder(country_iso3, hhi), y = hhi, fill = grupo)) +
  geom_col(show.legend = FALSE) +
  coord_flip() +
  facet_wrap(~ grupo, scales = "free_y") +
  scale_fill_manual(values = c("Más concentrados"   = "tomato",
                               "Más diversificados" = "steelblue")) +
  labs(x = NULL, y = "HHI de destinos",
       title = "Concentración de los destinos de exportación",
       subtitle = paste0("BACI HS22, 2024. Países con exportaciones sobre ",
                         format(umbral_expo / 1000, big.mark = ".",
                                decimal.mark = ",", scientific = FALSE),
                         " millones de USD"),
       caption = "Fuente: elaboración propia en base a BACI, CEPII.")

grafico_extremos


# =============================================================================
# 4. CONCENTRACIÓN DE PRODUCTOS: ¿QUÉ TAN DIVERSIFICADA ES LA CANASTA?
# =============================================================================
#
# Misma fórmula, otra pregunta. Ahora las "empresas" son los productos que
# exporta un país. Es el Herfindahl de exportaciones de la lámina 31.

# ---- 4.1 Exportaciones por (exportador, producto) y niveles del HS ---------
#
# Recién acá hacemos el str_pad: sobre 565 mil filas en vez de 11 millones.
#
# El Sistema Armonizado es jerárquico. El código 080810 se lee así:
#   08      capítulo   -> frutas y frutos comestibles
#   0808    partida    -> manzanas, peras y membrillos
#   080810  subpartida -> manzanas
# Cortar los primeros 2 o 4 caracteres es, literalmente, subir un nivel.

expo_productos <- baci |>
  group_by(i, k) |>
  summarise(valor = sum(v), .groups = "drop") |>
  mutate(
    hs6 = str_pad(k, width = 6, side = "left", pad = "0"),
    hs4 = str_sub(hs6, 1, 4),
    hs2 = str_sub(hs6, 1, 2)
  )

expo_productos |> select(i, hs2, hs4, hs6, valor)


# ---- 4.2 Una función para no escribir tres veces lo mismo ------------------
#
# Vamos a calcular los mismos índices a tres niveles de agregación. En vez de
# copiar y pegar el bloque tres veces (que es como se cuelan los errores),
# escribimos una función que toma el nivel como argumento.

concentracion_por_nivel <- function(datos, nivel) {
  datos |>
    group_by(i, producto = .data[[nivel]]) |>
    summarise(valor = sum(valor), .groups = "drop") |>
    group_by(i) |>
    mutate(total_i = sum(valor),
           share   = valor / total_i) |>
    summarise(
      n_productos = n(),
      cr4         = calcular_cr(share, 4),
      cr8         = calcular_cr(share, 8),
      hhi         = calcular_hhi(share),
      total_expo  = first(total_i),
      .groups     = "drop"
    ) |>
    mutate(nivel = nivel)
}

conc_productos <- bind_rows(
  concentracion_por_nivel(expo_productos, "hs2"),
  concentracion_por_nivel(expo_productos, "hs4"),
  concentracion_por_nivel(expo_productos, "hs6")
) |>
  left_join(paises, by = c("i" = "country_code"))

# Ojo con los nombres: a HS2 son capítulos, a HS4 partidas y a HS6 subpartidas.
# Por eso la columna se llama n_productos y no n_capitulos.

conc_productos |>
  filter(country_iso3 == "ARG") |>
  select(nivel, n_productos, cr4, cr8, hhi)


# =============================================================================
# 5. EL NIVEL DE DESAGREGACIÓN: UNA PROPIEDAD, NO UN HALLAZGO
# =============================================================================
#
# Miren la tabla de arriba: el HHI baja al pasar de HS2 a HS4 y de HS4 a HS6.
#
# ANTES DE SEGUIR, PENSAR: ¿es un resultado empírico sobre Argentina, o tenía
# que pasar sí o sí?
#
# Tenía que pasar. Agregar productos es sumar participaciones, y el cuadrado de
# una suma es siempre mayor o igual que la suma de los cuadrados:
#
#     (a + b)^2 = a^2 + b^2 + 2ab  >=  a^2 + b^2        (con a, b >= 0)
#
# Cada vez que juntamos dos subpartidas en una partida, el HHI sube o queda
# igual. Nunca baja. Entonces HHI(HS2) >= HHI(HS4) >= HHI(HS6) para TODOS los
# países, siempre, en cualquier año y con cualquier dato.
#
# Esto no es un detalle. Quiere decir que la frase "el país X tiene un HHI de
# exportaciones de 0,25" no significa nada si no se aclara a qué nivel se
# calculó, y que comparar el HHI de un estudio hecho a HS2 con otro hecho a HS6
# es comparar cualquier cosa.

# ---- 5.1 Verificarlo sobre los 226 países ----------------------------------

verificacion <- conc_productos |>
  select(i, nivel, hhi) |>
  pivot_wider(names_from = nivel, values_from = hhi) |>
  mutate(cumple = hs2 >= hs4 & hs4 >= hs6)

table(verificacion$cumple)

# TRUE para todos. No hay excepciones porque no puede haberlas.


# ---- 5.2 Mostrarlo ---------------------------------------------------------

seleccion <- c("ARG", "BRA", "CHL", "MEX", "VEN", "DEU", "USA", "CHN",
               "KOR", "JPN", "AUS", "ZAF", "NGA", "SAU")

datos_grafico <- conc_productos |>
  filter(country_iso3 %in% seleccion, total_expo >= umbral_expo) |>
  mutate(nivel = factor(nivel,
                        levels = c("hs2", "hs4", "hs6"),
                        labels = c("HS2 (capítulos)",
                                   "HS4 (partidas)",
                                   "HS6 (subpartidas)")))

grafico_niveles <- datos_grafico |>
  ggplot(aes(x = reorder(country_iso3, hhi), y = hhi, fill = nivel)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.7) +
  coord_flip() +
  scale_fill_brewer(palette = "Blues") +
  labs(x = NULL, y = "HHI de la canasta exportadora",
       fill = "Nivel de desagregación",
       title = "La concentración depende de cómo se agrupen los productos",
       subtitle = "El HHI baja al desagregar más fino. No es un hallazgo: es aritmética.",
       caption = "Fuente: elaboración propia en base a BACI HS22, CEPII (2024).") +
  theme(legend.position = "bottom")

grafico_niveles

# Ejercicio 5.2 --------------------------------------------------------------
# a) Venezuela, Nigeria y Arabia Saudita son economías petroleras. ¿Cuánto les
#    baja el HHI entre HS2 y HS6? ¿Y a Alemania? ¿Por qué la caída es tan
#    distinta? (Pista: pensar cuántas subpartidas tiene el capítulo 27 frente a
#    cuántas tiene el 87.)
# b) Calculen, para cada país, el cociente hhi_hs6 / hhi_hs2. ¿Qué mide ese
#    número? ¿Serviría como índice por sí mismo?


# =============================================================================
# EJERCICIOS INTEGRADORES
# =============================================================================
#
# 1. Concentración de ORIGEN de las importaciones. Todo el script miró de quién
#    depende un país para VENDER. Rehagan el punto 2 agrupando por j en lugar
#    de por i para responder de quién depende para COMPRAR. ¿Argentina está más
#    concentrada como vendedora o como compradora?
#
# 2. Los dos ejes a la vez. Hagan un scatter con el HHI de destinos en un eje y
#    el HHI de productos (a HS4) en el otro, para los países sobre el umbral.
#    ¿Hay relación? Interpreten los cuatro cuadrantes: ¿qué significa estar
#    concentrado en destinos pero diversificado en productos? ¿Se les ocurre un
#    país así?
#
# 3. El HHI en escala regulatoria. La lámina 10 menciona que el DOJ usa el HHI
#    multiplicado por 10.000, con cortes en 1.500 y 2.500. Reescriban la
#    función para que devuelva esa escala y clasifiquen a los países en "no
#    concentrado", "moderado" y "altamente concentrado" según sus destinos.
#    ¿Tiene sentido aplicar un criterio pensado para fusiones de empresas a la
#    geografía del comercio? Justifiquen.
