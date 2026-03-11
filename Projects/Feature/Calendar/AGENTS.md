# Calendar Feature

## 관련 문서
- [MODULES.md](../../../docs/02-설계/MODULES.md) - Calendar 모듈 상세 정의 (Calendar 섹션 참고)
- [ARCHITECTURE.md](../../../docs/02-설계/ARCHITECTURE.md) - Clean Architecture 패턴

## 구조
- Domain: CalendarUseCases
- Presentation: TCA Reducer + SwiftUI (캘린더 기반 기록 조회)

## 문서 동기화 규칙
코드 변경 후 아래 문서를 확인하고 필요 시 업데이트:

| 변경 유형 | 업데이트 대상 |
|----------|-------------|
| Entity 추가/수정/삭제 | `docs/02-설계/MODULES.md` → Calendar 섹션 |
| UseCase 추가/수정/삭제 | `docs/02-설계/MODULES.md` → Calendar 섹션 |
| View/Coordinator 추가 | `docs/02-설계/MODULES.md` → Calendar 섹션 |
