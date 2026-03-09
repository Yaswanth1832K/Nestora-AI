#!/bin/bash

# Exit on error
set -e

echo "--- Installing Flutter ---"
# Clone outside the current project to prevent Python builder from seeing it
git clone https://github.com/flutter/flutter.git /tmp/flutter -b stable --depth 1
export PATH="$PATH:/tmp/flutter/bin"

echo "--- Flutter Version ---"
flutter --version

echo "--- Building for Web ---"
flutter config --enable-web
flutter pub get
flutter build web --release

echo "--- Cleaning up .dart_tool (to save final bundle space) ---"
rm -rf .dart_tool
rm -rf /vercel/.pub-cache

echo "--- Build Complete ---"
