# NetworkInfra

## 관련 문서
- [ARCHITECTURE.md](../../../docs/02-설계/ARCHITECTURE.md) - Clean Architecture 인프라 계층
- [API.md](../../../docs/03-구현/API.md) - API 연동 명세

## 구조
- Network: Moya/Alamofire 기반 네트워크 클라이언트
- Targets: API 엔드포인트 정의
- Interceptors: 인증, 로깅, 에러 처리

## 문서 동기화 규칙
코드 변경 후 아래 문서를 확인하고 필요 시 업데이트:

| 변경 유형 | 업데이트 대상 |
|----------|-------------|
| API 엔드포인트 추가/변경 | `docs/03-구현/API.md` |
| 네트워크 계층 구조 변경 | `docs/02-설계/ARCHITECTURE.md` |
| 인증/인터셉터 변경 | `docs/03-구현/API.md` |
