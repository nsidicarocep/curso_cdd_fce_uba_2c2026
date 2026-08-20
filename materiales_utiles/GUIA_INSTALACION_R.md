# Guía de instalación: R, RStudio y paquetes

**Ciencia de Datos para Economía y Negocios — FCE-UBA — 2c 2026**

Esta guía te deja el entorno listo para trabajar en la materia. Son cuatro pasos y toma entre 20 y 40 minutos, casi todo tiempo de descarga.

> **Hacelo antes de la primera clase.** No hace falta que entiendas nada de lo que instalás: solo que corra.
>
> Si no podés instalar nada en tu computadora (equipo prestado, del trabajo, sin permisos de administrador, o con poco espacio), saltá a la sección **[Alternativa: Google Colab](#alternativa-google-colab)**.

---

## Qué vas a instalar y por qué

| Componente | Qué es | ¿Obligatorio? |
|---|---|---|
| **R** | El lenguaje. Es el motor que ejecuta el código. | Sí |
| **RStudio** | El entorno de trabajo (editor, consola, gráficos, ayuda). | Sí |
| **Paquetes** | Librerías que agregan funciones. Usamos `tidyverse` y algunos más. | Sí |
| **Rtools** (Windows) | Herramientas para compilar paquetes desde el código fuente. | **No** (ver FAQ) |
| **XQuartz** (macOS) | Sistema gráfico X11 para algunos paquetes puntuales. | **No** (ver FAQ) |

Son **dos programas separados**: RStudio no trae R adentro. Hay que instalar R primero, después RStudio. Si lo hacés al revés, RStudio no arranca.

---

## Paso 1 — Instalar R

Entrá a **[cran.r-project.org](https://cran.r-project.org/)** y elegí tu sistema operativo.

### 🪟 Windows

1. **Download R for Windows** → **base** → **Download R 4.x.x for Windows**
2. Ejecutá el `.exe` descargado.
3. En el instalador: **dejá todo por defecto** y andá clickeando *Siguiente*.
   - Idioma: el que quieras.
   - Carpeta de instalación: **no la cambies** (`C:\Program Files\R\R-4.x.x`).
   - Cuando pregunte *"¿Desea utilizar las opciones de configuración?"* → dejá **No** y seguí.
4. Finalizar.

> **⚠️ "Windows protegió su PC" (SmartScreen)**
>
> Es normal. Aparece porque el instalador es nuevo y Windows todavía no lo tiene fichado, no porque haya algo mal.
>
> **Clic en "Más información" → "Ejecutar de todas formas".**
>
> Si bajaste el archivo desde `cran.r-project.org` y no desde otro lado, es seguro.

### 🍎 macOS

Antes de bajar nada, **fijate qué procesador tenés**: menú  → *Acerca de esta Mac*.

- Si dice **Chip: Apple M1 / M2 / M3 / M4** → tenés **Apple silicon**
- Si dice **Procesador: Intel** → tenés **Intel**

Ahora sí:

1. **Download R for macOS**
2. Bajá el `.pkg` que corresponda:

   | Tu Mac | Archivo | Requiere |
   |---|---|---|
   | Apple silicon (M1–M4) | **`R-4.6.1-arm64.pkg`** | macOS 14 (Sonoma) o superior |
   | Intel | **`R-4.6.1-x86_64.pkg`** | macOS 11 (Big Sur) o superior |

   *Si tenés una Mac con chip M pero con macOS 12 o 13, no podés usar el build arm64: instalá el `x86_64.pkg` (corre vía Rosetta, un poco más lento pero funciona) o actualizá el sistema.*

3. Doble clic en el `.pkg` y seguí el instalador: **Continuar → Continuar → Instalar**. Te va a pedir tu contraseña de usuario.
4. Listo. R queda en `/Applications/R.app`, pero **no lo vas a abrir directamente**: se usa desde RStudio.

> **⚠️ Si macOS bloquea la instalación**
>
> El `.pkg` de CRAN está firmado y notarizado, así que normalmente no da problemas. Si igual aparece *"no se puede abrir porque proviene de un desarrollador no identificado"*:
>
> - Clic derecho sobre el archivo → **Abrir** → **Abrir** de nuevo en el cartel, **o**
> - *Ajustes del Sistema → Privacidad y seguridad* → bajá hasta el aviso y clic en **Abrir igualmente**.

### 🐧 Linux

En CRAN, **Download R for Linux** y seguí las instrucciones de tu distribución. En Ubuntu/Debian conviene usar el repositorio de CRAN (no el de la distro, que suele traer una versión vieja). Si usás Linux, probablemente esto ya lo sepas; si no, escribí al foro y te ayudamos.

---

## Paso 2 — Instalar RStudio

1. Entrá a **[posit.co/download/rstudio-desktop](https://posit.co/download/rstudio-desktop/)**
2. Bajá **RStudio Desktop**, la versión **gratuita (Open Source)**.

   | Sistema | Archivo | Requiere |
   |---|---|---|
   | Windows | `RStudio-2026.07.1-147.exe` (el `.exe`, **no** el `.zip`) | Windows 10 o superior |
   | macOS | `RStudio-2026.07.1-147.dmg` | macOS 13 o superior |

   **No** bajes *RStudio Pro* (es paga) ni *RStudio Server* (es para servidores Linux).

3. Instalá:
   - **Windows:** ejecutá el `.exe`, todo por defecto.
   - **macOS:** abrí el `.dmg` y **arrastrá el ícono de RStudio a la carpeta Aplicaciones**. Después expulsá el disco montado. La primera vez que lo abras, macOS te va a preguntar si estás seguro porque se descargó de internet → **Abrir**.
4. Abrí **RStudio** (no "R" ni "RGui" — esos son la interfaz vieja y básica).

### Si te aparece "Choose R Installation"

RStudio te pregunta qué versión de R usar. Elegí:

**☑ Use your machine's default 64-bit version of R**

y Rendering Engine en **Auto-detect (recommended)**. Aceptá.

*(Si la lista aparece vacía, es que R no se instaló bien: volvé al Paso 1.)*

---

## Paso 3 — Reconocer la pantalla

Cuando abrís RStudio vas a ver cuatro paneles:

```
┌──────────────────────────┬──────────────────────────┐
│  1. EDITOR               │  3. ENVIRONMENT          │
│  Tus scripts .R          │  Los objetos que creaste │
│  Acá escribís y guardás  │  (datos, variables)      │
├──────────────────────────┼──────────────────────────┤
│  2. CONSOLA              │  4. FILES / PLOTS /      │
│  Acá se ejecuta el código│     PACKAGES / HELP      │
│  y aparecen los mensajes │  Archivos y gráficos     │
└──────────────────────────┴──────────────────────────┘
```

Dos cosas que conviene tener claras desde el día uno:

- **El código va en el Editor, no en la Consola.** La consola no se guarda; el script sí. Para ejecutar una línea del editor: `Ctrl + Enter` (`Cmd + Enter` en Mac).
- Si el panel Editor no aparece, es porque no hay ningún script abierto: `Archivo → Nuevo archivo → R Script`.

---

## Paso 4 — Instalar los paquetes

Copiá esto en la **Consola** (panel inferior izquierdo), Enter, y andá a hacer otra cosa. Tarda entre 5 y 15 minutos.

```r
install.packages(c(
  "tidyverse",   # dplyr, ggplot2, tidyr, readr, stringr, forcats, lubridate, purrr
  "readxl",      # leer archivos .xlsx
  "janitor",     # limpieza de nombres de columnas y tablas
  "skimr",       # resúmenes descriptivos rápidos
  "scales"       # formatos de ejes: %, $, miles
))
```

Vas a ver muchísimas líneas de texto pasando (`probando la URL...`, `package 'x' successfully unpacked`). Es normal: `tidyverse` arrastra cerca de 90 paquetes de dependencias.

> **En Mac**, si en algún momento pregunta *"Do you want to install from sources the packages which need compilation?"*, respondé **`no`** y Enter. Con los binarios alcanza y evitás compilar durante media hora.

### Verificá que funcionó

```r
library(tidyverse)
```

Tiene que salir algo así:

```
── Attaching core tidyverse packages ──────────────── tidyverse 2.0.0 ──
✔ dplyr     1.2.1     ✔ readr     2.2.0
✔ forcats   1.0.1     ✔ stringr   1.6.0
✔ ggplot2   4.0.3     ✔ tibble    3.3.1
✔ lubridate 1.9.5     ✔ tidyr     1.3.2
✔ purrr     1.2.2
── Conflicts ──────────────────────────── tidyverse_conflicts() ──
✖ dplyr::filter() masks stats::filter()
✖ dplyr::lag()    masks stats::lag()
```

**Los "Conflicts" NO son errores.** Solo avisan que `dplyr` tiene funciones con el mismo nombre que las de base R y que van a prevalecer las de `dplyr`. Es lo esperado y lo que queremos.

### Prueba final

Pegá esto entero en la consola:

```r
library(tidyverse)

# Índice de precios (base 2019 = 100), valores aproximados a fin de cada año
precios <- tibble(
  anio  = 2019:2024,
  ipc   = c(100, 136.1, 205.4, 400.1, 1246.0, 2713.6)
)

precios <- precios |>
  mutate(var_ia = ipc / lag(ipc) - 1)

print(precios)

ggplot(precios, aes(x = anio, y = var_ia)) +
  geom_col(fill = "steelblue") +
  scale_y_continuous(labels = scales::percent) +
  labs(title = "Variación interanual", x = NULL, y = NULL) +
  theme_minimal()
```

Si ves la tabla en la consola **y** un gráfico de barras en el panel *Plots*, terminaste. El entorno está listo. ✅

---

## Paso 5 (recomendado) — Tres ajustes de configuración

Andá a **Tools → Global Options → General** (en Mac: *RStudio → Preferences*) y:

1. **Destildá** *"Restore .RData into workspace at startup"*
2. Poné *"Save workspace to .RData on exit"* en **Never**

> **Por qué importa:** si R guarda y restaura tu sesión anterior, terminás con código que "funciona" solo porque tenés objetos viejos dando vueltas en memoria. Cuando lo corrés de cero, falla. Empezar siempre limpio es la única forma de saber que tu script realmente anda.

3. En **Code → Editing**, tildá *"Use native pipe operator, |> "*.

Y para reiniciar la sesión cuando algo se ensucia: `Ctrl + Shift + F10` (`Cmd + Shift + F10` en Mac).

---

## Trabajar con Proyectos (.Rproj)

Cuando bajes el material de una clase, **no abras el `.R` haciendo doble clic sobre el archivo**. Hacé esto:

1. Descomprimí la carpeta de la clase en algún lugar fijo (ej: `Documentos/CDD/`).
2. En RStudio: **File → New Project → Existing Directory** → elegí esa carpeta.
3. De ahí en adelante abrís el archivo **`.Rproj`**, y desde el panel *Files* abrís los scripts.

Así el directorio de trabajo queda apuntado a la carpeta de la clase y las rutas del tipo `read_csv("datos/ipc.csv")` funcionan sin que tengas que tocar nada. Es la causa número uno de "a mí no me anda y a vos sí".

---

## Alternativa: Google Colab

**Google Colab** te deja correr R desde el navegador, sin instalar nada. Solo necesitás una cuenta de Google.

**Cuándo usarlo:**

- No podés instalar programas (computadora prestada, del trabajo, sin permisos de admin).
- Tu máquina no da (poco disco, sistema operativo viejo).
- Querés probar algo rápido desde otra computadora o compartir código con un compañero.

**Cuándo NO:** como reemplazo permanente de RStudio. La cursada, las prácticas y las entregas están pensadas para RStudio, y todo lo que aprendas de manejo de proyectos y rutas no se traslada. Usalo como plan B o como complemento, no como plan A.

### Cómo abrir un notebook de R

1. Entrá a **[colab.research.google.com](https://colab.research.google.com/)** e iniciá sesión con tu cuenta de Google.
2. **Archivo → Nuevo notebook** *(File → New notebook)*.
3. En el menú: **Entorno de ejecución → Cambiar tipo de entorno de ejecución**
   *(Runtime → Change runtime type)*.
4. En **Tipo de entorno de ejecución** elegí **R** y **Guardar**.
5. Verificá que quedó bien: escribí esto en una celda y ejecutala con `Ctrl + Enter`:

```r
R.version.string
```

Tiene que devolver `"R version 4.x.x ..."`. Si devuelve un error de Python, el runtime no cambió: repetí el paso 3.

### Los paquetes ya vienen instalados

Esta es la ventaja grande de Colab: **el entorno de R ya trae la mayoría de los paquetes que usamos**, así que no perdés 15 minutos instalando. Antes de instalar nada, probá directamente:

```r
library(tidyverse)
```

Si carga, listo, no hay nada que hacer. Solo si te da `there is no package called '...'` corré:

```r
install.packages("nombre_del_paquete")
```

En Colab la instalación compila desde el código fuente y es **bastante más lenta** que en tu computadora, así que instalá solo lo que te falte, no la lista entera.

### Lo que tenés que saber sí o sí

- **La máquina se borra.** Cuando cerrás el notebook o pasa un rato de inactividad, el entorno se reinicia: se pierde todo lo que instalaste con `install.packages()` y todos los archivos que subiste. El código del notebook sí queda guardado en tu Drive. Al volver, reinstalás y volvés a subir.
- **Los archivos van en el panel de la izquierda.** Ícono de carpeta 📁 → botón de subir. Se suben a la raíz, así que se leen como `read_csv("datos.csv")`. También podés montar tu Google Drive desde ese mismo panel.
- **No hay paneles.** No existe *Environment* ni *Plots*: los gráficos aparecen debajo de la celda que los generó. Para verlos más grandes, corré esto una vez al principio del notebook:

  ```r
  options(repr.plot.width = 9, repr.plot.height = 5)
  ```

- **Los atajos cambian.** `Ctrl + Enter` corre **toda la celda** (no la línea, como en RStudio). `Shift + Enter` corre la celda y pasa a la siguiente.
- **Si después de instalar un paquete te da un error raro de versiones** (`namespace 'x' is already loaded, but >= y is required`): *Entorno de ejecución → Reiniciar entorno de ejecución* y volvé a correr desde arriba.

---

## Paquetes que vamos a sumar más adelante

**No los instales ahora.** Los vas a necesitar recién cuando lleguemos a cada bloque; los dejamos acá para que tengas la lista en un solo lugar.

```r
# Inferencia por simulación (bootstrap, permutaciones)
install.packages(c("infer", "broom"))

# Limpieza y datos faltantes
install.packages(c("naniar", "visdat"))

# Series de tiempo e índices económicos
install.packages(c("zoo", "tsibble", "feasts", "ineq"))

# Clustering y PCA
install.packages(c("cluster", "factoextra", "FactoMineR"))

# Visualización y presentación de resultados
install.packages(c("patchwork", "ggrepel", "gt", "knitr", "rmarkdown"))
```

---

## Preguntas frecuentes y problemas típicos

### 🪟 "WARNING: Rtools is required to build R packages but is not currently installed"

**Ignoralo.** Rtools sirve para compilar paquetes desde el código fuente, algo que no vamos a hacer en la materia: en Windows los paquetes se bajan ya compilados (binarios `.zip`). El aviso aparece siempre y no impide nada.

Solo instalá Rtools si alguna vez un paquete falla explícitamente pidiéndolo.

### 🪟 El instalador dice que necesito UCRT

Si tenés **Windows 10 u 11, ya lo tenés**. El aviso es para versiones anteriores de Windows.

### 🍎 ¿Necesito instalar XQuartz?

**No para esta materia.** XQuartz hace falta solo para el paquete `tcltk`, el dispositivo gráfico X11 y algunos paquetes puntuales como `rgl`. Nada de eso lo usamos. Si más adelante un paquete lo pide, lo bajás de [xquartz.org](https://www.xquartz.org/).

### 🍎 Bajé el `arm64.pkg` y no instala

Ese build pide **macOS 14 (Sonoma) o superior**. Si tenés una Mac con chip M pero con macOS 12 o 13, instalá el `x86_64.pkg`: funciona vía Rosetta. La otra opción es actualizar el sistema.

### 🍎 RStudio no me abre / dice que no es compatible

RStudio 2026.07 pide **macOS 13 o superior**. Si tenés una versión anterior, bajá una release vieja de RStudio desde *[Older versions of RStudio](https://posit.co/download/rstudio-desktop/)* (al final de la página).

### Ya tenía R instalado de antes, ¿actualizo?

Si tu versión es **4.3 o superior**, podés seguir con esa. Si es más vieja, instalá la nueva: R permite tener varias versiones conviviendo, y en RStudio elegís cuál usar desde *Tools → Global Options → General → R version*.

Ojo: al cambiar de versión mayor (4.5 → 4.6) los paquetes hay que reinstalarlos.

### `Error in library(tidyverse) : there is no package called 'tidyverse'`

No se instaló. Volvé al Paso 4. Fijate si en la salida del `install.packages()` hubo alguna línea con `non-zero exit status` o `cannot open URL`.

### La instalación de paquetes falla o queda a medias

Probá, en orden:

1. Reiniciá RStudio y corré `install.packages("tidyverse")` de nuevo (a veces es una descarga cortada).
2. **Windows:** cerrá RStudio, abrilo **como administrador** (clic derecho → *Ejecutar como administrador*) y reintentá.
3. **Windows:** si tu carpeta de usuario tiene tildes o eñes (`C:\Users\Nicolás\...`), puede dar problemas. Definí una biblioteca alternativa:
   ```r
   dir.create("C:/Rlibs", showWarnings = FALSE)
   .libPaths("C:/Rlibs")
   install.packages("tidyverse")
   ```
   Para que quede fijo, agregá esa línea `.libPaths("C:/Rlibs")` a tu archivo `.Rprofile`.
4. Si estás detrás del firewall de la facultad o del trabajo, probá desde otra red.

### Los paquetes están en OneDrive / iCloud y todo va lentísimo

Pasa seguido. Si tu carpeta `Documentos` está sincronizada con OneDrive o iCloud Drive, movés la biblioteca de R fuera de ahí con el truco de `.libPaths()` del punto anterior (en Mac, algo como `.libPaths("~/Rlibs")`).

### Me aparecen caracteres raros: `Ã¡`, `Ã±`, `<U+00F1>`

Es un problema de codificación al leer archivos. Dos cosas:

- En RStudio: *Tools → Global Options → Code → Saving → Default text encoding:* **UTF-8**.
- Al leer un CSV que viene mal: `read_csv("archivo.csv", locale = locale(encoding = "latin1"))`.

### ¿Puedo usar Python en vez de R?

**Sí, se puede.** Si ya venís trabajando en Python (o en otro lenguaje) y preferís resolver las entregas ahí, está habilitado. Desde la ayudantía tenemos experiencia en Python y podemos acompañarte tanto durante la cursada como en la corrección.

Ahora, dos cosas que conviene que sepas antes de decidir:

- **Conviene que lo avises al principio**, no en la primera entrega, así coordinamos cómo entregás (notebook, script, formato de salida) y no hay sorpresas en la corrección.
- **Aun si entregás en Python, instalá R igual.** Lo vas a necesitar para seguir las clases en vivo.

La buena noticia es que el pasaje es corto en los dos sentidos: `dplyr` ≈ `pandas`, `ggplot2` ≈ `matplotlib`/`seaborn`, `tibble` ≈ `DataFrame`. Lo que se aprende en la materia es cómo pensar el trabajo con datos, y eso viaja entre lenguajes; la sintaxis es lo de menos.

---

## Antes de la primera clase, chequeá que tenés

- [ ] R instalado (versión 4.3 o superior)
- [ ] RStudio abre y muestra los cuatro paneles
- [ ] `library(tidyverse)` corre sin error
- [ ] La prueba final devuelve la tabla **y** el gráfico
- [ ] "Restore .RData at startup" destildado

*(Si vas por Colab: un notebook con el runtime en R y `library(tidyverse)` cargando.)*

Si algo de esto falla, escribí al foro de la materia **antes** de la clase, con:

1. Qué paso estabas haciendo y en qué sistema operativo.
2. El mensaje de error **copiado y pegado completo** (no una captura recortada).
3. La salida de correr esto en la consola:

```r
sessionInfo()
```

---

## Recursos

- **[R for Data Science (2ª ed.)](https://r4ds.hadley.nz/)** — bibliografía principal de la materia, gratis y online. Hay [traducción al español de la 1ª edición](https://es.r4ds.hadley.nz/).
- **[Posit Cheatsheets](https://posit.co/resources/cheatsheets/)** — hojas de referencia de `dplyr`, `ggplot2`, etc. Imprimí la de `dplyr`.
- **[CRAN](https://cran.r-project.org/)** — repositorio oficial de R y de todos los paquetes.
- **[Google Colab](https://colab.research.google.com/)** — entorno online, sin instalación.

---

*Última actualización: agosto 2026 · Versiones de referencia: R 4.6.1 · RStudio 2026.07.1*
