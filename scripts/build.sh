#!/bin/bash

# Build script for Exhibition Platform
# Usage: ./scripts/build.sh [environment] [platform]
# Example: ./scripts/build.sh production android

set -e

ENVIRONMENT=${1:-development}
PLATFORM=${2:-apk}

echo "Building Exhibition Platform"
echo "Environment: $ENVIRONMENT"
echo "Platform: $PLATFORM"

# Select entry point based on environment
case $ENVIRONMENT in
  development|dev)
    ENTRY_POINT="lib/main.dart"
    FLAVOR="dev"
    ;;
  staging)
    ENTRY_POINT="lib/main_staging.dart"
    FLAVOR="staging"
    ;;
  production|prod)
    ENTRY_POINT="lib/main_production.dart"
    FLAVOR="prod"
    ;;
  *)
    echo "Unknown environment: $ENVIRONMENT"
    echo "Use: development, staging, or production"
    exit 1
    ;;
esac

# Clean previous builds
flutter clean
flutter pub get

# Generate code
flutter pub run build_runner build --delete-conflicting-outputs

# Build based on platform
case $PLATFORM in
  apk)
    echo "Building Android APK..."
    flutter build apk --release -t $ENTRY_POINT --dart-define=FLAVOR=$FLAVOR
    echo "APK built at: build/app/outputs/flutter-apk/app-release.apk"
    ;;
  appbundle|aab)
    echo "Building Android App Bundle..."
    flutter build appbundle --release -t $ENTRY_POINT --dart-define=FLAVOR=$FLAVOR
    echo "AAB built at: build/app/outputs/bundle/release/app-release.aab"
    ;;
  ios)
    echo "Building iOS..."
    flutter build ios --release -t $ENTRY_POINT --dart-define=FLAVOR=$FLAVOR
    echo "iOS build complete"
    ;;
  ipa)
    echo "Building iOS IPA..."
    flutter build ipa --release -t $ENTRY_POINT --dart-define=FLAVOR=$FLAVOR
    echo "IPA built at: build/ios/ipa/"
    ;;
  web)
    echo "Building Web..."
    flutter build web --release -t $ENTRY_POINT --dart-define=FLAVOR=$FLAVOR
    echo "Web build at: build/web/"
    ;;
  *)
    echo "Unknown platform: $PLATFORM"
    echo "Use: apk, appbundle, ios, ipa, or web"
    exit 1
    ;;
esac

echo "Build complete!"
