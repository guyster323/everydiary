#!/bin/bash

# EveryDiary Version Management Script
# This script handles version bumping and management

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
    echo "  -t, --type TYPE      Version bump type (major, minor, patch, build)"
    echo "  -v, --version VER    Set specific version (e.g., 1.2.3+4)"
    echo "  -s, --show           Show current version"
    echo "  -c, --commit         Commit version changes"
    echo "  -t, --tag            Create git tag for version"
    echo "  -h, --help           Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --type patch --commit --tag"
    echo "  $0 --version 1.2.3+4 --commit"
    echo "  $0 --show"
}

# Default values
VERSION_TYPE=""
SPECIFIC_VERSION=""
SHOW_VERSION=false
COMMIT=false
TAG=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--type)
            VERSION_TYPE="$2"
            shift 2
            ;;
        -v|--version)
            SPECIFIC_VERSION="$2"
            shift 2
            ;;
        -s|--show)
            SHOW_VERSION=true
            shift
            ;;
        -c|--commit)
            COMMIT=true
            shift
            ;;
        --tag)
            TAG=true
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

# Get current version from pubspec.yaml
get_current_version() {
    grep '^version:' pubspec.yaml | cut -d' ' -f2
}

# Parse version string
parse_version() {
    local version=$1
    local major=$(echo $version | cut -d'.' -f1)
    local minor=$(echo $version | cut -d'.' -f2)
    local patch=$(echo $version | cut -d'.' -f3 | cut -d'+' -f1)
    local build=$(echo $version | cut -d'+' -f2)

    echo "$major $minor $patch $build"
}

# Bump version based on type
bump_version() {
    local current_version=$1
    local bump_type=$2

    local version_parts=($(parse_version $current_version))
    local major=${version_parts[0]}
    local minor=${version_parts[1]}
    local patch=${version_parts[2]}
    local build=${version_parts[3]}

    case $bump_type in
        major)
            major=$((major + 1))
            minor=0
            patch=0
            build=$((build + 1))
            ;;
        minor)
            minor=$((minor + 1))
            patch=0
            build=$((build + 1))
            ;;
        patch)
            patch=$((patch + 1))
            build=$((build + 1))
            ;;
        build)
            build=$((build + 1))
            ;;
        *)
            print_error "Invalid version type: $bump_type"
            print_error "Valid types: major, minor, patch, build"
            exit 1
            ;;
    esac

    echo "$major.$minor.$patch+$build"
}

# Update version in pubspec.yaml
update_version() {
    local new_version=$1
    local pubspec_file="pubspec.yaml"

    # Create backup
    cp $pubspec_file "${pubspec_file}.backup"

    # Update version
    sed -i "s/^version: .*/version: $new_version/" $pubspec_file

    print_success "Version updated to $new_version in $pubspec_file"
}

# Show current version
if [ "$SHOW_VERSION" = true ]; then
    current_version=$(get_current_version)
    print_status "Current version: $current_version"

    # Parse and show version components
    version_parts=($(parse_version $current_version))
    echo "  Major: ${version_parts[0]}"
    echo "  Minor: ${version_parts[1]}"
    echo "  Patch: ${version_parts[2]}"
    echo "  Build: ${version_parts[3]}"
    exit 0
fi

# Get current version
current_version=$(get_current_version)
print_status "Current version: $current_version"

# Determine new version
if [ -n "$SPECIFIC_VERSION" ]; then
    new_version=$SPECIFIC_VERSION
    print_status "Setting specific version: $new_version"
elif [ -n "$VERSION_TYPE" ]; then
    new_version=$(bump_version $current_version $VERSION_TYPE)
    print_status "Bumping $VERSION_TYPE version: $current_version -> $new_version"
else
    print_error "Either --type or --version must be specified"
    show_usage
    exit 1
fi

# Validate new version format
if [[ ! $new_version =~ ^[0-9]+\.[0-9]+\.[0-9]+\+[0-9]+$ ]]; then
    print_error "Invalid version format: $new_version"
    print_error "Expected format: major.minor.patch+build (e.g., 1.2.3+4)"
    exit 1
fi

# Update version in pubspec.yaml
update_version $new_version

# Commit changes if requested
if [ "$COMMIT" = true ]; then
    print_status "Committing version changes..."
    git add pubspec.yaml
    git commit -m "chore: bump version to $new_version"
    print_success "Version changes committed"
fi

# Create git tag if requested
if [ "$TAG" = true ]; then
    tag_name="v${new_version%+*}"  # Remove build number for tag
    print_status "Creating git tag: $tag_name"
    git tag -a $tag_name -m "Release $tag_name"
    print_success "Git tag $tag_name created"
fi

print_success "Version management completed successfully!"
print_status "New version: $new_version"

if [ "$COMMIT" = false ] && [ "$TAG" = false ]; then
    print_warning "Version updated but not committed or tagged"
    print_warning "Use --commit and --tag flags to commit and tag the changes"
fi

