# Práctica integradora: EPH-INDEC

**Ciencia de Datos para Economía y Negocios | FCE-UBA**

En esta práctica van a trabajar con la **base de datos de personas de la EPH-INDEC** (último trimestre disponible). El objetivo es integrar los temas vistos en clase: *joins*, *pivots*, estadísticas descriptivas, lógica condicional (`case_when` / `if_else`), cálculo de proporciones y de diferencias porcentuales.

> ⚠️ **Importante:** todos los cálculos deben realizarse usando **valores ponderados** (revisá el factor de expansión correspondiente a la base de personas en el diseño de registro de la EPH). Son dos ponderadores distintos los de ingresos y los de personas, ya que el primero corrige la no respuesta. Buscar en el final de la documentación de EPH esos ponderadores. 

> 📖 **Pista general:** antes de empezar, abrí el documento de diseño de registro de la EPH y ubicá las variables vinculadas a: aglomerado urbano, nivel educativo alcanzado, ingreso de la ocupación principal, categoría ocupacional (asalariado / no asalariado), descuentos jubilatorios y condición de actividad. 

---

## Parte 1 — Preparación de los datos

1. Cargá la base de personas de la EPH del último trimestre disponible.
2. Filtrá la base para quedarte únicamente con **trabajadores asalariados**.
3. Creá una nueva variable llamada `nivel_educativo` que asigne **etiquetas con nombres reales** a cada categoría educativa (por ejemplo: *"Primario incompleto"*, *"Primario completo"*, *"Secundario incompleto"*, *"Secundario completo"*, *"Superior incompleto"*, *"Superior completo"*, *"Sin instrucción"*). **No uses los códigos numéricos de INDEC en las tablas finales.**
   - 💡 Usá `case_when()` para hacer la recodificación de manera ordenada.
4. Creá otra variable llamada `condicion_registro` que tome los valores `"Registrado"` o `"No registrado"`, según si al trabajador le realizan o no descuentos jubilatorios.
   - 💡 Para esta variable binaria, `if_else()` puede ser más simple que `case_when()`.
5. Creá una variable `aglomerado_nombre` con el nombre del aglomerado urbano (no el código numérico). Podés ayudarte con una tabla de equivalencias armada manualmente con los aglomerados que aparecen en la base (o pedirle al chat que arme esa recodificación. En ese caso, cargar el documento metodológico de EPH para que no invente los códigos de EPH).

---

## Parte 2 — Estadísticas descriptivas ponderadas

Usando las funciones ponderadas vistas en clase (`mediana_ponderada`, `desvio_ponderado`, etc.) y la lógica de `weighted.mean()`:

1. Calculá el **salario promedio ponderado** por aglomerado urbano. Ordená la tabla de mayor a menor.
2. Calculá el **salario promedio ponderado** por nivel educativo (a nivel nacional).
3. Para cada aglomerado, calculá además del salario promedio:
   - El **desvío estándar ponderado** del salario.
   - El **coeficiente de dispersión** (desvío / media).
   ¿Qué aglomerados tienen mayor heterogeneidad salarial relativa? ¿Qué interpretación económica le darías?
   ¿Qué otras conclusiones podés sacar sobre este punto?

---

## Parte 3 — Pivots y diferencias salariales por condición de registro

1. Calculá el salario promedio ponderado **cruzando aglomerado y condición de registro** (registrado / no registrado). El resultado debería ser una tabla "larga" con tres columnas: aglomerado, condición y salario promedio.
2. **Pivoteá** la tabla para que quede en formato ancho: una fila por aglomerado y dos columnas (`Registrado` y `No registrado`) con los salarios promedio.
3. Agregá dos columnas nuevas:
   - `diferencia_absoluta`: diferencia entre el salario de los registrados y el de los no registrados.
   - `diferencia_relativa`: variación porcentual del salario de los registrados respecto al de los no registrados (algo similar a `(registrado - no_registrado) / no_registrado * 100`).
4. ¿En qué aglomerado la brecha relativa entre registrados y no registrados es mayor? ¿Y dónde es menor?

---

## Parte 4 — Pivots y diferencias salariales por nivel educativo

Repetí la lógica de la Parte 3, pero ahora cruzando **aglomerado y nivel educativo**.

1. Calculá el salario promedio ponderado por aglomerado y nivel educativo.
2. Pivoteá a formato ancho (filas: aglomerados; columnas: niveles educativos).
3. Calculá la diferencia **absoluta** y **relativa** entre los trabajadores con **estudios superiores completos** y los que tienen **hasta secundario completo**.
4. **Pregunta clave:** ¿cuál es el aglomerado donde la brecha salarial entre quienes tienen estudios superiores y quienes solo llegaron hasta secundario completo es más grande? ¿Y dónde es más chica? ¿Qué hipótesis podrías plantear sobre las causas?

---

## Parte 5 — Proporciones por nivel educativo

1. Para cada nivel educativo, calculá la **proporción ponderada** de trabajadores asalariados que son **registrados** y la proporción que son **no registrados** (las dos proporciones deben sumar 1 dentro de cada nivel educativo).
2. Presentá el resultado en una tabla en formato ancho.
3. **Pregunta clave:** ¿en qué niveles educativos los trabajadores **no registrados** superan en proporción a los registrados? ¿Qué lectura económica te sugiere ese patrón?

---

## Parte 6 — Joins: armar una tabla final por aglomerado

El objetivo de esta parte es practicar `*_join()` consolidando información en una **única tabla a nivel de aglomerado**.

Construí por separado las siguientes tablas auxiliares (todas ponderadas, todas a nivel de aglomerado):

- **Tabla A:** proporción de población ocupada en cada nivel educativo, por aglomerado. (Tip: probá pivotear para tener una columna por nivel educativo.)
- **Tabla B:** proporción de asalariados registrados y no registrados, por aglomerado.
- **Tabla C:** tasa de desempleo por aglomerado. Recordá la definición: desocupados sobre población económicamente activa (ocupados + desocupados). Vas a necesitar la variable de condición de actividad.

Una vez que tengas las tres tablas:

1. Uní las tres mediante *joins* en una única tabla final llamada `aglomerados_resumen`, con una fila por aglomerado.
2. Pensá qué tipo de join conviene usar (`left_join`, `inner_join`, `full_join`) y justificá brevemente la elección.
3. Verificá que no se haya perdido ni duplicado ningún aglomerado en el camino.

---

