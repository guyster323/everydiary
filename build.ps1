# Flutter 빌드 스크립트 (PowerShell)
# 사용법: .\build.ps1 [apk|appbundle|ios|web]

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("apk", "appbundle", "ios", "web")]
    [string]$target
)

Write-Host "🔍 API 키 파일 확인 중..." -ForegroundColor Cyan

# .env.flutter.local 파일 확인
if (-Not (Test-Path ".env.flutter.local")) {
    Write-Host ""
    Write-Host "❌ .env.flutter.local 파일이 없습니다." -ForegroundColor Red
    Write-Host ""
    Write-Host "다음 단계를 따라주세요:" -ForegroundColor Yellow
    Write-Host "1. 템플릿 파일 복사:" -ForegroundColor White
    Write-Host "   Copy-Item .env.flutter.example .env.flutter.local" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. .env.flutter.local 파일을 열어서 실제 API 키를 입력하세요:" -ForegroundColor White
    Write-Host "   notepad .env.flutter.local" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

Write-Host "✅ API 키 파일 발견" -ForegroundColor Green

# API 키 읽기
try {
    $envContent = Get-Content .env.flutter.local -ErrorAction Stop
    $geminiKey = ($envContent | Select-String "GEMINI_API_KEY" | Select-Object -First 1).ToString().Split("=", 2)[1].Trim()
    $hfKey = ($envContent | Select-String "HUGGING_FACE_API_KEY" | Select-Object -First 1).ToString().Split("=", 2)[1].Trim()

    # API 키 유효성 검사
    if ([string]::IsNullOrWhiteSpace($geminiKey) -or $geminiKey -eq "your_gemini_api_key_here") {
        Write-Host "❌ GEMINI_API_KEY가 설정되지 않았습니다." -ForegroundColor Red
        Write-Host "   .env.flutter.local 파일을 열어서 실제 API 키를 입력하세요." -ForegroundColor Yellow
        exit 1
    }

    if ([string]::IsNullOrWhiteSpace($hfKey) -or $hfKey -eq "your_huggingface_api_key_here") {
        Write-Host "❌ HUGGING_FACE_API_KEY가 설정되지 않았습니다." -ForegroundColor Red
        Write-Host "   .env.flutter.local 파일을 열어서 실제 API 키를 입력하세요." -ForegroundColor Yellow
        exit 1
    }

    Write-Host "✅ API 키 검증 완료" -ForegroundColor Green
} catch {
    Write-Host "❌ API 키를 읽는 중 오류가 발생했습니다: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🚀 빌드 시작: $target" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
Write-Host ""

# 빌드 명령어 구성
$buildArgs = @(
    "build",
    $target,
    "--dart-define=GEMINI_API_KEY=$geminiKey",
    "--dart-define=HUGGING_FACE_API_KEY=$hfKey"
)

# 빌드 실행
try {
    flutter @buildArgs

    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
        Write-Host "✅ 빌드 성공!" -ForegroundColor Green
        Write-Host ""

        # 빌드 결과 위치 안내
        switch ($target) {
            "apk" {
                Write-Host "📦 APK 파일 위치:" -ForegroundColor Cyan
                Write-Host "   build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor White
            }
            "appbundle" {
                Write-Host "📦 App Bundle 파일 위치:" -ForegroundColor Cyan
                Write-Host "   build\app\outputs\bundle\release\app-release.aab" -ForegroundColor White
            }
            "ios" {
                Write-Host "📦 iOS 빌드 완료:" -ForegroundColor Cyan
                Write-Host "   build\ios\archive\" -ForegroundColor White
            }
            "web" {
                Write-Host "📦 Web 빌드 완료:" -ForegroundColor Cyan
                Write-Host "   build\web\" -ForegroundColor White
            }
        }
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
        Write-Host "❌ 빌드 실패 (종료 코드: $LASTEXITCODE)" -ForegroundColor Red
        Write-Host ""
        exit $LASTEXITCODE
    }
} catch {
    Write-Host ""
    Write-Host "❌ 빌드 중 오류 발생: $_" -ForegroundColor Red
    Write-Host ""
    exit 1
}
