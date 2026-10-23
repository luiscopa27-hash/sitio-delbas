# Malla de Tronadura

Aplicación web (un solo archivo `index.html`, sin instalación) para trabajar sobre planos PDF de mallas de perforación y tronadura a cielo abierto.

## Qué hace

- **Lee el plano PDF** (p. ej. exportado desde Vulcan) y detecta cada pozo a partir del texto: el **ID** (ej. `1008`) y la **profundidad de diseño** escrita justo debajo (ej. `12.0`). Las coordenadas de la grilla (8300, 25700) se descartan.
- **Ficha por pozo**: tipo de etiquetado, N° de etiqueta(s), profundidad de diseño, profundidad real medida (con diferencia), malla/disparo y observaciones.
- **Tipos de etiquetado** diferenciados por color y símbolo:
  - Simple: círculo azul, 1 etiqueta
  - Doble: círculo doble naranjo, 2 etiquetas
  - Triple: triángulo rojo, 3 etiquetas
  - Se pueden editar (color, símbolo, cantidad de etiquetas) y agregar tipos nuevos.
- **Selección por área** (botón *Área* o Mayús + arrastrar) para asignar tipo o malla a varios pozos a la vez.
- **Agregar pozo** a mano cuando no se detecta en el plano; eliminar pozos.
- **Alertas**: N° de etiqueta repetido e ID de pozo repetido dentro de la misma malla.
- **Resumen**: pozos por tipo, detonadores totales, metros de diseño y reales, etiquetas pendientes.
- **Exportar**: PDF anotado (plano original + simbología + etiquetas + cuadro resumen), planilla CSV para Excel (separador `;`, coma decimal) y respaldo JSON.
- El trabajo se **guarda automáticamente** en el navegador (por archivo PDF) y el último plano se reabre solo.

## Uso

Abrir `index.html` en Chrome, Edge o Firefox (requiere internet para cargar pdf.js y pdf-lib desde cdnjs).

Atajos: `1`/`2`/`3` asignan Simple/Doble/Triple al pozo seleccionado, `0` lo deja sin tipo, `→`/`←` pasan al pozo siguiente/anterior, `Enter` en *Prof. real* avanza al siguiente pozo, `Esc` limpia la selección, `V`/`A`/`N` cambian de modo.

## Notas

- La detección supone el formato del plano de referencia: ID entero sobre la profundidad decimal. Si un plano es una imagen escaneada (sin texto), los pozos deben agregarse a mano.
- Un mismo PDF puede contener dos mallas con IDs repetidos (ej. F082400_02 y F082400_03); asignar el campo *Malla / disparo* para diferenciarlos.
