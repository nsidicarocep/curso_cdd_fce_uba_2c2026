# Práctica clase 10: tests de hipótesis con datos del Banco Mundial

**Ciencia de Datos para Economía y Negocios | FCE-UBA**

---

Estos ejercicios aplican los tests de la clase 9: diferencia de medias, test pareado, ANOVA, Tukey, tests no paramétricos y chi-cuadrado. No son de entrega obligatoria. Pueden empezarlos en la práctica y terminarlos en casa; las dudas las traen a la clase siguiente.

Los tres ejercicios usan el paquete `WDI`. La descarga necesita internet la primera vez; después guarden los datos con `write_rds()` y trabajen con la copia local.

```r
install.packages(c("tidyverse", "WDI", "rstatix"))
```

**Antes de cada test**, escriban H0 y H1 y miren los descriptivos. El p-valor se lee al final.

---

## Ejercicio A: desigualdad en el tiempo y entre regiones

### Pregunta central

*¿Cambió la desigualdad de ingresos en la última década? ¿Difiere entre regiones del mundo?*

### Datos

- **Indicador**: índice de Gini (0 a 100).
- **Código WDI**: `SI.POV.GINI`.
- **Fuente original**: World Bank Poverty and Inequality Platform.
- **Años**: 2010 a 2022.

```r
library(tidyverse)
library(WDI)

gini_raw <- WDI(country   = "all",
                indicator = c(gini = "SI.POV.GINI"),
                start     = 2010, end = 2022,
                extra     = TRUE)
```

**Advertencia**: el Gini no se mide todos los años en todos los países. Algunos tienen una sola medición en la década y otros tienen diez. Piensen bien cómo armar la base antes de testear.

### Preguntas guía

**1. Exploración**

- Saquen los agregados (`region != "Aggregates"`) y las filas sin Gini.
- ¿Cuántos países tienen al menos una medición? ¿Cuántos tienen al menos dos años distintos?
- Grafiquen la distribución del Gini usando la medición más reciente de cada país.

**2. Test pareado: ¿cambió el Gini?**

- Para cada país, quédense con la **primera** y la **última** medición del período. Descarten los países con una sola medición.
- Planteen H0 y H1 sobre la diferencia (última − primera).
- Corran el test pareado con `t.test(..., paired = TRUE)` y su versión no paramétrica, `wilcox.test(..., paired = TRUE)`.
- ¿Rechazan H0? ¿En qué dirección va el cambio?
- **Crítica al diseño**: la primera medición no es del mismo año para todos los países, y la distancia entre las dos mediciones tampoco. Calculen los años transcurridos entre ambas para cada país. ¿Qué supuesto implícito hacemos al compararlos así? ¿Cómo lo mejorarían?

**3. ANOVA: ¿el Gini difiere entre regiones?**

- Usen la medición **más reciente** de cada país. La variable `region` viene con `extra = TRUE`.
- Descriptivos por región: cantidad de países, media, mediana y desvío.
- **Ojo**: `North America` tiene solo 2 países con Gini (Estados Unidos y Canadá) y `South Asia` tiene pocos. ¿Qué consecuencia tiene eso sobre los intervalos de Tukey? ¿Conviene sacar North America del análisis o mantenerla?
- Planteen H0 y H1.
- Corran `aov()` y miren el QQ-plot de los residuos. Calculen el cociente entre el desvío más grande y el más chico: si supera 2, corran también `oneway.test()` (Welch).
- Corran `TukeyHSD()` y grafiquen los intervalos con `plot()`.
- ¿Qué regiones difieren significativamente? ¿Cuál tiene el Gini más alto en promedio?

**4. Reflexión**

- ¿Qué dice el test pareado sobre la evolución de la desigualdad? ¿Y el ANOVA sobre su distribución entre regiones?
- ¿Son resultados contradictorios o complementarios?

### Pistas técnicas

- Primera y última medición por país. El truco es crear una etiqueta (`inicio` / `fin`) **antes** de pivotar, porque los años no son los mismos para todos:

```r
gini_extremos <- gini_raw %>%
  filter(region != "Aggregates", !is.na(gini)) %>%
  group_by(iso3c) %>%
  filter(n() >= 2) %>%                          # al menos dos mediciones
  filter(year == min(year) | year == max(year)) %>%
  mutate(momento = if_else(year == min(year), "inicio", "fin")) %>%
  ungroup()
# ... sigan con pivot_wider(): una fila por país, una columna por momento
```

- Si pivotan con `names_from = year`, van a obtener una columna por año con casi todo `NA`.
- Para la medición más reciente: `group_by(iso3c) %>% filter(year == max(year))`.

---

## Ejercicio B: comercio internacional y grupo de ingreso

### Pregunta central

*¿Los países de ingreso alto comercian proporcionalmente más (respecto de su PBI) que el resto?*

### Datos

- **Indicador**: comercio como % del PBI (exportaciones + importaciones de bienes y servicios, sobre PBI).
- **Código WDI**: `NE.TRD.GNFS.ZS`.
- **Año**: 2022.

```r
comercio_raw <- WDI(country   = "all",
                    indicator = c(comercio_pbi = "NE.TRD.GNFS.ZS",
                                  poblacion    = "SP.POP.TOTL"),
                    start     = 2022, end = 2022,
                    extra     = TRUE)
```

La variable `income` clasifica a los países en `Low income`, `Lower middle income`, `Upper middle income` y `High income`. Es la clasificación **actual** del Banco Mundial, no la de 2022. Hay un país `Not classified`: sáquenlo.

### Preguntas guía

**1. Exploración**

- Filtren agregados y países sin dato.
- Descriptivos de `comercio_pbi` por grupo de ingreso: cantidad, media, mediana, desvío y máximo.
- Boxplot de `comercio_pbi` por `income`. ¿Qué países aparecen como outliers? ¿Qué tienen en común?
- En el grupo de ingreso alto, ¿la media y la mediana se parecen? ¿Por qué?

**2. Dos grupos: High income contra Upper middle income**

- Filtren esos dos grupos.
- Planteen H0 y H1 del t-test (bilateral) y de Mann-Whitney. Ojo: no son la misma hipótesis.
- Corran `t.test()` (Welch, que es el default) y `wilcox.test()`.
- Interpreten el IC 95% de la diferencia de medias.
- ¿Los dos tests dan p-valores parecidos? ¿Cuál se ve más afectado por Luxemburgo, Hong Kong o Singapur? Prueben sacar esos tres países y repetir los dos tests.

**3. Los cuatro grupos a la vez**

- En lugar de hacer un t-test por cada par de grupos, planteen un test global.
- Corran el ANOVA sobre `comercio_pbi` y sobre `log(comercio_pbi)`. Comparen los QQ-plots de los residuos.
- Corran Kruskal-Wallis (`kruskal.test()`). ¿Cambia el resultado si usan el logaritmo? ¿Por qué?
- Corran `TukeyHSD()` sobre el modelo en logaritmos. ¿Qué pares difieren?
- **Pregunta**: con 4 grupos hay 6 pares. Si hubieran hecho 6 t-tests sin corregir, ¿qué problema tendrían?

**4. Extensión: controlar por tamaño**

- Si los países chicos comercian más (no pueden producir todo internamente) y hay muchos países chicos entre los de ingreso alto, ¿estamos midiendo un "efecto ingreso" o un "efecto tamaño"?
- Clasifiquen los países en chicos (menos de 10 millones de habitantes) y grandes.
- Repitan la comparación High income contra Upper middle income **solo entre países grandes**. ¿Cambia la conclusión?
- Esto no es un análisis causal, pero muestra por qué un solo test rara vez responde una pregunta económica.

**5. Reflexión**

- ¿Qué diferencia hay entre "los países ricos comercian más" y "ser rico hace que un país comercie más"?
- ¿Un test de hipótesis puede distinguir entre esas dos afirmaciones?

---

## Ejercicio C: ¿el grupo de ingreso está asociado a la desigualdad?

### Pregunta central

*¿Los países con desigualdad alta se concentran en algunos grupos de ingreso?*

Usen la base de Gini del Ejercicio A, con la medición más reciente de cada país.

### Preguntas guía

**1. Armar las variables categóricas**

- Creen `desigualdad` con dos categorías: `"Alta"` si el Gini es 40 o más, `"Baja o media"` si es menor.
- Saquen los países `Not classified` en `income`.
- Armen la tabla de contingencia `income × desigualdad` con `table()` y agreguen los márgenes con `addmargins()`.
- Calculen los perfiles por fila con `prop.table(tabla, margin = 1)`. Bajo independencia, ¿cómo deberían verse?

**2. El test**

- Planteen H0 y H1.
- Corran `chisq.test()`. ¿Cuántos grados de libertad tiene y por qué?
- Revisen `$expected`. ¿Se cumple la regla de esperados grandes (todos ≥ 1 y al menos 80% ≥ 5)? Si no, usen `simulate.p.value = TRUE`.
- Miren los residuos estandarizados (`$stdres`, no `$residuals`). ¿En qué celdas está la asociación?
- Calculen la V de Cramér: `sqrt(chi2 / (n * (min(filas, columnas) - 1)))`.

**3. El umbral es una decisión**

- Repitan el test con el umbral en 35 y en 45. ¿Cambia la conclusión? ¿Y la V de Cramér?
- ¿Qué se pierde al convertir una variable numérica (Gini) en categórica? ¿Qué test del Ejercicio A responde una pregunta parecida sin cortar la variable?

---

## Si quieren feedback

No es obligatorio. Si quieren devolución pueden enviar:

- Un script `.R` o un `.Rmd` con el código comentado.
- Las respuestas a las preguntas guía en comentarios o en el texto.
- Un párrafo corto de reflexión por ejercicio.

Lo que importa no es que el código sea perfecto sino que el razonamiento sea claro: qué H0 plantean, qué test eligen, por qué y cómo interpretan el resultado.
