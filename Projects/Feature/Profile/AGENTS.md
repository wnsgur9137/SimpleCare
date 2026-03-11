# Profile Feature

## 관련 문서
- [MODULES.md](../../../docs/02-설계/MODULES.md) - Profile 모듈 상세 정의 (Profile 섹션 참고)
- [ARCHITECTURE.md](../../../docs/02-설계/ARCHITECTURE.md) - Clean Architecture 패턴

## 구조
- Domain: UserProfile / ProfileUseCases
- Data: ProfileRepository (SwiftData)
- Presentation: TCA Reducer + SwiftUI (사용자 프로필 조회/수정)

## 문서 동기화 규칙
코드 변경 후 아래 문서를 확인하고 필요 시 업데이트:

| 변경 유형 | 업데이트 대상 |
|----------|-------------|
| Entity 추가/수정/삭제 | `docs/02-설계/MODULES.md` → Profile 섹션 |
| UseCase 추가/수정/삭제 | `docs/02-설계/MODULES.md` → Profile 섹션 |
| View/Coordinator 추가 | `docs/02-설계/MODULES.md` → Profile 섹션 |
