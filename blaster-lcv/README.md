# blaster.lcv

Aplicación para mallas de tronadura a cielo abierto.

Aplicación web para trabajar sobre planos PDF de mallas de perforación y tronadura a cielo abierto. Funciona **con y sin internet** (en terreno).

## Qué hace

- **Lee el plano PDF** y detecta cada pozo. Reconoce dos formatos, incluso mezclados en el mismo plano (si un pozo trae ambos datos se guardan los dos):
  - **Malla de perforación** (p. ej. Vulcan): ID entero con la **profundidad de diseño** debajo (ej. `1008` / `12.0`).
  - **Plano de secuencia** (pozo dibujado como círculo): ID encima del círculo (también alfanumérico, ej. `D041`) y **tiempo de diseño en ms** al lado (ej. `7054`). Los pozos sin círculo legible se ubican por su ID.
- **Detonadores por pozo**, diferenciados por color y símbolo:
  - Simple: círculo azul, 1 detonador
  - Doble: círculo doble naranjo, 2 detonadores
  - Triple: triángulo rojo, 3 detonadores
  - Editables (color, símbolo, cantidad) y se pueden agregar tipos nuevos.
- **Por cada detonador**: etiqueta (código alfanumérico, se guarda en mayúsculas) y retardo en ms.
- **Ficha del pozo**: tiempo de diseño (ms, con botón para usarlo como retardo), profundidad de diseño y real (con diferencia), estado (normal / tapado / repasado), agua (sí/no y altura), taco, largo de columna de carga calculado, tipo de explosivo, carga en kg, malla/disparo y observaciones.
- **Lazo**: comando de la barra para dibujar una forma libre alrededor de los pozos y seleccionarlos (también marca reparto y saca pozos de strings con *Quitar*).
- **Pozo reprimado**: casilla en la ficha, con detonadores agregados (1 por defecto) y comentario que sale en el informe (sección *Pozos reprimados - comentarios*). Marca «R» morada en el plano y filtro en el listado.
- **Detonadores usados**: total por tipo (Simple ×1, Doble ×2, Triple ×3) más los agregados por reprimado, en el resumen, la ficha del pozo, la barra inferior, los informes y el CSV.
- **Reparto de detonadores a piso** (comando *Reparto* de la barra o pestaña *Reparto*; al repartir se puede asignar primado Simple, Doble o Triple): mientras está abierta, el plano cambia a la vista de reparto y muestra los pozos donde ya se dejó el detonador, pintados con el color del programador que lo dejó (los pendientes en gris).
  - Paleta de programadores: nombre y color de cada uno; se elige el activo en la barra de reparto sobre el plano.
  - Un toque marca el pozo (otro toque lo desmarca); con *Área* se marcan varios. *Deshacer* revierte la última marca.
  - Resumen de pozos y detonadores por programador, y pendientes. Plano de reparto en PDF o impreso; columnas *Detonador depositado* y *Programador* en los CSV e informes.
- **Strings de secuencia**: una línea de color une los pozos en el orden en que se etiquetan, con flechas de sentido y N° de secuencia junto a cada pozo.
  - Modo **String** en el plano: cada toque agrega el pozo al final del string activo; tocar el último lo quita.
  - **Primado simple**: cada pozo que entra a un string queda asignado como *Simple* si aún no tiene tipo (se puede desactivar; *Deshacer* también revierte el tipo asignado).
  - **Tramo automático**: tocar el pozo 1 y luego el 10 agrega en orden los pozos que quedan entre ambos (en línea recta, o por ID correlativo según la opción elegida). Mayús/Ctrl + toque agrega solo ese pozo. **Deshacer** (o `Retroceso`) quita el último tramo.
  - **Quitar** pozos: en la barra String, *Quitar* + toque saca un pozo de su string y arrastrar un rectángulo saca varios (también Alt + toque, el botón *Quitar del string* de la ficha o *Quitar de los strings* con selección múltiple). Los pozos siguientes se renumeran y *Deshacer* los devuelve a su lugar.
  - Al volver al modo String después de usar otro comando, pregunta si **continuar** el mismo string o **iniciar otro**; el nuevo toma un color distinto.
  - Opcional: al cargar la etiqueta de un pozo, se agrega solo al string activo.
  - Cada string tiene nombre, color y **N° de inicio** definido por el programador (ej. S2 parte en 401); botón *Numeración continua*.
  - Sin límite fijo de strings; máximo de pozos por string configurable (400 por defecto) con aviso al superarlo. Probado con 10 strings de 400 pozos (4.000 pozos).
  - Quitar último, invertir sentido, vaciar y eliminar.
- **Vista configurable**: elegir qué mostrar junto a cada pozo (N° de secuencia, etiqueta, retardo, profundidad real, taco, carga, explosivo, marcas, líneas de string) y qué columnas lleva el informe PDF/TXT, ordenado por ID o por secuencia.
- **Selección por área** para asignar a varios pozos el tipo, estado, malla, taco, explosivo o carga.
- **Alertas**: etiquetas repetidas e IDs repetidos dentro de la misma malla; filtro de pozos con datos pendientes.
- **Resumen**: pozos por tipo, detonadores, metros de diseño y reales, kg de explosivo total y por tipo, pozos con agua, tapados y repasados.

## Interfaz para tablet y teléfono

- El **plano ocupa toda la pantalla** y se ve **nítido con cualquier zoom**: al terminar de mover o ampliar, la zona visible se vuelve a dibujar desde el PDF a la resolución exacta de la pantalla del equipo.
- Los comandos van en una **barra vertical a un costado**, con botones grandes para el dedo.
- La barra se configura con el botón **Barra**: lado (izquierda o derecha), tamaño (normal o grande), mostrar u ocultar nombres y elegir qué comandos aparecen. La configuración queda guardada en cada equipo.
- Abajo hay una **barra desplegable** con el resumen del pozo tocado (o de la malla). Al tocarla se abre el **panel completo** (ficha, listado, strings y vista):
  - En tablet sale al costado y se puede **fijar** (el plano se achica para dejarlo a la vista).
  - En teléfono sale desde abajo; la manija lo agranda a pantalla completa.
  - La posición se puede forzar (automática, lateral o inferior) y se puede elegir si se abre solo al tocar un pozo.
- **Imprimir**: comando propio en la barra. Imprime el informe completo, el plano anotado o la tabla de pozos con el diálogo de impresión del equipo, que también permite **«Guardar como PDF»**. Funciona en computador, tablet y teléfono.

## Exportar e imprimir

| Formato | Contenido |
|---|---|
| Informe PDF completo | Plano anotado + resumen + tabla de pozos (listo para imprimir) |
| Plano anotado PDF | Plano original con simbología, etiquetas, retardos y marcas |
| Informe PDF (tabla) | Resumen y detalle por pozo |
| Informe TXT | El mismo informe en texto plano por columnas |
| CSV por pozo | Una fila por pozo (Excel: separador `;`, coma decimal) |
| CSV de detonadores | Una fila por detonador en orden de string y secuencia: string, N°, pozo, etiqueta y retardo |
| Respaldo JSON | Para mover el trabajo a otro equipo (Importar respaldo) |

## Instalar en Android e iOS

- **Android:** `descargas/blaster-lcv-1.1.apk` (firmado, Android 5.0+). Instrucciones en [`descargas/INSTALAR.md`](descargas/INSTALAR.md). El código del contenedor está en `android/` y se compila con `android/build.sh` (herramientas de Android de Ubuntu; requiere la llave de firma).
- **iOS:** proyecto Xcode en `ios/` (se compila en una Mac), o instalar como app web desde Safari. Ver [`descargas/INSTALAR.md`](descargas/INSTALAR.md).

## Uso con y sin conexión

- **Publicada en un servidor (https)**, por ejemplo GitHub Pages: al abrirla una vez con señal queda guardada en el equipo y luego abre sin internet. En el celular se puede **instalar** desde el menú del navegador ("Agregar a pantalla de inicio").
- **Como carpeta local**: copiar la carpeta `blaster-lcv` completa (incluida `vendor/`) y abrir `index.html`. Las librerías van incluidas, por lo que no necesita internet.
- Los datos se guardan automáticamente en el navegador del equipo, por archivo PDF; el último plano se reabre solo. Para respaldar o pasar a otro equipo usar *Respaldo JSON*.

Atajos: `1`/`2`/`3` asignan Simple/Doble/Triple, `0` deja sin tipo, `→`/`←` pozo siguiente/anterior, `Enter` avanza de etiqueta a retardo y de *Prof. real* al siguiente pozo, `Esc` limpia la selección, `V`/`A`/`S`/`N` cambian de modo (Seleccionar, Área, String, Agregar pozo).

## Notas

- La detección supone el formato del plano de referencia: ID entero sobre la profundidad decimal. Si el plano es una imagen escaneada (sin texto), los pozos se agregan a mano.
- Un mismo PDF puede contener dos mallas con IDs repetidos (ej. F082400_02 y F082400_03); completar *Malla / disparo* para diferenciarlas.
- Librerías incluidas en `vendor/`: pdf.js 3.11.174 (Apache-2.0) y pdf-lib 1.17.1 (MIT).
