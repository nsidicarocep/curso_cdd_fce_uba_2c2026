# =============================================================================
# CIENCIA DE DATOS PARA ECONOMIA Y NEGOCIOS — FCE-UBA — 2c 2026
#
# GUIA COMPLETA DE CODIGO EN VIVO
# Clases 4 (28/08) y 6 (04/09): del tidyverse basico a joins y EDA
#
# Base de datos: Datos_por_departamento_y_actividad.csv
# (Distribucion geografica de establecimientos productivos, datos.produccion.gob.ar)
# 195.370 filas x 11 columnas. Empleo y establecimientos por departamento,
# actividad (clae6 / clae2 / letra) y anio (2021 y 2022).
#
# COMO USAR ESTE ARCHIVO
#   - Cada paso arranca con la CONSIGNA: que se busca hacer y por que.
#   - Debajo va el codigo, con el resultado esperado como comentario.
#   - Corran bloque por bloque (Ctrl+Enter linea a linea, o seleccionar y Ctrl+Enter).
#   - Si un numero no les da igual, revisen el paso anterior antes de seguir.
#
# HILO CONDUCTOR DE LA CLASE 6
#   Casi ninguno de los errores que vamos a ver TIRA ERROR. El codigo corre,
#   devuelve una tabla que parece correcta, y el numero esta mal. Por eso cada
#   paso incluye su propio control.
# =============================================================================


# =============================================================================
# PASO 0 — Configuracion inicial
# =============================================================================
# CONSIGNA:
#   a. Cargar tidyverse para manipulacion de datos.
#      Desactivar la notacion cientifica en numeros grandes
#      (6.595449e+06 -> 6595449). Va arriba de todo, con las librerias.

#a. Cargar tidyverse
library(tidyverse)

# Si no tienen janitor instalado, corran una sola vez:
# install.packages("janitor")

# scipen = 999 evita que las sumas de millones se impriman en notacion
# cientifica. Es cosmetico, pero hace toda la diferencia para leer resultados.
options(scipen = 999)


# =============================================================================
# PASO 1 — Definir rutas de trabajo
# =============================================================================
# CONSIGNA:
#   b. Establecer el directorio de trabajo (setwd).
#   c. Definir dos carpetas: datos/ (donde estan los archivos) y
#      output/clase04/ (donde van los resultados).
#   c. Armar una ruta unica al CSV con file.path().

#b. Decirle a R donde estoy trabajando.
# CADA UNO TIENE QUE PONER SU PROPIA RUTA. La r"( )" es para que R no se coma
# las contrabarras de Windows.
setwd(r"(C:\Users\Usuario\Desktop\UBA\Ciencia de Datos\repo_catedra)")

#c. Definir variables de rutas con las que vamos a ir trabajando.
# La idea: escribir las carpetas UNA sola vez. Si despues cambia la
# estructura, se corrige un renglon y no veinte.
instub  <- "datos"
outstub <- "output/clase04"

#c. Armar la ruta al archivo con file.path().
# file.path() pega las partes con el separador correcto segun el sistema
# operativo. Es preferible a escribir "datos/archivo.csv" a mano.
ruta_csv <- file.path(instub, "Datos_por_departamento_y_actividad.csv")


# =============================================================================
# PASO 2 — Cargar la base de datos
# =============================================================================
# CONSIGNA:
#   d. Leer Datos_por_departamento_y_actividad.csv y asignarlo a
#      "establecimientos". ESTA ES LA BASE ORIGINAL: no se toca ni se modifica.
#   e. clean_names() procesa los nombres de columna (todo a minuscula, sin
#      espacios). Punto de partida para todo lo que sigue.

#d. Definimos la variable del data frame base.
establecimientos <- read_csv(ruta_csv)
# read_csv() imprime un mensaje con las dimensiones y los tipos de columna.
# NO es un error: es informativo. Deberia decir 195.370 filas y 11 columnas.

#e. Procesar la info obtenida.
establecimientos <- janitor::clean_names(establecimientos)
# clean_names() pasa todos los nombres a minuscula y sin espacios.
# Por eso de aca en adelante escribimos "empleo" y no "Empleo".
# Si escriben "Empleo" con mayuscula van a recibir: object 'Empleo' not found.


# =============================================================================
# PASO 3 — Exploracion inicial de los datos
# =============================================================================
# CONSIGNA:
#   a. Usar glimpse() para ver la estructura.
#   b. Ver cuantas filas y columnas hay, y de que tipo es cada dato.
#   c. Mirar las primeras filas y un resumen estadistico de cada columna.

#a. glimpse(): una fila por variable, con el tipo de dato y los primeros valores.
glimpse(establecimientos)

#b. dim(): filas y columnas.
dim(establecimientos)
# 195370 filas, 11 columnas.

#c. Mirar las primeras filas y el resumen.
View(head(establecimientos, 10))

summary(establecimientos)
# summary() sirve sobre todo para detectar minimos raros, maximos absurdos
# y cantidad de NA por columna.


# =============================================================================
# PASO 4 — select(): opera sobre COLUMNAS
# =============================================================================
# CONSIGNA:
#   a. Seleccionar, dentro del conjunto de datos, las columnas que vamos a usar.
#      Dos formas: nombrando las que quiero, o sacando las que no.

#a. Forma positiva: nombro las que quiero conservar.
esta_trabajo <- establecimientos |> 
  select(anio, provincia, letra, empleo, establecimientos)

# Forma negativa: saco las que no quiero, con el signo menos.
esta_trabajo <- establecimientos |> 
  select(-clae6, -clae2)

# OJO: la segunda linea PISA a la primera. "esta_trabajo" es una variable de
# trabajo, descartable: la usamos para probar cosas. La base original
# ("establecimientos") sigue intacta, que es lo que importa.


# =============================================================================
# PASO 5 — filter(): opera sobre FILAS
# =============================================================================
# CONSIGNA:
#   a. Filtrar solamente las filas de CABA en 2022.
#   b. Filtrar donde la letra sea "C" (Industria manufacturera).
#   c. Filtrar que el empleo sea mayor a 100.
#   d. Encadenar todo junto.
#   e. Filtrar varias provincias con %in%.

#a. Un filtro con dos condiciones unidas por & (y).
esta_trabajo <- establecimientos |> 
  filter(provincia == "CABA" & anio == 2022)

#b. Filtrar por letra de actividad.
esta_trabajo <- establecimientos |> 
  filter(letra == "C")

#c. Filtrar por un valor numerico.
esta_trabajo <- establecimientos |> 
  filter(empleo > 100)

#d. Encadenando todo de una.
# Poner cuatro filter() seguidos o uno solo con & es exactamente lo mismo.
esta_trabajo <- establecimientos |> 
  filter(provincia == "CABA") |> 
  filter(anio == 2022) |> 
  filter(letra == "C") |> 
  filter(empleo > 100)

#e. Filtrar varias provincias con %in%.
#
# PRIMER ERROR SILENCIOSO DE LA CURSADA. En la clase del 28/08 esta linea
# decia "Santa fe", con f minuscula. R NO dio error: simplemente Santa Fe
# no entro en el resultado (275 filas menos) y nadie se entero.
# R compara texto EXACTO, mayusculas incluidas.
esta_trabajo <- establecimientos |> 
  filter(provincia %in% c("Cordoba", "Buenos Aires", "Santa Fe") & anio == 2022
         & letra == "C" & empleo > 100)

# El control: contar cuantas filas quedaron por provincia.
esta_trabajo |> count(provincia)
# Buenos Aires 1228 | Cordoba 229 | Santa Fe 275  -> TRES provincias.
# Con "Santa fe" salen solo dos, y ningun aviso.


# =============================================================================
# PASO 6 — mutate(): crea columnas nuevas
# =============================================================================
# CONSIGNA:
#   a. Crear una columna "emp_por_estab" = empleo / establecimientos,
#      redondeada a 1 decimal.
#   b. Crear una columna "gran_empleador" con if_else().

#a. mutate() agrega la columna al data frame, no reemplaza nada.
establecimientos <- establecimientos |> 
  mutate(emp_por_estab = round(empleo / establecimientos, 1))

#b. if_else() maneja DOS opciones: condicion, valor si es verdadera,
#   valor si es falsa.
establecimientos <- establecimientos |> 
  mutate(gran_empleador = if_else(empleo > 500, "Si", "No"))

dim(establecimientos)
# Ahora 195370 x 13: las 11 originales mas las 2 que acabamos de crear.

establecimientos |> count(gran_empleador)
# No 190.852 | Si 4.518

# ACA SI reasignamos sobre la base original, y esta bien: mutate() AGREGA
# columnas, no saca filas ni columnas. El cambio tiene que valer para todo
# lo que sigue. Comparar con el Paso 7a, donde reasignar es un error.


# =============================================================================
# PASO 7 — arrange(): ordena el data frame
# =============================================================================
# CONSIGNA:
#   a. Filtrar 2022 y letra "C" (industria) y ordenar por empleo descendente.
#   b. Ordenar por provincia (ascendente) y, dentro de cada provincia, por
#      empleo (descendente).

#a. SEGUNDO ERROR SILENCIOSO DE LA CURSADA, y el mas caro.
#
# En la clase del 28/08 esta consulta se escribio asi:
#
#   establecimientos <- establecimientos |> filter(...) |> arrange(...) |> select(...)
#
# Con esa flecha de asignacion, "establecimientos" paso de 195.370 x 13 a
# 17.921 x 7: quedo solo 2022, solo industria manufacturera, y sin las dos
# columnas creadas en el Paso 6. Todos los pasos siguientes corrieron sobre
# esa base mutilada. El empleo nacional dio 1.223.643 en vez de 6.595.449.
# R no dio ningun error.
#
# REGLA: si es para MIRAR, no se asigna. Si es para CONSERVAR, se asigna a un
# nombre NUEVO. Se reasigna sobre la base original solo cuando el cambio tiene
# que valer para todo lo que sigue (como el mutate del Paso 6).

# Version correcta: sin flecha, es una consulta para mirar.
establecimientos |> 
  filter(anio == 2022 & letra == "C") |> 
  arrange(desc(empleo)) |> 
  select(provincia, departamento, clae6, clae2, empleo, establecimientos, anio)
# Arriba de todo: Buenos Aires / Zarate / clae6 291000 / 7.707 empleados.

# Si la queremos conservar, va a un nombre NUEVO.
industria_2022 <- establecimientos |> 
  filter(anio == 2022 & letra == "C") |> 
  arrange(desc(empleo)) |> 
  select(provincia, departamento, clae6, clae2, empleo, establecimientos, anio)

#b. Dos criterios de orden a la vez.
establecimientos |> 
  filter(anio == 2022) |> 
  arrange(provincia, desc(empleo)) |> 
  select(provincia, departamento, letra, empleo)
# Primero ordena por provincia de la A a la Z, y DENTRO de cada provincia
# ordena por empleo de mayor a menor.


# =============================================================================
# PASO 8 — summarise() + group_by()
# =============================================================================
# CONSIGNA:
#   a. Calcular el empleo total nacional para 2022.
#   b. Calcular el empleo total por provincia para 2022, de mayor a menor.
#   c. Calcular por provincia varias metricas juntas.

#a. Empleo total nacional 2022.
#
# El filter(anio == 2022) tiene que estar SIEMPRE. En la clase del 28/08 no
# estaba, y no se noto porque el error del Paso 7a ya habia dejado la base
# filtrada en 2022. Un error tapaba al otro.
establecimientos |> 
  filter(anio == 2022) |> 
  summarise(empleo_total = sum(empleo, na.rm = TRUE))
# 6.595.449   (sin el filtro, sumando los dos anios, daria 12.905.484)

#b. Empleo total por provincia.
# group_by() parte la tabla en grupos; summarise() calcula uno por grupo y
# COLAPSA: el resultado tiene una fila por provincia.
empleo_provincia <- establecimientos |> 
  filter(anio == 2022) |> 
  group_by(provincia) |> 
  summarise(empleo_total = sum(empleo, na.rm = TRUE)) |> 
  arrange(desc(empleo_total))
empleo_provincia
# Buenos Aires 2.108.119 | CABA 1.596.397 | Santa Fe 543.358 |
# Cordoba 537.565 | Mendoza 252.202

# PREGUNTA: cuales son las 5 provincias con mas empleo?

#c. Varias metricas en un mismo summarise().
resumen_prov <- establecimientos |> 
  filter(anio == 2022) |> 
  group_by(provincia) |> 
  summarise(empleo_total             = sum(empleo, na.rm = TRUE),
            establecimientos_totales = sum(establecimientos, na.rm = TRUE),
            em_por_estab             = sum(empleo, na.rm = TRUE) / sum(establecimientos, na.rm = TRUE),
            prom_empleados_est       = mean(empleo / establecimientos, na.rm = TRUE)) |> 
  arrange(desc(empleo_total))
resumen_prov
# Buenos Aires: 2.108.119 empleos | 302.925 establecimientos |
#               em_por_estab 6.96 | prom_empleados_est 6.81
#
# OJO: em_por_estab y prom_empleados_est NO son lo mismo.
# El primero es el cociente de las sumas; el segundo, el promedio de los
# cocientes. Cual corresponde depende de la pregunta que se quiera responder.


# =============================================================================
# =============================================================================
#                    CLASE 6 — viernes 04/09
#         Parte 2: agrupamiento avanzado, pivots, case_when y joins
# =============================================================================
# =============================================================================


# =============================================================================
# PASO 9 — group_by() con DOS variables: el argumento .groups
# =============================================================================
# CONSIGNA:
#   a. Agrupar por provincia Y letra simultaneamente. Leer el mensaje de
#      consola que dice "Output is grouped by provincia".
#   b. Introducir .groups = "drop" como buena practica: quita todos los
#      grupos al final.

#a. Agrupamos por dos variables y miramos el mensaje.
resumen_uno <- establecimientos |> 
  filter(anio == 2022) |> 
  group_by(provincia, letra) |> 
  summarise(empleo = sum(empleo, na.rm = TRUE))
resumen_uno
# 476 filas x 3 columnas. Y arriba de la tabla dice: # Groups: provincia [24]
#
# Que paso: agrupamos por DOS variables, y summarise() cierra solamente la
# ULTIMA (letra). El resultado sigue agrupado por provincia. El mensaje de
# consola lo avisa, pero es facil pasarlo por alto.
#
# IMPORTANTE: esto solo se ve imprimiendo el objeto en la CONSOLA. En View()
# las dos tablas se ven exactamente iguales.

#b. Con .groups = "drop" se sacan todos los grupos. Es la buena practica.
resumen <- establecimientos |> 
  filter(anio == 2022) |> 
  group_by(provincia, letra) |> 
  summarise(empleo = sum(empleo, na.rm = TRUE), .groups = "drop")
resumen
# Las mismas 476 filas y exactamente los mismos numeros que resumen_uno.
# Lo unico que cambia es que ya NO dice "# Groups:".
#
# El contenido es identico; lo que cambia es un estado invisible. Ese estado
# invisible es el que decide el resultado del paso siguiente.


# =============================================================================
# PASO 10 — group_by() + mutate() vs summarise()
# =============================================================================
# CONSIGNA:
#   summarise() colapsa a una fila por grupo; mutate() conserva TODAS las
#   filas y agrega la estadistica del grupo en cada una.
#   a. Version A: agrupada por provincia -> el denominador es el total de
#      cada provincia.
#   b. Version B: sin agrupar -> el denominador es el total nacional.
#   Pregunta clave: mismo codigo, dos numeros distintos, ninguno da error.
#   Cual responde que?
#   Regla: group_by() + mutate() SIEMPRE termina en ungroup().

#a. Version A: agrupada por provincia.
resumen |> 
  group_by(provincia) |> 
  mutate(participacion = round(empleo / sum(empleo) * 100, 1)) |> 
  ungroup() |> 
  filter(provincia == "CABA", letra == "C")
# CABA | C | 152.697 | 9.6
# Con group_by(provincia), sum(empleo) suma SOLO las filas de CABA.
# El denominador es el empleo total de CABA.
# Responde: cuanto pesa la industria DENTRO de CABA.

#b. Version B: sin agrupar.
resumen |> 
  mutate(participacion = round(empleo / sum(empleo) * 100, 1)) |> 
  filter(provincia == "CABA", letra == "C")
# CABA | C | 152.697 | 2.3
# Sin group_by(), sum(empleo) suma las 476 filas.
# El denominador es el empleo total del pais.
# Responde: cuanto pesa la industria de CABA en el empleo del PAIS.

# Mismo codigo, misma columna, dos numeros. Ninguno tira error.
# Cual responde "cuanto pesa la industria de CABA en el empleo del pais"?
# -> La version B: 2,3 %.
#
# Un porcentaje siempre es "sobre la suma de que conjunto". group_by() cambia
# ese conjunto sin avisar.
#
# REGLA: group_by() + mutate() termina SIEMPRE en ungroup().


# =============================================================================
# PASO 11 — pivot_wider() y pivot_longer(): cambiar la forma de la tabla
# =============================================================================
# CONSIGNA:
#   Formato LARGO (muchas filas, para calcular) vs formato ANCHO (columnas,
#   para leer y comparar).
#   a. Armar la tabla larga: una fila por provincia-anio. Aca NO va el filtro
#      de anio: se necesitan los dos.
#   b. pivot_wider() pasa los anios de filas a columnas -> ahora se pueden restar.
#   c. Calcular el crecimiento restando columnas y ordenar de mayor a menor.
#   d. pivot_longer() revierte el cambio (anios de vuelta a filas).
#   Regla: longer para ANALIZAR (calculos, graficos), wider para PRESENTAR o
#   para operar entre columnas.

#a. Tabla larga: empleo por provincia y anio.
# Es la unica tabla del dia SIN filter(anio == 2022): necesitamos los dos
# anios, porque justamente los vamos a poner en columnas.
empleo_largo <- establecimientos |> 
  group_by(provincia, anio) |> 
  summarise(empleo = sum(empleo, na.rm = TRUE), .groups = "drop")
empleo_largo
# 48 filas: 24 provincias x 2 anios. 3 columnas.
# Buenos Aires 2021: 2.007.325 | Buenos Aires 2022: 2.108.119

#b. pivot_wider(): de largo a ancho.
# OJO: parte de empleo_largo, NO de establecimientos. Si se pivotea la base
# cruda, R toma como identificador de fila TODAS las columnas que no se
# nombraron (departamento, clae6, letra...) y devuelve cientos de filas en
# vez de 24, con crecimientos absurdos.
empleo_ancho <- empleo_largo |> 
  pivot_wider(names_from  = anio,
              values_from = empleo,
              names_prefix = "empleo_")
empleo_ancho
# 24 filas (una por provincia) x 3 columnas:
# provincia | empleo_2021 | empleo_2022

#c. Para que sirve tener los anios en columnas? Para restarlos.
crecimiento <- empleo_ancho |> 
  mutate(crecimiento = round((empleo_2022 / empleo_2021 - 1) * 100, 1)) |> 
  arrange(desc(crecimiento))
crecimiento
# Catamarca +15.5 arriba de todo | Formosa y La Rioja +10.1 |
# Tucuman -0.7 es la unica provincia que cae.
# Esta cuenta, en formato largo, seria mucho mas incomoda.

#d. pivot_longer(): la vuelta. Necesaria para ggplot2 y para group_by().
empleo_ancho |> 
  pivot_longer(cols         = starts_with("empleo_"),
               names_to     = "anio",
               names_prefix = "empleo_",
               values_to    = "empleo") |> 
  mutate(anio = as.integer(anio))
# Vuelve a 48 filas x 3 columnas.
# names_prefix limpia el "empleo_" del nombre.
# values_to nombra la columna de valores (sin el, R la llama "value").
# as.integer() porque el nombre de una columna SIEMPRE viene como texto:
# sin convertir, despues no se puede ordenar ni filtrar por anio.


# =============================================================================
# PASO 12 — case_when(): cuando son mas de dos categorias
# =============================================================================
# CONSIGNA:
#   Con if_else() hay solo 2 opciones; con case_when() se manejan 3 o mas.
#   Crear la columna "tamano" clasificando por cantidad de empleados.
#   Las condiciones se evaluan EN ORDEN: la primera que se cumple gana.
#   .default captura lo que ninguna condicion cubrio.
#   Control obligatorio: count() despues de cada case_when().

establecimientos <- establecimientos |> 
  mutate(tamano = case_when(
    empleo >= 1000 ~ "Grande",
    empleo >= 100  ~ "Mediano",
    empleo >= 10   ~ "Chico",
    .default       = "Micro"
  ))

establecimientos |> count(tamano, sort = TRUE)
# Micro 100.918 | Chico 71.849 | Mediano 20.794 | Grande 1.809

# REGLAS:
# 1. Las condiciones se evaluan EN ORDEN: la primera que se cumple gana.
# 2. .default captura lo que no atrapo ninguna condicion.
# 3. Todos los resultados tienen que ser del mismo tipo (aca, todos texto).
# 4. Sin .default, lo que no quedo cubierto queda NA.
#
# PREGUNTA: que pasa si ponemos empleo >= 10 primero?
# Respuesta: se lleva TODO. Grande y Mediano quedan vacios. Y no tira error.
# Por eso el count() despues de cada case_when() no es opcional: es el unico
# control que tenemos.


# =============================================================================
# PASO 13 — Modelo relacional: identificar la clave primaria
# =============================================================================
# CONSIGNA:
#   Clave primaria = la columna (o combinacion de columnas) que identifica
#   cada fila de forma unica. Se verifica contando duplicados ANTES de
#   cualquier join.
#   a. Es anio + departamento + clae6 una clave valida?
#   b. Por que falla.
#   c. Usando el codigo (in_departamentos) en vez del nombre.
#   Conclusion: los codigos identifican, los nombres no.

#a. Contamos combinaciones repetidas.
# count() cuenta cuantas filas hay por combinacion; si alguna tiene n > 1,
# esa combinacion no identifica de forma unica.
establecimientos |> 
  count(anio, departamento, clae6) |> 
  filter(n > 1) |> 
  nrow()
# 10.147 combinaciones duplicadas. NO sirve como clave.

#b. Por que falla, si parece razonable?
establecimientos |> 
  filter(departamento == "Capital") |> 
  distinct(provincia)
# 11 provincias tienen un departamento llamado "Capital":
# Catamarca, Cordoba, Corrientes, La Pampa, La Rioja, Mendoza, Misiones,
# Salta, San Juan, Santiago del Estero y Tucuman.
# El NOMBRE del departamento no identifica.

#c. La clave de verdad usa el codigo, no el nombre.
establecimientos |> 
  count(anio, in_departamentos, clae6) |> 
  filter(n > 1) |> 
  nrow()
# 0 duplicados. ESA es la clave primaria.
#
# Por eso las bases oficiales traen codigos ademas de nombres: el nombre no
# identifica, el codigo si.


# =============================================================================
# PASO 14 — Los cuatro tipos de joins
# =============================================================================
# CONSIGNA:
#   a. Tabla auxiliar (lookup): letra -> nombre del sector. Faltan O, T y U,
#      y sobra Z, a proposito, para ver que hace cada join con lo que no matchea.
#   b. anti_join(): muestra las filas que NO encuentran pareja. Detecta datos
#      mal codificados antes de unir. SIEMPRE va primero, es el join de control.
#      No es simetrico: dar vuelta las tablas cambia la pregunta.
#   c. left_join(): conserva TODAS las filas de la izquierda; los no
#      matcheados quedan con NA.
#   d. inner_join(): solo las filas que existen en AMBAS tablas. Descarta sin avisar.
#   e. full_join(): todas las filas de las dos tablas. Muestra lo que esta
#      solo en la derecha, que left_join() descarta.
#   f. Join por UNA clave: cuando el dato de la derecha se repite igual para
#      todos los anios.
#   g. Join por MAS DE UNA clave, by = c("col1", "col2"): cuando el dato
#      cambia por provincia Y por anio.

#a. Tabla auxiliar: letra -> nombre del sector.
# tribble() sirve para escribir a mano tablas chicas, fila por fila.
sectores <- tribble(
  ~letra, ~sector,
  "A", "Agro y Pesca",              "B", "Mineria",
  "C", "Industria Manufacturera",   "D", "Electricidad y gas",
  "E", "Agua y saneamiento",        "F", "Construccion",
  "G", "Comercio",                  "H", "Transporte",
  "I", "Hoteleria y gastronomia",   "J", "Informacion y comunicacion",
  "K", "Finanzas y seguros",        "L", "Inmobiliarias",
  "M", "Actividades profesionales", "N", "Servicios administrativos",
  "P", "Ensenanza",                 "Q", "Salud",
  "R", "Arte y entretenimiento",    "S", "Otros servicios",
  "Z", "Sector inventado"
)
# Faltan O, T y U (existen en la base y no estan aca).
# Y sobra Z (esta aca y no existe en la base).
# Las dos cosas estan puestas a proposito.

#b. anti_join(): SIEMPRE primero. Es el join de CONTROL, no sirve para unir.
# Devuelve las filas de la tabla de la IZQUIERDA que NO encuentran pareja
# en la de la derecha.
establecimientos |> 
  distinct(letra) |> 
  anti_join(sectores, by = "letra")
# O, T y U: estan en la base y no tienen nombre de sector asignado.

# Y al reves, dando vuelta las tablas:
sectores |> 
  anti_join(establecimientos |> distinct(letra), by = "letra")
# Z: esta en la tabla auxiliar y no existe en la base.
#
# El anti_join NO es simetrico: el orden de las tablas cambia la pregunta.

#c. left_join(): conserva TODAS las filas de la izquierda.
resumen_sectores <- resumen |> 
  left_join(sectores, by = "letra")

resumen_sectores |> nrow()
# 476: las mismas filas que resumen. No se perdio nada.

resumen_sectores |> filter(is.na(sector)) |> distinct(letra)
# O, T y U quedaron con sector = NA. Sin error y sin warning,
# pero el NA por lo menos se ve.

#d. inner_join(): solo las filas que existen en AMBAS tablas.
resumen |> inner_join(sectores, by = "letra") |> nrow()   # 432
resumen_sectores |> nrow()                                # 476
# 44 filas menos: son las de O, T y U.
#
# inner_join() descarta lo que no matchea SIN AVISAR. left_join() las deja
# con NA, que se ve; inner_join() las hace desaparecer. Un filter() mal
# puesto por lo menos se sospecha; esto corre perfecto y pierde datos reales.

#e. full_join(): todas las filas de las DOS tablas.
# Lo unico que full_join() puede mostrar y left_join() no: las filas que
# estan SOLO en la tabla de la derecha.
resumen |> 
  full_join(sectores, by = "letra") |> 
  filter(is.na(provincia)) |> 
  distinct(letra, provincia, sector)
# Una sola fila: la Z. Esta en sectores y no existe en la base, asi que
# quedo sin provincia. Con left_join() esta fila directamente se pierde.

#f. Join por UNA clave.
# El crecimiento es un dato por provincia: se repite igual en los dos anios.
empleo_largo |> 
  left_join(crecimiento |> select(provincia, crecimiento), by = "provincia") |> 
  head()
# Buenos Aires 2021 -> 5.0 ; Buenos Aires 2022 -> 5.0. El mismo valor dos veces.
# CABA 3.6 y 3.6. Catamarca 15.5 y 15.5.

#g. Join por MAS DE UNA clave.
# Cuando el dato de la derecha cambia por provincia Y por anio, la clave
# tiene que ser la combinacion de las dos.
promedio <- establecimientos |> 
  group_by(provincia, anio) |> 
  summarise(emp_promedio = round(mean(empleo, na.rm = TRUE), 1),
            .groups = "drop")

empleo_largo |> 
  left_join(promedio, by = c("provincia", "anio")) |> 
  head(15)
# Buenos Aires 2021 -> 59.4 ; Buenos Aires 2022 -> 60.9. Ahora SI cambia.
# Comparar con el inciso f: alla el valor se repetia porque la clave estaba
# incompleta.

# LOS TRES ERRORES CLASICOS DE JOINS
# 1. Si la tabla de la derecha tiene la clave REPETIDA, el join MULTIPLICA
#    filas. Por eso el Paso 13 (clave primaria) va antes que este.
# 2. left_join() genera NA sin avisar. Por eso anti_join() primero.
# 3. Si las dos tablas tienen columnas con el mismo nombre (ademas de la
#    clave), R les agrega los sufijos .x y .y.


# =============================================================================
# PASO 15 — Tabla final: cierre
# =============================================================================
# CONSIGNA:
#   Filtrar los NA (saca O, T y U, que quedaron sin sector).
#   Agrupar por sector y sumar el empleo total.
#   Calcular la participacion (% que representa cada sector).
#   Ordenar de mayor a menor empleo.
#   Resultado: tabla limpia, lista para presentar o graficar.

resumen_final <- resumen_sectores |> 
  filter(!is.na(sector)) |>   # saca O, T y U. La Z nunca entro: usamos left_join
  group_by(sector) |> 
  summarise(empleo = sum(empleo), .groups = "drop") |> 
  mutate(participacion = round(empleo / sum(empleo) * 100, 1)) |> 
  arrange(desc(empleo))

resumen_final
# Industria Manufacturera   1.223.643   18.6 %
# Comercio                  1.158.431   17.6 %
# Servicios administrativos   537.265    8.2 %
# Ensenanza                   493.314    7.5 %
# Transporte                  480.367    7.3 %
# Construccion                444.753    6.8 %
#



# =============================================================================
# PARA CERRAR
# =============================================================================
# Lo que tienen en comun todos los verbos de esta guia —el argumento .groups,
# el ungroup(), el orden de las condiciones del case_when, la eleccion de la
# clave primaria y el tipo de join— es que NINGUNO tira error cuando se elige
# mal. Todos devuelven una tabla que parece correcta.
#
# Por eso, los controles no son opcionales:
#   - count() despues de cada recodificacion.
#   - contar duplicados antes de cualquier join.
#   - anti_join() antes de unir.
#   - comparar nrow() antes y despues de un join.
#
# Son el unico aviso que van a tener.
