#!/usr/bin/env bash
set -e

echo "=== Starting Flutter Web Build ==="

# Clone Flutter SDK if not present in build environment
if [ ! -d "flutter" ]; then
  echo "Cloning Flutter stable SDK..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi

# Add Flutter to PATH
export PATH="$PWD/flutter/bin:$PATH"

# Configure Flutter for web
flutter config --no-analytics
flutter precache --web

echo "Running flutter pub get..."
flutter pub get

echo "Building Flutter Web release..."
flutter build web --release --dart-define=API_BASE_URL=https://calotex-mes-plus.onrender.com/api

echo "=== Flutter Web Build Complete ==="
