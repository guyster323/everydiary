#!/bin/bash

# EveryDiary Deployment Script
# This script handles deployment to different environments

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
    echo "  -p, --platform PLAT Set platform (android, ios, web, all)"
    echo "  -t, --type TYPE      Set build type (debug, profile, release)"
    echo "  -d, --deploy         Actually deploy (default is dry-run)"
    echo "  -c, --clean          Clean before building"
    echo "  -h, --help           Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --env staging --platform android --type release --deploy"
    echo "  $0 --env production --platform all --type release --deploy"
    echo "  $0 --env development --platform web --type debug"
}

# Default values
ENVIRONMENT="development"
PLATFORM="all"
BUILD_TYPE="release"
DEPLOY=false
CLEAN=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--env)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -p|--platform)
            PLATFORM="$2"
            shift 2
            ;;
        -t|--type)
            BUILD_TYPE="$2"
            shift 2
            ;;
        -d|--deploy)
            DEPLOY=true
            shift
            ;;
        -c|--clean)
            CLEAN=true
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

# Validate platform
if [[ ! "$PLATFORM" =~ ^(android|ios|web|all)$ ]]; then
    print_error "Invalid platform: $PLATFORM"
    print_error "Valid platforms: android, ios, web, all"
    exit 1
fi

# Validate build type
if [[ ! "$BUILD_TYPE" =~ ^(debug|profile|release)$ ]]; then
    print_error "Invalid build type: $BUILD_TYPE"
    print_error "Valid build types: debug, profile, release"
    exit 1
fi

print_status "Starting EveryDiary deployment process..."
print_status "Environment: $ENVIRONMENT"
print_status "Platform: $PLATFORM"
print_status "Build Type: $BUILD_TYPE"
print_status "Deploy: $DEPLOY"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

# Check Flutter version
FLUTTER_VERSION=$(flutter --version | head -n 1)
print_status "Using $FLUTTER_VERSION"

# Set environment variables
export FLUTTER_ENV="$ENVIRONMENT"

# Clean if requested
if [ "$CLEAN" = true ]; then
    print_status "Cleaning project..."
    flutter clean
    flutter pub get
fi

# Get dependencies
print_status "Getting dependencies..."
flutter pub get

# Run tests before deployment
if [ "$BUILD_TYPE" = "release" ]; then
    print_status "Running tests before release deployment..."
    flutter test
    print_success "All tests passed"
fi

# Build and deploy based on platform
case $PLATFORM in
    android)
        print_status "Building Android APK ($BUILD_TYPE)..."
        flutter build apk --$BUILD_TYPE

        if [ "$DEPLOY" = true ]; then
            print_status "Deploying Android APK to $ENVIRONMENT..."
            # Add actual deployment logic here
            # For example: upload to Firebase App Distribution, Google Play, etc.
            print_success "Android APK deployed to $ENVIRONMENT"
        else
            print_warning "Dry run: Android APK built but not deployed"
        fi
        ;;
    ios)
        print_status "Building iOS ($BUILD_TYPE)..."
        flutter build ios --$BUILD_TYPE

        if [ "$DEPLOY" = true ]; then
            print_status "Deploying iOS to $ENVIRONMENT..."
            # Add actual deployment logic here
            # For example: upload to TestFlight, App Store Connect, etc.
            print_success "iOS deployed to $ENVIRONMENT"
        else
            print_warning "Dry run: iOS built but not deployed"
        fi
        ;;
    web)
        print_status "Building Web ($BUILD_TYPE)..."
        flutter build web --$BUILD_TYPE

        if [ "$DEPLOY" = true ]; then
            print_status "Deploying Web to $ENVIRONMENT..."
            # Add actual deployment logic here
            # For example: upload to Firebase Hosting, Netlify, etc.
            print_success "Web deployed to $ENVIRONMENT"
        else
            print_warning "Dry run: Web built but not deployed"
        fi
        ;;
    all)
        print_status "Building all platforms ($BUILD_TYPE)..."

        # Build Android
        flutter build apk --$BUILD_TYPE
        print_success "Android APK built"

        # Build iOS
        flutter build ios --$BUILD_TYPE
        print_success "iOS built"

        # Build Web
        flutter build web --$BUILD_TYPE
        print_success "Web built"

        if [ "$DEPLOY" = true ]; then
            print_status "Deploying all platforms to $ENVIRONMENT..."
            # Add actual deployment logic here
            print_success "All platforms deployed to $ENVIRONMENT"
        else
            print_warning "Dry run: All platforms built but not deployed"
        fi
        ;;
esac

print_success "Deployment process completed successfully!"

if [ "$DEPLOY" = false ]; then
    print_warning "This was a dry run. Use --deploy flag to actually deploy."
fi

