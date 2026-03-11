# StorageInfra

## 관련 문서
- [ARCHITECTURE.md](../../../docs/02-설계/ARCHITECTURE.md) - Clean Architecture 인프라 계층
- [MODULES.md](../../../docs/02-설계/MODULES.md) - StorageInfra 모듈 정의

## 구조
- SwiftData: ModelContainer 설정, 마이그레이션
- Repositories: SwiftData 기반 Repository 구현체

## 문서 동기화 규칙
코드 변경 후 아래 문서를 확인하고 필요 시 업데이트:

| 변경 유형 | 업데이트 대상 |
|----------|-------------|
| 스키마/모델 변경 | `docs/02-설계/ARCHITECTURE.md` |
| Repository 구현 추가 | `docs/02-설계/ARCHITECTURE.md` |
| 마이그레이션 추가 | `docs/03-구현/SETUP.md` |
