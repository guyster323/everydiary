@echo off
REM EveryDiary Version Management Script for Windows
REM This script handles version bumping and management

setlocal enabledelayedexpansion

REM Default values
set VERSION_TYPE=
set SPECIFIC_VERSION=
set SHOW_VERSION=false
set COMMIT=false
set TAG=false

REM Parse command line arguments
:parse_args
if "%~1"=="" goto :end_parse
if "%~1"=="-t" (
    set VERSION_TYPE=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="--type" (
    set VERSION_TYPE=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="-v" (
    set SPECIFIC_VERSION=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="--version" (
    set SPECIFIC_VERSION=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="-s" (
    set SHOW_VERSION=true
    shift
    goto :parse_args
)
if "%~1"=="--show" (
    set SHOW_VERSION=true
    shift
    goto :parse_args
)
if "%~1"=="-c" (
    set COMMIT=true
    shift
    goto :parse_args
)
if "%~1"=="--commit" (
    set COMMIT=true
    shift
    goto :parse_args
)
if "%~1"=="--tag" (
    set TAG=true
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

REM Get current version from pubspec.yaml
for /f "tokens=2" %%i in ('findstr /r "^version:" pubspec.yaml') do set CURRENT_VERSION=%%i

REM Show current version
if "%SHOW_VERSION%"=="true" (
    echo [INFO] Current version: %CURRENT_VERSION%

    REM Parse version components
    for /f "tokens=1,2,3 delims=." %%a in ("%CURRENT_VERSION%") do (
        set MAJOR=%%a
        for /f "tokens=1,2 delims=+" %%d in ("%%c") do (
            set MINOR=%%b
            set PATCH=%%d
            set BUILD=%%e
        )
    )

    echo   Major: !MAJOR!
    echo   Minor: !MINOR!
    echo   Patch: !PATCH!
    echo   Build: !BUILD!
    exit /b 0
)

echo [INFO] Current version: %CURRENT_VERSION%

REM Determine new version
if not "%SPECIFIC_VERSION%"=="" (
    set NEW_VERSION=%SPECIFIC_VERSION%
    echo [INFO] Setting specific version: %NEW_VERSION%
) else if not "%VERSION_TYPE%"=="" (
    REM Parse current version
    for /f "tokens=1,2,3 delims=." %%a in ("%CURRENT_VERSION%") do (
        set MAJOR=%%a
        for /f "tokens=1,2 delims=+" %%d in ("%%c") do (
            set MINOR=%%b
            set PATCH=%%d
            set BUILD=%%e
        )
    )

    REM Bump version based on type
    if "%VERSION_TYPE%"=="major" (
        set /a MAJOR+=1
        set MINOR=0
        set PATCH=0
        set /a BUILD+=1
    ) else if "%VERSION_TYPE%"=="minor" (
        set /a MINOR+=1
        set PATCH=0
        set /a BUILD+=1
    ) else if "%VERSION_TYPE%"=="patch" (
        set /a PATCH+=1
        set /a BUILD+=1
    ) else if "%VERSION_TYPE%"=="build" (
        set /a BUILD+=1
    ) else (
        echo [ERROR] Invalid version type: %VERSION_TYPE%
        echo [ERROR] Valid types: major, minor, patch, build
        exit /b 1
    )

    set NEW_VERSION=!MAJOR!.!MINOR!.!PATCH!+!BUILD!
    echo [INFO] Bumping %VERSION_TYPE% version: %CURRENT_VERSION% -^> %NEW_VERSION%
) else (
    echo [ERROR] Either --type or --version must be specified
    goto :show_help
)

REM Update version in pubspec.yaml
echo [INFO] Updating version in pubspec.yaml...
copy pubspec.yaml pubspec.yaml.backup >nul

REM Use findstr and more to replace version line
findstr /v "^version:" pubspec.yaml > pubspec_temp.yaml
echo version: %NEW_VERSION% >> pubspec_temp.yaml
move pubspec_temp.yaml pubspec.yaml >nul

echo [SUCCESS] Version updated to %NEW_VERSION% in pubspec.yaml

REM Commit changes if requested
if "%COMMIT%"=="true" (
    echo [INFO] Committing version changes...
    git add pubspec.yaml
    git commit -m "chore: bump version to %NEW_VERSION%"
    echo [SUCCESS] Version changes committed
)

REM Create git tag if requested
if "%TAG%"=="true" (
    REM Remove build number for tag
    for /f "tokens=1,2,3 delims=+" %%a in ("%NEW_VERSION%") do set TAG_VERSION=v%%a
    echo [INFO] Creating git tag: %TAG_VERSION%
    git tag -a %TAG_VERSION% -m "Release %TAG_VERSION%"
    echo [SUCCESS] Git tag %TAG_VERSION% created
)

echo [SUCCESS] Version management completed successfully!
echo [INFO] New version: %NEW_VERSION%

if "%COMMIT%"=="false" if "%TAG%"=="false" (
    echo [WARNING] Version updated but not committed or tagged
    echo [WARNING] Use --commit and --tag flags to commit and tag the changes
)

exit /b 0

:show_help
echo Usage: %0 [OPTIONS]
echo.
echo Options:
echo   -t, --type TYPE      Version bump type (major, minor, patch, build)
echo   -v, --version VER    Set specific version (e.g., 1.2.3+4)
echo   -s, --show           Show current version
echo   -c, --commit         Commit version changes
echo   --tag                Create git tag for version
echo   -h, --help           Show this help message
echo.
echo Examples:
echo   %0 --type patch --commit --tag
echo   %0 --version 1.2.3+4 --commit
echo   %0 --show
exit /b 0
