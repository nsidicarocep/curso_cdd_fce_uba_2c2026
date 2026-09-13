# =============================================================================
# PRÁCTICA. Tests de hipótesis en R: dos grupos, ANOVA, Tukey y chi-cuadrado
# Ciencia de Datos para Economía y Negocios — FCE-UBA
#
# Práctica de la clase 10. Aplica en R los tests vistos en la teórica de la
# clase 9.
#
# Contenidos
#   1. Dos grupos independientes: t-test y Mann-Whitney (EPH)
#   2. Opcional: el mismo test con ponderadores (paquete survey)
#   3. Test pareado: ¿cambió la esperanza de vida en diez años? (WDI)
#   4. ANOVA: ¿difiere el PBI per cápita entre regiones? (WDI)
#   5. Después del ANOVA: ¿qué pares de regiones difieren?
#   6. Chi-cuadrado de independencia (EPH y WDI)
#
# Cómo leer cada test, siempre en el mismo orden
#   1. Escribir H0 y H1.
#   2. Mirar los descriptivos y un gráfico.
#   3. Correr el test.
#   4. Leer el p-valor: si es menor a 0,05, rechazamos H0 al 5%.
#   5. Mirar el tamaño del efecto: significativo no quiere decir grande.
#
# Los ejercicios aparecen como comentarios "Ejercicio" a lo largo del script.
# =============================================================================


# =============================================================================
# 0. PAQUETES Y DATOS
# =============================================================================

# Si falta algún paquete, instalarlo una sola vez:
# install.packages(c("tidyverse", "eph", "WDI", "survey", "rstatix"))

library(tidyverse)   # manipulación de datos y gráficos
library(eph)         # descarga de la EPH-INDEC
library(WDI)         # descarga de indicadores del Banco Mundial
library(survey)      # estadísticas con ponderadores
library(rstatix)     # test de Games-Howell (punto 5)

# R a veces muestra los números en notación científica (2.2e-16). Con esta
# opción los muestra completos.
options(scipen = 999)

theme_set(theme_minimal(base_size = 12))


# --- 0.1. EPH ----------------------------------------------------------------

# Descarga de la base de personas del primer trimestre de 2026.
# Necesita internet y puede tardar un minuto. Una vez descargada, conviene
# guardarla en la carpeta del proyecto y leerla desde ahí las veces siguientes:
#   write_rds(eph_raw, "eph_individual_1t2026.rds")   # guardar (una vez)
#   eph_raw <- read_rds("eph_individual_1t2026.rds")  # leer

eph_raw <- get_microdata(year = 2026, period = 1, type = "individual")

# Nos quedamos con asalariados de 18 a 65 años con ingreso y horas válidas.
# Variables de la EPH que usamos (ver el diseño de registro del INDEC):
#   ESTADO      condición de actividad. 1 = ocupado
#   CAT_OCUP    categoría ocupacional. 3 = asalariado
#   P21         ingreso mensual de la ocupación principal. -9 = no respondió
#   PP3E_TOT    horas semanales en la ocupación principal. 999 = no respondió
#   CH04        sexo. 1 = varón, 2 = mujer
#   CH06        edad en años
#   PONDIIO     ponderador para el ingreso de la ocupación principal
#
# El tope de 84 horas semanales (12 por día, 7 días) descarta valores que
# probablemente sean errores de carga.

base <- eph_raw %>%
  filter(
    ESTADO == 1,
    CAT_OCUP == 3,
    P21 > 0,                        # también descarta el -9
    PP3E_TOT > 0, PP3E_TOT <= 84,   # también descarta el 999
    CH06 >= 18, CH06 <= 65,
    CH04 %in% c(1, 2)
  ) %>%
  mutate(
    sexo        = factor(CH04, levels = c(1, 2), labels = c("Varón", "Mujer")),
    ing_mensual = P21,
    # Un mes tiene en promedio 4,33 semanas (52 semanas / 12 meses)
    ing_horario = P21 / (PP3E_TOT * 4.33),
    log_horario = log(ing_horario)
  )

# Cuántos asalariados quedaron de cada sexo
base %>% count(sexo)


# --- 0.2. WDI (Banco Mundial) ------------------------------------------------

# Dos indicadores para todos los países, de 2013 a 2023:
#   SP.DYN.LE00.IN   esperanza de vida al nacer, en años
#   NY.GDP.PCAP.KD   PBI per cápita en dólares constantes de 2015
#
# Con c(esp_vida = "SP.DYN.LE00.IN") le ponemos un nombre legible a la columna.
# extra = TRUE agrega columnas útiles, entre ellas la región (region) y el
# grupo de ingreso (income). El grupo de ingreso es la clasificación ACTUAL
# del Banco Mundial, no la de cada año.

wdi_raw <- WDI(
  country   = "all",
  indicator = c(esp_vida = "SP.DYN.LE00.IN",
                pbi_pc   = "NY.GDP.PCAP.KD"),
  start = 2013, end = 2023,
  extra = TRUE
)
# write_rds(wdi_raw, "wdi_clase10.rds")   # guardar una copia local

# La base trae, además de países, agregados como "World" o "Latin America &
# Caribbean". Esos agregados tienen region == "Aggregates" y los sacamos para
# quedarnos solo con países.
wdi_paises <- wdi_raw %>%
  filter(region != "Aggregates")


# =============================================================================
# 1. DOS GRUPOS INDEPENDIENTES: t-test y Mann-Whitney
# =============================================================================

# Pregunta: ¿el ingreso de los asalariados difiere entre varones y mujeres?
#
# Son dos grupos de personas distintas, así que las muestras son independientes.
#
# t-test (Welch)   compara MEDIAS
#   H0: mu_varones = mu_mujeres
#   H1: mu_varones != mu_mujeres
#
# Mann-Whitney     compara RANGOS (el orden de los datos, no sus valores)
#   H0: P(varón > mujer) = 0,5   (ningún grupo tiende a ganar más)
#   H1: P(varón > mujer) != 0,5
#
# t.test() usa por defecto la versión de Welch, que no supone que los dos
# grupos tengan la misma varianza. Los ingresos son muy asimétricos, pero con
# muestras grandes el Teorema Central del Límite hace que el t-test siga
# siendo válido para comparar medias.

# --- 1.1. Descriptivos --------------------------------------------------------

base %>%
  group_by(sexo) %>%
  summarise(
    n               = n(),
    media_mensual   = mean(ing_mensual),
    mediana_mensual = median(ing_mensual),
    media_horario   = mean(ing_horario),
    mediana_horario = median(ing_horario),
    horas_semanales = mean(PP3E_TOT)
  )

# Boxplot en escala logarítmica: sin el log, unos pocos ingresos muy altos
# aplastan el gráfico y no se ve la diferencia entre las cajas.
ggplot(base, aes(x = sexo, y = ing_horario)) +
  geom_boxplot(outlier.alpha = 0.2) +
  scale_y_log10(labels = scales::label_number(big.mark = ".", decimal.mark = ",")) +
  labs(title = "Ingreso horario de asalariados por sexo",
       subtitle = "Escala logarítmica", x = NULL, y = "Pesos por hora")


# --- 1.2. Ingreso mensual ----------------------------------------------------

# La fórmula ing_mensual ~ sexo se lee "ing_mensual según sexo".
t_mensual <- t.test(ing_mensual ~ sexo, data = base)
t_mensual

# Cómo leer la salida
#   t, df                  estadístico de prueba y grados de libertad
#   p-value                si H0 fuera cierta, probabilidad de observar una
#                          diferencia al menos tan grande como esta.
#                          "< 0.00000000000000022" es el mínimo que R muestra:
#                          el p-valor es prácticamente cero.
#   95 percent confidence  IC 95% de la diferencia de medias. La resta es en el
#   interval               orden de los niveles del factor: Varón − Mujer.
#                          Si el intervalo no contiene el 0, rechazamos H0.
#   sample estimates       media de cada grupo


# --- 1.3. Ingreso horario ----------------------------------------------------

t_horario <- t.test(ing_horario ~ sexo, data = base)
t_horario

# Ejercicio 1.a
# Comparen la brecha en ingreso mensual con la brecha en ingreso horario.
# Las dos usan el mismo ingreso (P21): lo único que cambia es que el horario
# divide por las horas trabajadas. ¿Cuánto de la brecha mensual se explica
# porque varones y mujeres trabajan distinta cantidad de horas?


# --- 1.4. Mann-Whitney --------------------------------------------------------

mw_horario <- wilcox.test(ing_horario ~ sexo, data = base)
mw_horario

# Cómo leer la salida
#   W          estadístico: entre todos los pares posibles (un varón y una
#              mujer), cuántas veces gana el varón
#   p-value    igual que en el t-test
#   La línea "true location shift is not equal to 0" es la forma en que R
#   escribe H1. La leemos como "un grupo tiende a tener valores más altos".

# Tamaño del efecto: dividir W por la cantidad total de pares da la
# probabilidad de que un varón tomado al azar gane más por hora que una mujer
# tomada al azar. 0,5 significa que no hay diferencia.
n_varones <- sum(base$sexo == "Varón")
n_mujeres <- sum(base$sexo == "Mujer")
unname(mw_horario$statistic) / (n_varones * n_mujeres)

# Mann-Whitney solo usa el orden de los datos. Tomar logaritmos no cambia el
# orden, así que el p-valor es el mismo con o sin log (la mínima diferencia
# viene del redondeo en los empates):
wilcox.test(log_horario ~ sexo, data = base)$p.value
mw_horario$p.value

# Ejercicio 1.b
# ¿Qué pregunta responde cada test? ¿Podrían dar conclusiones distintas con
# los mismos datos? Piensen en un caso con un outlier muy grande.


# =============================================================================
# 2. OPCIONAL: EL MISMO TEST CON PONDERADORES
# =============================================================================

# La EPH no es una muestra donde todas las personas pesan igual: cada persona
# representa a una cantidad distinta de personas de la población. Ese peso es
# el ponderador. Para ingresos, el INDEC publica ponderadores propios que
# además corrigen por las personas que no declaran ingresos:
#   PONDIIO   para el ingreso de la ocupación principal (P21)
#   PONDII    para el ingreso total individual (P47T)
#   PONDERA   para las variables que no son de ingreso
#
# svydesign() crea un "diseño" que guarda los datos junto con sus pesos.
#   ids = ~1            no indicamos conglomerados
#   weights = ~PONDIIO  columna del ponderador
# Es una versión simplificada del diseño de la EPH: solo tiene en cuenta los
# pesos, no los estratos ni los conglomerados de la muestra.

dis_eph <- svydesign(ids = ~1, weights = ~PONDIIO,
                     data = base %>% filter(PONDIIO > 0))

# Medias ponderadas de cada grupo, con su error estándar (se)
svyby(~ing_horario, ~sexo, design = dis_eph, FUN = svymean)

# t-test ponderado
svyttest(ing_horario ~ sexo, design = dis_eph)

# Atención: svyttest() resta en el orden contrario a t.test(). La diferencia
# es Mujer − Varón, así que un valor negativo significa que las mujeres ganan
# MENOS. Compárenlo con las medias de svyby() para confirmarlo.

# Ejercicio 2
# Comparen las medias, el IC y el p-valor con la versión sin ponderar del
# punto 1.3. ¿Cambia la dirección de la diferencia? ¿Cambia la conclusión?


# =============================================================================
# 3. TEST PAREADO: ¿CAMBIÓ LA ESPERANZA DE VIDA EN DIEZ AÑOS?
# =============================================================================

# Comparamos la esperanza de vida de cada país en 2013 y en 2023.
#
# Acá las muestras NO son independientes: cada país aparece dos veces y sus
# dos valores están relacionados (Japón en 2013 y Japón en 2023 se parecen
# mucho más entre sí que a Chad). Por eso usamos un test PAREADO: se calcula
# la diferencia de cada país y se testea si esas diferencias promedian 0.
#
# H0: la media de las diferencias (2023 − 2013) es 0
# H1: la media de las diferencias es distinta de 0

# Para el test pareado necesitamos formato ANCHO: una fila por país, una
# columna por año. pivot_wider() crea las columnas ev_2013 y ev_2023.
esp_vida <- wdi_paises %>%
  filter(year %in% c(2013, 2023), !is.na(esp_vida)) %>%
  select(iso3c, country, region, year, esp_vida) %>%
  pivot_wider(names_from = year, values_from = esp_vida,
              names_prefix = "ev_") %>%
  filter(!is.na(ev_2013), !is.na(ev_2023)) %>%   # países con los dos años
  mutate(dif = ev_2023 - ev_2013)

# Descriptivos de las diferencias: sobre ellas corre el test
esp_vida %>%
  summarise(n = n(), media_dif = mean(dif), mediana_dif = median(dif),
            sd_dif = sd(dif), min_dif = min(dif), max_dif = max(dif))

# Histograma de las diferencias. La línea punteada marca el 0 (sin cambio):
# ¿la mayoría de los países está a la derecha o a la izquierda?
ggplot(esp_vida, aes(x = dif)) +
  geom_histogram(bins = 30) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  labs(title = "Cambio en la esperanza de vida 2013-2023",
       x = "Años (2023 − 2013)", y = "Cantidad de países")

# Dos formas equivalentes de hacer el mismo test
t.test(esp_vida$ev_2023, esp_vida$ev_2013, paired = TRUE)
t.test(esp_vida$dif, mu = 0)   # t de una muestra sobre las diferencias

# En la salida, "mean difference" es el cambio promedio en años y el IC 95%
# es el intervalo para ese cambio promedio.

# Versión no paramétrica: test de Wilcoxon de rangos con signo.
# Útil si las diferencias tienen outliers o una distribución muy asimétrica.
wilcox.test(esp_vida$ev_2023, esp_vida$ev_2013, paired = TRUE)

# Ejercicio 3
# Corran t.test() con los mismos dos vectores pero SIN paired = TRUE, como si
# fueran dos grupos de países distintos. Comparen el p-valor. ¿Por qué cambia
# tanto? Pista: ¿cuánto varía la esperanza de vida ENTRE países y cuánto
# varía DENTRO de cada país en diez años?


# =============================================================================
# 4. ANOVA: ¿DIFIERE EL PBI PER CÁPITA ENTRE REGIONES?
# =============================================================================

# Con más de dos grupos no hacemos muchos t-tests de a pares: cada uno tiene
# 5% de falso positivo y, al sumar tests, la probabilidad de encontrar alguna
# diferencia falsa crece rápido. Primero hacemos UN test global: el ANOVA.
#
# H0: mu_1 = mu_2 = ... = mu_k   (todas las regiones tienen la misma media)
# H1: al menos una región tiene una media distinta
#
# Dos cosas que el ANOVA NO dice
#   - Entre cuáles regiones está la diferencia (eso lo vemos en el punto 5).
#   - Que la región CAUSE el nivel de ingreso: solo que las regiones difieren.

df_anova <- wdi_paises %>%
  filter(year == 2023, !is.na(pbi_pc), !is.na(region)) %>%
  select(iso3c, country, region, pbi_pc) %>%
  mutate(region  = factor(region),
         log_pbi = log(pbi_pc))


# --- 4.1. Descriptivos --------------------------------------------------------

df_anova %>%
  group_by(region) %>%
  summarise(n       = n(),
            media   = mean(pbi_pc),
            mediana = median(pbi_pc),
            sd      = sd(pbi_pc),
            sd_log  = sd(log_pbi)) %>%
  arrange(desc(media))

# Qué mirar en esta tabla
#   - sd: el desvío en dólares cambia muchísimo de una región a otra. El ANOVA
#     clásico supone varianzas parecidas entre grupos, así que en dólares ese
#     supuesto no se cumple.
#   - sd_log: en logaritmos los desvíos quedan mucho más parejos.
#   - n: North America tiene muy pocos países, así que todo lo que digamos de
#     esa región va a tener mucha incertidumbre.

# Boxplot por región con cada país como un punto
#   reorder()       ordena las regiones por su mediana
#   geom_jitter()   dibuja los países separándolos un poco para que no se pisen
#   coord_flip()    pone las regiones en el eje vertical para que se lean
ggplot(df_anova, aes(x = reorder(region, pbi_pc, FUN = median), y = pbi_pc)) +
  geom_boxplot(outlier.shape = NA) +
  geom_jitter(width = 0.15, alpha = 0.4) +
  scale_y_log10(labels = scales::label_dollar()) +
  coord_flip() +
  labs(title = "PBI per cápita 2023 por región", subtitle = "Escala logarítmica",
       x = NULL, y = "USD constantes de 2015")


# --- 4.2. ANOVA en dólares y en logaritmos ----------------------------------

# aov() ajusta el ANOVA y summary() muestra la tabla
anova_niveles <- aov(pbi_pc ~ region, data = df_anova)
summary(anova_niveles)

anova_log <- aov(log_pbi ~ region, data = df_anova)
summary(anova_log)

# Cómo leer la tabla
#   Df        grados de libertad. Fila region: k − 1 (grupos menos uno).
#             Fila Residuals: N − k (países menos grupos).
#   Sum Sq    suma de cuadrados. region = variabilidad ENTRE regiones.
#             Residuals = variabilidad DENTRO de cada región.
#   Mean Sq   cuadrado medio = Sum Sq / Df
#   F value   Mean Sq de region / Mean Sq de Residuals. Si H0 es cierta, ronda
#             1; cuanto más grande, más separadas están las medias respecto
#             del ruido dentro de cada región.
#   Pr(>F)    p-valor
#
# Con logaritmos, la conclusión es sobre medias GEOMÉTRICAS del PBI per
# cápita, que se parecen más a un "país típico" de cada región.

# Tamaño del efecto: eta cuadrado = SC entre / SC total, es decir, qué
# proporción de la variabilidad entre países se explica por la región.
# summary() devuelve una lista; con [[1]] tomamos la tabla que contiene.
tabla_log <- summary(anova_log)[[1]]
tabla_log$`Sum Sq`[1] / sum(tabla_log$`Sum Sq`)


# --- 4.3. Supuestos ------------------------------------------------------------

# Supuesto 1: independencia. Cada país aparece una sola vez. No hay un test
# que lo verifique: se piensa a partir de cómo se armaron los datos.

# Supuesto 2: normalidad de los residuos. El residuo de cada país es la
# distancia a la media de su región. En un QQ-plot, si los residuos son
# normales, los puntos caen sobre la recta.
# par(mfrow = c(1, 2)) divide la ventana de gráficos en 1 fila y 2 columnas,
# y la última línea la vuelve a dejar como estaba.
par(mfrow = c(1, 2))
qqnorm(residuals(anova_niveles), main = "Residuos, PBI en dólares")
qqline(residuals(anova_niveles))
qqnorm(residuals(anova_log), main = "Residuos, log del PBI")
qqline(residuals(anova_log))
par(mfrow = c(1, 1))

# Supuesto 3: varianzas parecidas. Una regla práctica es dividir el desvío
# más grande por el más chico: si el resultado supera 2, conviene usar Welch.
df_anova %>%
  group_by(region) %>%
  summarise(sd_log = sd(log_pbi)) %>%
  summarise(cociente = max(sd_log) / min(sd_log))


# --- 4.4. Si los supuestos fallan ---------------------------------------------

# ANOVA de Welch: sigue comparando medias, pero no supone varianzas iguales.
# En la salida, "denom df" suele tener decimales: es el ajuste de Welch.
oneway.test(log_pbi ~ region, data = df_anova)

# Kruskal-Wallis: la versión no paramétrica. Compara rangos, así que responde
# si alguna región tiende a tener valores más altos, no si las medias son
# iguales. Como los rangos no cambian con el logaritmo, lo corremos en dólares.
# R llama "Kruskal-Wallis chi-squared" al estadístico H.
kw <- kruskal.test(pbi_pc ~ region, data = df_anova)
kw

# Tamaño del efecto: epsilon cuadrado = H / (N − 1). Se lee parecido al eta
# cuadrado del ANOVA.
unname(kw$statistic) / (nrow(df_anova) - 1)

# Ejercicio 4
# ¿Cambia la conclusión entre ANOVA, Welch y Kruskal-Wallis? ¿Qué pregunta
# responde cada uno? La elección del test se hace mirando los datos y la
# pregunta ANTES de ver los p-valores: probar varios y quedarse con el que
# "da" no es válido.


# =============================================================================
# 5. DESPUÉS DEL ANOVA: ¿QUÉ PARES DE REGIONES DIFIEREN?
# =============================================================================

# Con 7 regiones hay 21 pares posibles. Si hiciéramos 21 t-tests al 5%, la
# probabilidad de encontrar al menos una diferencia falsa sería mucho mayor
# que 5%. El test de Tukey ajusta las comparaciones para que el 5% valga para
# el conjunto de los 21 pares.

tukey <- TukeyHSD(anova_log)
tukey

# Cómo leer cada fila
#   Nombre     "Europe & Central Asia-East Asia & Pacific" significa la media
#              de la primera región MENOS la de la segunda.
#   diff       diferencia de medias (acá, en logaritmos)
#   lwr, upr   límites del IC 95% simultáneo
#   p adj      p-valor ajustado por comparaciones múltiples
# Si el intervalo NO contiene el 0 (o p adj < 0,05), ese par difiere.

# Las diferencias en logaritmos son difíciles de leer. exp(diff) − 1 las
# convierte en diferencias porcentuales entre medias geométricas: un diff de
# 0,69 equivale a que la primera región tiene un PBI per cápita típico un
# 100% más alto (el doble) que la segunda.
#   as_tibble(..., rownames = "par")   pasa la tabla a tibble y guarda el
#                                      nombre de cada par en la columna "par"
#   across(c(diff, lwr, upr), ...)     aplica la misma cuenta a las 3 columnas
#   print(n = Inf, width = Inf)        muestra todas las filas sin cortar los
#                                      nombres de los pares
as_tibble(tukey$region, rownames = "par") %>%
  mutate(across(c(diff, lwr, upr), ~ 100 * (exp(.x) - 1)),
         significativo = `p adj` < 0.05) %>%
  arrange(desc(diff)) %>%
  print(n = Inf, width = Inf)

# Gráfico de los 21 intervalos. Los que no cruzan la línea del 0 son pares
# que difieren. par(mar = ...) agranda el margen izquierdo para que entren los
# nombres de los pares; la última línea vuelve a los márgenes normales.
par(mar = c(4, 16, 2, 1))
plot(tukey, las = 1, cex.axis = 0.6)
par(mar = c(5, 4, 4, 2) + 0.1)

# Para comparar: los mismos 21 pares con t-tests SIN corregir. La salida es
# una tabla de p-valores: cada celda es el par formado por su fila y su columna.
pairwise.t.test(df_anova$log_pbi, df_anova$region, p.adjust.method = "none")

# Tukey supone varianzas parecidas. Si no se cumple (el cociente de desvíos
# del punto 4.3 superaba 2), la alternativa es Games-Howell. Seleccionamos
# columnas para que los nombres de las regiones no se corten al imprimir.
#   estimate             diferencia de medias (group2 − group1)
#   conf.low, conf.high  IC 95%
#   p.adj                p-valor ajustado
games_howell_test(df_anova, log_pbi ~ region) %>%
  select(group1, group2, estimate, conf.low, conf.high, p.adj) %>%
  print(n = Inf, width = Inf)

# Ejercicio 5
# ¿Cuántos pares son significativos con Tukey y cuántos con los t-tests sin
# corregir? ¿Qué pares cambian de conclusión? ¿Qué pasa con los intervalos
# de North America y por qué?


# =============================================================================
# 6. CHI-CUADRADO DE INDEPENDENCIA
# =============================================================================

# Hasta acá comparamos una variable NUMÉRICA entre grupos. El chi-cuadrado
# responde otra pregunta: si dos variables CATEGÓRICAS están asociadas.
#
# La idea: armar la tabla de conteos observados y compararla con la tabla que
# esperaríamos si las variables fueran independientes.
#
#   Chi² = suma de (observado − esperado)² / esperado
#
# Cuanto más se alejan los observados de los esperados, más grande es Chi².
#
# Condiciones para usarlo
#   - Cada persona (o país) cuenta en una sola celda.
#   - La tabla tiene conteos, nunca porcentajes.
#   - Los esperados no son muy chicos: todos >= 1 y al menos el 80% >= 5.

# Tamaño del efecto: V de Cramér, entre 0 (independencia) y 1 (asociación
# perfecta). A diferencia de Chi², no crece con el tamaño de la muestra.
#   V = raíz(Chi² / (n × (mínimo entre filas y columnas − 1)))
# Escribimos una función para no repetir la cuenta. Recibe el resultado de
# chisq.test(), que guarda la tabla original en $observed.
#   dim(tabla) devuelve la cantidad de filas y de columnas
v_cramer <- function(prueba) {
  tabla <- prueba$observed
  sqrt(unname(prueba$statistic) / (sum(tabla) * (min(dim(tabla)) - 1)))
}


# --- 6.1. EPH: sexo y nivel educativo de los asalariados -------------------

# H0: sexo y nivel educativo son independientes (varones y mujeres tienen la
#     misma distribución de niveles educativos)
# H1: están asociados
#
# Códigos de NIVEL_ED en la EPH
#   7 = Sin instrucción
#   1 = Primario incompleto (incluye educación especial)
#   2 = Primario completo
#   3 = Secundario incompleto
#   4 = Secundario completo
#   5 = Superior universitario incompleto
#   6 = Superior universitario completo
#   9 = No sabe / no responde (lo sacamos)
#
# En factor(), levels = c(7, 1:6) ordena las categorías de menor a mayor
# nivel: "Sin instrucción" va primero aunque su código sea 7.

base_chi <- base %>%
  filter(NIVEL_ED %in% c(7, 1:6)) %>%
  mutate(nivel_ed = factor(NIVEL_ED, levels = c(7, 1:6),
                           labels = c("Sin instr.", "Prim. inc.", "Prim. comp.",
                                      "Sec. inc.", "Sec. comp.",
                                      "Sup. inc.", "Sup. comp.")))

# Tabla de contingencia: filas = sexo, columnas = nivel educativo.
# addmargins() agrega los totales de cada fila y columna.
tabla <- table(base_chi$sexo, base_chi$nivel_ed)
addmargins(tabla)

# Perfiles por fila: qué porcentaje de varones y de mujeres hay en cada nivel.
# margin = 1 calcula los porcentajes dentro de cada fila.
# Si las variables fueran independientes, las dos filas serían iguales.
prop.table(tabla, margin = 1) %>% round(3)

prueba_chi <- chisq.test(tabla)
prueba_chi

# Cómo leer la salida
#   X-squared   estadístico Chi²
#   df          grados de libertad = (filas − 1) × (columnas − 1) = 1 × 6 = 6
#   p-value     igual que en los otros tests

# Esperados bajo independencia. Revisamos que ninguno sea muy chico: si lo
# fuera, la aproximación del p-valor no sería confiable.
prueba_chi$expected %>% round(1)

# ¿Dónde está la asociación? El test dice SI hay asociación; los residuos
# estandarizados dicen en qué celdas.
#   residuo > 0      hay MÁS casos que los esperados bajo independencia
#   residuo < 0      hay MENOS casos que los esperados
#   |residuo| > 2    esa celda se aparta claramente de H0
# Usamos $stdres. chisq.test() también guarda $residuals (residuos de
# Pearson), que dan valores más chicos y no se leen con la regla del 2.
prueba_chi$stdres %>% round(2)

v_cramer(prueba_chi)

# Ejercicio 6.a
# Con miles de asalariados, el p-valor sale diminuto. ¿La asociación es fuerte
# o débil según la V de Cramér? ¿En qué niveles educativos hay más varones que
# los esperados y en cuáles más mujeres?


# --- 6.2. WDI: región y grupo de ingreso de los países ---------------------

# H0: región y grupo de ingreso son independientes
# H1: están asociados

# Un país aparece una vez por año en la base: filtramos un solo año para
# contar cada país una vez. Sacamos los países sin clasificación de ingreso y
# ordenamos los grupos de menor a mayor ingreso.
df_chi_wdi <- wdi_paises %>%
  filter(year == 2023, !is.na(region), income != "Not classified") %>%
  mutate(income = factor(income, levels = c("Low income", "Lower middle income",
                                            "Upper middle income", "High income")))

tabla_wdi <- table(df_chi_wdi$region, df_chi_wdi$income)
addmargins(tabla_wdi)

# Unos 200 países repartidos en 28 celdas: muchos esperados quedan por debajo
# de 5. R lo avisa con "Chi-squared approximation may be incorrect".
chisq.test(tabla_wdi)$expected %>% round(1)

# Primera salida: calcular el p-valor por simulación. R arma B = 5000 tablas
# al azar con los mismos totales de filas y columnas y cuenta en qué
# proporción el Chi² supera al observado. No depende de que los esperados
# sean grandes.
# set.seed() fija el punto de partida del azar para que todos obtengamos el
# mismo p-valor al correr el código.
set.seed(123)
prueba_wdi <- chisq.test(tabla_wdi, simulate.p.value = TRUE, B = 5000)
prueba_wdi

prueba_wdi$stdres %>% round(2)
v_cramer(prueba_wdi)

# Segunda salida: agrupar categorías para que los esperados sean más grandes.
# fct_collapse() junta niveles de un factor bajo un nombre nuevo.
# with(datos, table(a, b)) permite usar las columnas sin escribir datos$a.
tabla_wdi_2 <- df_chi_wdi %>%
  mutate(ingreso_2 = fct_collapse(income,
                                  "Bajo o medio-bajo" = c("Low income", "Lower middle income"),
                                  "Medio-alto o alto" = c("Upper middle income", "High income"))) %>%
  with(table(region, ingreso_2))
tabla_wdi_2

# Si R vuelve a mostrar el aviso "Chi-squared approximation may be incorrect",
# todavía quedan esperados chicos.
chisq.test(tabla_wdi_2)$expected %>% round(1)

# Ejercicio 6.b
# ¿Qué combinaciones de región e ingreso tienen los residuos más grandes?
# Después de agrupar los ingresos, ¿todos los esperados son grandes? Si no,
# ¿qué regiones habría que agrupar?
