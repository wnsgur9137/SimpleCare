# HealthKitInfra

## 관련 문서
- [ARCHITECTURE.md](../../../docs/02-설계/ARCHITECTURE.md) - Clean Architecture 인프라 계층

## 구조
- HealthKit: HealthKit 데이터 읽기/쓰기 서비스
- Services: 걸음 수, 활동 에너지 등 건강 데이터 연동

## 문서 동기화 규칙
코드 변경 후 아래 문서를 확인하고 필요 시 업데이트:

| 변경 유형 | 업데이트 대상 |
|----------|-------------|
| HealthKit 데이터 타입 추가 | `docs/02-설계/ARCHITECTURE.md` |
| 서비스 인터페이스 변경 | `docs/02-설계/ARCHITECTURE.md` |
