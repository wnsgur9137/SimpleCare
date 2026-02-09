앱 버전을 관리합니다. 인자로 bump 타입을 받습니다.

사용법: /version [major|minor|patch|build|current]

$ARGUMENTS 값에 따라 실행:

- `current` 또는 인자 없음: `fastlane ios current_version` 실행하여 현재 버전 확인
- `major`: `fastlane ios bump_major` 실행 (X.0.0 증가)
- `minor`: `fastlane ios bump_minor` 실행 (0.X.0 증가)
- `patch`: `fastlane ios bump_patch` 실행 (0.0.X 증가)
- `build`: `fastlane ios bump_build` 실행 (빌드 번호 증가)

실행 후:
1. 변경된 버전 정보를 출력
2. `Tuist/ProjectDescriptionHelpers/Project+Templates.swift` 파일에서 버전이 올바르게 반영되었는지 확인
3. fastlane 스크립트에 의해 버전 변경 커밋이 생성되었는지 확인
