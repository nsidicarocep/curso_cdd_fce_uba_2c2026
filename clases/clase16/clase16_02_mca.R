# ==============================================================================
# Clase 16 - Practica 2: Analisis de correspondencias multiples (MCA)
# Ciencia de Datos para Economia y Negocios - FCE-UBA
#
# QUE ES ESTE SCRIPT
# El MCA de la clase 15 sobre los ocupados de la EPH (1er trimestre 2026):
# cinco atributos del puesto de trabajo como variables activas (categoria,
# educacion, cobertura de salud, tamanio del establecimiento, intensidad) y
# sexo, edad y region como suplementarias.
#
# Cada paso esta comentado en tres niveles:
#   QUE HACE    -> que calcula el bloque
#   COMO SE LEE -> que hay que mirar en el resultado
#   EN TU TP    -> como adaptarlo a la base del trabajo final
#
# COMO USARLO
# Ejecutar linea por linea (Ctrl+Enter). Al final hay ejercicios.
#
# PAQUETES
#   install.packages(c("FactoMineR", "factoextra"))
# ==============================================================================


# ---- 0. Preparacion ------------------------------------------------------

library(tidyverse)
library(FactoMineR)
library(factoextra)

options(scipen = 999)
theme_set(theme_minimal(base_size = 12))

# Ruta a la base. AJUSTAR si el script se corre desde otra carpeta.
ruta <- file.path("..", "diapositivas", "datos", "eph_ind_1t2026.rds")
eph <- readRDS(ruta)

# Si no tienen el archivo, se puede bajar del INDEC con el paquete eph:
# install.packages("eph")
# eph <- eph::get_microdata(year = 2026, trimester = 1, type = "individual")


# ==============================================================================
# 1. ARMAR LAS VARIABLES CATEGORICAS
# ==============================================================================
# MCA trabaja con variables categoricas (factores). La decision mas importante
# es COMO agrupar las categorias: cuantas, con que cortes, que hacer con los
# "no sabe / no responde". Eso cambia el resultado tanto como el algoritmo.
#
# Codigos usados (ver diseno de registro de la EPH):
#   ESTADO   1 = ocupado
#   CAT_OCUP 1 = patron, 2 = cuenta propia, 3 = asalariado
#   PP07H    descuento jubilatorio (asalariados): 1 = si, 2 = no
#   NIVEL_ED 1-3 y 7 = hasta secundario incompleto; 4-5 = secundario completo /
#            universitario incompleto; 6 = universitario completo
#   CH08     cobertura medica: 1 obra social (y combinaciones 12, 13, 123),
#            2 mutual / prepaga, 3 plan estatal, 4 no paga ni le descuentan
#   PP04C    cantidad de personas en el establecimiento (1 a 5 = hasta 5
#            personas, 6 a 8 = 6 a 40, 9 a 12 = mas de 40, 99 = ns/nr)
#   INTENSI  1 subocupado, 2 ocupado pleno, 3 sobreocupado, 4 no trabajo

vars_num <- c("ESTADO", "CAT_OCUP", "PP07H", "NIVEL_ED", "CH08", "PP04C",
              "INTENSI", "CH04", "CH06", "REGION", "PONDERA")

ocup <- eph |>
  mutate(across(all_of(vars_num), as.numeric)) |>
  filter(ESTADO == 1, CAT_OCUP %in% 1:3) |>
  transmute(
    categoria = case_when(CAT_OCUP == 1 ~ "Patron",
                          CAT_OCUP == 2 ~ "Cuenta propia",
                          CAT_OCUP == 3 & PP07H == 1 ~ "Asal. registrado",
                          CAT_OCUP == 3 & PP07H == 2 ~ "Asal. no registrado"),
    educacion = case_when(NIVEL_ED %in% c(1, 2, 3, 7) ~ "Hasta sec. incompleto",
                          NIVEL_ED %in% c(4, 5) ~ "Sec. completo",
                          NIVEL_ED == 6 ~ "Univ. completo"),
    salud = case_when(CH08 %in% c(1, 12, 13, 123) ~ "Obra social",
                      CH08 == 4 ~ "Sin cobertura",
                      CH08 %in% c(2, 3, 23) ~ "Prepaga / plan estatal"),
    tamanio = case_when(PP04C %in% 1:5 ~ "Hasta 5 personas",
                        PP04C %in% 6:8 ~ "6 a 40 personas",
                        PP04C %in% 9:12 ~ "Mas de 40 personas"),
    intensidad = case_when(INTENSI == 1 ~ "Subocupado",
                           INTENSI == 2 ~ "Ocupado pleno",
                           INTENSI == 3 ~ "Sobreocupado"),
    sexo   = if_else(CH04 == 1, "Varon", "Mujer"),
    edad   = cut(CH06, c(-Inf, 29, 49, Inf),
                 labels = c("Hasta 29 anios", "30 a 49 anios", "50 anios y mas")),
    region = factor(REGION, c(1, 40, 41, 42, 43, 44),
                    c("GBA", "NOA", "NEA", "Cuyo", "Pampeana", "Patagonia")),
    # Cobertura con las categorias chicas SIN agrupar (para la seccion 6)
    salud_det = case_when(CH08 %in% c(1, 12, 13, 123) ~ "Obra social",
                          CH08 == 4 ~ "Sin cobertura",
                          CH08 %in% c(2, 23) ~ "Mutual / prepaga",
                          CH08 == 3 ~ "Plan estatal"),
    edad_num = CH06,
    PONDERA
  )

# Cuantos casos perdemos por NA (ns/nr, no corresponde)?
colSums(is.na(ocup))
ocup <- ocup |> drop_na() |> mutate(across(categoria:salud_det, as.factor))
nrow(ocup)

# ---- 1.1 Frecuencias: buscar categorias raras ----
# QUE HACE: cuenta cada categoria. Las categorias con muy pocos casos (menos
#   del 2-5%) quedan lejisimos del origen y dominan el mapa.
ocup |>
  select(categoria:intensidad) |>
  pivot_longer(everything(), names_to = "variable", values_to = "categoria") |>
  count(variable, categoria) |>
  group_by(variable) |>
  mutate(pct = round(100 * n / sum(n), 1)) |>
  print(n = Inf)

# COMO SE LEE: "Patron" tiene ~5% y "Prepaga / plan estatal" ~6%. Estan en el
# limite. Por eso agrupamos prepaga con plan estatal (cada una por separado era
# todavia mas chica).

# EN TU TP: listar las categorias de cada variable con su frecuencia y agrupar
# las raras ANTES del MCA. Las variables numericas se convierten en tramos.


# ==============================================================================
# 2. EL MCA
# ==============================================================================
# QUE HACE: MCA() recibe un data frame de factores.
#   - quali.sup = posiciones de las columnas suplementarias
#   - quanti.sup = posiciones de numericas suplementarias (aca, la edad)
#   - row.w = ponderadores de cada fila (el PONDERA de la EPH)

base_mca <- ocup |>
  select(categoria, educacion, salud, tamanio, intensidad,   # 1-5 activas
         sexo, edad, region,                                 # 6-8 suplementarias
         edad_num) |>                                        # 9 numerica sup.
  as.data.frame()

res <- MCA(base_mca, quali.sup = 6:8, quanti.sup = 9,
           row.w = ocup$PONDERA, graph = FALSE)

# ---- 2.1 Inercia por dimension ----
res$eig[1:8, ]
fviz_screeplot(res, addlabels = TRUE)

# COMO SE LEE: la primera dimension resume ~23% de la inercia. En MCA los %
# son bajos por construccion: J categorias en Q variables generan J - Q
# dimensiones, la mayoria "ruido" de la codificacion 0/1.

# Correccion de Benzecri: solo cuentan los autovalores mayores que 1/Q
Q <- 5                                    # cantidad de variables activas
lambda <- res$eig[, 1]
benz <- ifelse(lambda > 1 / Q, ((Q / (Q - 1)) * (lambda - 1 / Q))^2, 0)
round(100 * benz / sum(benz), 1)[1:5]

# COMO SE LEE: con la correccion, la Dim 1 resume ~95% de la inercia "real".
# No comparar nunca los % de un MCA con los de un PCA.


# ==============================================================================
# 3. LAS CATEGORIAS
# ==============================================================================

# ---- 3.1 El mapa ----
fviz_mca_var(res, choice = "var.cat", repel = TRUE, col.var = "black",
             col.quali.sup = "gray50", labelsize = 3)

# Solo las activas, coloreadas por contribucion:
fviz_mca_var(res, choice = "var.cat", invisible = "quali.sup", repel = TRUE,
             col.var = "contrib", gradient.cols = c("gray70", "steelblue", "firebrick"))

# ---- 3.2 Coordenadas, contribuciones y cos2 ----
round(res$var$coord[, 1:2], 2)
round(res$var$contrib[, 1:2], 1)
round(res$var$cos2[, 1:2], 2)

fviz_contrib(res, choice = "var", axes = 1)
fviz_contrib(res, choice = "var", axes = 2)

# COMO SE LEE:
#   Dim 1 = formalidad: a un lado asalariado registrado, establecimientos
#   grandes, obra social, universitarios; al otro, sin cobertura, hasta 5
#   personas, subocupacion, cuenta propia.
#   Dim 2 = dos informalidades: asalariado no registrado (arriba) vs cuenta
#   propia (abajo).
#   - contrib: que categorias CONSTRUYEN el eje (las que hay que nombrar).
#   - cos2: que tan bien representada esta una categoria en el eje. Una
#     categoria con cos2 bajo puede estar cerca del origen solo porque su
#     diferencia esta en otra dimension.

# ---- 3.3 Variables (no categorias): eta2 ----
round(res$var$eta2[, 1:2], 2)
fviz_mca_var(res, choice = "mca.cor", repel = TRUE)

# COMO SE LEE: eta2 = R2 de un ANOVA de la coordenada contra la variable
# (clase 9). Categoria, tamanio y salud arman la Dim 1; la Dim 2 es casi solo
# categoria.

# ---- 3.4 Descripcion automatica ----
dimdesc(res, axes = 1:2)


# ==============================================================================
# 4. VARIABLES SUPLEMENTARIAS
# ==============================================================================

round(res$quali.sup$coord[, 1:2], 2)
round(res$quali.sup$v.test[, 1:2], 1)
res$quanti.sup$coord      # correlacion de la edad (numerica) con cada dimension

# COMO SE LEE: v.test es un estadistico tipo z: |v.test| > 2 indica que la
# categoria se aparta significativamente del origen en esa dimension. Con
# ~14.000 casos casi todo es "significativo": mirar sobre todo la magnitud de
# la coordenada. Los jovenes caen hacia la informalidad asalariada; Patagonia
# hacia la formalidad; el sexo casi no se mueve.

# EN TU TP: separar variables que DESCRIBEN el fenomeno (activas) de las que
# queremos USAR PARA INTERPRETARLO (suplementarias). Justificar la eleccion.


# ==============================================================================
# 5. LOS INDIVIDUOS
# ==============================================================================
# Con 14.000 puntos el grafico es una mancha. Dos alternativas: colorear por
# una variable o dibujar elipses de concentracion.

fviz_mca_ind(res, label = "none", habillage = "categoria",
             addEllipses = TRUE, ellipse.type = "confidence", alpha.ind = 0.1)

# Coordenadas de cada ocupado: se pueden usar como variables numericas
# (por ejemplo, la Dim 1 como un "indice de formalidad" del puesto)
coords <- as_tibble(res$ind$coord[, 1:2]) |>
  rename(dim1 = `Dim 1`, dim2 = `Dim 2`) |>
  bind_cols(select(ocup, sexo, edad, region, PONDERA))

coords |>
  group_by(region) |>
  summarise(dim1_media = weighted.mean(dim1, PONDERA)) |>
  arrange(dim1_media)


# ==============================================================================
# 6. QUE PASA CON UNA CATEGORIA RARA
# ==============================================================================
# QUE HACE: rehace el MCA con la cobertura de salud SIN agrupar: "Mutual /
#   prepaga" y "Plan estatal" por separado, cada una con pocos casos.

table(ocup$salud_det)
res_rara <- MCA(as.data.frame(select(ocup, categoria, educacion, salud = salud_det,
                                     tamanio, intensidad)),
                row.w = ocup$PONDERA, graph = FALSE)
res_rara$eig[1:6, ]
round(res_rara$var$coord[, 1:5], 2)
round(res_rara$var$contrib[, 1:5], 1)
fviz_mca_var(res_rara, axes = c(4, 5), repel = TRUE)

# COMO SE LEE: el plano 1-2 casi no cambia, pero mirar la Dim 5: "Plan
# estatal" (219 personas, 1,5% de la muestra) tiene coordenada ~7 y aporta
# ~43% de esa dimension. Una dimension entera construida por una categoria
# minuscula. Lo mismo pasa con "Patron" (5%) en las Dim 3 y 4. Las categorias
# raras se alejan del origen y se "roban" dimensiones: por eso se agrupan.


# ==============================================================================
# EJERCICIOS
# ==============================================================================
# 1. Pasar region a variable ACTIVA. Cambia la interpretacion de la Dim 1? Y
#    la Dim 2? Por que conviene (o no) tenerla como suplementaria?
#
# 2. Rehacer el MCA sin ponderar (sacar row.w). Cambian mucho las
#    coordenadas? Cuando seria importante ponderar?
#
# 3. Agregar el sector (PP04A: 1 estatal, 2 privado, 3 otro) como variable
#    activa, agrupando "otro" con privado. Que dimension se modifica?
#
# 4. Discretizar la edad en 5 tramos en lugar de 3 y usarla como activa.
#    Como se ubican los tramos en el mapa? Forman una "curva"? (efecto
#    herradura / Guttman: aparece cuando una variable ordinal domina)
#
# 5. Con las coordenadas de la Dim 1 (seccion 5), comparar la "formalidad"
#    media de varones y mujeres por grupo de edad. Coincide con lo que dice
#    el mapa de suplementarias?
#
# 6. EN TU TP: si tu base tiene variables categoricas, correr un MCA y
#    escribir un parrafo con la lectura de las dos primeras dimensiones.
