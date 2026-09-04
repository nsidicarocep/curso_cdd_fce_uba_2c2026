# Guía de Git y GitHub

*Ciencia de Datos para Economía y Negocios | FCE-UBA | Cátedra Sidicaro | 2c2026*

Esta guía está pensada para alguien que nunca usó Git ni GitHub. No hace falta saber programar para seguirla. Se lee en orden: cada parte usa lo de la anterior.

**Qué vas a poder hacer al terminarla**

- Tener tu cuenta de GitHub.
- Bajar a tu computadora el repositorio del curso y mantenerlo actualizado.
- Crear el repositorio de tu grupo para el Trabajo Práctico, subir tu proyecto y trabajar ahí con tus compañeros.
- Hacer todo eso de dos formas: con botones (GitHub Desktop) o escribiendo comandos (PowerShell / Terminal / Git Bash).

**Índice**

| Parte | Contenido | ¿Cuándo la necesito? |
|---|---|---|
| 1 | Qué son Git y GitHub | Antes que nada |
| 2 | Crear la cuenta de GitHub | Una sola vez |
| 3 | Instalar los programas (Windows y Mac) | Una sola vez |
| 4 | Bajar el repositorio del curso y actualizarlo | Todo el cuatrimestre |
| 5 | Subir tu proyecto del TP a GitHub | Cuando arranque el TP |
| 6 | Autenticación: el token de GitHub | La primera vez que subas algo |
| 7 | Git Bash y los comandos | Opcional |
| 8 | Errores comunes | Cuando algo no funciona |
| 9 | Glosario y resumen de una carilla | Para tener a mano |

**Dos aclaraciones antes de empezar**

1. Todo funciona igual en **Windows** y en **Mac**. Donde cambia algo, está marcado con **En Windows** / **En Mac**.
2. Vas a ver dos formas de hacer lo mismo: apretando botones y escribiendo comandos. **No son dos programas distintos**: es el mismo Git manejado de dos maneras. Empezá por los botones; los comandos vienen después.

---

# Parte 1 — Qué son Git y GitHub

## 1.1 El problema que resuelven

Pensá en cómo se guarda normalmente un trabajo largo. Empieza así:

```
TP_final.R
TP_final_v2.R
TP_final_v2_corregido.R
TP_final_DEFINITIVO.R
TP_final_DEFINITIVO_este_si.R
```

Y sigue así: se lo mandás por mail a un compañero, él le hace cambios, vos también le hiciste cambios mientras tanto, y ahora hay dos archivos distintos y nadie sabe cuál tiene lo bueno de los dos. Si algo se rompió, tampoco hay forma de saber cuándo se rompió ni de volver a la versión que andaba.

Git y GitHub existen para eso. No son una moda de programadores: son la respuesta a ese problema concreto.

## 1.2 Git: el historial

**Git es un programa que se instala en tu computadora y lleva el historial de una carpeta.**

Cada tanto, cuando terminás algo que funciona, le decís a Git: "guardá este momento". Git saca una foto del estado completo de la carpeta y la anota en una lista, con la fecha, tu nombre y una frase que vos escribís explicando qué hiciste.

Esa foto se llama **commit**.

A partir de ahí podés ver la lista completa de commits, ver qué línea cambió entre uno y otro, y volver a cualquier estado anterior si rompiste algo.

Es parecido al historial de versiones de un documento de Google Docs, con una diferencia importante: **acá vos decidís cuándo se guarda un punto del historial y le ponés un nombre**. No queda un registro automático de cada tecla, sino una lista de momentos que vos elegiste, cada uno con su explicación.

> **Importante:** Git no guarda nada solo. Si no hacés un commit, no hay historial.

## 1.3 GitHub: el lugar en internet

Git vive en tu computadora. Eso alcanza para tener historial, pero no para compartir nada ni para tener una copia a salvo si se te rompe la máquina.

**GitHub es un sitio web donde se sube esa carpeta con todo su historial.**

Una vez que está en GitHub: tus compañeros pueden bajarla y trabajar sobre lo mismo, no perdés nada si se te rompe la computadora, el profesor puede ver el trabajo entrando a un link, y queda registrado quién hizo cada cosa y cuándo.

Es, a grandes rasgos, un Drive especializado en carpetas con historial. Pero la diferencia con Drive importa: **GitHub no sincroniza solo**. Los cambios suben cuando vos los mandás y bajan cuando vos los pedís.

| | Git | GitHub |
|---|---|---|
| Qué es | Un programa | Un sitio web |
| Dónde está | En tu computadora | En internet |
| Para qué sirve | Llevar el historial | Guardar y compartir ese historial |
| ¿Necesita internet? | No | Sí |

## 1.4 El mapa: dos lugares y cuatro movimientos

La misma carpeta vive en **dos lugares**: tu computadora y GitHub. Entre esos dos lugares hay **cuatro movimientos**, y con eso se hace casi todo.

| # | Movimiento | Va de | Va a | ¿Cuántas veces? | ¿Internet? |
|---|---|---|---|---|---|
| 1 | **Clone** (clonar) | GitHub | Tu computadora | Una sola vez por proyecto | Sí |
| 2 | **Commit** (confirmar) | — | Historial local | Muchas veces por día | No |
| 3 | **Push** (empujar) | Tu computadora | GitHub | Al terminar de trabajar | Sí |
| 4 | **Pull** (traer) | GitHub | Tu computadora | Antes de empezar a trabajar | Sí |

El ciclo normal es: **pull → trabajar → commit → push**. Traés lo último que hay, hacés lo tuyo, lo guardás en el historial y lo subís.

Hay un quinto movimiento que aparece cuando la carpeta que te interesa es de otra persona:

5. **Fork (bifurcar)** — Hacés una copia tuya, dentro de GitHub, del repositorio de otro. Esa copia queda en tu cuenta y podés modificarla sin tocar la original. Sirve para experimentar sobre el material de la cátedra sin miedo a romper nada. **Para el TP no hace falta**: el repo del grupo se crea nuevo, desde cero (Parte 5).

## 1.5 Vocabulario mínimo

Ocho palabras alcanzan para toda la guía. No las memorices ahora; volvé acá cuando aparezcan.

| Palabra | Qué significa |
|---|---|
| **Repositorio** (o *repo*) | Una carpeta con historial de Git. Puede estar en tu computadora, en GitHub, o en los dos lados. |
| **Commit** | Un punto guardado del historial. También el verbo: guardar ese punto. |
| **Mensaje de commit** | La frase que escribís al hacer un commit para explicar qué cambiaste. |
| **Clonar** | Bajar por primera vez a tu computadora un repositorio de GitHub. |
| **Push** | Subir tus commits a GitHub. |
| **Pull** | Bajar de GitHub los commits de los demás. |
| **Fork** | Copiar el repositorio de otra persona a tu propia cuenta de GitHub. |
| **README** | El archivo de presentación del repositorio: es lo que se ve al entrar a la página del repo. |

## 1.6 Qué NO es Git

- **No es un backup automático.** Guarda solo lo que vos le decís, cuando se lo decís.
- **No sincroniza como Drive o Dropbox.** Nada sube ni baja solo.
- **No sirve bien para archivos pesados** (videos, bases enormes, Excel de cientos de MB). Está hecho para archivos de texto: código, CSV, documentos.
- **No es solo para programadores.** Sirve para cualquier trabajo con historial y varias personas tocando los mismos archivos.

## 1.7 Por qué nos importa en esta materia

1. **El material del curso vive en un repositorio de GitHub.** Bajarlo y actualizarlo es la forma de tener siempre la última versión de clases, datos y prácticas.
2. **El TP se trabaja en grupo.** Sin Git, coordinar tres o cuatro personas sobre los mismos scripts de R termina en el problema del punto 1.1.
3. **Es una herramienta de trabajo real.** En cualquier puesto de datos se da por supuesto que la manejás, y un GitHub con trabajo propio hecho es algo que se mira.

---

# Parte 2 — Crear la cuenta de GitHub

Se hace una sola vez y es gratis. Tardás cinco minutos.

**Paso 1.** Entrá a [github.com](https://github.com) y hacé clic en **Sign up** (arriba a la derecha).

> **Atajo recomendado:** si tenés cuenta de Google, elegí **Continue with Google** / **Sign up with Google**. Te saltea la contraseña, el código por mail y la verificación en dos pasos: entrás con la cuenta de Google que ya usás. Solo te va a pedir que elijas un nombre de usuario. Si usás este camino, salteá los pasos 2, 3 y 4 y seguí en el 5.

**Si preferís el camino tradicional (usuario y contraseña propios):**

**Paso 2.** Completá:

- **Email**: usá un mail al que entres siempre. Si pensás usar GitHub después de la facultad, mejor uno personal que el institucional.
- **Password**: mínimo 8 caracteres con números y letras. Anotala en algún lado.
- **Username**: es tu nombre público y va a aparecer en el link de todos tus repositorios (`github.com/tu-usuario`). Elegí algo sobrio y que se pueda decir en voz alta: `mbeltran`, `maida-beltran`. Evitá apodos o números al azar: este link se comparte en un CV.

**Paso 3.** Resolvé el desafío visual que aparece (es para verificar que no sos un robot).

**Paso 4.** GitHub te manda un **código de 8 dígitos por mail**. Copialo y pegalo en la pantalla. Si no llega, revisá spam.

**Paso 5.** Te va a preguntar cuánta gente sos, para qué lo vas a usar y si querés Copilot. Podés saltear todo con **Skip personalization** o elegir el plan **Free**. No hace falta pagar nada.

**Listo.** Ya tenés cuenta. Anotá tu usuario y contraseña: los vas a necesitar en la Parte 3.

> **Recomendación:** activá la verificación en dos pasos (2FA) cuando GitHub te lo ofrezca, con la app de autenticación del celular. Es obligatorio en algunos casos y evita dolores de cabeza más adelante.

---

# Parte 3 — Instalar los programas

Vas a instalar **dos** cosas. Son distintas y las dos hacen falta:

| Programa | Qué es | ¿Obligatorio? |
|---|---|---|
| **Git** | El motor. Es el programa que lleva el historial. No tiene ventana propia: trabaja por detrás. | Sí |
| **GitHub Desktop** | La ventana con botones para manejar Git sin escribir comandos. | Muy recomendado |

GitHub Desktop **usa** Git por debajo. Por eso primero se instala Git.

## 3.1 Instalar Git

### En Windows

**Paso 1 — Fijate si ya lo tenés.** Apretá `Win + R`, escribí `powershell` y Enter. En la ventana azul escribí:

```powershell
git --version
```

Si te contesta algo como `git version 2.51.0.windows.1`, **ya está instalado**: pasá al punto 3.2. Si dice que no reconoce el comando, seguí.

**Paso 2 — Descargalo.** Entrá a [git-scm.com/downloads](https://git-scm.com/downloads) y hacé clic en **Download for Windows**. Se baja un archivo `.exe`.

**Paso 3 — Instalalo.** Abrí el archivo descargado. El instalador te va a hacer muchas preguntas: **dejá todo como viene y apretá Next en todas**. Las opciones por defecto son las correctas. Al final, **Install** y después **Finish**.

**Paso 4 — Verificá.** Cerrá PowerShell y abrilo de nuevo (esto es importante: si no lo cerrás, no reconoce el programa recién instalado). Escribí otra vez:

```powershell
git --version
```

Ahora sí tiene que contestarte con un número de versión.

### En Mac

**Paso 1 — Fijate si ya lo tenés.** Abrí la **Terminal** (`Cmd + Espacio`, escribí `Terminal`, Enter) y escribí:

```bash
git --version
```

Si contesta con un número de versión, ya está: pasá al 3.2.

**Paso 2 — Si no lo tenés**, la misma Terminal te va a ofrecer instalar las *Command Line Tools* con una ventana emergente. Aceptá y esperá; instala Git junto con otras herramientas. Si esa ventana no aparece, escribí:

```bash
xcode-select --install
```

**Paso 3 — Verificá** con `git --version` de nuevo.

> **Alternativa en Mac:** también podés bajar el instalador desde [git-scm.com/downloads](https://git-scm.com/downloads). Cualquiera de las dos vías sirve.

## 3.2 Instalar GitHub Desktop

Es el programa con botones. Con esto vas a hacer el 90% del trabajo del cuatrimestre.

**Paso 1.** Entrá a [desktop.github.com](https://desktop.github.com) y hacé clic en el botón de descarga. La página detecta sola si estás en Windows o en Mac.

**Paso 2 — Instalá.**

- **En Windows:** abrí el `.exe` descargado. Se instala solo, sin preguntas.
- **En Mac:** abrí el `.zip`, y arrastrá el ícono de **GitHub Desktop** a la carpeta **Aplicaciones**. Después abrilo desde ahí. Si aparece un aviso de que la app se descargó de internet, dale **Abrir**.

**Paso 3 — Conectalo con tu cuenta.** Al abrirlo por primera vez te va a decir **Sign in to GitHub.com**. Hacé clic ahí: se abre el navegador, ponés tu usuario y contraseña de la Parte 2, y volvés solo a GitHub Desktop.

**Paso 4 — Configurá tu nombre.** Te va a mostrar una pantalla con **Name** y **Email**. Vienen completados con los datos de tu cuenta: dejalos así y dale **Finish**. Ese nombre es el que va a figurar en cada commit que hagas.

> **Por qué conviene hacer este paso ahora:** al iniciar sesión acá, GitHub Desktop deja resuelto el tema de las contraseñas. Si más adelante usás comandos, la Parte 6 explica el token que hace falta en ese caso.

## 3.3 Verificación de la Parte 3

Antes de seguir, chequeá las tres cosas:

- [ ] `git --version` contesta con un número, en PowerShell o Terminal.
- [ ] GitHub Desktop abre y arriba a la izquierda dice tu nombre de usuario.
- [ ] Podés entrar a `github.com/tu-usuario` desde el navegador y ves tu perfil.

---

# Parte 4 — Bajar el repositorio del curso y mantenerlo actualizado

Todo el material de la materia (clases, datos, prácticas, bibliografía) está en este repositorio:

```
https://github.com/nsidicarocep/curso_cdd_fce_uba_2c2026
```

Podés mirarlo desde el navegador, pero para trabajar necesitás una copia en tu computadora. Eso es **clonar**.

Hay dos formas de hacerlo. **Elegí una sola.** Las dos dejan exactamente el mismo resultado.

- **4.1 con GitHub Desktop** — con botones. Recomendada.
- **4.2 con PowerShell o Terminal** — escribiendo un comando.

## 4.1 Clonar con GitHub Desktop (recomendado)

**Paso 1.** Abrí GitHub Desktop.

**Paso 2.** Menú **File** → **Clone repository**.

**Paso 3.** En la ventana que se abre, elegí la solapa **URL** y pegá la dirección del repositorio:

```
https://github.com/nsidicarocep/curso_cdd_fce_uba_2c2026
```

**Paso 4 — Elegí dónde guardarlo.** En **Local path** decís en qué carpeta de tu computadora se va a bajar. Por defecto propone algo como `C:\Users\TU_USUARIO\Documents\GitHub`. Está bien dejarlo así, pero **anotá la ruta**: vas a necesitar saber dónde quedó cuando abras los archivos desde RStudio.

**Paso 5.** Hacé clic en **Clone** y esperá. La primera vez tarda un poco porque baja archivos grandes (slides, datos).

**Listo.** Ya tenés todo el material en tu computadora. Para abrir la carpeta: menú **Repository** → **Show in Explorer** (o **Show in Finder** en Mac).

## 4.2 Clonar con PowerShell (Windows) o Terminal (Mac)

Misma operación, escrita.

**Paso 1 — Abrí la terminal.**

- **En Windows:** `Win + R` → escribí `powershell` → Enter.
- **En Mac:** `Cmd + Espacio` → escribí `Terminal` → Enter.

**Paso 2 — Ubicate en la carpeta donde querés guardar el repo.** El comando `cd` significa *change directory*: sirve para pararte en una carpeta.

**En Windows:**

```powershell
cd "C:\Users\TU_USUARIO\Desktop\UBA\Ciencia de Datos"
```

Reemplazá `TU_USUARIO` por tu nombre de usuario de Windows. Si esa carpeta no existe todavía, creala primero:

```powershell
mkdir "C:\Users\TU_USUARIO\Desktop\UBA\Ciencia de Datos"
```

**En Mac:**

```bash
cd ~/Desktop/UBA/"Ciencia de Datos"
```

(`~` significa tu carpeta de usuario. Si no existe: `mkdir -p ~/Desktop/UBA/"Ciencia de Datos"`.)

> **Truco para no equivocarte escribiendo la ruta:** escribí `cd ` (con el espacio) y arrastrá la carpeta desde el Explorador o el Finder hasta la ventana de la terminal. La ruta se escribe sola.

**Paso 3 — Cloná.**

```
git clone https://github.com/nsidicarocep/curso_cdd_fce_uba_2c2026.git repo_catedra
```

Esto descarga todo el contenido en una carpeta nueva llamada `repo_catedra`. La última palabra del comando es el nombre que le querés poner a la carpeta; si no ponés ninguno, se llama igual que el repositorio.

**Paso 4 — Verificá que bajó bien.**

- **En Windows:** `dir repo_catedra`
- **En Mac:** `ls repo_catedra`

Tenés que ver carpetas como `clases`, `datos`, `trabajo_practico`, `bibliografia`, `utils`, `output` y el archivo `README.md`.

## 4.3 Traer las clases nuevas: `pull`

Esto es lo que vas a hacer todas las semanas.

**Git no se actualiza solo.** Cada vez que el profesor suba una clase nueva, un dataset o una corrección, hay que traer los cambios a mano.

**Con GitHub Desktop:** abrí el programa, asegurate de que arriba a la izquierda diga `curso_cdd_fce_uba_2c2026` (si no, hacé clic ahí y elegilo de la lista) y apretá el botón **Fetch origin**. Si hay novedades, el botón cambia a **Pull origin**: apretalo de nuevo y listo.

**Con PowerShell o Terminal:** primero entrá a la carpeta del repositorio y después pedí los cambios.

```powershell
cd "C:\Users\TU_USUARIO\Desktop\UBA\Ciencia de Datos\repo_catedra"
git pull
```

Si hay archivos nuevos, los vas a ver bajar. Si no hay nada nuevo, dice `Already up to date.`

> **Cuándo hacerlo:** antes de cada clase, y cada vez que avisen por el grupo que subieron material.

## 4.4 Una advertencia importante sobre el repo del curso

Este repositorio es **del profesor**: vos podés bajarlo y leerlo, pero no subir cambios.

Por eso, **no trabajes adentro de esa carpeta**. Si escribís tus propias notas o resolvés los ejercicios modificando los archivos que están ahí, el próximo `pull` puede chocar con tus cambios y darte un error.

**Qué hacer en cambio:** creá una carpeta aparte para vos (por ejemplo `mis_practicas`, al lado de `repo_catedra`, no adentro) y copiá ahí los scripts que vayas a modificar. Así el repo del curso queda siempre limpio y el `pull` nunca falla.

---

# Parte 5 — Subir tu proyecto del TP a GitHub

Hasta acá bajaste algo que ya existía. Ahora es al revés: tenés (o vas a tener) una carpeta en tu computadora con el TP, y querés que viva en GitHub para trabajarla con tu grupo y entregarla.

**El orden es:** crear el repositorio vacío en GitHub → conectarlo con tu carpeta → subir → invitar a los compañeros.

> **Quién hace qué:** los pasos 5.1 a 5.3 los hace **una sola persona del grupo**. El resto se suma en el 5.5 clonando lo que esa persona subió. Definan quién antes de empezar, para no terminar con tres repositorios distintos.

## 5.1 Crear el repositorio en GitHub

**Paso 1.** Entrá a [github.com](https://github.com) con tu cuenta.

**Paso 2.** Arriba a la derecha, hacé clic en el **+** → **New repository**. (Atajo: entrar directo a [github.com/new](https://github.com/new).)

El formulario tiene dos bloques numerados: **1 General** y **2 Configuration**.

**Paso 3 — Bloque 1: General**

- **Owner**: quién es el dueño. Tiene que decir **tu nombre de usuario**. Si aparece una lista para elegir, verificá que no estés creándolo dentro de otra organización.
- **Repository name** (obligatorio): **sin espacios ni acentos**, separando con guiones. Por ejemplo `tp-cdd-grupo3`. GitHub te propone un nombre inventado al azar debajo del campo: ignoralo y escribí el tuyo.
- **Description** (opcional pero conviene): `Trabajo Práctico — Ciencia de Datos FCE-UBA 2c2026 — Grupo 3`.

**Paso 4 — Bloque 2: Configuration**

- **Choose visibility**: elegí **Public**.

  > **En esta materia el repositorio del TP va público**, para que la cátedra pueda ver y corregir el avance durante la cursada. *Public* significa que cualquiera puede **leerlo**; **escribir** solo podés vos y los colaboradores que invites (5.4). Como es público, no subas nada que no quieras que se vea: contraseñas, tokens, datos personales de terceros o bases que no se puedan compartir.

- **Add README**: es un interruptor que viene en **Off**. **Pasalo a On.** Crea el archivo de presentación y evita que el repositorio nazca vacío, que es lo que más complica los pasos siguientes.
- **Add .gitignore**: abrí la lista y elegí **R**. Sirve para que Git ignore automáticamente los archivos temporales que genera RStudio y no los suba.
- **Add license**: dejalo sin elegir. Para un TP de la materia no hace falta.

**Paso 5.** Botón **Create repository**, al final de la página.

Ya tenés el repositorio en internet, con un README adentro. Su dirección es `https://github.com/tu-usuario/tp-cdd-grupo3`.

> **Si la pantalla no te coincide exactamente:** GitHub cambia el diseño de este formulario cada tanto. Los campos son siempre los mismos aunque cambien de lugar: dueño, nombre, visibilidad, README, .gitignore.

## 5.2 Bajarlo y trabajar adentro (la forma simple)

La manera más fácil de no pelearse con nada: **cloná el repo vacío y poné tus archivos adentro**.

**Paso 1.** En GitHub Desktop: **File** → **Clone repository** → solapa **GitHub.com**. Ahí aparece tu repositorio recién creado. Seleccionalo, elegí dónde guardarlo y **Clone**.

**Paso 2.** Abrí esa carpeta (**Repository** → **Show in Explorer / Show in Finder**) y copiá adentro los archivos de tu TP: los `.R`, los datos, lo que tengas.

**Paso 3 — Volvé a GitHub Desktop.** Vas a ver, en la columna de la izquierda, la lista de todos los archivos que agregaste. Eso es Git avisándote qué cambió.

**Paso 4 — Hacé el commit.** Abajo a la izquierda hay dos casillas:

- **Summary**: escribí en una línea qué hiciste. Por ejemplo `Primera versión del script de limpieza`.
- **Description**: opcional, para detalles.

Apretá el botón **Commit to main**.

> **Cómo escribir el mensaje de commit:** que describa el cambio, no el archivo. `Agrego gráfico de inflación por región` sirve; `cambios`, `asdasd` o `subo cosas` no le sirven a nadie, empezando por vos dentro de tres semanas.

**Paso 5 — Subilo.** Arriba aparece el botón **Push origin**. Apretalo. Eso manda tus commits a GitHub.

**Paso 6 — Comprobá.** Entrá desde el navegador a `github.com/tu-usuario/tp-cdd-grupo3`. Tienen que estar tus archivos ahí.

## 5.3 Si tu carpeta ya existe y no querés moverla (por comandos)

Si ya venías trabajando en una carpeta y preferís conectarla tal como está, se hace con cuatro comandos. Esta vía **sí** te va a pedir el token de la Parte 6.

Abrí PowerShell (Windows) o Terminal (Mac), entrá a tu carpeta con `cd` y escribí, uno por uno:

```bash
git init
git add .
git commit -m "Primera versión del TP"
git branch -M main
git remote add origin https://github.com/TU_USUARIO/tp-cdd-grupo3.git
git push -u origin main
```

Qué hace cada uno:

| Comando | Qué hace |
|---|---|
| `git init` | Le dice a Git que empiece a llevar el historial de esta carpeta. |
| `git add .` | Marca todos los archivos para el próximo commit. El punto significa "todo lo que hay acá". |
| `git commit -m "..."` | Guarda el punto en el historial, con ese mensaje. |
| `git branch -M main` | Le pone `main` de nombre a la línea de trabajo (es el nombre estándar). |
| `git remote add origin ...` | Conecta tu carpeta con el repositorio de GitHub. `origin` es el apodo de esa dirección. |
| `git push -u origin main` | Sube todo por primera vez. El `-u` hace que después alcance con escribir `git push`. |

> Si al crear el repositorio en GitHub tildaste **Add a README**, este camino puede darte un error de que el remoto tiene cambios que vos no tenés. Se arregla con `git pull origin main --allow-unrelated-histories` y después el `git push`. Si eso te suena a mucho, usá el camino del 5.2: no tiene este problema.

## 5.4 Invitar a tus compañeros

Sin este paso, los demás pueden ver el repositorio (si es público) pero no subir nada.

**Paso 1.** Entrá al repositorio en GitHub, en el navegador.

**Paso 2.** Solapa **Settings** (arriba, a la derecha del todo).

**Paso 3.** En la columna de la izquierda: **Collaborators**. Puede pedirte la contraseña de nuevo.

**Paso 4.** Botón **Add people**. Escribí el **nombre de usuario de GitHub** de tu compañero (no el mail común: el usuario). Seleccionalo y confirmá.

**Paso 5.** A tu compañero le llega una invitación por mail. **Tiene que aceptarla** para poder subir cambios.

Repetilo con cada integrante. También conviene invitar al docente si la cátedra lo pide.

## 5.5 Cómo trabajan los demás integrantes

Cada uno, desde su computadora:

1. Abre GitHub Desktop → **File** → **Clone repository** → solapa **GitHub.com** → elige el repo del grupo → **Clone**.
2. Trabaja en los archivos normalmente, desde RStudio o desde donde sea.
3. Vuelve a GitHub Desktop, escribe el mensaje, **Commit to main**, y **Push origin**.

## 5.6 La regla de oro para no chocar entre ustedes

Como todos trabajan sobre los mismos archivos, hay una sola regla que evita casi todos los problemas:

> **Antes de empezar a trabajar, siempre `pull`. Al terminar, siempre `commit` + `push`.**

En GitHub Desktop: apretá **Fetch origin** antes de arrancar (si hay novedades se convierte en **Pull origin**, apretalo), y **Push origin** cuando terminaste.

Tres recomendaciones más, en orden de importancia:

1. **Repártanse los archivos.** Si cada uno trabaja en un script distinto, no hay forma de chocar. Es la solución más simple y la más efectiva.
2. **Subí seguido.** Un commit por cada cosa terminada, no uno solo con todo el TP la noche anterior a la entrega.
3. **Avisen por el grupo de chat** cuando suben algo importante.

**Si igual chocan:** cuando dos personas modifican la misma línea del mismo archivo, Git no sabe cuál vale y avisa que hay un **conflicto**. GitHub Desktop te muestra el archivo con las dos versiones marcadas; hay que abrirlo, dejar la que corresponde, borrar la otra junto con las líneas de marcas (`<<<<<<<`, `=======`, `>>>>>>>`) y hacer un commit. Si les pasa y no se dan maña, **no lo fuercen ni borren la carpeta**: consulten en clase.

---

# Parte 6 — Autenticación: el token de GitHub

**Si usás GitHub Desktop, saltea esta parte.** Ya quedó resuelto cuando iniciaste sesión en el paso 3.2. Volvé acá solo si te aparece un pedido de contraseña.

## 6.1 Por qué hace falta

La primera vez que intentás subir algo con comandos, GitHub te pide usuario y contraseña. Ponés tu contraseña de siempre y te contesta algo así:

```
remote: Support for password authentication was removed.
fatal: Authentication failed
```

No es un error tuyo: **GitHub dejó de aceptar la contraseña común para estas operaciones**. En su lugar hay que usar un **token**: una clave larga, generada por GitHub, que funciona como contraseña de un solo uso técnico. Es más seguro porque se puede anular sin cambiar tu contraseña.

## 6.2 Generar el token

**Paso 1.** En GitHub, hacé clic en tu foto de perfil (arriba a la derecha) → **Settings**.

**Paso 2.** Bajá hasta el final de la columna izquierda: **Developer settings**.

**Paso 3.** **Personal access tokens** → **Tokens (classic)** → botón **Generate new token** → **Generate new token (classic)**.

**Paso 4.** Completá:

- **Note**: para qué es. Por ejemplo `Notebook facultad`.
- **Expiration**: cuánto dura. Elegí una fecha después del fin del cuatrimestre (por ejemplo 90 días).
- **Select scopes**: tildá la casilla **repo**. Con eso alcanza para todo lo de esta materia.

**Paso 5.** Botón **Generate token** al final de la página.

**Paso 6 — ¡Copiá el token ahora!** Aparece una vez sola, en verde, y empieza con `ghp_`. Si cerrás la página sin copiarlo, no hay forma de recuperarlo: hay que generar uno nuevo. Copialo y pegalo en un lugar seguro (un gestor de contraseñas, o al menos una nota tuya que no compartas).

> **Tratalo como una contraseña.** No lo pegues en un chat, en un mail, ni adentro de un archivo que vayas a subir a GitHub.

## 6.3 Usarlo

La próxima vez que hagas `git push` y te pida credenciales:

- **Username**: tu nombre de usuario de GitHub.
- **Password**: **pegá el token**, no tu contraseña.

Ojo con dos cosas: al pegar la contraseña **la terminal no muestra nada**, ni asteriscos. Está bien: pegá y dale Enter igual. Y en **Windows** puede abrirse una ventanita de *Git Credential Manager* que te ofrece iniciar sesión con el navegador; si aparece, es más simple usar esa opción y ni siquiera hace falta el token.

Una vez que lo aceptó, el sistema lo guarda y no te lo vuelve a pedir en esa computadora.

---

# Parte 7 — Git Bash y los comandos

Esta parte es **opcional**. Todo lo del curso se puede hacer con GitHub Desktop. Pero conviene leerla, por dos razones: cuando algo se rompe, la solución que vas a encontrar en internet casi siempre viene escrita como comando; y en el trabajo real se usan comandos.

## 7.1 Qué es Git Bash y por qué existe

Cuando instalaste Git en Windows, se instaló también un programa llamado **Git Bash**. Es una ventana negra donde se escriben comandos, parecida a PowerShell pero no igual.

La diferencia: Git Bash entiende los comandos de **Linux y Mac** (`ls`, `pwd`, `rm`), mientras que PowerShell usa los de Windows. Como casi todos los tutoriales de Git del mundo están escritos para Linux/Mac, **usar Git Bash te permite copiar y pegar esos tutoriales sin traducir nada**. Esa es toda la ventaja.

**En Mac no existe Git Bash ni hace falta:** la Terminal de Mac ya funciona igual. Donde esta guía diga "Git Bash", en Mac leé "Terminal".

**Cómo abrirlo en Windows:** botón de Inicio → escribí `Git Bash` → Enter. También podés hacer clic derecho dentro de una carpeta en el Explorador y elegir **Open Git Bash here** (te abre la ventana ya parada en esa carpeta, que es lo más cómodo).

| | PowerShell (Windows) | Git Bash (Windows) | Terminal (Mac) |
|---|---|---|---|
| Listar archivos | `dir` | `ls` | `ls` |
| Dónde estoy parado | `pwd` | `pwd` | `pwd` |
| Entrar a una carpeta | `cd carpeta` | `cd carpeta` | `cd carpeta` |
| Subir un nivel | `cd ..` | `cd ..` | `cd ..` |
| Rutas | `C:\Users\Ana` | `/c/Users/Ana` | `/Users/ana` |
| Comandos de Git | Iguales | Iguales | Iguales |

**Los comandos de `git` son idénticos en las tres.** Lo único que cambia es cómo se escriben las rutas y cómo se listan archivos.

## 7.2 Lo mínimo para moverte en una terminal

Antes de cualquier comando de Git, tenés que estar **parado en la carpeta del repositorio**. Es como abrir la carpeta correcta antes de abrir un archivo.

```bash
pwd            # ¿dónde estoy?
ls             # ¿qué hay acá? (en PowerShell: dir)
cd repo_catedra    # entro a la carpeta repo_catedra
cd ..          # salgo un nivel
```

Tres cosas que ahorran mucho tiempo:

- **Tecla Tab**: escribí las primeras letras de una carpeta y apretá `Tab`; el nombre se completa solo. Evita errores de tipeo.
- **Flecha para arriba**: repite el comando anterior.
- **Rutas con espacios van entre comillas**: `cd "Ciencia de Datos"`.

## 7.3 Configuración inicial (una sola vez)

Git necesita saber tu nombre para firmar los commits. Si ya usaste GitHub Desktop, esto ya está hecho. Si no:

```bash
git config --global user.name "Tu Nombre"
git config --global user.email "tu@mail.com"
```

Usá el **mismo mail que en tu cuenta de GitHub**, así los commits quedan asociados a tu perfil.

Para chequear cómo quedó:

```bash
git config --global --list
```

## 7.4 Los comandos del día a día

Estos seis cubren todo el cuatrimestre:

```bash
git status                    # ¿qué cambió? Es el comando que más vas a usar.
git add nombre_archivo.R      # marco un archivo para el próximo commit
git add .                     # marco todo lo que cambió
git commit -m "mensaje"       # guardo el punto en el historial
git push                      # subo mis commits a GitHub
git pull                      # bajo lo que subieron los demás
```

**El ciclo completo, escrito:**

```bash
cd "C:\Users\TU_USUARIO\Desktop\UBA\Ciencia de Datos\tp-cdd-grupo3"
git pull                      # 1. traigo lo último
                              # 2. trabajo en RStudio, guardo los archivos
git status                    # 3. reviso qué cambió
git add .                     # 4. marco los cambios
git commit -m "Agrego limpieza de la base de precios"
git push                      # 5. subo
```

> **`add` y `commit` son dos pasos por algo.** `add` elige *qué* entra en la foto; `commit` saca la foto. Sirve para subir solo una parte de lo que cambiaste. Al principio, `git add .` y listo.

## 7.5 Comandos para mirar, sin modificar nada

Estos son seguros: solo muestran información.

```bash
git status          # estado actual
git log             # historial completo de commits
git log --oneline   # el mismo historial, una línea por commit
git diff            # qué cambió exactamente desde el último commit
git remote -v       # a qué repositorio de GitHub está conectada esta carpeta
git branch          # en qué línea de trabajo estoy (debería decir main)
```

> **Si `git log` te deja en una pantalla de la que no podés salir** (aparece un `:` abajo), apretá la tecla **`q`**. Es el visor de texto, no un error.

## 7.6 Equivalencias: botón ↔ comando

| Quiero... | En GitHub Desktop | Comando |
|---|---|---|
| Bajar un repo por primera vez | File → Clone repository | `git clone URL` |
| Ver qué cambié | Aparece solo en la columna izquierda | `git status` |
| Guardar un punto del historial | Escribir Summary → **Commit to main** | `git add .` + `git commit -m "..."` |
| Subir mis cambios | **Push origin** | `git push` |
| Traer los cambios de otros | **Fetch origin** → **Pull origin** | `git pull` |
| Ver el historial | Solapa **History** | `git log --oneline` |
| Ver a qué repo está conectado | Repository → Repository settings | `git remote -v` |
| Ver la versión de Git | — | `git --version` |

---

# Parte 8 — Errores comunes

| Lo que dice la pantalla | Qué pasó | Cómo se arregla |
|---|---|---|
| `git: command not found` o "no se reconoce el término git" | Git no está instalado, o abriste la terminal antes de instalarlo | Instalalo (3.1) y **cerrá y volvé a abrir** la terminal |
| `fatal: not a git repository` | Estás parado en una carpeta cualquiera, no en un repositorio | `cd` hasta la carpeta del repo. Verificá con `ls` que ahí estén los archivos del proyecto |
| `fatal: destination path 'repo_catedra' already exists` | Ya clonaste antes y la carpeta existe | No hace falta clonar de nuevo: entrá con `cd repo_catedra` y hacé `git pull` |
| `Support for password authentication was removed` | Pusiste tu contraseña en vez del token | Generá un token (Parte 6) y usalo como contraseña |
| `Updates were rejected because the remote contains work that you do not have` | Un compañero subió algo después de tu último pull | `git pull` primero, después `git push` |
| `CONFLICT (content): Merge conflict in archivo.R` | Dos personas cambiaron la misma línea | Abrí el archivo, dejá la versión correcta, borrá las marcas `<<<<<<<`, `=======`, `>>>>>>>`, y hacé commit (5.6) |
| `Please tell me who you are` | Falta configurar nombre y mail | Los dos comandos de 7.3 |
| `Permission denied` / `403` al hacer push | No sos colaborador de ese repositorio | Que el dueño te invite (5.4) y aceptá la invitación por mail |
| Una ruta rara tipo `C:UsersUsuarioDesktop` (sin barras) | Copiaste una ruta de Windows en Git Bash, que usa otro formato | Usá PowerShell para esa ruta, o escribila como `/c/Users/Usuario/Desktop` |
| `Already up to date.` | **No es un error.** No hay nada nuevo para bajar | Nada |
| Se abre un editor raro de pantalla completa al hacer commit | Hiciste `git commit` sin el `-m "mensaje"` | Apretá `Esc`, después escribí `:q!` y Enter. Volvé a hacer el commit con `-m "mensaje"` |

**Regla general:** cuando algo no funciona, lo primero es `git status`. Casi siempre te dice qué pasa y qué hacer.

---

# Parte 9 — Glosario y resumen

## 9.1 Glosario

| Término | Significado |
|---|---|
| **Repositorio (repo)** | Carpeta con historial de Git |
| **Local** | En tu computadora |
| **Remoto** | En GitHub |
| **origin** | El apodo que Git le pone a la dirección de tu repositorio en GitHub |
| **main** | La línea principal de trabajo. Es donde va todo en esta materia |
| **Commit** | Un punto guardado del historial |
| **Clone** | Bajar un repo por primera vez |
| **Push** | Subir tus commits a GitHub |
| **Pull** | Bajar a tu computadora los commits de los demás |
| **Fetch** | Preguntarle a GitHub si hay novedades, sin bajarlas todavía |
| **Fork** | Copiar el repo de otra persona a tu cuenta de GitHub |
| **Colaborador** | Persona con permiso para subir cambios a un repositorio |
| **Conflicto** | Dos personas cambiaron la misma línea y Git no sabe cuál vale |
| **Token (PAT)** | Clave larga que reemplaza a la contraseña al usar comandos |
| **.gitignore** | Archivo que lista lo que Git tiene que ignorar y no subir |
| **README** | Archivo de presentación del repositorio |

## 9.2 Resumen de una carilla

**Una sola vez en la vida**

1. Crear cuenta en [github.com](https://github.com).
2. Instalar **Git** desde [git-scm.com](https://git-scm.com/downloads).
3. Instalar **GitHub Desktop** desde [desktop.github.com](https://desktop.github.com) e iniciar sesión.

**Una sola vez por proyecto**

| | Repo del curso | Repo del TP |
|---|---|---|
| Cómo empieza | Ya existe, lo clonás | Lo crea uno del grupo en github.com: **Public** + README en On + .gitignore de R |
| Cómo lo bajás | File → Clone repository → pegar la URL | File → Clone repository → solapa GitHub.com |
| ¿Podés subir? | **No.** Solo bajar | Sí, si sos colaborador |
| Cuidado | No modifiques archivos adentro | Definan quién crea el repo, para no tener tres |

URL del curso: `https://github.com/nsidicarocep/curso_cdd_fce_uba_2c2026`

**Todas las semanas — repo del curso**

- GitHub Desktop → **Fetch origin** → si aparece **Pull origin**, apretalo.
- O bien: `cd` a la carpeta + `git pull`.

**Todos los días — repo del TP**

1. **Antes de trabajar:** Fetch/Pull origin *(o `git pull`)*
2. Trabajar en RStudio y guardar los archivos
3. **Al terminar:** escribir el Summary → **Commit to main** *(o `git add .` + `git commit -m "..."`)*
4. **Push origin** *(o `git push`)*

**Si algo falla:** `git status`, y después la Parte 8.

---

*Guía preparada para la cátedra de Ciencia de Datos para Economía y Negocios, FCE-UBA, segundo cuatrimestre 2026.*
