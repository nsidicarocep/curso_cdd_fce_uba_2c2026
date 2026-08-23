# =============================================================================
# Clase 04 — Código en vivo
# Ciencia de Datos para Economía y Negocios | FCE-UBA
# =============================================================================

# --- 0. Setup ----------------------------------------------------------------

# Cargar tidyverse.
library(tidyverse)
# install.packages(janitor)
# Definir instub y outstub con la ruta del repositorio
setwd(r'(D:\Docencia\UBA\Ciencia de datos\curso_cdd_fce_uba_1c2026)')
instub <- 'datos'
outstub <- 'output/clase03'
# Construir la ruta al CSV con file.path() y leerlo con read_csv().
ruta_csv <- file.path(instub,'Datos_por_departamento_y_actividad.csv')
# Guardar en un objeto llamado "establecimientos".
establecimientos <- read_csv(ruta_csv)
# corregir el nombre de las variables 
establecimientos <- janitor::clean_names(establecimientos)
# --- 1. Exploración inicial --------------------------------------------------

# Usar glimpse() para ver la estructura.
glimpse(establecimientos)
# cuántas filas, cuántas columnas, qué tipo tiene cada una.
dim(establecimientos)
str(establecimientos)
summary(establecimientos)
# Ver las primeras fillas, las ultimas y los nombres de las columnas
View(head(establecimientos,100))

# --- 2. select() -------------------------------------------------------------

# Seleccionar: anio, provincia, letra, Empleo, Establecimientos.
# Guardar en est_trabajo.
est_trabajo <- establecimientos %>% 
  select(anio,provincia,letra,empleo,establecimientos)
# Excluir columnas clae6 y clae2
est_trabajo <- establecimientos %>% 
  select(-clae6,-clae2)
# starts_with():# Despues vamos a profundizar sobre esto en unas clases
# Todos los verbos del tidyverse tienen modificadores 
est_trabajo <- establecimientos %>% 
  select(contains('e'))
# --- 3. filter() -------------------------------------------------------------

# Filtrar solamente las filas de CABA en 2022.
est_trabajo <- establecimientos %>% 
  filter(provincia == 'CABA' & anio == 2022)
# Filtrar las filas donde la letra sea "C" (Industria manufacturera)
est_trabajo <- est_trabajo %>% 
  filter(letra == 'C')
# y el empleo sea mayor a 100.
est_trabajo <- est_trabajo %>% 
  filter(empleo > 100)
# Encadenando todo de una 
est_trabajo <- establecimientos %>% 
  filter(provincia == 'CABA' & anio == 2022 & letra == 'C' & empleo > 100)
# O lo que es lo mismo
est_trabajo <- establecimientos %>% 
  filter(provincia == 'CABA') %>% 
  filter(anio == 2022) %>% 
  filter(letra == 'C') %>% 
  filter(empleo > 100)
# Filtrar varias provincias con %in%: Buenos Aires, Cordoba y Santa Fe.
est_trabajo <- establecimientos %>% 
  filter(provincia %in% c('Cordoba','Buenos Aires','Santa Fe') & anio == 2022 & letra == 'C' & empleo > 100)
# Chequear forma de Cordoba para ver si tiene tilde 
unique(establecimientos$provincia)
# --- 5. mutate() -------------------------------------------------------------

# Sobre df, crear una columna "emp_por_estab" que calcule
# Empleo / Establecimientos. Redondear a 1 decimal.
establecimientos <- establecimientos %>% 
  mutate(emp_por_estab = round(empleo / establecimientos,1))
 # O lo mismo
establecimientos <- establecimientos %>% 
  mutate(emp_por_estab = empleo / establecimientos, 
         emp_por_estab = round(emp_por_estab,1))

# Crear una columna "gran_empleador" con ifelse():
# si Empleo > 500, poner "Sí", sino "No".
establecimientos <- establecimientos %>% 
  mutate(gran_empleador = if_else(empleo > 500,'Sí','No'))

# --- 6. arrange() ------------------------------------------------------------

# Filtrar año 2022 y letra "C" (industria), luego ordenar por Empleo descendente.

# Ordenar por provincia (ascendente) y dentro de cada provincia
# por Empleo (descendente)


# --- 7. summarise() + group_by() --------------------------------------------

# Calcular el empleo total nacional para 2022.

# Ahora calcular empleo total por provincia para 2022.
# Ordenar de mayor a menor. ¿Cuáles son las 5 provincias con más empleo?

# Calcular por provincia: empleo total, cantidad de establecimientos
# y el promedio de empleados por establecimiento.

# Calcular el share de empleo por provincia sobre el total nacional

# --- 8. Cadena completa con pipe ---------------------------------------------

# Armar una cadena que en un solo bloque:
#   1. Filtre año 2022
#   2. Agrupe por provincia
#   3. Calcule empleo total y establecimientos totales
#   4. Cree emp_por_estab con mutate
#   5. Ordene de mayor a menor por empleo
#   6. Calcular proporcion de empleo a nivel nacional de cada provincia
df_final <- establecimientos %>% 
  filter(anio == 2022) %>% 
  group_by(provincia) %>% 
  summarize(empleo_total = sum(empleo,na.rm=TRUE),
            establecimientos_totales = sum(establecimientos)) %>% 
  ungroup() %>%  # Me aseguro que desagrupe los datos 
  mutate(emp_por_estab = empleo_total / establecimientos_totales) %>% 
  arrange(desc(empleo_total)) %>% 
  mutate(prop_empleo = empleo_total / sum(empleo_total,na.rm=T))

# --- 9. Guardar resultados ---------------------------------------------------

# Mostrar dir.create() con recursive = TRUE para crear output/clase03.
# La sintaxis no es obvia, así que va resuelta:
dir.create(file.path(outstub), recursive = TRUE, showWarnings = FALSE)

# Guardar el resultado de la cadena anterior con write_csv().
# Construir la ruta con file.path().
write_csv(df_final,file = file.path(outstub,'datos_x_provincia.csv'))
