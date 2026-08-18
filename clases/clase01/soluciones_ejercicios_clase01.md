# Soluciones — Ejercicios de Pseudocódigo (Clase 1)

**Ciencia de Datos para Economía y Negocios | FCE-UBA | Nicolás Sidicaro**

---

## Ejercicio A: Clasificar alumnos

**Enunciado:** Dado un listado de notas de estudiantes (0 a 10), escribir un algoritmo que clasifique a cada estudiante como "promocionado" (nota >= 7), "aprobado" (nota >= 4) o "desaprobado" (nota < 4). Al final, mostrar cuántos hay en cada categoría.

### Solución

```
INICIO
    LEER lista_notas
    promocionados ← 0
    aprobados ← 0
    desaprobados ← 0

    PARA CADA nota EN lista_notas:
        SI nota >= 7 ENTONCES
            promocionados ← promocionados + 1
        SINO SI nota >= 4 ENTONCES
            aprobados ← aprobados + 1
        SINO
            desaprobados ← desaprobados + 1

    MOSTRAR "Promocionados:", promocionados
    MOSTRAR "Aprobados:", aprobados
    MOSTRAR "Desaprobados:", desaprobados
FIN
```

### ¿Qué conceptos de la clase se aplican acá?

**Estructuras de control usadas:** iteración (`PARA CADA`) y condicional anidado (`SI ... SINO SI ... SINO`).

**Tipos de datos involucrados:** numérico (las notas y los contadores) y texto (las categorías, aunque acá solo se usan como etiquetas al mostrar).

**El orden de las condiciones importa.** Lo primero que se evalúa `nota >= 7` y recién después `nota >= 4`. Si se invirtiera el orden, un estudiante con nota 9 entraría en "aprobado" (porque 9 >= 4 es verdadero) y nunca llegaría a evaluarse si es promocionado. Este es un error muy común: cuando las categorías se solapan, hay que evaluar primero la condición más restrictiva.

**Patrón: contadores.** Las tres variables (`promocionados`, `aprobados`, `desaprobados`) arrancan en 0 y se incrementan de a 1 cada vez que se cumple la condición correspondiente. Es un patrón que van a usar constantemente en programación.

---

## Ejercicio B: Canasta básica

**Enunciado:** Dada una lista de productos con sus precios de enero y de febrero, escribir un algoritmo que calcule la variación porcentual de cada producto y determine cuál tuvo la mayor suba de precio.

### Solución

```
INICIO
    LEER lista_productos
    // Cada producto tiene: nombre, precio_enero, precio_febrero

    mayor_variacion ← -infinito
    producto_mayor ← ""

    PARA CADA producto EN lista_productos:
        variacion ← (producto.precio_febrero - producto.precio_enero) / producto.precio_enero * 100
        MOSTRAR producto.nombre, "variación:", variacion, "%"

        SI variacion > mayor_variacion ENTONCES
            mayor_variacion ← variacion
            producto_mayor ← producto.nombre

    MOSTRAR "Mayor suba:", producto_mayor, "con", mayor_variacion, "%"
FIN
```

### ¿Qué conceptos de la clase se aplican acá?

**Estructuras de control usadas:** iteración (`PARA CADA`) y condicional simple (`SI ... ENTONCES`).

**Tipos de datos involucrados:** numérico decimal (precios y variación porcentual) y texto (nombre de producto).

**Fórmula de variación porcentual.** La expresión `(precio_febrero - precio_enero) / precio_enero * 100` es la fórmula estándar de variación porcentual que se usa en economía. Noten que se divide por el precio del período base (enero).

**Patrón: encontrar el máximo.** Para determinar cuál producto tuvo la mayor suba, se usa una técnica clásica: se inicializa `mayor_variacion` en `-infinito` (un valor tan bajo que cualquier variación real lo supera) y se va actualizando cada vez que se encuentra un valor más alto. Este patrón es muy frecuente: funciona igual para encontrar el mínimo (inicializando en `+infinito` y usando `<` en vez de `>`).

**¿Por qué `-infinito` y no `0`?** Si todos los productos hubieran bajado de precio, la mayor variación sería negativa (por ejemplo, -2%). Si hubiéramos inicializado en 0, el algoritmo no la detectaría porque -2 no es mayor que 0. Usando `-infinito` nos aseguramos de que funcione con cualquier dato válido — una de las propiedades que tiene que tener un buen algoritmo.

**Notación con punto** (`producto.nombre`). Es una forma de acceder a un atributo dentro de una estructura. Todavía no lo vimos en R, pero conceptualmente es como decir "el campo `nombre` dentro de la variable `producto`". En R lo equivalente sería `producto$nombre` o acceder a una columna de un dataframe.

---

## Ejercicio C: Filtrar provincias

**Enunciado:** Dada una tabla con provincias y su tasa de desempleo, escribir un algoritmo que seleccione solo las provincias con desempleo mayor al promedio nacional y las ordene de mayor a menor.

### Solución

```
INICIO
    LEER tabla_provincias
    // Cada fila tiene: nombre, tasa_desempleo

    // --- Paso 1: calcular el promedio nacional ---
    suma ← 0
    contador ← 0
    PARA CADA provincia EN tabla_provincias:
        suma ← suma + provincia.tasa_desempleo
        contador ← contador + 1
    promedio_nacional ← suma / contador

    // --- Paso 2: filtrar las que superan el promedio ---
    lista_filtrada ← []
    PARA CADA provincia EN tabla_provincias:
        SI provincia.tasa_desempleo > promedio_nacional ENTONCES
            AGREGAR provincia A lista_filtrada

    // --- Paso 3: ordenar de mayor a menor ---
    ORDENAR lista_filtrada POR tasa_desempleo DESCENDENTE

    MOSTRAR "Promedio nacional:", promedio_nacional
    MOSTRAR lista_filtrada
FIN
```

### ¿Qué conceptos de la clase se aplican acá?

**Estructuras de control usadas:** dos iteraciones (`PARA CADA`) y un condicional (`SI ... ENTONCES`).

**Tipos de datos involucrados:** numérico decimal (tasa de desempleo, promedio), texto (nombre de provincia) y una estructura de tipo tabla/lista.

**Descomposición en tres pasos.** Este ejercicio es el que más directamente conecta con la idea de *pensamiento computacional* que vimos al inicio de la clase. El problema se descompone en tres subproblemas independientes: calcular el promedio, filtrar y ordenar. Cada uno podría resolverse por separado, y de hecho en la Clase 3 (Tidyverse) van a ver que cada paso se traduce casi literalmente a una función de R: `mean()`, `filter()` y `arrange()`.

**Patrón: acumulador para el promedio.** Para calcular el promedio se necesitan dos cosas: la suma total y la cantidad de elementos. Se recorre la lista una vez acumulando ambos valores, y después se divide. Es el mismo patrón del ejercicio de "promedio de salarios" que aparece en la diapositiva de pseudocódigo.

**La operación `ORDENAR` como caja negra.** Noten que no especificamos *cómo* se ordena internamente la lista (hay muchos algoritmos de ordenamiento). Solo indicamos *qué* queremos: ordenar por `tasa_desempleo` de forma descendente. Esto es un ejemplo de **abstracción**: nos enfocamos en lo que necesitamos sin preocuparnos por los detalles de implementación. Cuando programemos en R, simplemente usaremos `arrange(desc(tasa_desempleo))` y el lenguaje se encarga del resto.

**¿Por qué se recorre la tabla dos veces?** Primero hay que conocer el promedio para poder comparar, y el promedio solo se puede calcular después de ver todos los datos. Por eso no es posible filtrar en la misma pasada en la que se calcula el promedio — necesitamos el valor final antes de empezar a comparar. Este tipo de dependencia entre pasos es algo habitual en el análisis de datos.

---

## Resumen de patrones

| Patrón | Ejercicio | Descripción |
|---|---|---|
| Contador | A | Variable que arranca en 0 y suma 1 por cada ocurrencia |
| Acumulador | C | Variable que arranca en 0 y suma valores para obtener un total |
| Máximo/mínimo | B | Se inicializa en -infinito/+infinito y se actualiza al encontrar un valor mejor |
| Filtrado | C | Recorrer una lista y copiar solo los elementos que cumplen una condición |
| Descomposición | Todos | Dividir el problema en pasos simples que se resuelven por separado |
