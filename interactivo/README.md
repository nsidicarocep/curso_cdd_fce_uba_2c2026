# Prácticas interactivas

Materiales de práctica para la cursada. Cada página es un ejercicio interactivo que corre entero en el navegador: no hay que instalar nada, no hay que registrarse y no queda ningún dato en un servidor. Se abren desde la compu o desde el celular.

La idea es simple. En clase vemos un concepto, y después hace falta usarlo unas cuantas veces para que se asiente. Estas páginas son ese lugar intermedio entre leer los apuntes y sentarse a escribir código: se practica el razonamiento —el orden de las operaciones, qué valor tiene cada variable, dónde está el error— sin pelearse todavía con la sintaxis ni con los mensajes de error del intérprete.

Cada ejercicio corrige al instante y explica por qué. La corrección no es un simple bien o mal: te dice hasta dónde ibas bien y qué revisar. Podés repetirlos las veces que quieras, y conviene hacerlo: la práctica espaciada rinde mucho más que resolverlos todos de una sentada la noche anterior al parcial.

**No se entregan ni se corrigen.** El progreso se guarda solamente en tu navegador, así que si cambiás de dispositivo o borrás los datos de navegación, arrancás de cero.

## Páginas disponibles

| Tema | Qué se practica | Link |
|---|---|---|
| Pensamiento computacional | Ordenar algoritmos, trazar el estado de las variables y encontrar errores de lógica en pseudocódigo | [Cuaderno de algoritmos](./pensamiento_computacional/) |

<!--
A medida que avance la cursada, agregá una fila por página nueva.
Formato: | Tema | Qué se practica | [Nombre](./carpeta/) |
Ideas para las próximas: manipulación de datos (verbos de dplyr sobre una
tabla chica), lectura de gráficos, interpretación de coeficientes de MCO,
supuestos del modelo lineal, inferencia y valores p.
-->

## Cómo se usan

Entrá al link del tema que estés cursando y resolvé los ejercicios en el orden en que aparecen: están pensados como una progresión, cada uno se apoya en el anterior. Si te trabás, cada ejercicio tiene una pista antes de la respuesta. Usala recién después de haber intentado en serio; leerla de entrada arruina el ejercicio.

Si encontrás un error en alguna consigna o en alguna respuesta esperada, avisame por el canal de la materia o abrí un issue en este repositorio.

## Sobre este repositorio

Sitio estático publicado con GitHub Pages. Cada tema vive en su propia carpeta con un `index.html` autocontenido, sin dependencias ni proceso de build.

```
.
├── README.md                      ← esta portada
└── pensamiento-computacional/
    └── index.html
```

Los ejercicios de cada página están definidos en un array al final del archivo, separados de la lógica de la interfaz, así que se pueden editar o ampliar sin tocar el código.
