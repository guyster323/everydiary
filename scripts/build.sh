#!/bin/bash

# EveryDiary Flutter Build Script
# This script handles different build configurations for the EveryDiary app

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -e, --env ENV        Set environment (development, staging, production)"
    echo "  -t, --type TYPE      Set build type (debug, profile, release)"
    echo "  -p, --platform PLAT Set platform (android, ios, web)"
    echo "  -c, --clean          Clean before building"
    echo "  -a, --analyze        Run code analysis"
    echo "  -s, --test           Run tests"
    echo "  -h, --help           Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --env development --type debug --platform android"
    echo "  $0 --env production --type release --platform android --clean"
    echo "  $0 --analyze --test"
}

# Default values
ENVIRONMENT="development"
BUILD_TYPE="debug"
PLATFORM="android"
CLEAN=false
ANALYZE=false
TEST=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--env)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -t|--type)
            BUILD_TYPE="$2"
            shift 2
            ;;
        -p|--platform)
            PLATFORM="$2"
            shift 2
            ;;
        -c|--clean)
            CLEAN=true
            shift
            ;;
        -a|--analyze)
            ANALYZE=true
            shift
            ;;
        -s|--test)
            TEST=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(development|staging|production)$ ]]; then
    print_error "Invalid environment: $ENVIRONMENT"
    print_error "Valid environments: development, staging, production"
    exit 1
fi

# Validate build type
if [[ ! "$BUILD_TYPE" =~ ^(debug|profile|release)$ ]]; then
    print_error "Invalid build type: $BUILD_TYPE"
    print_error "Valid build types: debug, profile, release"
    exit 1
fi

# Validate platform
if [[ ! "$PLATFORM" =~ ^(android|ios|web)$ ]]; then
    print_error "Invalid platform: $PLATFORM"
    print_error "Valid platforms: android, ios, web"
    exit 1
fi

print_status "Starting EveryDiary build process..."
print_status "Environment: $ENVIRONMENT"
print_status "Build Type: $BUILD_TYPE"
print_status "Platform: $PLATFORM"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

# Check Flutter version
FLUTTER_VERSION=$(flutter --version | head -n 1)
print_status "Using $FLUTTER_VERSION"

# Clean if requested
if [ "$CLEAN" = true ]; then
    print_status "Cleaning project..."
    flutter clean
    flutter pub get
fi

# Get dependencies
print_status "Getting dependencies..."
flutter pub get

# Run analysis if requested
if [ "$ANALYZE" = true ]; then
    print_status "Running code analysis..."
    flutter analyze
    print_success "Code analysis completed"
fi

# Run tests if requested
if [ "$TEST" = true ]; then
    print_status "Running tests..."
    flutter test
    print_success "Tests completed"
fi

# Set environment variables for build
export FLUTTER_ENV="$ENVIRONMENT"

# Build based on platform
case $PLATFORM in
    android)
        case $BUILD_TYPE in
            debug)
                print_status "Building Android APK (Debug)..."
                flutter build apk --debug
                ;;
            profile)
                print_status "Building Android APK (Profile)..."
                flutter build apk --profile
                ;;
            release)
                print_status "Building Android APK (Release)..."
                flutter build apk --release
                ;;
        esac
        print_success "Android build completed"
        ;;
    ios)
        case $BUILD_TYPE in
            debug)
                print_status "Building iOS (Debug)..."
                flutter build ios --debug
                ;;
            profile)
                print_status "Building iOS (Profile)..."
                flutter build ios --profile
                ;;
            release)
                print_status "Building iOS (Release)..."
                flutter build ios --release
                ;;
        esac
        print_success "iOS build completed"
        ;;
    web)
        case $BUILD_TYPE in
            debug)
                print_status "Building Web (Debug)..."
                flutter build web --debug
                ;;
            profile)
                print_status "Building Web (Profile)..."
                flutter build web --profile
                ;;
            release)
                print_status "Building Web (Release)..."
                flutter build web --release
                ;;
        esac
        print_success "Web build completed"
        ;;
esac

print_success "Build process completed successfully!"
print_status "Build artifacts are available in the build/ directory"
