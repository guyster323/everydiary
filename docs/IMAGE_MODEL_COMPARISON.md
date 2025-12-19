# Google AI Studio 이미지 생성 모델 비교

> 작성일: 2025년 12월 19일

---

## 1. 모델 만료일 정보

| 모델 | 상태 | 만료일 |
|------|------|--------|
| `gemini-2.5-flash-image-preview` | ⚠️ Deprecated | **2026년 1월 15일** |
| `gemini-2.0-flash-exp-image-generation` | 🧪 Experimental | 명시 안됨 (실험적 모델은 언제든 종료 가능) |
| `gemini-2.5-flash-image` | ✅ Stable | 없음 (안정 버전) |
| `gemini-3-pro-image-preview` | 🔵 Preview | 없음 (최신) |
| `imagen-4.0-*` | ✅ GA | 없음 (2025년 8월 GA) |

---

## 2. 가격 비교 (이미지 1장당)

| 모델 | 가격 (USD) | 비고 |
|------|------------|------|
| **Imagen 4 Fast** | **$0.02** | 가장 저렴, 빠른 생성 |
| Imagen 3 | $0.03 | Vertex AI 전용 |
| Gemini 2.5 Flash Image | $0.039 | 텍스트+이미지 통합 |
| **Imagen 4** | **$0.04** | 표준 품질 |
| Imagen 4 Ultra | $0.06 | 최고 품질, 2K 해상도 |
| Gemini 3 Pro Image (1K) | $0.134 | 프리미엄 |
| Gemini 3 Pro Image (4K) | $0.24 | 4K 해상도 |

---

## 3. Google AI Studio API에서 사용 가능한 모델

### 테스트 결과 (2025-12-19)

```
✅ 사용 가능 (generateContent 메서드)
- gemini-2.0-flash-exp-image-generation
- gemini-2.5-flash-image-preview (deprecated)
- gemini-2.5-flash-image
- gemini-3-pro-image-preview

❌ 사용 불가 (predict 메서드 - Vertex AI 전용)
- imagen-3.0-generate-002
- imagen-4.0-generate-001
- imagen-4.0-ultra-generate-001
- imagen-4.0-fast-generate-001
```

---

## 4. 현재 상황 및 권장 사항

### 현재 사용 중인 모델
- **모델**: `gemini-2.5-flash-image-preview`
- **만료일**: 2026년 1월 15일
- **상태**: Deprecated

### 추천 대안 (우선순위)

#### 1순위: `gemini-2.5-flash-image` (권장)
- **장점**: Stable 버전, 동일 API 구조, 코드 수정 최소화
- **가격**: $0.039/이미지
- **메서드**: generateContent

#### 2순위: `gemini-2.0-flash-preview-image-generation`
- **장점**: Preview 버전, 활발히 업데이트 중
- **단점**: 일부 유럽/중동/아프리카 지역 제한
- **메서드**: generateContent

#### 3순위: `gemini-3-pro-image-preview`
- **장점**: 최신 모델, 최고 품질
- **단점**: 가격이 비쌈 ($0.134/이미지)
- **메서드**: generateContent

#### Imagen 4 사용 시
- Vertex AI 프로젝트 설정 필요
- Google AI Studio API로는 사용 불가
- predict 메서드 사용

---

## 5. 코드 변경 가이드

### 현재 코드 (변경 전)
```dart
final uri = Uri.parse(
  'https://generativelanguage.googleapis.com/v1beta/models/imagen-3.0-generate-002:predict?key=$apiKey',
);
```

### 권장 변경 (gemini-2.5-flash-image)
```dart
final uri = Uri.parse(
  'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image:generateContent?key=$apiKey',
);

// Request Body
{
  'contents': [
    {
      'parts': [
        {'text': 'Generate an image: $prompt'},
      ],
    },
  ],
  'generationConfig': {
    'responseModalities': ['IMAGE', 'TEXT'],
  },
}

// Response 파싱
candidates[0].content.parts[].inlineData.data (base64)
```

---

## 6. 참고 링크

- [Gemini API Pricing](https://ai.google.dev/gemini-api/docs/pricing)
- [Gemini Models Documentation](https://ai.google.dev/gemini-api/docs/models)
- [Imagen 4 Announcement](https://developers.googleblog.com/en/imagen-4-now-available-in-the-gemini-api-and-google-ai-studio/)
- [Gemini 2.5 Flash Image Introduction](https://developers.googleblog.com/en/introducing-gemini-2-5-flash-image/)
