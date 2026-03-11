# Settings Feature

## 관련 문서
- [MODULES.md](../../../docs/02-설계/MODULES.md) - Settings 모듈 상세 정의 (Settings 섹션 참고)
- [ARCHITECTURE.md](../../../docs/02-설계/ARCHITECTURE.md) - Clean Architecture 패턴

## 구조
- Domain: (minimal - 설정 관련 로직)
- Data: (minimal - UserDefaults 기반 설정 저장)
- Presentation: TCA Reducer + SwiftUI (테마, 언어, 알림, 데이터 내보내기 등)
