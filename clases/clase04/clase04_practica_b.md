# Práctica B — Clase 04: Joins y case_when

**Ciencia de Datos para Economía y Negocios | FCE-UBA**

---

## Instrucciones generales

- Todos los ejercicios utilizan el dataset `Datos_por_departamento_y_actividad.csv` ubicado en la carpeta `datos/` del repositorio.
- Resolver cada ejercicio en un único bloque encadenado con el pipe `|>`.
- Guardar cada resultado como un CSV dentro de `output/clase03/` usando `write_csv()`.
- En esta práctica se incorporan funciones nuevas: `case_when()`, `left_join()`, `inner_join()`, `anti_join()` y `tibble()`. Se pueden combinar con las funciones ya vistas (`select()`, `filter()`, `mutate()`, `summarise()`, `group_by()`, `arrange()`).

---

## Ejercicio 1 — Clasificación de provincias por nivel de empleo

Para el año **2022**, calcular el empleo total por **provincia** y luego clasificar cada provincia en una categoría usando `case_when()`:

| Empleo total            | Categoría    |
|-------------------------|--------------|
| Más de 500.000          | `"Alto"`     |
| Entre 100.000 y 500.000 | `"Medio"`    |
| Entre 10.000 y 100.000  | `"Bajo"`     |
| Menos de 10.000         | `"Muy bajo"` |

Ordenar por empleo total descendente.

El resultado debe tener las columnas: `provincia`, `empleo_total`, `categoria`.

**Pistas:**

- Primero agrupar por provincia y calcular el empleo total con `summarise()`.
- Luego usar `mutate()` con `case_when()` para crear la columna `categoria`.
- La sintaxis es: `case_when(condicion1 ~ "valor1", condicion2 ~ "valor2", .default = "otro")`.

---

## Ejercicio 2 — Tabla de referencia de sectores con left_join()

Crear una tabla auxiliar con `tibble()` que contenga los siguientes códigos de sector y su descripción:

| letra | sector                    |
|-------|---------------------------|
| `"A"` | `"Agro, ganadería y pesca"` |
| `"C"` | `"Industria manufacturera"` |
| `"F"` | `"Construcción"`            |
| `"G"` | `"Comercio"`                |
| `"K"` | `"Serv. financieros"`       |

Luego, para el año **2022**, calcular el empleo total por **sector** (`letra`) y unir la tabla de descripciones con `left_join()`. Ordenar de mayor a menor por empleo.

El resultado debe tener las columnas: `letra`, `empleo_total`, `sector`.

**Pistas:**

- Crear la tabla auxiliar antes de la cadena: `sectores <- tibble(letra = c("A", "C", ...), sector = c("Agro, ganadería y pesca", ...))`.
- Usar `left_join(sectores, by = "letra")` al final de la cadena.
- Los sectores que no estén en la tabla auxiliar tendrán `NA` en la columna `sector`.

---

## Ejercicio 3 — Variación del empleo entre 2021 y 2022 con inner_join()

Comparar el empleo total por **provincia** entre los años **2021** y **2022**. Para esto:

1. Crear un dataframe `empleo_2021` con el empleo total por provincia para 2021.
2. Crear un dataframe `empleo_2022` con el empleo total por provincia para 2022.
3. Unir ambas tablas con `inner_join()` por la columna `provincia`.
4. Calcular la variación porcentual: `(empleo_2022 - empleo_2021) / empleo_2021 * 100`.
5. Clasificar la variación con `case_when()`: `"Crecimiento fuerte"` si supera el 5%, `"Crecimiento moderado"` si está entre 0% y 5%, `"Caída"` si es negativa.
6. Ordenar de mayor a menor por variación.

El resultado debe tener las columnas: `provincia`, `empleo_2021`, `empleo_2022`, `variacion_pct`, `tendencia`.

**Pistas:**

- Al crear cada tabla, renombrar la columna de empleo para distinguirlas después del join. Por ejemplo: `summarise(empleo_2021 = sum(Empleo, na.rm = TRUE))`.
- `inner_join()` conserva solo las provincias que aparecen en **ambas** tablas.

---

## Ejercicio 4 — Departamentos sin actividad exportadora con anti_join()

Para el año **2022**, identificar qué **departamentos** de la provincia de Córdoba tienen empleo registrado pero **no tienen empresas exportadoras** en ningún sector.

Para esto:

1. Crear un dataframe `deptos_con_empleo` con los departamentos de Córdoba en 2022 que tengan `Empleo > 0`, quedándose solo con los nombres de departamento únicos (`distinct()`).
2. Crear un dataframe `deptos_exportadores` con los departamentos de Córdoba en 2022 que tengan `empresas_exportadoras > 0`, quedándose solo con los nombres de departamento únicos.
3. Usar `anti_join()` para encontrar los departamentos que están en `deptos_con_empleo` pero **no** en `deptos_exportadores`.

El resultado debe tener la columna: `departamento`.

**Pistas:**

- Para obtener departamentos únicos se puede usar `distinct(departamento)` o `summarise()` agrupando por departamento.
- La sintaxis es: `deptos_con_empleo |> anti_join(deptos_exportadores, by = "departamento")`.
- `anti_join()` devuelve las filas de la tabla izquierda que **no tienen** coincidencia en la tabla derecha.
