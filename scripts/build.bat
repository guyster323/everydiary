@echo off
REM EveryDiary Flutter Build Script for Windows
REM This script handles different build configurations for the EveryDiary app

setlocal enabledelayedexpansion

REM Default values
set ENVIRONMENT=development
set BUILD_TYPE=debug
set PLATFORM=android
set CLEAN=false
set ANALYZE=false
set TEST=false

REM Parse command line arguments
:parse_args
if "%~1"=="" goto :end_parse
if "%~1"=="-e" (
    set ENVIRONMENT=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="--env" (
    set ENVIRONMENT=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="-t" (
    set BUILD_TYPE=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="--type" (
    set BUILD_TYPE=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="-p" (
    set PLATFORM=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="--platform" (
    set PLATFORM=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="-c" (
    set CLEAN=true
    shift
    goto :parse_args
)
if "%~1"=="--clean" (
    set CLEAN=true
    shift
    goto :parse_args
)
if "%~1"=="-a" (
    set ANALYZE=true
    shift
    goto :parse_args
)
if "%~1"=="--analyze" (
    set ANALYZE=true
    shift
    goto :parse_args
)
if "%~1"=="-s" (
    set TEST=true
    shift
    goto :parse_args
)
if "%~1"=="--test" (
    set TEST=true
    shift
    goto :parse_args
)
if "%~1"=="-h" (
    goto :show_help
)
if "%~1"=="--help" (
    goto :show_help
)
echo [ERROR] Unknown option: %~1
goto :show_help

:end_parse

REM Validate environment
if not "%ENVIRONMENT%"=="development" if not "%ENVIRONMENT%"=="staging" if not "%ENVIRONMENT%"=="production" (
    echo [ERROR] Invalid environment: %ENVIRONMENT%
    echo [ERROR] Valid environments: development, staging, production
    exit /b 1
)

REM Validate build type
if not "%BUILD_TYPE%"=="debug" if not "%BUILD_TYPE%"=="profile" if not "%BUILD_TYPE%"=="release" (
    echo [ERROR] Invalid build type: %BUILD_TYPE%
    echo [ERROR] Valid build types: debug, profile, release
    exit /b 1
)

REM Validate platform
if not "%PLATFORM%"=="android" if not "%PLATFORM%"=="ios" if not "%PLATFORM%"=="web" (
    echo [ERROR] Invalid platform: %PLATFORM%
    echo [ERROR] Valid platforms: android, ios, web
    exit /b 1
)

echo [INFO] Starting EveryDiary build process...
echo [INFO] Environment: %ENVIRONMENT%
echo [INFO] Build Type: %BUILD_TYPE%
echo [INFO] Platform: %PLATFORM%

REM Check if Flutter is installed
flutter --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Flutter is not installed or not in PATH
    exit /b 1
)

REM Get Flutter version
echo [INFO] Checking Flutter version...
flutter --version

REM Clean if requested
if "%CLEAN%"=="true" (
    echo [INFO] Cleaning project...
    flutter clean
    flutter pub get
)

REM Get dependencies
echo [INFO] Getting dependencies...
flutter pub get
if errorlevel 1 (
    echo [ERROR] Failed to get dependencies
    exit /b 1
)

REM Run analysis if requested
if "%ANALYZE%"=="true" (
    echo [INFO] Running code analysis...
    flutter analyze
    if errorlevel 1 (
        echo [ERROR] Code analysis failed
        exit /b 1
    )
    echo [SUCCESS] Code analysis completed
)

REM Run tests if requested
if "%TEST%"=="true" (
    echo [INFO] Running tests...
    flutter test
    if errorlevel 1 (
        echo [ERROR] Tests failed
        exit /b 1
    )
    echo [SUCCESS] Tests completed
)

REM Set environment variables for build
set FLUTTER_ENV=%ENVIRONMENT%

REM Build based on platform
if "%PLATFORM%"=="android" (
    if "%BUILD_TYPE%"=="debug" (
        echo [INFO] Building Android APK (Debug)...
        flutter build apk --debug
    ) else if "%BUILD_TYPE%"=="profile" (
        echo [INFO] Building Android APK (Profile)...
        flutter build apk --profile
    ) else if "%BUILD_TYPE%"=="release" (
        echo [INFO] Building Android APK (Release)...
        flutter build apk --release
    )
    if errorlevel 1 (
        echo [ERROR] Android build failed
        exit /b 1
    )
    echo [SUCCESS] Android build completed
) else if "%PLATFORM%"=="ios" (
    if "%BUILD_TYPE%"=="debug" (
        echo [INFO] Building iOS (Debug)...
        flutter build ios --debug
    ) else if "%BUILD_TYPE%"=="profile" (
        echo [INFO] Building iOS (Profile)...
        flutter build ios --profile
    ) else if "%BUILD_TYPE%"=="release" (
        echo [INFO] Building iOS (Release)...
        flutter build ios --release
    )
    if errorlevel 1 (
        echo [ERROR] iOS build failed
        exit /b 1
    )
    echo [SUCCESS] iOS build completed
) else if "%PLATFORM%"=="web" (
    if "%BUILD_TYPE%"=="debug" (
        echo [INFO] Building Web (Debug)...
        flutter build web --debug
    ) else if "%BUILD_TYPE%"=="profile" (
        echo [INFO] Building Web (Profile)...
        flutter build web --profile
    ) else if "%BUILD_TYPE%"=="release" (
        echo [INFO] Building Web (Release)...
        flutter build web --release
    )
    if errorlevel 1 (
        echo [ERROR] Web build failed
        exit /b 1
    )
    echo [SUCCESS] Web build completed
)

echo [SUCCESS] Build process completed successfully!
echo [INFO] Build artifacts are available in the build/ directory
exit /b 0

:show_help
echo Usage: %0 [OPTIONS]
echo.
echo Options:
echo   -e, --env ENV        Set environment (development, staging, production)
echo   -t, --type TYPE      Set build type (debug, profile, release)
echo   -p, --platform PLAT Set platform (android, ios, web)
echo   -c, --clean          Clean before building
echo   -a, --analyze        Run code analysis
echo   -s, --test           Run tests
echo   -h, --help           Show this help message
echo.
echo Examples:
echo   %0 --env development --type debug --platform android
echo   %0 --env production --type release --platform android --clean
echo   %0 --analyze --test
exit /b 0
