#!/bin/bash

# Exit on error
set -e

echo "--- Installing Flutter ---"
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:`pwd`/flutter/bin"

echo "--- Flutter Version ---"
flutter --version

echo "--- Building for Web ---"
flutter config --enable-web
flutter pub get
flutter build web --release

echo "--- Cleaning up Flutter SDK (to stay under Vercel 500MB limit) ---"
# Remove the entire flutter directory and pub cache to save space
rm -rf flutter
rm -rf .dart_tool
rm -rf /vercel/.pub-cache

echo "--- Build Complete ---"
