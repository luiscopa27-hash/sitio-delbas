# Instalar blaster.lcv

## Android (teléfono o tablet) — archivo `blaster-lcv-1.1.apk`

1. Copia `blaster-lcv-1.1.apk` al equipo (descarga, WhatsApp, correo, cable USB o Drive).
2. Ábrelo desde *Archivos* o *Descargas*.
3. La primera vez Android pide permitir **«Instalar apps desconocidas»** para la app desde la que lo abriste (Chrome, Archivos, WhatsApp…). Actívalo y vuelve atrás.
4. Toca **Instalar**. Si aparece Play Protect, elige *Instalar de todos modos* (la app no está publicada en Play Store).
5. Abre **blaster.lcv** desde el menú de aplicaciones.

Requisitos: Android 5.0 o superior. Funciona sin internet; con internet solo carga las fuentes tipográficas.

En la app:
- *Archivo → Abrir plano PDF* abre el selector de archivos de Android.
- Las exportaciones (PDF, CSV, TXT, JSON) abren el diálogo **Guardar como** de Android para elegir carpeta.
- *Imprimir* abre el servicio de impresión de Android (impresora Wi-Fi o «Guardar como PDF»).

**Actualizaciones:** cada versión nueva se instala encima de la anterior y conserva los datos, siempre que esté firmada con la misma llave (`blaster-lcv-release.jks`). Si se pierde la llave, para instalar una versión nueva hay que desinstalar la anterior y se pierden los datos guardados en el equipo (respaldar antes con *Archivo → Respaldo JSON*).

## iPhone / iPad

Apple no permite instalar archivos de app (.ipa) sin pasar por sus herramientas. Hay dos caminos:

### A. Como app web instalada (sin Mac ni cuenta de Apple)
1. Publicar la carpeta `blaster-lcv` en un sitio **https** (por ejemplo GitHub Pages).
2. En el iPhone o iPad abrir esa dirección en **Safari** → botón Compartir → **Agregar a pantalla de inicio**.
3. Queda con su ícono, abre a pantalla completa y funciona sin internet después de la primera carga.

### B. Como app nativa (requiere una Mac con Xcode)
El proyecto está en `blaster-lcv/ios`:
```
cd blaster-lcv/ios
brew install xcodegen      # una sola vez
./prepare.sh               # copia la app web dentro del proyecto
xcodegen                   # genera BlasterLCV.xcodeproj
open BlasterLCV.xcodeproj
```
En Xcode: *Signing & Capabilities* → elegir el equipo (Team) → conectar el iPhone/iPad → **Run**.
- Con Apple ID gratuito: la app funciona 7 días y hay que reinstalarla.
- Con cuenta Apple Developer (USD 99/año): distribución por **TestFlight** o *Ad Hoc* a los equipos de la faena.
