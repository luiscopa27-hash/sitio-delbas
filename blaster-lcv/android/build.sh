#!/usr/bin/env bash
# Compila el APK de blaster.lcv con las herramientas de Android de Ubuntu
# (apt install aapt apksigner android-sdk-platform-23 dalvik-exchange zipalign).
#
# Uso:  KEYSTORE=/ruta/blaster.jks KS_PASS=clave ./build.sh
# Resultado: build/blaster-lcv.apk (firmado)
set -euo pipefail
cd "$(dirname "$0")"
SDK=/usr/lib/android-sdk
JAR=$SDK/platforms/android-23/android.jar
BT=$(ls -d $SDK/build-tools/* | sort -V | tail -1)
: "${KEYSTORE:?Indica KEYSTORE=/ruta/al/keystore.jks}"
: "${KS_PASS:?Indica KS_PASS=clave del keystore}"

rm -rf build && mkdir -p build/assets/www build/classes build/res
# 1. App web dentro del APK (sin el propio proyecto android)
WEB=..
cp "$WEB/index.html" "$WEB/icon.svg" "$WEB/manifest.webmanifest" build/assets/www/
cp -r "$WEB/vendor" build/assets/www/
# 2. Recursos y manifiesto
aapt2 compile --dir res -o build/res/res.zip
aapt2 link -o build/base.apk -I "$JAR" --manifest AndroidManifest.xml -A build/assets \
  --min-sdk-version 21 --target-sdk-version 34 build/res/res.zip
# 3. Código Java → dex
javac -nowarn -Xlint:-options -source 8 -target 8 -bootclasspath "$JAR" -encoding UTF-8 -d build/classes $(find src -name '*.java')
"$BT/dx" --dex --min-sdk-version=21 --output=build/classes.dex build/classes
(cd build && cp base.apk unsigned.apk && zip -q -j unsigned.apk classes.dex)
# 4. Alinear y firmar
zipalign -f -p 4 build/unsigned.apk build/aligned.apk
apksigner sign --ks "$KEYSTORE" --ks-pass "pass:$KS_PASS" --out build/blaster-lcv.apk build/aligned.apk
apksigner verify --print-certs build/blaster-lcv.apk | head -3
echo "APK listo: $(pwd)/build/blaster-lcv.apk"
