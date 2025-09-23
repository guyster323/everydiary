@echo off
REM Pre-commit script for EveryDiary Flutter project
REM This script runs code quality checks before committing

echo Running pre-commit checks for EveryDiary...

REM Check if we're in a Flutter project
if not exist "pubspec.yaml" (
    echo Error: Not in a Flutter project directory
    exit /b 1
)

REM Run Flutter analyze
echo Running Flutter analyze...
flutter analyze
if %errorlevel% neq 0 (
    echo Flutter analyze failed. Please fix the issues before committing.
    exit /b 1
)

REM Run Dart format check
echo Checking code formatting...
dart format --set-exit-if-changed .
if %errorlevel% neq 0 (
    echo Code formatting issues found. Please run 'dart format .' to fix them.
    exit /b 1
)

REM Run tests (if any exist)
if exist "test" (
    echo Running tests...
    flutter test
    if %errorlevel% neq 0 (
        echo Tests failed. Please fix the failing tests before committing.
        exit /b 1
    )
)

echo All pre-commit checks passed!
echo Ready to commit!
