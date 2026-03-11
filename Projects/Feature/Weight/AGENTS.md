# Weight Feature

## 관련 문서
- [MODULES.md](../../../docs/02-설계/MODULES.md) - Weight 모듈 상세 정의 (Weight 섹션 참고)
- [ARCHITECTURE.md](../../../docs/02-설계/ARCHITECTURE.md) - Clean Architecture 패턴

## 구조
- Domain: WeightRecord / WeightUseCases
- Data: WeightRepository (SwiftData)
- Presentation: TCA Reducer + SwiftUI (체중 추적 & 목표 관리)
