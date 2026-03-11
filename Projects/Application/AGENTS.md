# Application

## 관련 문서
- [ARCHITECTURE.md](../../../docs/02-설계/ARCHITECTURE.md) - Clean Architecture, Coordinator 계층 구조

## 구조
- AppCoordinator: 최상위 Coordinator (Splash → Onboarding → Tab 분기)
- DIContainer: 루트 의존성 주입 컨테이너
- App Entry Point: SwiftUI App 진입점

## 문서 동기화 규칙
코드 변경 후 아래 문서를 확인하고 필요 시 업데이트:

| 변경 유형 | 업데이트 대상 |
|----------|-------------|
| Coordinator 플로우 변경 | `docs/02-설계/ARCHITECTURE.md` |
| DIContainer 구조 변경 | `docs/02-설계/ARCHITECTURE.md` |
| 앱 설정/Config 변경 | `docs/03-구현/SETUP.md` |
