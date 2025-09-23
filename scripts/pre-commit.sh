#!/bin/bash

# Pre-commit script for EveryDiary Flutter project
# This script runs code quality checks before committing

echo "🔍 Running pre-commit checks for EveryDiary..."

# Check if we're in a Flutter project
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: Not in a Flutter project directory"
    exit 1
fi

# Run Flutter analyze
echo "📊 Running Flutter analyze..."
flutter analyze
if [ $? -ne 0 ]; then
    echo "❌ Flutter analyze failed. Please fix the issues before committing."
    exit 1
fi

# Run Dart format check
echo "🎨 Checking code formatting..."
dart format --set-exit-if-changed .
if [ $? -ne 0 ]; then
    echo "❌ Code formatting issues found. Please run 'dart format .' to fix them."
    exit 1
fi

# Run tests (if any exist)
if [ -d "test" ] && [ "$(ls -A test)" ]; then
    echo "🧪 Running tests..."
    flutter test
    if [ $? -ne 0 ]; then
        echo "❌ Tests failed. Please fix the failing tests before committing."
        exit 1
    fi
fi

echo "✅ All pre-commit checks passed!"
echo "🚀 Ready to commit!"
