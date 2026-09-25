# Práctica clase 12: índices económicos

**Ciencia de Datos para Economía y Negocios | FCE-UBA**

---

Esta práctica aplica los índices de la clase 11: concentración (CR4, CR8, HHI), comercio internacional (Balassa, Grubel-Lloyd) y desigualdad (Gini, Theil). No son de entrega obligatoria. Pueden empezarlos en la práctica y terminarlos en casa; las dudas las traen a la clase siguiente.

Los índices compuestos (IDH, competitividad) tienen su propia clase. La complejidad económica la vamos a ver de forma cualitativa con el Atlas de Harvard, sin programarla.

```r
install.packages(c("tidyverse", "fst", "eph", "scales"))
```

---

## Los scripts

| Script | Contenido | Datos |
|---|---|---|
| `01_concentracion_baci.R` | CR_k, HHI, número equivalente. Destinos y productos. | BACI 2024 |
| `02_comercio_baci.R` | RCA de Balassa, RSCA, diversidad, Grubel-Lloyd. | BACI 2024 |
| `03_desigualdad_gini_theil.R` | Gini, curva de Lorenz, Theil y su descomposición. | BACI 2024 + EPH |

Se corren en orden. Cada uno se puede correr solo, pero los conceptos se encadenan.

---

## Los datos

**BACI (CEPII)** es la base de comercio bilateral mundial: para cada año, cuánto le exportó cada país a cada otro país en cada producto a 6 dígitos del Sistema Armonizado. Está en `datos/baci/` en formato `.fst` porque son 11,25 millones de filas.

Tres cosas de las que acordarse siempre:

- **`v` está en MILES de dólares.** Todos los umbrales del curso se escriben en esa unidad. Un piso de `10000` son 10 millones, no 10 mil ni 100 millones.
- **`k` es un `integer`, no texto.** El código 080810 está guardado como 80810. Antes de cortar capítulos o partidas hay que hacer `str_pad(k, 6, "left", "0")`.
- **El catálogo de países repite el ISO3.** BEL, DEU y SDN aparecen dos veces, con el código actual y uno histórico. Hay que filtrar el catálogo antes de usarlo como clave.

**EPH (INDEC)**: base individual del T3 2025, en `datos/usu_individual_T325.txt`. El archivo usa **coma decimal**, así que hay que leerlo con `locale(decimal_mark = ",", grouping_mark = ".")`. Sin eso, readr interpreta la coma como separador de miles y los ingresos salen cien veces más grandes, en silencio.

---

## Ejercicio A: el perfil comercial de un país

### Pregunta central

*¿De qué depende un país para vender, y qué tan frágil lo hace eso?*

### Consigna

Elijan un país que no sea Argentina. Sugerencias con perfiles bien distintos: Chile, Vietnam, Nigeria, Polonia, Nueva Zelanda, Marruecos.

**1. Concentración de destinos**

- Calculen CR1, CR4, CR8 y HHI de sus destinos de exportación.
- Traduzcan el HHI a número equivalente de socios. ¿Cómo se compara con la cantidad real de destinos?
- Ubíquenlo en la distribución mundial: ¿en qué percentil de HHI está?

**2. Concentración de productos**

- Calculen el HHI de su canasta exportadora a HS2, HS4 y HS6.
- **Antes de correr el código**, escriban cuál esperan que sea mayor y por qué. La justificación tiene que ser aritmética, no económica.

**3. Ventaja comparativa**

- Listen las 15 partidas con mayor RCA, con un umbral de valor razonable.
- Verifiquen si el umbral cambia el resultado (como con Nueva Caledonia en el script 02). Si cambia, decidan cuál reportar y justifiquen.

**4. Comercio intraindustrial**

- Calculen el GL agregado a HS4 y el GL de las 10 partidas de mayor comercio.
- ¿El perfil es intraindustrial o interindustrial? ¿Se corresponde con lo que predice el modelo ricardiano o con lo que predice Krugman?

**5. La síntesis**

Escriban un párrafo de no más de diez líneas describiendo el perfil comercial del país usando los cuatro índices. Regla: cada número que citen tiene que ir acompañado del nivel de desagregación y el umbral con el que se calculó.

---

## Ejercicio B: la sensibilidad de un ranking

### Pregunta central

*¿Cuánto de un ranking es el fenómeno y cuánto son nuestras decisiones?*

### Consigna

Construyan el ranking de los 20 países más concentrados en destinos, cuatro veces:

1. Sin ningún filtro.
2. Con piso de exportaciones de 10 millones de USD.
3. Con piso de 1.000 millones de USD.
4. Sin piso de valor, pero exigiendo al menos 50 destinos.

**Preguntas**

- ¿Cuántos países aparecen en los cuatro rankings? Ese número es una medida de robustez.
- ¿Hay algún país que esté primero en uno y no aparezca en otro? ¿Qué tiene de particular?
- Armen un gráfico que muestre cómo se mueve la posición de cada país entre los cuatro criterios (un *bump chart*, o líneas que unan las posiciones).
- Si tuvieran que publicar un solo ranking, ¿cuál elegirían? Escriban las tres líneas de nota metodológica que lo acompañarían.

**El punto del ejercicio** no es encontrar el ranking correcto. Es que se acostumbren a que un índice sin su nota metodológica no es un resultado.

---

## Ejercicio C: desigualdad, dos preguntas distintas

### Pregunta central

*¿La desigualdad argentina es entre grupos o dentro de los grupos?*

### Consigna

**1. Dos variables de ingreso**

- Calculen el Gini de P21 (ingreso de la ocupación principal, ponderador PONDIIO) y el de IPCF (ingreso per cápita familiar, ponderador PONDIH).
- Expliquen en tres líneas por qué dan distinto y cuál de los dos usa el INDEC en su informe de ingresos.

**2. Descomposición de Theil**

Descompongan el Theil del ingreso laboral según tres particiones distintas:

- región
- nivel educativo
- sexo

**Importante**: las tres tienen que correr sobre la misma muestra. Verifiquen con `nrow()` antes de comparar.

- ¿Cuál tiene el componente "entre grupos" más alto?
- Para la partición por sexo: calculen también la brecha de ingresos con `weighted.mean()`. ¿Por qué una brecha grande puede convivir con un componente "entre" chico?

**3. La crítica**

- ¿Qué porcentaje de los ocupados quedó afuera por no declarar ingresos?
- Comparen la distribución de los que declaran y los que no según nivel educativo y categoría ocupacional (`CAT_OCUP`). ¿Los que no responden se parecen a los que sí?
- Si los que no responden ganaran sistemáticamente más, ¿nuestro Gini sobreestima o subestima la desigualdad? Justifiquen.

**4. La curva de Lorenz**

- Grafiquen la curva de Lorenz de dos regiones con Gini parecido. ¿Se cruzan?
- Si se cruzan, ¿qué quiere decir que el Gini las ordene igual? ¿Qué información se perdió al resumir la curva en un número?

---

## Ejercicio D: integrador

Elijan **una** de estas dos:

**D.1 — Concentración y desigualdad son la misma cuenta**

El Gini, el HHI y el Theil se pueden aplicar a cualquier distribución. Tomen las exportaciones mundiales por país (no por producto) y calculen los tres índices sobre esa distribución. Después descompongan el Theil agrupando los países por continente o por nivel de ingreso.

¿Qué proporción de la desigualdad del comercio mundial es entre continentes y qué proporción es dentro de cada uno? Comparen ese resultado con el de la EPH por región del ejercicio C.

**D.2 — Un índice propio**

Construyan un índice de "fragilidad comercial" que combine concentración de destinos y concentración de productos en un solo número para cada país.

Tienen que decidir: cómo normalizar cada componente, qué peso darle a cada uno y a qué nivel de desagregación calcular el de productos.

Después, la parte importante: hagan un análisis de sensibilidad. Cambien los pesos (70/30, 50/50, 30/70) y vean cuánto se mueve el top 10. Si el ranking cambia mucho con un cambio chico de pesos, el índice es frágil y hay que decirlo.

Este ejercicio anticipa la clase de índices compuestos.

---

## Para revisar antes de entregar cualquier resultado

- [ ] ¿Aclaré el nivel de desagregación de cada índice que reporto?
- [ ] ¿Aclaré los umbrales y filtros que apliqué?
- [ ] ¿Verifiqué que las claves de mis `join` sean únicas?
- [ ] ¿Los órdenes de magnitud tienen sentido? (locale, unidades, overflow)
- [ ] ¿Comparé poblaciones y variables comparables entre sí?
- [ ] ¿Dije qué quedó afuera de la muestra y por qué?

---

## Para profundizar

- Balassa, B. (1965), "Trade Liberalisation and Revealed Comparative Advantage".
- Grubel, H. y Lloyd, P. (1975), *Intra-Industry Trade*.
- Schteingart, D. y Makari, P., *Una nueva inserción comercial argentina* (tiene varios de estos índices calculados para Argentina).
- Atlas of Economic Complexity, Harvard: [atlas.cid.harvard.edu](https://atlas.cid.harvard.edu)
- Documentación de BACI: [cepii.fr](http://www.cepii.fr/CEPII/en/bdd_modele/bdd_modele_item.asp?id=37)
