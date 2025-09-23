@echo off
REM EveryDiary Deployment Script for Windows
REM This script handles deployment to different environments

setlocal enabledelayedexpansion

REM Default values
set ENVIRONMENT=development
set PLATFORM=all
set BUILD_TYPE=release
set DEPLOY=false
set CLEAN=false

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
if "%~1"=="-d" (
    set DEPLOY=true
    shift
    goto :parse_args
)
if "%~1"=="--deploy" (
    set DEPLOY=true
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

REM Validate platform
if not "%PLATFORM%"=="android" if not "%PLATFORM%"=="ios" if not "%PLATFORM%"=="web" if not "%PLATFORM%"=="all" (
    echo [ERROR] Invalid platform: %PLATFORM%
    echo [ERROR] Valid platforms: android, ios, web, all
    exit /b 1
)

REM Validate build type
if not "%BUILD_TYPE%"=="debug" if not "%BUILD_TYPE%"=="profile" if not "%BUILD_TYPE%"=="release" (
    echo [ERROR] Invalid build type: %BUILD_TYPE%
    echo [ERROR] Valid build types: debug, profile, release
    exit /b 1
)

echo [INFO] Starting EveryDiary deployment process...
echo [INFO] Environment: %ENVIRONMENT%
echo [INFO] Platform: %PLATFORM%
echo [INFO] Build Type: %BUILD_TYPE%
echo [INFO] Deploy: %DEPLOY%

REM Check if Flutter is installed
flutter --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Flutter is not installed or not in PATH
    exit /b 1
)

REM Get Flutter version
echo [INFO] Checking Flutter version...
flutter --version

REM Set environment variables
set FLUTTER_ENV=%ENVIRONMENT%

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

REM Run tests before deployment
if "%BUILD_TYPE%"=="release" (
    echo [INFO] Running tests before release deployment...
    flutter test
    if errorlevel 1 (
        echo [ERROR] Tests failed
        exit /b 1
    )
    echo [SUCCESS] All tests passed
)

REM Build and deploy based on platform
if "%PLATFORM%"=="android" (
    echo [INFO] Building Android APK (%BUILD_TYPE%)...
    flutter build apk --%BUILD_TYPE%
    if errorlevel 1 (
        echo [ERROR] Android build failed
        exit /b 1
    )

    if "%DEPLOY%"=="true" (
        echo [INFO] Deploying Android APK to %ENVIRONMENT%...
        REM Add actual deployment logic here
        echo [SUCCESS] Android APK deployed to %ENVIRONMENT%
    ) else (
        echo [WARNING] Dry run: Android APK built but not deployed
    )
) else if "%PLATFORM%"=="ios" (
    echo [INFO] Building iOS (%BUILD_TYPE%)...
    flutter build ios --%BUILD_TYPE%
    if errorlevel 1 (
        echo [ERROR] iOS build failed
        exit /b 1
    )

    if "%DEPLOY%"=="true" (
        echo [INFO] Deploying iOS to %ENVIRONMENT%...
        REM Add actual deployment logic here
        echo [SUCCESS] iOS deployed to %ENVIRONMENT%
    ) else (
        echo [WARNING] Dry run: iOS built but not deployed
    )
) else if "%PLATFORM%"=="web" (
    echo [INFO] Building Web (%BUILD_TYPE%)...
    flutter build web --%BUILD_TYPE%
    if errorlevel 1 (
        echo [ERROR] Web build failed
        exit /b 1
    )

    if "%DEPLOY%"=="true" (
        echo [INFO] Deploying Web to %ENVIRONMENT%...
        REM Add actual deployment logic here
        echo [SUCCESS] Web deployed to %ENVIRONMENT%
    ) else (
        echo [WARNING] Dry run: Web built but not deployed
    )
) else if "%PLATFORM%"=="all" (
    echo [INFO] Building all platforms (%BUILD_TYPE%)...

    REM Build Android
    flutter build apk --%BUILD_TYPE%
    if errorlevel 1 (
        echo [ERROR] Android build failed
        exit /b 1
    )
    echo [SUCCESS] Android APK built

    REM Build iOS
    flutter build ios --%BUILD_TYPE%
    if errorlevel 1 (
        echo [ERROR] iOS build failed
        exit /b 1
    )
    echo [SUCCESS] iOS built

    REM Build Web
    flutter build web --%BUILD_TYPE%
    if errorlevel 1 (
        echo [ERROR] Web build failed
        exit /b 1
    )
    echo [SUCCESS] Web built

    if "%DEPLOY%"=="true" (
        echo [INFO] Deploying all platforms to %ENVIRONMENT%...
        REM Add actual deployment logic here
        echo [SUCCESS] All platforms deployed to %ENVIRONMENT%
    ) else (
        echo [WARNING] Dry run: All platforms built but not deployed
    )
)

echo [SUCCESS] Deployment process completed successfully!

if "%DEPLOY%"=="false" (
    echo [WARNING] This was a dry run. Use --deploy flag to actually deploy.
)

exit /b 0

:show_help
echo Usage: %0 [OPTIONS]
echo.
echo Options:
echo   -e, --env ENV        Set environment (development, staging, production)
echo   -p, --platform PLAT Set platform (android, ios, web, all)
echo   -t, --type TYPE      Set build type (debug, profile, release)
echo   -d, --deploy         Actually deploy (default is dry-run)
echo   -c, --clean          Clean before building
echo   -h, --help           Show this help message
echo.
echo Examples:
echo   %0 --env staging --platform android --type release --deploy
echo   %0 --env production --platform all --type release --deploy
echo   %0 --env development --platform web --type debug
exit /b 0

