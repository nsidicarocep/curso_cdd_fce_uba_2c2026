# Práctica — Clase 2: Introducción a R

**Ciencia de Datos para Economía y Negocios | FCE-UBA**

## Instrucciones

- Resolvé cada ejercicio en un script `.R` nuevo. Guardalo como `practica_clase02.R`.
- Ejecutá cada línea con `Ctrl + Enter` y verificá el resultado en la consola.
- Si te trabás, revisá el script de clase (`clase_02_script.R`) o usá `?nombre_funcion` para consultar la ayuda.

---

## Parte 1: Variables y tipos de datos

**Ejercicio 1.1** — Creá las siguientes variables y verificá el tipo de cada una con `class()`:

| Variable | Valor |
|---|---|
| `pais` | "Uruguay" |
| `poblacion` | 3.4 |
| `anio_censo` | 2023L |
| `es_mercosur` | TRUE |

**Ejercicio 1.2** — Calculá el PBI per cápita de Uruguay sabiendo que su PBI es de 77.2 miles de millones de dólares y su población es de 3.4 millones. Guardá el resultado en una variable llamada `pbi_pc` y mostralo en la consola.

**Ejercicio 1.3** — ¿Qué pasa si ejecutás lo siguiente? ¿Por qué?

```r
mi_variable <- 10
Mi_Variable
```

---

## Parte 2: Vectores

**Ejercicio 2.1** — Creá un vector `paises` con los nombres de los 5 países del Mercosur: Argentina, Brasil, Paraguay, Uruguay y Venezuela. Luego creá un vector `poblaciones` con sus poblaciones aproximadas en millones: 46, 214, 7, 3.4, 28.

**Ejercicio 2.2** — Usando los vectores anteriores:

- a) Accedé al tercer elemento de `paises`.
- b) Accedé a los elementos 1, 2 y 4 de `poblaciones`.
- c) Mostrá todos los países excepto el último.

**Ejercicio 2.3** — Creá un vector `anios` que contenga todos los años desde 2000 hasta 2024 usando el operador `:`. ¿Cuántos elementos tiene? Verificalo con `length()`.

**Ejercicio 2.4** — Usando el vector `poblaciones`:

- a) Calculá la población total del Mercosur con `sum()`.
- b) Calculá la población promedio con `mean()`.
- c) ¿Cuál es el país con mayor población? Usá `max()` para encontrar el valor y luego `which.max()` para encontrar la posición. Combinalo con `paises` para obtener el nombre.

**Ejercicio 2.5** — Usá una condición lógica para obtener los nombres de los países con más de 10 millones de habitantes.

---

## Parte 3: Listas

**Ejercicio 3.1** — Creá una lista llamada `universidad` que contenga:

- `nombre`: "Universidad de Buenos Aires"
- `fundacion`: 1821
- `facultades`: un vector con al menos 3 facultades que conozcas
- `publica`: TRUE

**Ejercicio 3.2** — A partir de la lista anterior:

- a) Accedé al nombre de la universidad usando `$`.
- b) Accedé a la segunda facultad del vector.
- c) ¿En qué año se fundó? Mostralo en consola.

---

## Parte 4: Data Frames

**Ejercicio 4.1** — Creá un data frame llamado `mercosur` con la siguiente información:

| pais | poblacion | pbi | moneda |
|---|---|---|---|
| Argentina | 46 | 632 | Peso |
| Brasil | 214 | 1920 | Real |
| Paraguay | 7 | 42 | Guaraní |
| Uruguay | 3.4 | 77 | Peso |

**Ejercicio 4.2** — Usando el data frame anterior:

- a) ¿Cuántas filas y columnas tiene? Usá `nrow()` y `ncol()`.
- b) Mostrá solo la columna de PBI.
- c) Mostrá las filas de los países con PBI mayor a 100.
- d) Calculá el PBI per cápita (PBI / población) y agregalo como nueva columna llamada `pbi_pc`.

**Ejercicio 4.3** — Usá `summary()` sobre el data frame. ¿Qué información te da para las columnas numéricas? ¿Y para las de texto?

---

## Parte 5: Operadores

**Ejercicio 5.1** — Sin ejecutar el código, predecí el resultado de cada expresión. Después verificá en R:

```r
15 %% 4
2 ^ 10
100 == 99 + 1
"hola" == "Hola"
TRUE & FALSE
TRUE | FALSE
!(5 > 3)
```

**Ejercicio 5.2** — Dado el vector `edades <- c(22, 35, 19, 41, 28, 17, 33)`:

- a) ¿Cuáles son mayores de edad (>= 18)?
- b) ¿Cuáles están entre 20 y 35 (inclusive)?
- c) ¿Cuántas personas son menores de 20? (Tip: `sum()` sobre un vector lógico cuenta los `TRUE`).

---

## Parte 6: Funciones

**Ejercicio 6.1** — Dado el vector `salarios <- c(45000, 62000, NA, 38000, 71000, NA, 55000)`:

- a) Calculá el salario promedio. ¿Qué pasa?
- b) Calculá el promedio ignorando los valores faltantes.
- c) ¿Cuántos valores faltantes hay?
- d) ¿Cuál es el salario máximo? ¿Y el mínimo? (Recordá el argumento `na.rm`).

**Ejercicio 6.2** — Usá `paste()` para construir la frase: "El PBI de Argentina es 632 miles de millones de dólares" a partir de las variables `pais`, `pbi` (que ya tenés creadas arriba). Tip: `paste()` acepta múltiples argumentos.

**Ejercicio 6.3** — Redondeá los siguientes valores a 1 decimal: `c(3.14159, 2.71828, 1.41421)`. Guardá el resultado en una variable.

---

## Parte 7: Pidiendo ayuda

**Ejercicio 7.1** — Usá `?seq` para consultar la documentación de la función `seq()`. ¿Qué hace el argumento `length.out`? Probalo creando una secuencia de 0 a 100 con exactamente 11 elementos.

**Ejercicio 7.2** — Buscá qué hace la función `rev()`. Usala para invertir el vector `paises` que creaste antes.

---

## Desafío opcional

Creá un data frame con datos de 5 productos de un supermercado (nombre, precio, cantidad en stock, categoría). Luego:

1. Mostrá los productos con precio mayor a 1000.
2. Calculá el valor total en stock de cada producto (precio × cantidad) y agregalo como columna.
3. ¿Cuál es el valor total del inventario?
4. ¿Cuál es el precio promedio por categoría? (Tip: no necesitás tidyverse, podés filtrar manualmente cada categoría con `mean(df$precio[df$categoria == "..."])`).
