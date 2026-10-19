## ===================================================
## TUTORIAL COMPLETO DEL PAQUETE STRINGR EN R
## ===================================================
## Nicolás Sidicaro
## Curso: Ciencia de datos para economía y negocios
## Fecha: Abril 2025
## ===================================================

# Instalar y cargar el paquete stringr (parte del tidyverse)
# install.packages("stringr")
#library(stringr)

# También podemos cargar todo el tidyverse que incluye stringr
# install.packages("tidyverse")
library(tidyverse)

## ===================================================
## 1. INTRODUCCIÓN A STRINGR
## ===================================================

# stringr proporciona un conjunto coherente de funciones para manipular cadenas de texto
# Casi todas las funciones de stringr comienzan con "str_" lo que facilita encontrarlas
# Muchas funciones de stringr son wrappers más intuitivos de funciones base de R

# Veamos las principales funciones con str_
ls("package:stringr") %>% str_subset("^str_")

# Creamos algunos vectores de texto para trabajar con ejemplos
nombres <- c("Juan Pérez", "María Gómez", "JOSÉ LÓPEZ", "  Ana Martínez  ")
emails <- c("juan.perez@empresa.com", "maria_23@gmail.com", "jose-lopez@yahoo.es", "info@empresa.com.ar")
telefonos <- c("(34) 612-345-678", "54 911 2345 6789", "1-800-555-1234", "+44 20 1234 5678")
textos <- c("Este es un ejemplo de texto con múltiples  espacios.", 
            "¿Cómo estás tú? Yo estoy bien.", 
            "Este texto tiene números: 123 y 456", 
            "Línea 1\nLínea 2\nLínea 3")

# Veamos cómo se ven nuestros datos
print(nombres)
print(emails)
print(telefonos)
print(textos)

## ===================================================
## 2. OPERACIONES BÁSICAS CON CADENAS DE TEXTO
## ===================================================

# 2.1 Convertir a mayúsculas y minúsculas
# -----------------------------------------

# str_to_lower(): Convertir a minúsculas
nombres_min <- str_to_lower(nombres)
print(nombres_min)

# str_to_upper(): Convertir a mayúsculas
nombres_may <- str_to_upper(nombres)
print(nombres_may)

# str_to_title(): Convertir a formato título (primera letra de cada palabra en mayúscula)
nombres_titulo <- str_to_title(nombres_min)
print(nombres_titulo)

# 2.2 Eliminar espacios en blanco
# -----------------------------------------

# str_trim(): Eliminar espacios al principio y al final
nombres_trim <- str_trim(nombres)
print(nombres_trim)

# str_squish(): Eliminar espacios al principio, al final y reducir espacios múltiples a uno solo
texto_con_espacios <- "  Este   texto    tiene    muchos     espacios  "
print(texto_con_espacios)
print(str_squish(texto_con_espacios))

# 2.3 Longitud de cadenas
# -----------------------------------------

# str_length(): Contar caracteres en cada cadena
longitudes <- str_length(nombres)
print(data.frame(nombre = nombres, longitud = longitudes))

# 2.4 Combinación y separación de cadenas
# -----------------------------------------

# str_c(): Concatenar cadenas (equivalente a paste0)
# paste0 (no tiene separador)
# paste (separador definen el separador, predefinido el " ")
nombres_y_emails <- str_c(nombres_trim, " <", emails, ">")
print(nombres_y_emails)

# Con separador
str_c(nombres_trim, emails, sep = " --> ")

# Colapsar un vector en una sola cadena
str_c(nombres_trim, collapse = ", ")
str_c(nombres_trim, collapse = "|")

# str_split(): Dividir cadenas en partes
# Dividir nombres en nombre y apellido
nombres_partes <- str_split(nombres_trim, " ")
print(nombres_partes)

# Para obtener resultados como matriz o data frame
nombres_partes_matriz <- str_split_fixed(nombres_trim, " ", n = 2)
print(nombres_partes_matriz)

# 2.5 Subcadenas y subconjuntos
# -----------------------------------------

# str_sub(): Extraer o reemplazar subcadenas por posición
# Extraer los primeros 3 caracteres
prefijos <- str_sub(emails, 1, 3)
print(prefijos)

# Extraer los últimos 3 caracteres (posiciones negativas cuentan desde el final)
sufijos <- str_sub(emails, -3, -1)
print(sufijos)

# 2.6 Tratamiento de caracteres especiales
# -----------------------------------------

# Reemplazar caracteres con acentos por sus equivalentes sin acento
# No hay una función específica en stringr, pero podemos crear una utilizando stringi
# install.packages("stringi")
library(stringi)

# Función para eliminar acentos
eliminar_acentos <- function(texto) {
  # Convertimos a formato NFD para separar caracteres base de diacríticos
  texto_nfd <- stri_trans_nfd(texto)
  # Eliminamos todos los diacríticos (categoría Mn en Unicode)
  texto_sin_acentos <- stri_replace_all_regex(texto_nfd, "\\p{Mn}", "")
  return(texto_sin_acentos)
}

textos_con_acentos <- c("café", "Máximo", "Nuñez", "Piña", "Öle", "Ñandú")
textos_sin_acentos <- eliminar_acentos(textos_con_acentos)

print(data.frame(original = textos_con_acentos, sin_acentos = textos_sin_acentos))

## ===================================================
## 3. FUNDAMENTOS DE EXPRESIONES REGULARES (REGEX)
## ===================================================

# Las expresiones regulares (regex) son patrones que describen conjuntos de cadenas
# Son extremadamente útiles para buscar, extraer, validar y manipular texto

# 3.1 Caracteres literales
# -----------------------------------------
# Los caracteres normales se representan a sí mismos
str_view(textos, "texto")  # Encuentra la palabra "texto"
str_view(textos, "[a-z]")  # Encuentra la palabra "texto"

# 3.2 Metacaracteres: caracteres con significado especial
# -----------------------------------------
# . : cualquier carácter
# ^ : inicio de cadena
# $ : fin de cadena
# | : alternativa (OR)
# ( ) : agrupamiento
# [ ] : clase de caracteres
# { } : cuantificador
# * : 0 o más repeticiones
# + : 1 o más repeticiones
# ? : 0 o 1 repetición
# \ : escape para caracteres especiales

# Para usar metacaracteres como literales, deben escaparse con \
# Nota: en R, para representar \ en un string necesitamos usar \\

# Buscar puntos literales
str_view(textos, "\\.")  # Encuentra puntos literales

# 3.3 Clases de caracteres predefinidas
# -----------------------------------------
# \\d : dígitos [0-9]
# \\D : no dígitos
# \\s : espacios en blanco
# \\S : no espacios en blanco
# \\w : caracteres de palabra [a-zA-Z0-9_]
# \\W : no caracteres de palabra

# Buscar dígitos
str_view(textos, "\\d")  # Encuentra números
str_view(textos, "[0-9]+")  # Encuentra números

# Buscar espacios en blanco
str_view(textos, "\\s")  # Encuentra espacios
str_view(textos, "[ ]{2,}")  # Encuentra mas de un espacio vacio

# 3.4 Cuantificadores
# -----------------------------------------
# {n} : exactamente n veces
# {n,} : n o más veces
# {n,m} : entre n y m veces
# * : 0 o más veces (equivalente a {0,})
# + : 1 o más veces (equivalente a {1,})
# ? : 0 o 1 veces (equivalente a {0,1})

# Buscar uno o más dígitos consecutivos
str_view(textos, "\\d+")  # Encuentra secuencias de números
str_view(textos,"[0-9]+")
# Buscar entre 2 y 3 dígitos consecutivos
str_view(textos, "\\d{2,3}")  # Encuentra secuencias de 2 o 3 números

# 3.5 Anclajes y límites
# -----------------------------------------
# ^ : inicio de cadena
# $ : fin de cadena
# \\b : límite de palabra
# \\B : no límite de palabra

# Buscar palabras que empiecen con "e"
str_view(str_to_lower(textos), "\\be\\w*")  # Encuentra palabras que empiezan con "e"
str_view(str_to_lower(textos), "^[e][a-z]*| [e][a-z]*")  # Encuentra palabras que empiezan con "e"

# 3.6 Grupos y capturas
# -----------------------------------------
# ( ) : define un grupo
# \\1, \\2, etc. : referencias a grupos capturados

# Capturar y reutilizar
str_view(textos, "(\\w+) (\\w+)", match = TRUE)  # Encuentra pares de palabras

## ===================================================
## 4. DETECCIÓN Y COINCIDENCIA DE PATRONES
## ===================================================

# 4.1 Detectar patrones
# -----------------------------------------

# str_detect(): Verifica si una cadena contiene un patrón (devuelve TRUE/FALSE)
# Detectar si los correos electrónicos contienen gmail
tiene_gmail <- str_detect(emails, "gmail")
print(data.frame(email = emails, es_gmail = tiene_gmail))
emails_df <- as_tibble(emails) %>% 
  mutate(es_gmail=str_detect(value,'gmail'),
         origen = str_extract(value,'com|es|ar'))

# Filtrar vectores basados en un patrón
emails_gmail <- emails[str_detect(emails, "gmail")]
print(emails_gmail)

# Contar cuántos elementos coinciden con un patrón
sum(str_detect(emails, "@"))  # Todos los correos tienen @
sum(str_detect(emails, "\\.com$"))  # Cuántos terminan en .com

# 4.2 Contar coincidencias
# -----------------------------------------

# str_count(): Cuenta cuántas veces aparece un patrón en cada cadena
# Contar vocales en nombres
vocales <- str_count(nombres, "[aeiouAEIOUáéíóúÁÉÍÓÚ]")
print(data.frame(nombre = nombres, n_vocales = vocales))

# Contar palabras en textos (simplificado como secuencias de caracteres no espacios)
palabras <- str_count(textos, "\\S+")
print(data.frame(texto = textos, n_palabras = palabras))

# 4.3 Localizar coincidencias
# -----------------------------------------

# str_locate(): Encuentra la posición de la primera coincidencia
# str_locate_all(): Encuentra todas las coincidencias
# Localizar la posición de la primera vocal
posicion_vocal <- str_locate(nombres, "[aeiouAEIOUáéíóúÁÉÍÓÚ]")
print(posicion_vocal)

# Localizar todas las vocales
posiciones_vocales <- str_locate_all(nombres, "[aeiouAEIOUáéíóúÁÉÍÓÚ]")
print(posiciones_vocales)

# 4.4 Visualizar coincidencias
# -----------------------------------------

# str_view(): Muestra visualmente dónde está la primera coincidencia
# str_view_all(): Muestra todas las coincidencias
# Ver dónde están los dígitos
str_view(telefonos, "\\d")
str_view_all(telefonos, "\\d")

# Ver dónde están los espacios
str_view_all(telefonos, "\\s")

## ===================================================
## 5. EXTRACCIÓN DE PATRONES
## ===================================================

# 5.1 Extraer coincidencias
# -----------------------------------------

# str_extract(): Extrae la primera coincidencia
# str_extract_all(): Extrae todas las coincidencias

# Extraer el primer número de cada teléfono
primer_numero <- str_extract(telefonos, "\\d")
print(data.frame(telefono = telefonos, primer_numero = primer_numero))

# Extraer todos los números
todos_numeros <- str_extract_all(telefonos, "\\d")
print(todos_numeros)

# Extraer secuencias de dígitos
digitos_consecutivos <- str_extract_all(telefonos, "\\d+")
print(digitos_consecutivos)

# Extraer dominios de correo electrónico
dominios <- str_extract(emails, "@[\\w\\.-]+")
dominios_clean <- str_replace(dominios, "@", "")  # Quitar el @
print(data.frame(email = emails, dominio = dominios_clean))

# Extraer códigos de país de teléfonos
codigos_pais <- str_extract(telefonos, "^\\(\\d+\\)|^\\+\\d+|^\\d+")
codigos_pais <- str_extract(telefonos, "^\\(\\d+\\)|^\\+\\d+|^\\d+")
print(data.frame(telefono = telefonos, codigo_pais = codigos_pais))

# 5.2 Extraer coincidencias usando grupos de captura
# -----------------------------------------

# str_match(): Extrae la primera coincidencia y los grupos capturados
# str_match_all(): Extrae todas las coincidencias y los grupos

# Extraer nombre y apellido
nombres_y_apellidos <- str_match(nombres_trim, "(\\w+)\\s+(\\w+)")
colnames(nombres_y_apellidos) <- c("nombre_completo", "nombre", "apellido")
print(nombres_y_apellidos)

# Extraer usuario y dominio de correos electrónicos
partes_email <- str_match(emails, "(.+)@(.+)")
colnames(partes_email) <- c("email_completo", "usuario", "dominio")
print(partes_email)

## ===================================================
## 6. REEMPLAZO DE PATRONES
## ===================================================

# 6.1 Reemplazar coincidencias
# -----------------------------------------

# str_replace(): Reemplaza la primera coincidencia
# str_replace_all(): Reemplaza todas las coincidencias

# Reemplazar espacios por guiones
nombres_con_guiones <- str_replace_all(nombres_trim, " ", "-")
print(data.frame(original = nombres_trim, con_guiones = nombres_con_guiones))

# Censurar información sensible: ocultar parte del email
emails_censurados <- str_replace(emails, "([^@]{3}).+(@.+)", "\\1***\\2")
print(data.frame(original = emails, censurado = emails_censurados))

# Formatear teléfonos: eliminar paréntesis, guiones y espacios
telefonos_limpios <- str_replace_all(telefonos, "[\\(\\)\\s-\\+]", "")
print(data.frame(original = telefonos, limpio = telefonos_limpios))

# 6.2 Reemplazo con referencias a grupos
# -----------------------------------------

# Reordenar nombre y apellido
nombres_reordenados <- str_replace(nombres_trim, "(\\w+)\\s+(\\w+)", "\\2, \\1")
print(data.frame(original = nombres_trim, reordenado = nombres_reordenados))

# Normalizar formatos de números telefónicos
telefonos_normalizados <- str_replace_all(telefonos, 
                                          "\\+?(\\d+)[\\s-]?(\\d+)[\\s-]?(\\d+)[\\s-]?(\\d+)", 
                                          "+\\1-\\2-\\3-\\4")
print(data.frame(original = telefonos, normalizado = telefonos_normalizados))

## ===================================================
## 7. OTRAS FUNCIONES ÚTILES DE STRINGR
## ===================================================

# 7.1 Rellenar cadenas
# -----------------------------------------

# str_pad(): Rellena cadenas para que tengan una longitud específica

# Rellenar con ceros a la izquierda
codigos <- c("1", "42", "873", "9541")
codigos_pad <- str_pad(codigos, width = 5, side = "left", pad = "0")
print(data.frame(original = codigos, rellenado = codigos_pad))

# Centrar texto
titulos <- c("Capítulo 1", "Introducción", "Métodos")
titulos_centrados <- str_pad(titulos, width = 20, side = "both", pad = "-")
print(titulos_centrados)

# 7.2 Recortar cadenas
# -----------------------------------------

# str_trunc(): Trunca cadenas a una longitud máxima

# Truncar nombres largos
nombres_truncados <- str_trunc(nombres, width = 8, side = "right", ellipsis = "...")
print(data.frame(original = nombres, truncado = nombres_truncados))


# 7.4 Eliminación selectiva
# -----------------------------------------

# str_remove(): Elimina la primera coincidencia de un patrón
# str_remove_all(): Elimina todas las coincidencias

# Eliminar caracteres no alfanuméricos
texto_con_simbolos <- "Este es un texto con #hashtags y @menciones!"
texto_limpio <- str_remove_all(texto_con_simbolos, "[^\\w\\s]")
print(data.frame(original = texto_con_simbolos, limpio = texto_limpio))

# Eliminar números
texto_sin_numeros <- str_remove_all(textos, "\\d")
print(data.frame(original = textos, sin_numeros = texto_sin_numeros))

# Combinacion
# Extraer solo los numeros 
telefono_df <- as_tibble(telefonos)
telefono_df <- telefono_df %>% 
  mutate(telefonos = str_remove_all(value,'-'),
         telefonos = str_remove(telefonos,'\\('),
         telefonos = str_remove(telefonos,'\\)'),
         telefonos = str_remove(telefonos,'\\+'),
         telefonos = str_remove_all(telefonos,'\\s'),
         telefonos = str_squish(telefonos))
telefono_df
## ===================================================
## 8. EJEMPLOS PRÁCTICOS DE USO
## ===================================================

# 8.1 Validación de correos electrónicos
# -----------------------------------------

# Un patrón simplificado para validar correos
patron_email <- "^[\\w.-]+@[\\w.-]+\\.[a-zA-Z]{2,}$"

emails_prueba <- c("usuario@dominio.com", "email@incorrecto", "otro.email@sub.dominio.co.uk", "@falta.usuario.com")
emails_validos <- str_detect(emails_prueba, patron_email)
print(data.frame(email = emails_prueba, es_valido = emails_validos))

# 8.2 Extracción de información estructurada
# -----------------------------------------

# Extraer información de texto estructurado
referencias <- c(
  "Smith J (2020). Statistical Analysis. Journal of Data, 12(3): 45-67.",
  "García A & López B (2021). Machine Learning Methods. Data Science Review, 5(1): 123-145.",
  "Taylor M et al. (2019). Deep Learning. AI Journal, 8(4): 78-92."
)

# Extraer autores, año y título
info_referencias <- str_match(referencias, "(.+) \\((\\d{4})\\)\\. (.+?)\\. (.+)")
colnames(info_referencias) <- c("referencia_completa", "autores", "año", "titulo", "revista_y_numero")
print(info_referencias)

# 8.3 Limpieza y normalización de datos
# -----------------------------------------

# Normalizar nombres propios
nombres_sucios <- c("  juan CARLOS pérez  ", "MARía JOSé gómez", "PEDRO   rodriguez")

nombres_limpios <- nombres_sucios %>%
  str_trim() %>%                 # Eliminar espacios inicio/fin
  str_squish() %>%               # Eliminar espacios múltiples
  str_to_lower() %>%             # Convertir a minúsculas
  str_replace_all("(\\b\\w)", function(x) str_to_upper(x))  # Primera letra de cada palabra en mayúscula

print(data.frame(original = nombres_sucios, limpio = nombres_limpios))

# 8.4 Análisis básico de texto
# -----------------------------------------

# Contar frecuencia de palabras en un texto
texto_largo <- "Este es un ejemplo de texto para análisis. Este texto contiene palabras repetidas. Las palabras repetidas son frecuentes en textos normales. Este análisis es simple pero útil para entender el texto."

# Convertir a minúsculas y dividir en palabras
palabras <- str_to_lower(texto_largo) %>%
  str_split("\\s+") %>%
  unlist()

# Eliminar puntuación al final de las palabras
palabras <- str_remove_all(palabras, "[.,;:!?]$")

# Contar frecuencia
tabla_frecuencia <- table(palabras)
tabla_ordenada <- sort(tabla_frecuencia, decreasing = TRUE)
print(tabla_ordenada)

# 8.5 Trabajando con datos del mundo real
# -----------------------------------------

# Simulemos una pequeña base de datos de clientes
clientes <- data.frame(
  id = 1:5,
  nombre = c("  Juan Pérez  ", "María GÓMEZ", "JOSÉ López", "ana martínez", "Pedro RODRÍGUEZ "),
  email = c("juanp@gmail.com", "maria@yahoo.es", "jose123@hotmail.com", "anamart@empresa.com", "pedro.rod@hotmail.com"),
  telefono = c("(34)612345678", "54-911-2345-6789", "1 800 555 1234", "612-34-56-78", "+44 20 1234 5678"),
  direccion = c("Calle Principal 123, Madrid", "Av. Libertador 4567, Buenos Aires", "Main St. 789, New York", "Gran Vía 234, Barcelona", "Oxford St. 567, London")
)

# Limpieza y estandarización completa
clientes_limpios <- clientes
clientes_limpios$nombre <- clientes$nombre %>%
  str_trim() %>%
  str_squish() %>%
  str_to_title()

# Estandarizar formato de teléfonos (ejemplo simplificado)
clientes_limpios$telefono <- clientes$telefono %>%
  str_remove_all("[\\(\\)\\s-]")

# Extraer ciudad de la dirección
clientes_limpios$ciudad <- clientes$direccion %>%
  str_extract(",[^,]+$") %>%
  str_remove(",") %>%
  str_trim()

# Mostrar los resultados
print(clientes_limpios)

## ===================================================
## 9. RESUMEN Y CONSEJOS FINALES
## ===================================================

# Puntos clave a recordar sobre stringr:
# 1. Todas las funciones empiezan con str_
# 2. El primer argumento es siempre el vector de cadenas
# 3. El segundo argumento es normalmente un patrón (string o regex)
# 4. La vectorización permite procesar muchas cadenas a la vez
# 5. Las funciones devuelven resultados del mismo largo que la entrada
# 6. Consistencia de la interfaz facilita el aprendizaje

# Consejos para trabajar con expresiones regulares:
# 1. Construir patrones paso a paso, probando cada componente
# 2. Usar str_view() para verificar visualmente los patrones
# 3. Aprender los metacaracteres más comunes: \d \w \s . + * ? [ ] ( )
# 4. Para patrones complejos, usar comentarios y separar en componentes
# 5. Guardar patrones útiles en variables para reutilizarlos
# 6. Recordar que en R los backslashes se duplican dentro de strings

# Recursos adicionales para profundizar:
# 1. Vignette de stringr: vignette("stringr")
# 2. RStudio Cheat Sheet de stringr
# 3. Libro "R for Data Science" de Hadley Wickham, capítulo de strings
# https://r4ds.hadley.nz/regexps.html
# 4. regex101.com para probar expresiones regulares (seleccionar PCRE)
# 5. stringi para operaciones más avanzadas con strings