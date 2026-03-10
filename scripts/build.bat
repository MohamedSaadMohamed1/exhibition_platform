@echo off
REM Build script for Exhibition Platform (Windows)
REM Usage: scripts\build.bat [environment] [platform]
REM Example: scripts\build.bat production apk

setlocal

set ENVIRONMENT=%1
set PLATFORM=%2

if "%ENVIRONMENT%"=="" set ENVIRONMENT=development
if "%PLATFORM%"=="" set PLATFORM=apk

echo Building Exhibition Platform
echo Environment: %ENVIRONMENT%
echo Platform: %PLATFORM%

REM Select entry point based on environment
if "%ENVIRONMENT%"=="development" (
    set ENTRY_POINT=lib/main.dart
    set FLAVOR=dev
) else if "%ENVIRONMENT%"=="dev" (
    set ENTRY_POINT=lib/main.dart
    set FLAVOR=dev
) else if "%ENVIRONMENT%"=="staging" (
    set ENTRY_POINT=lib/main_staging.dart
    set FLAVOR=staging
) else if "%ENVIRONMENT%"=="production" (
    set ENTRY_POINT=lib/main_production.dart
    set FLAVOR=prod
) else if "%ENVIRONMENT%"=="prod" (
    set ENTRY_POINT=lib/main_production.dart
    set FLAVOR=prod
) else (
    echo Unknown environment: %ENVIRONMENT%
    echo Use: development, staging, or production
    exit /b 1
)

REM Clean previous builds
call flutter clean
call flutter pub get

REM Generate code
call flutter pub run build_runner build --delete-conflicting-outputs

REM Build based on platform
if "%PLATFORM%"=="apk" (
    echo Building Android APK...
    call flutter build apk --release -t %ENTRY_POINT% --dart-define=FLAVOR=%FLAVOR%
    echo APK built at: build\app\outputs\flutter-apk\app-release.apk
) else if "%PLATFORM%"=="appbundle" (
    echo Building Android App Bundle...
    call flutter build appbundle --release -t %ENTRY_POINT% --dart-define=FLAVOR=%FLAVOR%
    echo AAB built at: build\app\outputs\bundle\release\app-release.aab
) else if "%PLATFORM%"=="aab" (
    echo Building Android App Bundle...
    call flutter build appbundle --release -t %ENTRY_POINT% --dart-define=FLAVOR=%FLAVOR%
    echo AAB built at: build\app\outputs\bundle\release\app-release.aab
) else if "%PLATFORM%"=="web" (
    echo Building Web...
    call flutter build web --release -t %ENTRY_POINT% --dart-define=FLAVOR=%FLAVOR%
    echo Web build at: build\web\
) else (
    echo Unknown platform: %PLATFORM%
    echo Use: apk, appbundle, or web
    exit /b 1
)

echo Build complete!
endlocal
