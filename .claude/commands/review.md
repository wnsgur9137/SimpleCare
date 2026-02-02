현재 브랜치의 변경사항을 코드 리뷰합니다.

다음 단계를 수행하세요:

1. `git diff main...HEAD` 로 main 브랜치 대비 모든 변경사항 확인
2. `git log main..HEAD --oneline` 으로 커밋 목록 확인

리뷰 기준:
- **아키텍처 준수**: Clean Architecture 레이어 분리가 올바른지 (Domain ← Data, Domain ← Presentation)
- **TCA 패턴**: Reducer의 State/Action/Effect 구조가 적절한지
- **네이밍 컨벤션**: 프로젝트 네이밍 규칙 준수 여부
- **코드 품질**: 함수 길이(60줄 이내), 파일 길이(500줄 이내), 복잡도
- **SwiftUI 모범 사례**: 뷰 분리, 성능 고려
- **보안**: API 키 노출, 하드코딩된 민감 정보 여부
- **에러 처리**: 적절한 에러 핸들링 여부

리뷰 결과를 우선순위별로 분류하여 출력:
- Critical: 반드시 수정 필요
- Warning: 수정 권장
- Info: 개선 제안
