#!/bin/bash

# EveryDiary Changelog Generator
# This script generates changelog and release notes

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
    echo "  -v, --version VER    Version for changelog (e.g., 1.2.3)"
    echo "  -f, --from TAG       Start from specific tag"
    echo "  -t, --to TAG         End at specific tag (default: HEAD)"
    echo "  -o, --output FILE    Output file (default: CHANGELOG.md)"
    echo "  -r, --release        Generate release notes format"
    echo "  -h, --help           Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --version 1.2.3 --release"
    echo "  $0 --from v1.1.0 --to v1.2.0"
    echo "  $0 --output RELEASE_NOTES.md --release"
}

# Default values
VERSION=""
FROM_TAG=""
TO_TAG="HEAD"
OUTPUT_FILE="CHANGELOG.md"
RELEASE_FORMAT=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--version)
            VERSION="$2"
            shift 2
            ;;
        -f|--from)
            FROM_TAG="$2"
            shift 2
            ;;
        -t|--to)
            TO_TAG="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -r|--release)
            RELEASE_FORMAT=true
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

# Get commit messages between tags
get_commits() {
    local from=$1
    local to=$2

    if [ -n "$from" ]; then
        git log --pretty=format:"%s" $from..$to
    else
        git log --pretty=format:"%s" --max-count=50
    fi
}

# Categorize commits
categorize_commits() {
    local commits=$1

    local features=()
    local fixes=()
    local docs=()
    local style=()
    local refactor=()
    local perf=()
    local test=()
    local chore=()
    local breaking=()

    while IFS= read -r commit; do
        case $commit in
            feat*|feature*)
                features+=("$commit")
                ;;
            fix*|bugfix*)
                fixes+=("$commit")
                ;;
            docs*|doc*)
                docs+=("$commit")
                ;;
            style*)
                style+=("$commit")
                ;;
            refactor*)
                refactor+=("$commit")
                ;;
            perf*|performance*)
                perf+=("$commit")
                ;;
            test*)
                test+=("$commit")
                ;;
            chore*)
                chore+=("$commit")
                ;;
            BREAKING*|!*)
                breaking+=("$commit")
                ;;
            *)
                # Default to features for unrecognized types
                features+=("$commit")
                ;;
        esac
    done <<< "$commits"

    # Export arrays (this is a workaround for bash limitations)
    echo "FEATURES:${features[*]}"
    echo "FIXES:${fixes[*]}"
    echo "DOCS:${docs[*]}"
    echo "STYLE:${style[*]}"
    echo "REFACTOR:${refactor[*]}"
    echo "PERF:${perf[*]}"
    echo "TEST:${test[*]}"
    echo "CHORE:${chore[*]}"
    echo "BREAKING:${breaking[*]}"
}

# Generate changelog content
generate_changelog() {
    local version=$1
    local from_tag=$2
    local to_tag=$3
    local release_format=$4

    local commits=$(get_commits $from_tag $to_tag)
    local categorized=$(categorize_commits "$commits")

    # Parse categorized commits
    local features=$(echo "$categorized" | grep "FEATURES:" | cut -d: -f2-)
    local fixes=$(echo "$categorized" | grep "FIXES:" | cut -d: -f2-)
    local docs=$(echo "$categorized" | grep "DOCS:" | cut -d: -f2-)
    local style=$(echo "$categorized" | grep "STYLE:" | cut -d: -f2-)
    local refactor=$(echo "$categorized" | grep "REFACTOR:" | cut -d: -f2-)
    local perf=$(echo "$categorized" | grep "PERF:" | cut -d: -f2-)
    local test=$(echo "$categorized" | grep "TEST:" | cut -d: -f2-)
    local chore=$(echo "$categorized" | grep "CHORE:" | cut -d: -f2-)
    local breaking=$(echo "$categorized" | grep "BREAKING:" | cut -d: -f2-)

    local changelog=""

    if [ "$release_format" = true ]; then
        changelog+="## 🚀 EveryDiary Release v$version\n\n"
        changelog+="### 📱 Build Information\n"
        changelog+="- **Release Date**: $(date -u +'%Y-%m-%d')\n"
        changelog+="- **Flutter Version**: $(flutter --version | head -n 1 | cut -d' ' -f2)\n"
        changelog+="- **Commit**: $(git rev-parse HEAD)\n\n"
    else
        changelog+="## [v$version] - $(date -u +'%Y-%m-%d')\n\n"
    fi

    # Breaking changes
    if [ -n "$breaking" ]; then
        changelog+="### ⚠️ Breaking Changes\n"
        for change in $breaking; do
            changelog+="- $change\n"
        done
        changelog+="\n"
    fi

    # Features
    if [ -n "$features" ]; then
        changelog+="### ✨ Features\n"
        for feature in $features; do
            changelog+="- $feature\n"
        done
        changelog+="\n"
    fi

    # Bug fixes
    if [ -n "$fixes" ]; then
        changelog+="### 🐛 Bug Fixes\n"
        for fix in $fixes; do
            changelog+="- $fix\n"
        done
        changelog+="\n"
    fi

    # Performance improvements
    if [ -n "$perf" ]; then
        changelog+="### ⚡ Performance Improvements\n"
        for improvement in $perf; do
            changelog+="- $improvement\n"
        done
        changelog+="\n"
    fi

    # Refactoring
    if [ -n "$refactor" ]; then
        changelog+="### 🔧 Refactoring\n"
        for ref in $refactor; do
            changelog+="- $ref\n"
        done
        changelog+="\n"
    fi

    # Documentation
    if [ -n "$docs" ]; then
        changelog+="### 📚 Documentation\n"
        for doc in $docs; do
            changelog+="- $doc\n"
        done
        changelog+="\n"
    fi

    # Tests
    if [ -n "$test" ]; then
        changelog+="### 🧪 Tests\n"
        for t in $test; do
            changelog+="- $t\n"
        done
        changelog+="\n"
    fi

    # Style changes
    if [ -n "$style" ]; then
        changelog+="### 💄 Style Changes\n"
        for s in $style; do
            changelog+="- $s\n"
        done
        changelog+="\n"
    fi

    # Chores
    if [ -n "$chore" ]; then
        changelog+="### 🔨 Chores\n"
        for c in $chore; do
            changelog+="- $c\n"
        done
        changelog+="\n"
    fi

    if [ "$release_format" = true ]; then
        changelog+="### 📥 Downloads\n"
        changelog+="- **APK**: Direct installation for Android devices\n"
        changelog+="- **AAB**: For Google Play Store distribution\n"
        changelog+="- **Web**: Browser-based version\n\n"
        changelog+="### 🔗 Links\n"
        changelog+="- [GitHub Release](https://github.com/your-org/everydiary/releases/tag/v$version)\n"
        changelog+="- [Download APK](https://github.com/your-org/everydiary/releases/download/v$version/app-release.apk)\n"
    fi

    echo -e "$changelog"
}

# Main execution
if [ -z "$VERSION" ] && [ -z "$FROM_TAG" ]; then
    print_error "Either --version or --from must be specified"
    show_usage
    exit 1
fi

# If version is not specified, try to get it from git tags
if [ -z "$VERSION" ]; then
    VERSION=$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//' || echo "unknown")
    print_warning "Version not specified, using: $VERSION"
fi

print_status "Generating changelog for version: $VERSION"
print_status "From: ${FROM_TAG:-"beginning"}"
print_status "To: $TO_TAG"
print_status "Output: $OUTPUT_FILE"

# Generate changelog
changelog_content=$(generate_changelog "$VERSION" "$FROM_TAG" "$TO_TAG" "$RELEASE_FORMAT")

# Write to file
echo -e "$changelog_content" > "$OUTPUT_FILE"

print_success "Changelog generated successfully: $OUTPUT_FILE"

# Show preview
if [ "$RELEASE_FORMAT" = true ]; then
    print_status "Release notes preview:"
else
    print_status "Changelog preview:"
fi
echo "----------------------------------------"
head -20 "$OUTPUT_FILE"
echo "----------------------------------------"

