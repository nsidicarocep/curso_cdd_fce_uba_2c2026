# Práctica — Clase 04: Tidyverse

**Ciencia de Datos para Economía y Negocios | FCE-UBA**

---

## Instrucciones generales

- Todos los ejercicios utilizan el dataset `Datos_por_departamento_y_actividad.csv` ubicado en la carpeta `datos/` del repositorio.
- Resolver cada ejercicio en un único bloque encadenado con el pipe `|>`.
- Guardar cada resultado como un CSV dentro de `output/clase03/` usando `write_csv()`.
- Se pueden usar solamente las funciones vistas en clase: `read_csv()`, `select()`, `filter()`, `mutate()`, `arrange()`, `summarise()`, `group_by()` y el pipe `|>`.

---

## Ejercicio 1 — Peso de la industria manufacturera en Buenos Aires

Obtener, para cada **departamento** de la provincia de Buenos Aires en el año **2022**, la cantidad de trabajadores en la rama industrial (letra `"C"`) y su participación (share) sobre el empleo total de ese departamento. Ordenar de mayor a menor por share industrial y quedarse únicamente con los departamentos que tengan **más de 500 empleos industriales**.

El resultado debe tener las columnas: `departamento`, `empleo_industrial`, `empleo_total`, `share_industrial`.

**Pistas:**

- Primero filtrar provincia y año para trabajar con un dataset más chico.
- Dentro de `summarise()` se puede calcular una suma condicional: `sum(Empleo[letra == "C"])` suma solamente las filas donde la letra es `"C"`, sin necesidad de hacer un filtro previo.
- El share se calcula como `empleo_industrial / empleo_total` (puede multiplicarse por 100 para expresarlo en porcentaje).

---

## Ejercicio 2 — Tamaño medio de los establecimientos por provincia

Para el año **2022**, calcular por **provincia** el empleo total, la cantidad total de establecimientos y el tamaño promedio de los establecimientos (empleados por establecimiento). Luego, crear una columna que indique si el tamaño promedio de la provincia está **por encima o por debajo de la mediana nacional** de ese indicador (es decir, la mediana de los valores provinciales calculados). Ordenar de mayor a menor por tamaño promedio.

El resultado debe tener las columnas: `provincia`, `empleo_total`, `establecimientos_total`, `emp_por_estab`, `categoria` (valores: `"Por encima de la mediana"` / `"Por debajo de la mediana"`).

**Pistas:**

- Calcular `emp_por_estab` como `sum(Empleo) / sum(Establecimientos)` dentro del `summarise()`, **no** como `mean(Empleo / Establecimientos)` (¿por qué?).
- La columna `categoria` se puede crear con `ifelse()` dentro de un `mutate()` posterior al `summarise()`.
- Dentro del `ifelse()` se puede usar `median(emp_por_estab)` directamente; como no hay `group_by()` activo en ese paso, calcula la mediana sobre todas las provincias.

---

## Ejercicio 3 — Sectores con mayor presencia exportadora

Para el año **2021**, calcular por **sector de actividad** (columna `letra`) la cantidad total de establecimientos y la cantidad total de empresas exportadoras. Crear una columna con la tasa de exportación (`empresas_exportadoras / establecimientos * 100`). Filtrar únicamente los sectores que tengan al menos **1.000 establecimientos** y ordenar de mayor a menor por tasa de exportación.

El resultado debe tener las columnas: `letra`, `establecimientos`, `exportadoras`, `tasa_exportacion`.

**Pistas:**

- Recordar que `filter()` puede aplicarse tanto antes del `summarise()` (para filtrar filas del dataset original) como después (para filtrar filas del resumen).
- En este ejercicio conviene filtrar el año **antes** de agrupar y el mínimo de establecimientos **después** de calcular los totales.
