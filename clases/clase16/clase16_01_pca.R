# ==============================================================================
# Clase 16 - Practica 1: Componentes principales (PCA)
# Ciencia de Datos para Economia y Negocios - FCE-UBA
#
# QUE ES ESTE SCRIPT
# El PCA de la clase 15, paso a paso y sobre los mismos datos: 7 indicadores de
# desarrollo para unos 150 paises (PNUD y otras fuentes, via Argendata). La idea
# es reproducir cada resultado de las diapositivas y aprender a leerlo.
#
# Cada paso esta comentado en tres niveles:
#   QUE HACE    -> que calcula el bloque
#   COMO SE LEE -> que hay que mirar en el resultado
#   EN TU TP    -> como adaptarlo a la base del trabajo final
#
# COMO USARLO
# Ejecutar linea por linea (Ctrl+Enter), leyendo los comentarios y mirando cada
# resultado antes de pasar al siguiente. Al final hay ejercicios.
# Hace falta conexion a internet la primera vez (los datos se bajan de Argendata
# y quedan guardados en una carpeta local).
#
# ORDEN SUGERIDO DE LA PRACTICA
#   01 PCA  ->  02 MCA  ->  03 Jerarquico con HCPC  ->  04 k-means y DBSCAN
# HCPC (script 03) arranca de un PCA o un MCA, por eso conviene hacer estos
# dos primero.
#
# PAQUETES
#   install.packages(c("FactoMineR", "factoextra", "ggrepel"))
# ==============================================================================


# ---- 0. Preparacion ------------------------------------------------------

library(tidyverse)
library(FactoMineR)   # PCA(), MCA(), HCPC(): los calculos
library(factoextra)   # fviz_*(): los graficos, en ggplot2
library(ggrepel)      # etiquetas que no se pisan

options(scipen = 999)
theme_set(theme_minimal(base_size = 12))


# ==============================================================================
# 1. ARMAR LA BASE
# ==============================================================================
# Misma base que la clase 15: una fila por pais, una columna por variable.
# leer_ad() busca primero el archivo en la carpeta de datos de las diapositivas;
# si no esta, lo baja de Argendata y lo guarda ahi.

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
# Corte transversal: filtra el anio y deja el codigo de pais + la(s) columna(s)
corte <- function(d, ...) d |> filter(anio == anio_ref) |> select(iso = geocodigoFundar, ...)

fec <- leer_ad("DEMOGR/tasa_fecundidad_adolescente_paises.csv") |>
  filter(anio == anio_ref) |>
  group_by(iso = geocodigoFundar) |>
  arrange(fuente != "World Population Prospects (UN)", .by_group = TRUE) |>
  slice(1) |>                                   # una fuente por pais
  ungroup() |>
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
  left_join(corte(leer_ad("DESHUM/indice_desarrollo_humano.csv"), idh), by = "iso")

# Cuantos faltantes hay por variable? (clase 12: mirar antes de borrar)
colSums(is.na(paises))

# PCA no acepta NA. Nos quedamos con los paises completos en las 7 variables.
# OJO: esto deja afuera sobre todo a paises sin dato de Gini.
paises <- paises |>
  drop_na(esp_vida, esc_esperada, esc_promedio, inb_pc, gini, emis_pc, fec_adol) |>
  mutate(log_inb = log(inb_pc), log_emis = log(emis_pc))
nrow(paises)

# Matriz con las variables ACTIVAS (las que construyen los componentes).
# Los nombres de fila son los paises: asi aparecen en los graficos.
vars <- c("esp_vida", "esc_esperada", "esc_promedio", "log_inb", "gini", "log_emis", "fec_adol")
X <- paises |> select(all_of(vars)) |> as.data.frame()
rownames(X) <- paises$pais

summary(X)

# EN TU TP: una fila por unidad (pais, provincia, empresa) y una columna por
# variable NUMERICA. Decidir que hacer con los NA antes del PCA (eliminar o
# imputar, clase 12) y dejarlo escrito.


# ==============================================================================
# 2. ANTES DEL PCA: CORRELACIONES
# ==============================================================================
# PCA resume variables CORRELACIONADAS. Si las variables no se correlacionan,
# no hay nada que resumir y cada componente va a ser casi una variable.

round(cor(X), 2)

# Version grafica: un heatmap con ggplot.
cor(X) |>
  as_tibble(rownames = "v1") |>
  pivot_longer(-v1, names_to = "v2", values_to = "r") |>
  ggplot(aes(v1, v2, fill = r)) +
  geom_tile(color = "white") +
  geom_text(aes(label = round(r, 2)), size = 3) +
  scale_fill_gradient2(low = "firebrick", mid = "white", high = "steelblue", limits = c(-1, 1)) +
  labs(x = NULL, y = NULL, title = "Correlaciones entre las variables activas") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# COMO SE LEE: salud, educacion e ingreso correlacionan entre 0,7 y 0,85:
# cuentan casi la misma historia. Gini y emisiones correlacionan menos con el
# resto: van a necesitar su propio componente.


# ==============================================================================
# 3. PCA CON R BASE: prcomp()
# ==============================================================================

# ---- 3.1 Estandarizar o no ----
# QUE HACE: prcomp() calcula los componentes. Con scale. = TRUE trabaja con
#   variables estandarizadas (matriz de correlaciones).
# OJO: el valor por defecto de prcomp() es scale. = FALSE.

pca_sin <- prcomp(X, scale. = FALSE)
pca_con <- prcomp(X, scale. = TRUE)

summary(pca_sin)$importance[2, ]   # proporcion de varianza por componente
summary(pca_con)$importance[2, ]

round(pca_sin$rotation[, 1], 3)    # loadings de PC1 sin estandarizar
round(pca_con$rotation[, 1], 3)    # loadings de PC1 estandarizando

# COMO SE LEE: sin estandarizar, PC1 es casi solo la variable de mayor varianza
# (fecundidad adolescente, medida en nacimientos cada mil). Estandarizando,
# todas pesan parecido. Probar con inb_pc en niveles en lugar de log_inb para
# ver un caso todavia mas extremo (ejercicio 1).

# ---- 3.2 Que devuelve prcomp() ----
pca <- pca_con
pca$sdev^2                 # autovalores (varianza de cada componente)
pca$rotation[, 1:3]        # loadings: el peso de cada variable en cada PC
head(pca$x[, 1:3])         # scores: la posicion de cada pais en cada PC

# Comprobar a mano que el score es una combinacion lineal:
z <- scale(X)
sum(z["Argentina", ] * pca$rotation[, 1])   # igual a...
pca$x["Argentina", 1]                        # ...el score de Argentina en PC1

# Los componentes NO estan correlacionados entre si:
round(cor(pca$x[, 1:3]), 3)


# ==============================================================================
# 4. PCA CON FactoMineR (la herramienta que vamos a usar)
# ==============================================================================
# FactoMineR::PCA() estandariza por defecto (scale.unit = TRUE) y devuelve,
# ademas de lo anterior, medidas para interpretar: cos2 y contribuciones.
# Tambien permite variables SUPLEMENTARIAS (ver seccion 7).

res <- PCA(X, scale.unit = TRUE, graph = FALSE)

# ---- 4.1 Cuantos componentes mirar ----
res$eig
fviz_eig(res, addlabels = TRUE)

# COMO SE LEE: columna 1 = autovalor, 2 = % de varianza, 3 = % acumulado.
#   PC1 explica ~69% y PC1 + PC2 ~81%.
#   Criterio de Kaiser: autovalor > 1 (con variables estandarizadas, un
#   componente que resume menos que UNA variable original no vale la pena).
#   Codo del scree plot: despues de PC2 o PC3 la curva se aplana.
# Son heuristicas: elegir tambien por interpretabilidad.

# ---- 4.2 Variables: coordenadas, cos2 y contribuciones ----
res$var$coord[, 1:2]     # correlacion de cada variable con cada componente
res$var$cos2[, 1:2]      # calidad de representacion (coord al cuadrado)
res$var$contrib[, 1:2]   # % con que cada variable construye cada componente

fviz_pca_var(res, repel = TRUE, col.var = "contrib",
             gradient.cols = c("gray70", "steelblue", "firebrick"))

fviz_contrib(res, choice = "var", axes = 1)   # quien arma PC1
fviz_contrib(res, choice = "var", axes = 2)   # quien arma PC2

# COMO SE LEE:
#   - coord: con variables estandarizadas, es la CORRELACION entre variable y
#     componente. Es lo que dibuja el circulo de correlaciones.
#   - cos2 cerca de 1: la variable esta bien representada en ese eje.
#   - contrib: suma 100 por componente. La linea roja punteada de fviz_contrib
#     es la contribucion "esperada" si todas aportaran igual (100/7).
#   PC1 lo arman salud, educacion, ingreso y fecundidad (con signo opuesto).
#   PC2 lo arman Gini y emisiones.

# ---- 4.3 Descripcion automatica de los ejes ----
dimdesc(res, axes = 1:2)

# COMO SE LEE: lista las variables con correlacion significativa con cada eje,
# ordenadas. Es un buen punto de partida para ponerle nombre a un componente.
# El nombre ("desarrollo") lo ponemos nosotros: PCA solo da numeros.


# ==============================================================================
# 5. LAS OBSERVACIONES: EL MAPA DE PAISES
# ==============================================================================

fviz_pca_ind(res, repel = TRUE, labelsize = 3, col.ind = "cos2",
             gradient.cols = c("gray80", "steelblue", "firebrick"))

# Colorear por continente (habillage = variable de agrupamiento)
fviz_pca_ind(res, label = "none", habillage = factor(paises$continente),
             addEllipses = TRUE, ellipse.level = 0.68)

# COMO SE LEE: paises cercanos tienen perfiles parecidos en las 7 variables.
# Un pais con cos2 bajo esta mal representado en el plano: su posicion en el
# grafico puede enganiar (su diferencia esta en PC3 o mas alla).

# Que paises "tiran" mas de cada componente:
fviz_contrib(res, choice = "ind", axes = 1, top = 15)

# Tabla con los scores para trabajar con dplyr
scores <- as_tibble(res$ind$coord[, 1:3], rownames = "pais") |>
  rename(PC1 = Dim.1, PC2 = Dim.2, PC3 = Dim.3) |>
  left_join(select(paises, pais, iso, continente, idh), by = "pais")

scores |> arrange(desc(PC2)) |> head(10)   # los mas "desiguales y emisores"
scores |> arrange(PC2) |> head(10)


# ==============================================================================
# 6. BIPLOT: VARIABLES Y OBSERVACIONES JUNTAS
# ==============================================================================

fviz_pca_biplot(res, repel = TRUE, labelsize = 3, col.var = "firebrick",
                col.ind = "gray50", select.ind = list(cos2 = 40))

# COMO SE LEE: un pais ubicado en la direccion de una flecha tiene valores
# altos en esa variable. select.ind = list(cos2 = 40) muestra solo los 40
# paises mejor representados, para que se pueda leer.


# ==============================================================================
# 7. VARIABLES SUPLEMENTARIAS
# ==============================================================================
# QUE HACE: una variable suplementaria NO participa en la construccion de los
#   componentes; se proyecta despues, para interpretar.
#   - quanti.sup: numericas (aca, el IDH oficial)
#   - quali.sup: categoricas (aca, el continente)

X_sup <- paises |> select(all_of(vars), idh, continente) |> as.data.frame()
rownames(X_sup) <- paises$pais

res_sup <- PCA(X_sup, quanti.sup = 8, quali.sup = 9, graph = FALSE)

res_sup$quanti.sup$coord     # correlacion del IDH con cada componente
res_sup$quali.sup$coord      # posicion media de cada continente

fviz_pca_var(res_sup, repel = TRUE)   # el IDH aparece en azul punteado

# COMO SE LEE: el IDH correlaciona ~0,98 con PC1. Sin haberlo usado, PCA
# "reconstruye" el IDH como la dimension principal de estos datos. Conexion
# con la clase 14: PC1 sirve como un indice compuesto con pesos estadisticos.


# ==============================================================================
# 8. EL SIGNO ES ARBITRARIO Y LA SELECCION DE VARIABLES IMPORTA
# ==============================================================================

# ---- 8.1 Signo ----
# prcomp() y PCA() pueden devolver el mismo componente con signo opuesto.
cor(pca$x[, 1], res$ind$coord[, 1])   # 1 o -1: es la misma dimension

# Si queremos que PC1 "crezca con el desarrollo", lo invertimos y lo decimos:
pc1 <- res$ind$coord[, 1]
if (cor(pc1, paises$log_inb) < 0) pc1 <- -pc1

# ---- 8.2 Sensibilidad: sacar una variable ----
# QUE HACE: rehace el PCA sin cada variable y compara el nuevo PC1 con el
#   original (correlacion de rangos).
sensibilidad <- map_dfr(vars, function(v) {
  r <- PCA(X[, setdiff(vars, v)], graph = FALSE)
  tibble(sin = v,
         var_pc1 = r$eig[1, 2],
         cor_pc1 = abs(cor(r$ind$coord[, 1], pc1, method = "spearman")))
})
sensibilidad

# COMO SE LEE: si PC1 casi no cambia al sacar cualquier variable (cor ~ 1),
# la dimension es robusta. Mirar en cambio que pasa con PC2 (ejercicio 4).

# EN TU TP: reportar (1) que variables entran y por que, (2) si se
# estandarizo, (3) % de varianza de los componentes que se usan, (4) loadings
# y la interpretacion propuesta, (5) alguna prueba de sensibilidad.


# ==============================================================================
# EJERCICIOS
# ==============================================================================
# 1. Repetir el PCA con inb_pc y emis_pc EN NIVELES (sin log), estandarizando
#    y sin estandarizar. Cuanto explica PC1 en cada caso? Que variable domina?
#
# 2. Sacar Gini y emisiones. Cuantos componentes tienen autovalor > 1 ahora?
#    Que paso con el % de varianza de PC1? Por que?
#
# 3. Con el mapa de paises: buscar dos paises con PC1 parecido y PC2 muy
#    distinto. Volver a la base original y explicar con las variables por que
#    se separan en PC2.
#
# 4. Adaptar la seccion 8.2 para medir la estabilidad de PC2. Es tan robusto
#    como PC1? Que conclusion saca sobre ponerle nombre a PC2?
#
# 5. Usar PC1 como indice de desarrollo: ordenar los paises de America del Sur
#    por PC1 y por el IDH oficial. Coinciden los rankings? (clase 14)
#
# 6. EN TU TP: correr un PCA con las variables numericas de tu base y escribir
#    un parrafo con la interpretacion de los dos primeros componentes.
