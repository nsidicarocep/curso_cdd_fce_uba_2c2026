# ==============================================================================
# Clase 16 - Practica 3: Cluster jerarquico y HCPC
# Ciencia de Datos para Economia y Negocios - FCE-UBA
#
# QUE ES ESTE SCRIPT
# Agrupar paises con cluster jerarquico, en dos etapas:
#   (A) "a mano": estandarizar, distancias, hclust(), dendrograma, corte,
#       caracterizacion. Para entender cada decision.
#   (B) con HCPC() de FactoMineR: PCA -> Ward sobre los componentes ->
#       consolidacion con k-means -> descripcion automatica de los grupos.
#       Es el flujo que conviene usar en el trabajo final.
# Al final, HCPC sobre un MCA (ocupados de la EPH): el mismo flujo con
# variables categoricas.
#
# Cada paso esta comentado en tres niveles:
#   QUE HACE    -> que calcula el bloque
#   COMO SE LEE -> que hay que mirar en el resultado
#   EN TU TP    -> como adaptarlo a la base del trabajo final
#
# Conviene haber hecho antes los scripts 01 (PCA) y 02 (MCA).
#
# PAQUETES
#   install.packages(c("FactoMineR", "factoextra", "cluster", "mclust"))
# ==============================================================================


# ---- 0. Preparacion ------------------------------------------------------

library(tidyverse)
library(FactoMineR)
library(factoextra)
library(cluster)      # silhouette()

options(scipen = 999)
theme_set(theme_minimal(base_size = 12))
set.seed(2026)


# ==============================================================================
# 1. LA BASE (la misma del script 01)
# ==============================================================================

base_ad   <- "https://raw.githubusercontent.com/argendatafundar/data/main/"
carpeta_ad <- file.path("..", "diapositivas", "datos", "argendata")
leer_ad <- function(ruta) {
  local <- file.path(carpeta_ad, basename(ruta))
  if (!file.exists(local)) {
    dir.create(carpeta_ad, recursive = TRUE, showWarnings = FALSE)
    download.file(paste0(base_ad, ruta), local, mode = "wb", quiet = TRUE)
  }
  read_csv(local, show_col_types = FALSE)
}
anio_ref <- 2022
corte <- function(d, ...) d |> filter(anio == anio_ref) |> select(iso = geocodigoFundar, ...)

fec <- leer_ad("DEMOGR/tasa_fecundidad_adolescente_paises.csv") |>
  filter(anio == anio_ref) |>
  group_by(iso = geocodigoFundar) |>
  arrange(fuente != "World Population Prospects (UN)", .by_group = TRUE) |>
  slice(1) |> ungroup() |>
  select(iso, fec_adol = tgf_adolescente)

paises <- leer_ad("DESHUM/expectativa_vida.csv") |>
  filter(es_agregacion == 0, anio == anio_ref) |>
  select(iso = geocodigoFundar, pais = geonombreFundar,
         continente = continente_fundar, esp_vida = expectativa_vida) |>
  inner_join(corte(leer_ad("DESHUM/expectativa_educ.csv"), esc_esperada = expectativa_educ), by = "iso") |>
  inner_join(corte(leer_ad("DESHUM/anios_prom_educ.csv"),  esc_promedio = anios_prom_educ),  by = "iso") |>
  inner_join(corte(leer_ad("DESHUM/inb_pc.csv"), inb_pc), by = "iso") |>
  left_join(leer_ad("DESIGU/ISA_mundo_i1.csv") |>
              transmute(iso = geocodigoFundar, gini = as.numeric(gini)), by = "iso") |>
  left_join(leer_ad("CAMCLI/emisiones_per_cap.csv") |> filter(anio == anio_ref) |>
              transmute(iso = geocodigoFundar, emis_pc = as.numeric(valor_per_cap)), by = "iso") |>
  left_join(fec, by = "iso") |>
  drop_na(esp_vida, esc_esperada, esc_promedio, inb_pc, gini, emis_pc, fec_adol) |>
  mutate(log_inb = log(inb_pc), log_emis = log(emis_pc))

vars <- c("esp_vida", "esc_esperada", "esc_promedio", "log_inb", "gini", "log_emis", "fec_adol")
X <- paises |> select(all_of(vars)) |> as.data.frame()
rownames(X) <- paises$pais


# ==============================================================================
# PARTE A: CLUSTER JERARQUICO "A MANO"
# ==============================================================================

# ---- A.1 Estandarizar y calcular distancias ----
# QUE HACE: scale() resta la media y divide por el desvio cada columna.
#   dist() calcula la distancia euclidea entre cada par de paises.
Z <- scale(X)
d <- dist(Z, method = "euclidean")

# La matriz de distancias tiene n(n-1)/2 elementos:
length(d)

# Quien se parece mas a Argentina?
as.matrix(d)["Argentina", ] |> sort() |> head(6)

# COMO SE LEE: el primer valor es 0 (Argentina consigo misma). Los siguientes
# son los paises con perfil mas parecido EN ESTAS 7 VARIABLES ESTANDARIZADAS.
# Probar sin estandarizar: dist(X). Cambia la lista? (ejercicio 1)

# ---- A.2 Aglomerar con distintos criterios de linkage ----
hc_ward     <- hclust(d, method = "ward.D2")
hc_complete <- hclust(d, method = "complete")
hc_average  <- hclust(d, method = "average")
hc_single   <- hclust(d, method = "single")

# OJO: en R, el Ward "de libro" es method = "ward.D2" (trabaja con distancias
# al cuadrado). "ward.D" es otra variante y da resultados distintos.

# Dendrogramas rapidos con R base
par(mfrow = c(2, 2), mar = c(1, 4, 2, 1))
plot(hc_ward, labels = FALSE, main = "Ward")
plot(hc_complete, labels = FALSE, main = "Complete")
plot(hc_average, labels = FALSE, main = "Average")
plot(hc_single, labels = FALSE, main = "Single")
par(mfrow = c(1, 1))

# COMO SE LEE: single produce el clasico "efecto cadena": va agregando paises
# de a uno a un grupo grande, sin grupos claros. Ward produce ramas
# balanceadas.

# Tamanio de los grupos al cortar en 4 con cada criterio:
map(list(ward = hc_ward, complete = hc_complete, average = hc_average,
         single = hc_single), ~ table(cutree(.x, k = 4)))

# ---- A.3 Que tan bien representa el arbol a las distancias? ----
# QUE HACE: la correlacion cofenetica compara la distancia original entre dos
#   paises con la altura a la que se unen en el dendrograma.
map_dbl(list(ward = hc_ward, complete = hc_complete, average = hc_average,
             single = hc_single), ~ cor(d, cophenetic(.x)))

# COMO SE LEE: valores cerca de 1 indican que el arbol respeta las distancias.
# Average suele ganar en esta medida (justamente optimiza algo parecido), pero
# Ward da grupos mas utiles para describir. No hay un criterio unico.

# ---- A.4 Dendrograma lindo con factoextra ----
fviz_dend(hc_ward, k = 4, cex = 0.45, horiz = TRUE, rect = TRUE,
          k_colors = c("#2C6E9B", "#C1553B", "#E3A33A", "#4E8F5A"),
          main = "Ward, 4 grupos")

# ---- A.5 Cuantos grupos? ----
# (a) Alturas de fusion: buscar un salto grande
tibble(k = 1:10, altura = rev(hc_ward$height)[1:10]) |>
  ggplot(aes(k, altura)) + geom_line() + geom_point() +
  scale_x_continuous(breaks = 1:10) +
  labs(title = "Altura de las ultimas fusiones", x = "Cantidad de grupos")

# (b) Silueta promedio para cada k
fviz_nbclust(Z, FUNcluster = hcut, method = "silhouette", k.max = 8,
             hc_method = "ward.D2")

# (c) Suma de cuadrados dentro de los grupos (codo)
fviz_nbclust(Z, FUNcluster = hcut, method = "wss", k.max = 8, hc_method = "ward.D2")

# COMO SE LEE: la silueta maxima esta en k = 2 (paises "desarrollados" vs
# "no desarrollados"), pero dos grupos dicen poco. El codo no es nitido: los
# paises forman un continuo. Elegimos k = 4 por interpretabilidad y lo
# DECIMOS. Es una decision analitica, no un descubrimiento.

k <- 4
grupos <- cutree(hc_ward, k = k)
table(grupos)

# ---- A.6 Caracterizar los grupos ----
# QUE HACE: promedios de las variables ORIGINALES (no estandarizadas) por grupo.
perfil <- paises |>
  mutate(grupo = factor(grupos)) |>
  group_by(grupo) |>
  summarise(n = n(),
            esp_vida = mean(esp_vida), esc_promedio = mean(esc_promedio),
            inb_pc_mediana = median(inb_pc), gini = mean(gini),
            emis_pc_mediana = median(emis_pc), fec_adol = mean(fec_adol)) |>
  arrange(inb_pc_mediana)
perfil

# Que paises hay en cada grupo?
split(paises$pais, grupos)

# Silueta de cada pais: quien esta "en el borde" entre dos grupos?
sil <- silhouette(grupos, d)
fviz_silhouette(sil, label = FALSE)
paises |>
  mutate(grupo = grupos, silueta = sil[, "sil_width"]) |>
  arrange(silueta) |>
  select(pais, grupo, silueta) |>
  head(10)

# COMO SE LEE: silueta negativa = el pais esta, en promedio, mas cerca de otro
# grupo que del suyo. Son los casos dudosos: conviene nombrarlos al presentar.

# EN TU TP: una tabla de perfiles en unidades originales, una lista de
# ejemplos por grupo y los casos con silueta mas baja.


# ==============================================================================
# PARTE B: HCPC (Hierarchical Clustering on Principal Components)
# ==============================================================================
# QUE HACE HCPC():
#   1. parte de un PCA (o MCA) y se queda con los primeros ncp componentes
#      (saca el "ruido" de los ultimos componentes);
#   2. hace Ward sobre esos componentes;
#   3. corta el arbol (sugiere un k, o le damos uno);
#   4. CONSOLIDA con k-means, usando los centros de Ward como punto de partida
#      (algunos paises pueden cambiar de grupo);
#   5. describe cada grupo con tests sobre las variables y los ejes.

# ---- B.1 El PCA de partida ----
res_pca <- PCA(X, ncp = 5, scale.unit = TRUE, graph = FALSE)
res_pca$eig[1:5, ]

# COMO SE LEE: con 5 componentes conservamos ~96% de la varianza. Usar
# ncp = Inf es equivalente a Ward sobre las variables estandarizadas.

# ---- B.2 Dejar que HCPC sugiera k ----
res_auto <- HCPC(res_pca, nb.clust = -1, graph = FALSE)   # -1 = corte automatico
table(res_auto$data.clust$clust)

# COMO SE LEE: el corte automatico elige el k que maximiza la ganancia
# relativa de inercia entre grupos. Suele elegir pocos grupos.

# ---- B.3 HCPC con k = 4 ----
res_hcpc <- HCPC(res_pca, nb.clust = 4, consol = TRUE, graph = FALSE)

plot(res_hcpc, choice = "tree")          # dendrograma con el corte
plot(res_hcpc, choice = "bar")           # ganancia de inercia por cada fusion
fviz_cluster(res_hcpc, repel = TRUE, labelsize = 7, show.clust.cent = TRUE,
             main = "HCPC: 4 grupos en el plano PC1-PC2")
plot(res_hcpc, choice = "3D.map")        # el arbol "parado" sobre el mapa

grupo_hcpc <- res_hcpc$data.clust$clust
table(grupo_hcpc)

# ---- B.4 Descripcion de los grupos ----
# (a) por las variables
res_hcpc$desc.var$quanti

# COMO SE LEE: para cada grupo, las variables cuyo promedio en el grupo es
# significativamente distinto del promedio general. v.test > 2: el grupo
# tiene valores MAS ALTOS que el promedio; v.test < -2: mas bajos.
# "Mean in category" vs "Overall mean" da la magnitud en unidades originales.

# (b) por los ejes
res_hcpc$desc.axes$quanti

# (c) paragons: los paises mas cercanos al centro de cada grupo (los mas
#     "tipicos") y los mas alejados de los otros grupos (los mas "distintivos")
res_hcpc$desc.ind$para
res_hcpc$desc.ind$dist

# COMO SE LEE: los paragons son los mejores ejemplos para NOMBRAR un grupo en
# una presentacion. Los distintivos muestran que lo hace unico.

# ---- B.5 Comparar con el Ward "a mano" ----
table(Ward = grupos, HCPC = grupo_hcpc)
mclust::adjustedRandIndex(grupos, grupo_hcpc)

# COMO SE LEE: la tabla cruza las dos particiones (los numeros de grupo son
# arbitrarios: no importa que el "1" de una coincida con el "1" de la otra).
# El indice de Rand ajustado mide el acuerdo sin depender de los numeros:
# 1 = particiones identicas, 0 = el acuerdo esperable por azar.
# Usar 5 componentes en lugar de 7 variables y consolidar con k-means
# cambia bastante la particion. Que un pais cambie de grupo es informacion
# sobre lo fragil que es la frontera, no un error.

# EN TU TP: reportar ncp, k y si hubo consolidacion. Presentar la tabla de
# desc.var con las magnitudes en unidades originales y los paragons.


# ==============================================================================
# PARTE C: HCPC SOBRE UN MCA (variables categoricas)
# ==============================================================================
# Mismo flujo con los ocupados de la EPH del script 02. Usamos una muestra
# de 3.000 personas: el jerarquico necesita todas las distancias y con 14.000
# filas es lento.

ruta <- file.path("..", "diapositivas", "datos", "eph_ind_1t2026.rds")
eph <- readRDS(ruta)

ocup <- eph |>
  mutate(across(c(ESTADO, CAT_OCUP, PP07H, NIVEL_ED, CH08, PP04C, INTENSI, CH04), as.numeric)) |>
  filter(ESTADO == 1, CAT_OCUP %in% 1:3) |>
  transmute(
    categoria = case_when(CAT_OCUP == 1 ~ "Patron", CAT_OCUP == 2 ~ "Cuenta propia",
                          CAT_OCUP == 3 & PP07H == 1 ~ "Asal. registrado",
                          CAT_OCUP == 3 & PP07H == 2 ~ "Asal. no registrado"),
    educacion = case_when(NIVEL_ED %in% c(1, 2, 3, 7) ~ "Hasta sec. incompleto",
                          NIVEL_ED %in% c(4, 5) ~ "Sec. completo", NIVEL_ED == 6 ~ "Univ. completo"),
    salud = case_when(CH08 %in% c(1, 12, 13, 123) ~ "Obra social", CH08 == 4 ~ "Sin cobertura",
                      CH08 %in% c(2, 3, 23) ~ "Prepaga / plan estatal"),
    tamanio = case_when(PP04C %in% 1:5 ~ "Hasta 5 personas", PP04C %in% 6:8 ~ "6 a 40 personas",
                        PP04C %in% 9:12 ~ "Mas de 40 personas"),
    intensidad = case_when(INTENSI == 1 ~ "Subocupado", INTENSI == 2 ~ "Ocupado pleno",
                           INTENSI == 3 ~ "Sobreocupado"),
    sexo = if_else(CH04 == 1, "Varon", "Mujer")
  ) |>
  drop_na() |>
  mutate(across(everything(), as.factor))

set.seed(123)
muestra <- ocup |> slice_sample(n = 3000) |> as.data.frame()

res_mca <- MCA(muestra, quali.sup = 6, ncp = 5, graph = FALSE)
res_hcpc_mca <- HCPC(res_mca, nb.clust = 4, graph = FALSE)

table(res_hcpc_mca$data.clust$clust)

# Descripcion por categorias: que categorias estan sobre o subrepresentadas
# en cada grupo
res_hcpc_mca$desc.var$category

# COMO SE LEE: "Cla/Mod" = % de la categoria que cae en el grupo;
# "Mod/Cla" = % del grupo que tiene la categoria; "Global" = % de la categoria
# en toda la muestra. Si Mod/Cla >> Global, la categoria CARACTERIZA al grupo.
# Una lectura posible de los cuatro grupos: asalariados formales (obra social,
# establecimientos grandes), asalariados no registrados (sin cobertura),
# cuentapropistas (establecimientos de hasta 5) y un grupo chico de patrones
# (muchos con prepaga). Los numeros de grupo pueden cambiar con la muestra.

fviz_cluster(res_hcpc_mca, geom = "point", main = "HCPC sobre el MCA de ocupados")


# ==============================================================================
# EJERCICIOS
# ==============================================================================
# 1. Calcular los 5 paises mas parecidos a Argentina SIN estandarizar
#    (dist(X)). Que variable domina la distancia? Por que?
#
# 2. Cortar el arbol de Ward en 3 y en 6 grupos. Que grupo se divide al pasar
#    de 4 a 6? Tiene una lectura economica?
#
# 3. Rehacer la parte A con complete linkage y k = 4. Cruzar los grupos con
#    los de Ward (table + adjustedRandIndex). Que paises cambian?
#
# 4. Correr HCPC con ncp = 2 y con ncp = Inf. Cuanto cambian los grupos
#    respecto de ncp = 5? Que se gana y que se pierde al usar pocos ejes?
#
# 5. Correr HCPC con consol = FALSE. Cuantos paises cambian de grupo por la
#    consolidacion con k-means?
#
# 6. Ponerle nombre a cada grupo de la parte C usando desc.var$category. Que
#    porcentaje de mujeres hay en cada grupo (sexo es suplementaria)?
#
# 7. EN TU TP: aplicar HCPC a tu base (sobre un PCA o un MCA) y presentar:
#    k elegido y por que, tabla de perfiles, paragons, y una prueba de
#    sensibilidad (otro k u otro ncp).
