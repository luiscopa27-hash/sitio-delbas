#!/usr/bin/env bash
# Copia la app web (index.html, librerías e ícono) dentro del proyecto iOS.
set -euo pipefail
cd "$(dirname "$0")"
rm -rf www && mkdir -p www
cp ../index.html ../icon.svg ../manifest.webmanifest www/
cp -r ../vendor www/
echo "App web copiada en ios/www"
