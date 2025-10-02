# 썸네일/배경 생성 차세대 설계 개요 (2025-09-30)

## 1. 목표

- 사용자 커스터마이징 기반 썸네일/배경 생성 경험을 일관되게 제공
- Gemini ↔ Hugging Face 폴백 흐름을 공통 프롬프트 파이프라인으로 통합
- 대량 배치 처리 및 회귀 모니터링을 지원하는 확장성 있는 아키텍처 수립

## 2. 주요 요구 정리 (출처: `docs/next-steps-2025-09-30.md`)

- **썸네일 스타일 설정 UI 구현**
  - 사용자 정의 옵션(스타일, 수동 키워드)을 `UserCustomizationService`와 연동
  - 설정 화면과 미리보기 위젯을 통해 즉각적 피드백 제공
- **썸네일 생성 배치 처리 최적화**
  - 최근 N개 일기 썸네일을 비동기 큐로 생성, 재시도·백오프 전략 포함
  - 처리 현황 및 실패 이력을 로깅/대시보드로 노출
- **회귀 테스트 및 모니터링 체계 구축**
  - Gemini/Hugging Face 생성 품질 비교를 위한 로그 지표 정의
  - 캐시 히트율/에러율, 프롬프트 성공률을 추적하는 대시보드 설계

## 3. 아키텍처 개략

### 3.1 계층 구조

```
├─ Presentation (UI)
│  ├─ SettingsThumbnailStyleScreen (HookConsumerWidget)
│  └─ ThumbnailPreviewWidget
├─ Application
│  ├─ ThumbnailSettingsController (AsyncNotifier)
│  ├─ BatchGenerationController (AsyncNotifier)
│  └─ RegressionDashboardController (AsyncNotifier)
├─ Domain/Services
│  ├─ ThumbnailPromptBuilder (신규)
│  ├─ ThumbnailBatchService (신규)
│  ├─ ThumbnailMonitoringService (신규)
│  └─ 기존 ImageGenerationService 확장
└─ Infrastructure
   ├─ SharedPreferences (사용자 설정)
   ├─ SQLite (배치 작업 큐 & 로그)
   ├─ Supabase / Analytics Export (옵션)
   └─ Flutter Logs + Crashlytics (에러 모니터링)
```

### 3.2 책임 분배

- **ThumbnailPromptBuilder**
  - `ImageGenerationService`와 `UserCustomizationService`를 주입받아 공통 프롬프트(positive/guideline/negative) 생성
  - Gemini/Hugging Face 모두에서 동일하게 사용할 DTO(`ImagePromptPayload`) 반환
- **ThumbnailBatchService**
  - 최근 N개 일기 대상 큐 생성, 잡 상태 관리(대기/진행/실패/완료)
  - 비동기 처리 및 재시도 지수 백오프 로직 구현
  - 처리 결과를 `ThumbnailMonitoringService`에 이벤트로 전달
- **ThumbnailMonitoringService**
  - 생성 성공/실패, 캐시 히트율, API별 응답 시간, negative prompt 위반율 등을 수집
  - 로그를 구조화하여 Supabase 혹은 로컬 SQLite로 저장, 대시보드 뷰모델에 제공

## 4. UI 플로우 설계

1. **설정 화면 진입**
   - `SettingsThumbnailStyleScreen`에서 Riverpod `AsyncNotifier`를 통해 현재 설정 로드
2. **스타일 선택 & 키워드 커스터마이징**
   - 변경 시 즉시 Preview 영역에 적용되도록 `Throttle` 기반 훅 구현
   - `ThumbnailPromptBuilder`를 호출해 미리보기용 프롬프트·샘플 이미지를 요청
3. **저장/취소 처리**
   - `UserCustomizationService.updateSettings()` 호출로 영속화
   - 변경 시 배치 큐에 “재생성 필요” 플래그를 추가하여 백그라운드 재생성 트리거

## 5. 배치 처리 설계

- **저장 구조**: SQLite `thumbnail_jobs` 테이블 (id, diary_id, status, retry_count, last_error, scheduled_at, processed_at 등)
- **트리거 시점**
  - 신규 일기 저장 시 자동 등록
  - 설정 변경 시 최근 N개 일기 재생성 등록
  - 수동 “전체 재생성” 버튼 제공 (경고/진행 상황 모달 포함)
- **큐 처리 로직**
  - `ThumbnailBatchService`가 Riverpod background isolate 혹은 메인 isolate의 `Timer`로 주기적 실행
  - `ImageGenerationService.generateImageFromText` 호출 → 성공 시 썸네일 캐시 업데이트, 실패 시 재시도 큐 등록

### 5.1 Task 11.4 Implementation Checklist

- **데이터 설계**
  - `thumbnail_jobs` 테이블(또는 마이그레이션) 정의: `id`, `diary_id`, `job_type(enum)`, `status(enum)`, `payload(json)`, `retry_count`, `last_error`, `scheduled_at`, `started_at`, `completed_at`, `created_at`, `updated_at`, `is_deleted` 필드 포함.
  - `DatabaseSchema` 및 `MigrationManager`에 반영하여 기존 사용자 데이터에 안전하게 적용.
- **서비스 레이어**
  - `ThumbnailBatchJob` 및 `ThumbnailJobStatus` 모델 (Freezed) 작성.
  - `ThumbnailBatchRepository` (SQLite CRUD) 구현: `enqueue`, `dequeue`, `markCompleted`, `markFailed`, `pendingJobs` 등 제공.
  - `ThumbnailBatchService` 구현:
    - 사용자 설정/네트워크 상태를 고려한 concurrency 제한(예: 한 번에 1~2개).
    - `ImageGenerationService` 호출 후 `DiaryImageHelper`를 통해 캐시 반영.
    - Retry with exponential backoff, `maxRetryCount` configurable.
- **Provider & Controller**
  - `ThumbnailBatchController` (`AsyncNotifier<List<ThumbnailBatchJob>>`): UI/다이얼로그에서 진행 상황 표시, 수동 트리거 및 리프레시 지원.
  - `BatchWorker` (`Provider.autoDispose`) : 앱 Foreground 중 주기적 실행 (`Timer.periodic` + `ref.onDispose`로 정리).
- **트리거 지점 통합**
  - `DiarySaveService` 저장 완료 후 `ThumbnailBatchRepository.enqueueSingle(diaryId)` 호출.
  - `UserCustomizationSettingsNotifier` 성공 시 `enqueueRebuildForRecentDiaries(limit: N)` 실행.
- **로깅 및 모니터링**
  - `log()` 기반 이벤트: job lifecycle, error stack.
  - 실패 시 `last_error` 저장 및 UI에서 `SelectableText.rich`로 노출.
- **테스트 전략**
  - Repository 메서드 단위 테스트: enqueue/dequeue/cleanup 로직.
  - Service 레벨: Mock `ImageGenerationService`로 성공/실패 경로 검증.
  - Provider smoke test: `ThumbnailBatchController` 상태 전이 확인.

## 6. 모니터링 및 회귀 테스트 계획

- **지표 정의**
  - 성공률, 실패 사유(네트워크, quota, 프롬프트 오류 등)
  - Gemini ↔ Hugging Face 폴백 발생 비율
  - negative prompt 위반 여부(텍스트 감지)
  - 캐시 히트율, 평균 처리 시간
- **도구**
  - Flutter `log` + remote logging(Supabase, Firebase Crashlytics) 연동
  - 내장 대시보드(설정 화면 내 “품질 리포트” 링크) → `RegressionDashboardController`가 데이터를 시각화
- **회귀 테스트**
  - 주요 일기 샘플 세트를 고정하여 정기적(예: 주간)으로 이미지 생성 후 시각적 리뷰
  - 자동화: negative prompt 위반 여부는 OCR/Text detection으로 1차 필터링

## 7. 후속 작업 가이드

- `task 11.3~11.5`에 해당하는 구현을 진행할 때 본 설계 문서를 참조
- PR 작성 시 본 문서를 링크하고, 구현 범위 대비 변경 사항을 요약
- 필요 시 PRD 업데이트(`.taskmaster/docs/prd.txt`) 또는 TaskMaster 태스크 확장(`expand_task --id=11`) 실행
