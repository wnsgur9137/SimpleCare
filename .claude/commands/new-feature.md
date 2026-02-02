새로운 Feature 모듈의 기본 구조를 생성합니다.

사용법: /new-feature [모듈이름]

$ARGUMENTS 에서 모듈 이름을 추출하세요.

다음 Clean Architecture 구조로 파일을 생성합니다:

```
Projects/Feature/[모듈이름]/
├── Domain/
│   └── Sources/
│       ├── Entity/
│       │   └── [모듈이름]Entity.swift
│       ├── UseCase/
│       │   └── [모듈이름]UseCase.swift
│       └── Repository/
│           └── [모듈이름]RepositoryProtocol.swift
├── Data/
│   └── Sources/
│       ├── Repository/
│       │   └── [모듈이름]Repository.swift
│       └── Model/
│           └── [모듈이름]DTO.swift
├── Presentation/
│   └── Sources/
│       ├── View/
│       │   └── [모듈이름]View.swift
│       ├── Reducer/
│       │   └── [모듈이름]Reducer.swift
│       ├── Coordinator/
│       │   └── [모듈이름]Coordinator.swift
│       └── DIContainer/
│           └── [모듈이름]DIContainer.swift
└── Project.swift
```

각 파일 생성 시 규칙:
1. 기존 Feature 모듈(예: Meal, Exercise)의 패턴을 참고하여 동일한 스타일로 작성
2. TCA Reducer 패턴 적용 (State, Action, body)
3. Repository 프로토콜은 Domain 레이어에, 구현은 Data 레이어에 배치
4. Coordinator는 ObservableObject 기반
5. DIContainer는 Factory 패턴으로 의존성 생성
6. Project.swift는 기존 모듈의 Project.swift를 참고하여 작성

생성 완료 후:
- 생성된 파일 목록 출력
- Tuist 프로젝트 재생성 필요 여부 안내
