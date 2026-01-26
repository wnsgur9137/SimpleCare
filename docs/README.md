# SimpleCare 문서

AI 기반 헬스케어 iOS 앱 기술 문서

---

## 문서 목록

| 문서 | 설명 |
|-----|------|
| [SETUP.md](./SETUP.md) | 개발 환경 설정 가이드 |
| [ARCHITECTURE.md](./ARCHITECTURE.md) | 프로젝트 아키텍처 설계 |
| [MODULES.md](./MODULES.md) | 모듈 상세 정의 |
| [API.md](./API.md) | AI API 연동 명세 |
| [ROADMAP.md](./ROADMAP.md) | 개발 로드맵 및 진행 상황 |

---

## 빠른 시작

```bash
# 1. 저장소 클론
git clone https://github.com/wnsgur9137/SimpleCare.git
cd SimpleCare

# 2. 프로젝트 생성
tuist install && tuist generate

# 3. Xcode에서 열기
open SimpleCare.xcworkspace
```

자세한 내용은 [SETUP.md](./SETUP.md)를 참고하세요.

---

## 기술 스택 요약

| 분류 | 기술 |
|-----|------|
| UI | SwiftUI |
| 아키텍처 | Clean Architecture + TCA |
| 상태 관리 | The Composable Architecture (TCA) |
| 데이터 저장 | SwiftData |
| 차트 | Swift Charts |
| AI | OpenAI GPT-4o |
| 빌드 | Tuist |

---

## 주요 기능

- **AI 영양 분석**: 텍스트/사진 입력으로 음식 영양소 자동 추정
- **운동 기록**: MET 기반 칼로리 소모량 계산
- **체중 관리**: 목표 설정 및 추세 분석
- **대시보드**: 일일 영양/운동 요약 시각화

---

## 모듈 구조

```
Application
    └── Features (Tab Coordinator)
            ├── Dashboard
            ├── Meal
            ├── Exercise
            ├── Weight
            ├── Profile
            └── Onboarding
                    └── Infrastructure
                            ├── StorageInfra (SwiftData)
                            ├── AIServiceInfra (OpenAI)
                            └── NetworkInfra (Moya)
```

---

## 면책 조항

> SimpleCare는 건강 관리를 돕기 위한 도구입니다.
> AI 추정치는 참고용이며 의료적 조언이 아닙니다.
> 건강 관련 결정은 반드시 전문가와 상담하세요.
