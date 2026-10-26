# Malla de Tronadura

Aplicación web para trabajar sobre planos PDF de mallas de perforación y tronadura a cielo abierto. Funciona **con y sin internet** (en terreno).

## Qué hace

- **Lee el plano PDF** y detecta cada pozo. Reconoce dos formatos:
  - **Malla de perforación** (p. ej. Vulcan): ID entero con la **profundidad de diseño** debajo (ej. `1008` / `12.0`).
  - **Plano de secuencia** (pozo dibujado como círculo): ID encima del círculo (también alfanumérico, ej. `D041`) y **tiempo de diseño en ms** al lado (ej. `7054`). Los pozos sin círculo legible se ubican por su ID.
- **Detonadores por pozo**, diferenciados por color y símbolo:
  - Simple: círculo azul, 1 detonador
  - Doble: círculo doble naranjo, 2 detonadores
  - Triple: triángulo rojo, 3 detonadores
  - Editables (color, símbolo, cantidad) y se pueden agregar tipos nuevos.
- **Por cada detonador**: etiqueta (código alfanumérico, se guarda en mayúsculas) y retardo en ms.
- **Ficha del pozo**: tiempo de diseño (ms, con botón para usarlo como retardo), profundidad de diseño y real (con diferencia), estado (normal / tapado / repasado), agua (sí/no y altura), taco, largo de columna de carga calculado, tipo de explosivo, carga en kg, malla/disparo y observaciones.
- **Strings de secuencia**: una línea de color une los pozos en el orden en que se etiquetan, con flechas de sentido y N° de secuencia junto a cada pozo.
  - Modo **String** en el plano: cada toque agrega el pozo al final del string activo; tocar el último lo quita.
  - **Tramo automático**: tocar el pozo 1 y luego el 10 agrega en orden los pozos que quedan entre ambos (en línea recta, o por ID correlativo según la opción elegida). Mayús/Ctrl + toque agrega solo ese pozo. **Deshacer** (o `Retroceso`) quita el último tramo.
  - Al volver al modo String después de usar otro comando, pregunta si **continuar** el mismo string o **iniciar otro**; el nuevo toma un color distinto.
  - Opcional: al cargar la etiqueta de un pozo, se agrega solo al string activo.
  - Cada string tiene nombre, color y **N° de inicio** definido por el programador (ej. S2 parte en 401); botón *Numeración continua*.
  - Sin límite fijo de strings; máximo de pozos por string configurable (400 por defecto) con aviso al superarlo. Probado con 10 strings de 400 pozos (4.000 pozos).
  - Quitar último, invertir sentido, vaciar y eliminar.
- **Vista configurable**: elegir qué mostrar junto a cada pozo (N° de secuencia, etiqueta, retardo, profundidad real, taco, carga, explosivo, marcas, líneas de string) y qué columnas lleva el informe PDF/TXT, ordenado por ID o por secuencia.
- **Selección por área** para asignar a varios pozos el tipo, estado, malla, taco, explosivo o carga.
- **Alertas**: etiquetas repetidas e IDs repetidos dentro de la misma malla; filtro de pozos con datos pendientes.
- **Resumen**: pozos por tipo, detonadores, metros de diseño y reales, kg de explosivo total y por tipo, pozos con agua, tapados y repasados.

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

## Uso con y sin conexión

- **Publicada en un servidor (https)**, por ejemplo GitHub Pages: al abrirla una vez con señal queda guardada en el equipo y luego abre sin internet. En el celular se puede **instalar** desde el menú del navegador ("Agregar a pantalla de inicio").
- **Como carpeta local**: copiar la carpeta `malla-tronadura` completa (incluida `vendor/`) y abrir `index.html`. Las librerías van incluidas, por lo que no necesita internet.
- Los datos se guardan automáticamente en el navegador del equipo, por archivo PDF; el último plano se reabre solo. Para respaldar o pasar a otro equipo usar *Respaldo JSON*.

Atajos: `1`/`2`/`3` asignan Simple/Doble/Triple, `0` deja sin tipo, `→`/`←` pozo siguiente/anterior, `Enter` avanza de etiqueta a retardo y de *Prof. real* al siguiente pozo, `Esc` limpia la selección, `V`/`A`/`S`/`N` cambian de modo (Seleccionar, Área, String, Agregar pozo).

## Notas

- La detección supone el formato del plano de referencia: ID entero sobre la profundidad decimal. Si el plano es una imagen escaneada (sin texto), los pozos se agregan a mano.
- Un mismo PDF puede contener dos mallas con IDs repetidos (ej. F082400_02 y F082400_03); completar *Malla / disparo* para diferenciarlas.
- Librerías incluidas en `vendor/`: pdf.js 3.11.174 (Apache-2.0) y pdf-lib 1.17.1 (MIT).
