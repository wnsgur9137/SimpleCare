---
title: "API 연동 명세"
aliases: ["API"]
tags:
  - 구현
  - 구현/API
created: 2026-01-26
updated: 2026-03-24
status: active
---

# SimpleCare API 문서

## 목차
1. [Google Gemini API 연동](#google-gemini-api-연동)
2. [AI 프롬프트 설계](#ai-프롬프트-설계)
3. [응답 스키마](#응답-스키마)
4. [에러 처리](#에러-처리)

---

## Google Gemini API 연동

### 개요
SimpleCare는 Google Gemini API (무료 티어)를 사용하여 음식 영양소 추정 및 일일 인사이트 생성을 수행합니다. 이미지 분석 기능은 Phase 6으로 연기되었습니다.

### 무료 티어 한도
| 항목 | 한도 |
|------|------|
| 요청 | 5~15 RPM (모델별 상이) |
| 일일 요청 | 최대 1,000회 |
| 토큰 | 분당 250,000 토큰 |
| 비용 | 완전 무료, 신용카드 불필요 |

### 설정

#### API Key 관리
```
XCConfig/DEV.xcconfig:
GEMINI_API_KEY = your-gemini-api-key-here

XCConfig/PROD.xcconfig:
GEMINI_API_KEY = $(GEMINI_API_KEY)
```

#### API Key 발급
1. [Google AI Studio](https://aistudio.google.com/)에 접속
2. "Get API key" 클릭
3. 새 API Key 생성 (무료, 신용카드 불필요)

#### Info.plist 설정
```xml
<key>GeminiAPIKey</key>
<string>$(GEMINI_API_KEY)</string>
```

#### 코드에서 로드
```swift
let apiKey = Bundle.main.infoDictionary?["GeminiAPIKey"] as? String
```

### 엔드포인트

| 기능 | 엔드포인트 | 모델 |
|-----|-----------|------|
| 텍스트 분석 | `POST /v1beta/models/{model}:generateContent` | gemini-2.5-flash |
| 이미지 분석 | `POST /v1beta/models/{model}:generateContent` | gemini-2.5-flash |
| 일일 인사이트 | `POST /v1beta/models/{model}:generateContent` | gemini-2.5-flash-lite |

**Base URL**: `https://generativelanguage.googleapis.com`
**인증**: `?key={apiKey}` 쿼리 파라미터

### 요청 형식

```json
{
  "systemInstruction": {
    "parts": [{"text": "시스템 프롬프트"}]
  },
  "contents": [
    {
      "role": "user",
      "parts": [{"text": "사용자 메시지"}]
    }
  ],
  "generationConfig": {
    "temperature": 0.3,
    "maxOutputTokens": 1500,
    "responseMimeType": "application/json"
  }
}
```

### 이미지 포함 요청 형식

```json
{
  "systemInstruction": {
    "parts": [{"text": "시스템 프롬프트"}]
  },
  "contents": [
    {
      "role": "user",
      "parts": [
        {"text": "사용자 메시지"},
        {
          "inlineData": {
            "mimeType": "image/jpeg",
            "data": "base64-encoded-image-data"
          }
        }
      ]
    }
  ],
  "generationConfig": {
    "temperature": 0.3,
    "maxOutputTokens": 2000,
    "responseMimeType": "application/json"
  }
}
```

---

## AI 프롬프트 설계

### 1. 영양소 추정 (텍스트 입력)

#### System Prompt
```
You are a nutrition expert assistant for a Korean health app.
Your task is to estimate nutritional information for foods described by users.

Rules:
1. Always respond in JSON format
2. Estimate based on typical Korean serving sizes
3. If uncertain, provide your best estimate with lower confidence
4. Include all required fields in the response
5. Use Korean food names when the input is in Korean
```

#### User Prompt Template
```
Estimate the nutritional information for the following food:
"{user_input}"

Respond in the following JSON format:
{
  "foods": [
    {
      "name": "Food name",
      "servingSize": 100,
      "servingUnit": "g",
      "calories": 0,
      "protein": 0.0,
      "carbs": 0.0,
      "fat": 0.0,
      "fiber": 0.0,
      "sodium": 0.0,
      "confidence": 0.0
    }
  ],
  "error": null
}
```

#### 예시

**입력**:
```
김치찌개 1인분, 공기밥
```

**응답**:
```json
{
  "foods": [
    {
      "name": "김치찌개",
      "servingSize": 300,
      "servingUnit": "g",
      "calories": 180,
      "protein": 12.0,
      "carbs": 8.0,
      "fat": 10.0,
      "fiber": 2.5,
      "sodium": 1200.0,
      "confidence": 0.85
    },
    {
      "name": "공기밥",
      "servingSize": 210,
      "servingUnit": "g",
      "calories": 313,
      "protein": 5.3,
      "carbs": 68.0,
      "fat": 0.5,
      "fiber": 1.0,
      "sodium": 5.0,
      "confidence": 0.95
    }
  ],
  "error": null
}
```

---

### 2. 이미지 분석 (미구현 — Phase 6 예정)

> ⚠️ 이 기능은 Phase 6으로 연기되었으며, 현재 미구현 상태입니다. 인프라(`generateContentWithVision`)는 준비되어 있습니다.

#### System Prompt
```
You are a nutrition expert assistant that analyzes food images.
Identify all visible foods in the image and estimate their nutritional information.

Rules:
1. Identify each distinct food item visible in the image
2. Estimate portion sizes based on visual cues
3. Provide nutritional estimates for each food
4. If you cannot identify a food, describe it and provide a general estimate
5. Always respond in JSON format
```

#### User Prompt Template
```
Analyze this food image and estimate the nutritional information for all visible foods.

Respond in the following JSON format:
{
  "foods": [
    {
      "name": "Food name",
      "servingSize": 100,
      "servingUnit": "g",
      "calories": 0,
      "protein": 0.0,
      "carbs": 0.0,
      "fat": 0.0,
      "fiber": 0.0,
      "sodium": 0.0,
      "confidence": 0.0
    }
  ],
  "error": null
}
```

---

### 3. AI 인사이트 생성

#### System Prompt
```
You are a friendly health coach providing brief daily insights.
Generate a short, encouraging comment about the user's daily nutrition intake.

Rules:
1. Keep the response under 50 characters in Korean
2. Be positive and encouraging
3. Focus on one key insight
4. Use simple, friendly language
```

#### User Prompt Template
```
User's daily summary:
- Target calories: {target}kcal
- Consumed calories: {consumed}kcal
- Remaining: {remaining}kcal
- Protein: {protein}g
- Carbs: {carbs}g
- Fat: {fat}g

Generate a brief Korean comment (under 50 chars).
```

#### 예시 응답
```
"단백질 섭취가 훌륭해요! 조금만 더 화이팅!"
"균형 잡힌 식단이에요. 잘하고 있어요!"
"탄수화물이 조금 부족해요. 간식으로 보충해볼까요?"
```

---

## 응답 스키마

### MealEstimationResult
```swift
public struct MealEstimationResult: Codable, Equatable {
    public let foods: [EstimatedFoodItem]
    public let error: String?
}
```

### EstimatedFoodItem
```swift
public struct EstimatedFoodItem: Codable, Equatable, Identifiable {
    public var id: UUID { UUID() }
    public let name: String
    public let servingSize: Double
    public let servingUnit: String
    public let calories: Int
    public let protein: Double
    public let carbs: Double
    public let fat: Double
    public let fiber: Double
    public let sodium: Double
    public let confidence: Double
}
```

### Confidence 레벨

| 범위 | 의미 | UI 표시 |
|-----|------|---------|
| 0.9 - 1.0 | 높은 확신 | 표시 없음 |
| 0.7 - 0.9 | 보통 확신 | 표시 없음 |
| 0.5 - 0.7 | 낮은 확신 | 경고 아이콘 |
| 0.0 - 0.5 | 매우 낮음 | 경고 + 메시지 |

---

## 에러 처리

### 에러 유형

```swift
public enum AIServiceError: Error {
    case invalidAPIKey
    case networkError(Error)
    case rateLimitExceeded
    case invalidResponse
    case parsingError
    case imageTooLarge
    case unsupportedImageFormat
    case serverError(Int)
}
```

### HTTP 상태 코드 처리

| 코드 | 의미 | 처리 |
|-----|------|------|
| 200 | 성공 | 응답 파싱 |
| 400 | 잘못된 요청 | 입력 검증 에러 표시 |
| 403 | 인증 실패 | API Key 확인 요청 |
| 429 | Rate Limit | 재시도 안내 (무료 티어 한도 초과) |
| 500 | 서버 에러 | 일시적 오류 안내 |

### 에러 메시지 (사용자용)

```swift
extension AIServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "AI 서비스 설정을 확인해주세요."
        case .networkError:
            return "네트워크 연결을 확인해주세요."
        case .rateLimitExceeded:
            return "잠시 후 다시 시도해주세요."
        case .invalidResponse, .parsingError:
            return "AI 응답을 처리할 수 없습니다."
        case .imageTooLarge:
            return "이미지 크기가 너무 큽니다."
        case .unsupportedImageFormat:
            return "지원하지 않는 이미지 형식입니다."
        case .serverError:
            return "일시적인 오류가 발생했습니다."
        }
    }
}
```

---

## 비용 최적화

### 모델 선택
- 영양 추정: `gemini-2.5-flash` (빠르고 정확)
- 일일 인사이트: `gemini-2.5-flash-lite` (경량, 더 빠른 응답)
- 무료 티어만으로 충분 (일 1,000회 요청)

### 이미지 처리
- 전송 전 이미지 리사이즈 (최대 512px)
- JPEG 압축 (품질 0.7)

### 토큰 제한
- System prompt: ~200 tokens
- User prompt: ~100 tokens
- Max response: 1000 tokens

### JSON 응답 보장
- `responseMimeType: "application/json"` 설정으로 구조화된 JSON 응답 보장
- 기존 `extractJSON()` 파싱 로직과 함께 이중 안전장치

### 캐싱
- 동일 입력에 대한 결과 캐싱 (24시간)
- 자주 사용되는 음식 로컬 DB 저장

---

## 보안 고려사항

### API Key 보안
- Git에 API Key 커밋 금지
- `.gitignore`에 XCConfig 파일 추가
- CI/CD에서 환경변수로 주입

### 데이터 전송
- HTTPS 통신만 사용
- 이미지 데이터 로컬에만 저장
- 개인정보 포함 금지

### 무료 티어 데이터 정책
- Google 무료 티어에서는 전송 데이터가 모델 개선에 사용될 수 있음
- 민감한 개인 건강 데이터 전송 시 유의
- 프롬프트에 개인 식별 정보 포함 금지

### 면책 조항
모든 AI 응답에 다음 면책 문구 표시:
> "AI 추정치이며 실제와 다를 수 있습니다. 의료적 조언이 아닙니다."
