#!/bin/bash

# Flutter 빌드 스크립트 (Bash)
# 사용법: ./build.sh [apk|appbundle|ios|web]

set -e  # 오류 발생 시 즉시 종료

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

TARGET=$1

# 사용법 확인
if [ -z "$TARGET" ]; then
    echo -e "${RED}❌ 사용법: ./build.sh [apk|appbundle|ios|web]${NC}"
    exit 1
fi

# 타겟 유효성 검사
if [[ ! "$TARGET" =~ ^(apk|appbundle|ios|web)$ ]]; then
    echo -e "${RED}❌ 잘못된 타겟: $TARGET${NC}"
    echo -e "${YELLOW}   가능한 타겟: apk, appbundle, ios, web${NC}"
    exit 1
fi

echo -e "${CYAN}🔍 API 키 파일 확인 중...${NC}"

# .env.flutter.local 파일 확인
if [ ! -f ".env.flutter.local" ]; then
    echo ""
    echo -e "${RED}❌ .env.flutter.local 파일이 없습니다.${NC}"
    echo ""
    echo -e "${YELLOW}다음 단계를 따라주세요:${NC}"
    echo -e "${WHITE}1. 템플릿 파일 복사:${NC}"
    echo -e "${GRAY}   cp .env.flutter.example .env.flutter.local${NC}"
    echo ""
    echo -e "${WHITE}2. .env.flutter.local 파일을 열어서 실제 API 키를 입력하세요:${NC}"
    echo -e "${GRAY}   nano .env.flutter.local${NC}"
    echo -e "${GRAY}   또는${NC}"
    echo -e "${GRAY}   code .env.flutter.local${NC}"
    echo ""
    exit 1
fi

echo -e "${GREEN}✅ API 키 파일 발견${NC}"

# API 키 읽기
GEMINI_KEY=$(grep "^GEMINI_API_KEY=" .env.flutter.local | cut -d '=' -f2- | tr -d ' ')
HF_KEY=$(grep "^HUGGING_FACE_API_KEY=" .env.flutter.local | cut -d '=' -f2- | tr -d ' ')

# API 키 유효성 검사
if [ -z "$GEMINI_KEY" ] || [ "$GEMINI_KEY" = "your_gemini_api_key_here" ]; then
    echo -e "${RED}❌ GEMINI_API_KEY가 설정되지 않았습니다.${NC}"
    echo -e "${YELLOW}   .env.flutter.local 파일을 열어서 실제 API 키를 입력하세요.${NC}"
    exit 1
fi

if [ -z "$HF_KEY" ] || [ "$HF_KEY" = "your_huggingface_api_key_here" ]; then
    echo -e "${RED}❌ HUGGING_FACE_API_KEY가 설정되지 않았습니다.${NC}"
    echo -e "${YELLOW}   .env.flutter.local 파일을 열어서 실제 API 키를 입력하세요.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ API 키 검증 완료${NC}"
echo ""
echo -e "${GREEN}🚀 빌드 시작: $TARGET${NC}"
echo -e "${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 빌드 실행
flutter build "$TARGET" \
    --dart-define=GEMINI_API_KEY="$GEMINI_KEY" \
    --dart-define=HUGGING_FACE_API_KEY="$HF_KEY"

BUILD_EXIT_CODE=$?

echo ""
echo -e "${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ $BUILD_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✅ 빌드 성공!${NC}"
    echo ""

    # 빌드 결과 위치 안내
    case "$TARGET" in
        apk)
            echo -e "${CYAN}📦 APK 파일 위치:${NC}"
            echo -e "${WHITE}   build/app/outputs/flutter-apk/app-release.apk${NC}"
            ;;
        appbundle)
            echo -e "${CYAN}📦 App Bundle 파일 위치:${NC}"
            echo -e "${WHITE}   build/app/outputs/bundle/release/app-release.aab${NC}"
            ;;
        ios)
            echo -e "${CYAN}📦 iOS 빌드 완료:${NC}"
            echo -e "${WHITE}   build/ios/archive/${NC}"
            ;;
        web)
            echo -e "${CYAN}📦 Web 빌드 완료:${NC}"
            echo -e "${WHITE}   build/web/${NC}"
            ;;
    esac
    echo ""
else
    echo -e "${RED}❌ 빌드 실패 (종료 코드: $BUILD_EXIT_CODE)${NC}"
    echo ""
    exit $BUILD_EXIT_CODE
fi
