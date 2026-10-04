# ==============================================================================
# Clase 16 - Practica 4: k-means, DBSCAN y otros algoritmos de clustering
# Ciencia de Datos para Economia y Negocios - FCE-UBA
#
# QUE ES ESTE SCRIPT
#   (A) k-means sobre los paises: como se corre, que devuelve, como elegir k,
#       por que hace falta nstart, como se ve la silueta.
#   (B) k-medoids (PAM): la alternativa robusta.
#   (C) DBSCAN y HDBSCAN: grupos por densidad. Primero con datos simulados
#       (donde k-means falla), despues con los paises.
#   (D) Mezclas gaussianas (GMM): asignacion "blanda", con probabilidades.
#   (E) Comparar todas las particiones.
#
# Cada paso esta comentado en tres niveles:
#   QUE HACE    -> que calcula el bloque
#   COMO SE LEE -> que hay que mirar en el resultado
#   EN TU TP    -> como adaptarlo a la base del trabajo final
#
# PAQUETES
#   install.packages(c("factoextra", "cluster", "dbscan", "mclust"))
# ==============================================================================


# ---- 0. Preparacion ------------------------------------------------------

library(tidyverse)
library(factoextra)
library(cluster)     # pam(), silhouette(), clusGap()
library(dbscan)      # dbscan(), hdbscan(), kNNdistplot()
library(mclust)      # Mclust(), adjustedRandIndex()

options(scipen = 999)
theme_set(theme_minimal(base_size = 12))
set.seed(2026)

# OJO: mclust tiene su propia funcion map() que tapa a purrr::map(). Si la
# necesitan, escribir purrr::map().


# ==============================================================================
# 1. LA BASE (la misma de los scripts 01 y 03)
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
Z <- scale(X)          # k-means usa distancia euclidea: estandarizar siempre


# ==============================================================================
# PARTE A: k-means
# ==============================================================================

# ---- A.1 Correr k-means ----
# QUE HACE: kmeans(datos, centers = k, nstart = r) prueba r arranques al azar
#   y se queda con el de menor suma de cuadrados dentro de los grupos.
km <- kmeans(Z, centers = 4, nstart = 50)

km$size                  # cuantos paises por grupo
km$centers               # centros, en unidades ESTANDARIZADAS
km$withinss              # suma de cuadrados dentro de cada grupo
km$betweenss / km$totss  # % de la variabilidad total que esta ENTRE grupos

# COMO SE LEE: betweenss / totss es como un R2: que parte de la variabilidad
# de los datos queda explicada por la pertenencia a un grupo. Siempre sube al
# aumentar k, asi que no sirve por si solo para elegir k.

# Centros en unidades originales: mas facil de comunicar
paises |>
  mutate(grupo = km$cluster) |>
  group_by(grupo) |>
  summarise(n = n(), across(c(esp_vida, esc_promedio, inb_pc, gini, emis_pc, fec_adol),
                            ~ round(mean(.x), 1))) |>
  arrange(inb_pc)

# Grafico en el plano de los dos primeros componentes principales
fviz_cluster(km, data = Z, repel = TRUE, labelsize = 7, ellipse.type = "convex",
             main = "k-means, k = 4 (proyectado en PC1-PC2)")

# ---- A.2 Por que nstart ----
# QUE HACE: corre k-means 100 veces con UN solo arranque y guarda la suma de
#   cuadrados final de cada corrida.
wss_un_arranque <- replicate(100, kmeans(Z, centers = 4, nstart = 1)$tot.withinss)
summary(wss_un_arranque)
mean(wss_un_arranque > min(wss_un_arranque) + 1e-6)   # % de corridas no optimas

hist(wss_un_arranque, breaks = 20, main = "k-means con un solo arranque",
     xlab = "Suma de cuadrados dentro de los grupos")

# COMO SE LEE: k-means puede quedar atrapado en una solucion local peor. Con
# nstart = 25 o mas, la chance de que eso pase es practicamente nula.

# ---- A.3 Elegir k ----
fviz_nbclust(Z, kmeans, method = "wss", k.max = 10, nstart = 25)          # codo
fviz_nbclust(Z, kmeans, method = "silhouette", k.max = 10, nstart = 25)   # silueta

# Estadistico gap: compara la suma de cuadrados con la que se obtendria en
# datos SIN estructura (uniformes en el mismo rango). B = cantidad de simulaciones.
gap <- clusGap(Z, FUN = kmeans, nstart = 25, K.max = 8, B = 100)
fviz_gap_stat(gap)

# COMO SE LEE: los tres criterios no tienen por que coincidir. La silueta
# sugiere 2; el gap suele sugerir pocos grupos. Con datos que forman un
# continuo, ningun k es "el correcto": elegir uno util y justificarlo.

# ---- A.4 Silueta de cada pais ----
sil_km <- silhouette(km$cluster, dist(Z))
fviz_silhouette(sil_km, label = FALSE)
mean(sil_km[, "sil_width"])

# ---- A.5 k-means es sensible a outliers ----
# QUE HACE: agrega un pais ficticio extremo y vuelve a correr k-means.
Z_out <- rbind(Z, "Pais extremo" = c(rep(6, 4), -4, 6, -4))
km_out <- kmeans(Z_out, centers = 4, nstart = 50)
km_out$size

# COMO SE LEE: con un solo punto extremo, k-means puede dedicarle un grupo
# entero (y fusionar dos grupos "reales"). El centro es un PROMEDIO y se deja
# arrastrar.


# ==============================================================================
# PARTE B: k-medoids (PAM)
# ==============================================================================
# QUE HACE: como k-means, pero el centro de cada grupo es una OBSERVACION REAL
#   (el medoide) y minimiza distancias, no distancias al cuadrado. Es mas
#   robusto a outliers y acepta cualquier matriz de distancias (por ejemplo,
#   Gower para mezclar variables numericas y categoricas).

pm <- pam(Z, k = 4)
pm$medoids          # los paises "centro" de cada grupo
table(pm$clustering)

pm_out <- pam(Z_out, k = 4)
table(pm_out$clustering)

# COMO SE LEE: los medoides son ejemplos concretos para presentar cada grupo.
# Con el pais extremo, PAM suele mantener la estructura de grupos.

# Comparar con k-means:
table(kmeans = km$cluster, pam = pm$clustering)

# EN TU TP: si hay variables categoricas, se puede usar
#   d_gower <- cluster::daisy(base, metric = "gower")
#   pam(d_gower, k = 4, diss = TRUE)


# ==============================================================================
# PARTE C: DBSCAN Y HDBSCAN
# ==============================================================================

# ---- C.1 Un caso donde k-means falla: medialunas ----
gen_moons <- function(n = 300, ruido = 0.08) {
  t1 <- runif(n / 2, 0, pi); t2 <- runif(n / 2, 0, pi)
  tibble(x = c(cos(t1), 1 - cos(t2)), y = c(sin(t1), 0.5 - sin(t2))) |>
    mutate(x = x + rnorm(n, 0, ruido), y = y + rnorm(n, 0, ruido))
}
moons <- bind_rows(gen_moons(),
                   tibble(x = runif(12, -1.2, 2.2), y = runif(12, -0.9, 1.3)))  # ruido

km_moons <- kmeans(moons, centers = 2, nstart = 25)
ggplot(moons, aes(x, y, color = factor(km_moons$cluster))) +
  geom_point() + labs(title = "k-means, k = 2", color = "Grupo")

# ---- C.2 Elegir eps con el grafico de k vecinos ----
# QUE HACE: para cada punto, la distancia a su (minPts - 1)-esimo vecino mas
#   cercano, ordenada. El "codo" de esa curva es un buen eps: separa los
#   puntos de zonas densas (distancias chicas) del ruido (distancias grandes).
kNNdistplot(moons, k = 4)
abline(h = 0.17, lty = 2, col = "red")

db_moons <- dbscan(moons, eps = 0.17, minPts = 5)
db_moons                    # cuantos grupos y cuantos puntos de ruido

ggplot(moons, aes(x, y, color = factor(db_moons$cluster))) +
  geom_point() +
  scale_color_manual(values = c("0" = "black", "1" = "#2C6E9B", "2" = "#C1553B"),
                     labels = c("0" = "Ruido", "1" = "1", "2" = "2")) +
  labs(title = "DBSCAN, eps = 0,17, minPts = 5", color = "Grupo")

# COMO SE LEE: el grupo 0 es RUIDO: puntos que no estan en ninguna zona densa.
# DBSCAN no necesita k, pero si eps y minPts. Probar eps = 0.1 y eps = 0.3
# (ejercicio 4).

# ---- C.3 HDBSCAN: sin eps ----
# QUE HACE: prueba todos los eps a la vez y se queda con los grupos mas
#   estables. Solo pide minPts (tamanio minimo de un grupo).
hdb_moons <- hdbscan(moons, minPts = 10)
hdb_moons
plot(hdb_moons, show_flat = TRUE)    # arbol de grupos y su estabilidad

# ---- C.4 DBSCAN con los paises ----
# DBSCAN sufre con muchas dimensiones (todo queda "lejos" de todo). Lo
# aplicamos sobre los dos primeros componentes principales, que resumen el
# ~81% de la varianza.
pcs <- prcomp(Z)$x[, 1:2]

kNNdistplot(pcs, k = 4)
abline(h = 0.6, lty = 2, col = "red")

db_p <- dbscan(pcs, eps = 0.6, minPts = 5)
db_p
paises$pais[db_p$cluster == 0]      # los paises "ruido"

fviz_cluster(list(data = pcs, cluster = db_p$cluster), geom = "point",
             ellipse = FALSE, main = "DBSCAN sobre PC1-PC2 (0 = ruido)")

hdb_p <- hdbscan(pcs, minPts = 8)
hdb_p
paises$pais[hdb_p$cluster == 0]

# COMO SE LEE: DBSCAN sobre los paises encuentra pocos grupos (a veces uno
# solo) y marca como ruido a los paises atipicos. Es consistente con lo que
# vimos en clase: los paises forman un CONTINUO, sin zonas vacias que separen
# grupos. Que DBSCAN "no encuentre grupos" tambien es un resultado.


# ==============================================================================
# PARTE D: MEZCLAS GAUSSIANAS (GMM)
# ==============================================================================
# QUE HACE: supone que los datos vienen de k distribuciones normales (elipses)
#   y estima a cual pertenece cada punto CON UNA PROBABILIDAD. Elige k y la
#   forma de las elipses con el BIC.

gmm <- Mclust(pcs, G = 1:6)
summary(gmm)
plot(gmm, what = "BIC")
plot(gmm, what = "classification")

# Incertidumbre: paises con probabilidad maxima baja estan entre dos grupos
tibble(pais = paises$pais, grupo = gmm$classification,
       prob_max = apply(gmm$z, 1, max)) |>
  arrange(prob_max) |>
  head(10)

# COMO SE LEE: a diferencia de k-means, GMM dice "este pais pertenece al
# grupo 2 con probabilidad 0,55": la frontera difusa queda a la vista.


# ==============================================================================
# PARTE E: COMPARAR TODAS LAS PARTICIONES
# ==============================================================================

ward <- cutree(hclust(dist(Z), method = "ward.D2"), k = 4)
particiones <- list(ward = ward, kmeans = km$cluster, pam = pm$clustering,
                    gmm = gmm$classification, dbscan = db_p$cluster)

# Indice de Rand ajustado entre cada par (1 = identicas, 0 = azar)
outer(names(particiones), names(particiones),
      Vectorize(function(a, b) round(adjustedRandIndex(particiones[[a]], particiones[[b]]), 2))) |>
  `dimnames<-`(list(names(particiones), names(particiones)))

# COMO SE LEE: Ward, k-means y PAM suelen coincidir bastante (todos buscan
# grupos compactos). GMM y DBSCAN tienen otra idea de "grupo" y difieren mas.
# Si distintos metodos coinciden, la particion es mas creible. Si no, hay que
# decir que la estructura de grupos es fragil.

# EN TU TP: no alcanza con un solo algoritmo. Correr al menos dos, compararlos
# y reportar que tan estables son los grupos.


# ==============================================================================
# EJERCICIOS
# ==============================================================================
# 1. Correr k-means sobre X SIN estandarizar. Comparar con km (table y
#    adjustedRandIndex). Que variable define los grupos ahora?
#
# 2. Elegir k = 3 y k = 5. Construir la tabla de perfiles en unidades
#    originales para cada uno. Cual contaria mejor en una presentacion?
#
# 3. Hacer la seccion A.5 con PAM y con k-means usando k = 5. Que metodo
#    "gasta" un grupo en el pais extremo?
#
# 4. En las medialunas, correr DBSCAN con eps = 0,1, 0,17 y 0,3. Cuantos
#    grupos y cuantos puntos de ruido hay en cada caso? Que pasa si minPts = 15?
#
# 5. Generar dos nubes de puntos con DENSIDADES distintas (rnorm con sd = 0,2 y
#    sd = 1). Hay un eps que separe bien las dos? Probar hdbscan().
#
# 6. Mirar los paises con prob_max mas baja en el GMM. Son los mismos que
#    tienen silueta baja en k-means (seccion A.4)?
#
# 7. EN TU TP: aplicar k-means (o PAM) y un segundo metodo a tu base, y
#    escribir un parrafo sobre que tan estables son los grupos.
