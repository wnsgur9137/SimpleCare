# SimpleCare iOS 프로젝트 스타일 가이드

## 개요

이 스타일 가이드는 SimpleCare iOS 애플리케이션의 코드 일관성, 가독성, 유지보수성을 보장하기 위한 가이드라인입니다.
모든 개발자는 이 가이드라인을 준수하여 Clean Architecture 기반의 모듈화된 코드를 작성해야 합니다.

## 핵심 원칙

1. **가독성**: 코드는 자명해야 하며, 의도가 명확히 드러나야 합니다
2. **일관성**: 프로젝트 전반에 걸쳐 일관된 코딩 스타일을 유지합니다
3. **모듈화**: Clean Architecture 원칙에 따라 레이어를 분리합니다
4. **테스트 가능성**: 모든 비즈니스 로직은 테스트 가능하도록 작성합니다
5. **성능**: 메모리 효율성과 배터리 소모를 고려합니다

## 프로젝트 아키텍처

### Clean Architecture 레이어
- **Domain**: 비즈니스 로직과 엔티티 (BaseDomain, *Domain 타겟)
- **Data**: 데이터 접근 및 Repository 구현 (BaseData, *Data 타겟)
- **Presentation**: UI 및 화면 로직 (BasePresentation, *Presentation 타겟)

### 의존성 방향
```
Presentation → Domain ← Data
```
- Presentation과 Data는 Domain에만 의존
- Domain은 다른 레이어에 의존하지 않음

## Swift 코딩 컨벤션

### 네이밍 규칙

#### 구조체 및 프로토콜 (PascalCase)
```swift
// ✅ 올바른 예시
struct UserRepository { }
struct CareItemModel { }
protocol UserRepositoryType { }

// ❌ 잘못된 예시
struct userRepository { }
struct care_item_model { }
```

#### 변수 및 함수 (camelCase)
```swift
// ✅ 올바른 예시
let defaultTimeout: TimeInterval = 30.0
func fetchUserData() -> User { }
var isLoading: Bool = false

// ❌ 잘못된 예시
let default_timeout: TimeInterval = 30.0
func fetch_user_data() -> User { }
```

#### 상수 (camelCase)
```swift
// ✅ 올바른 예시
private let apiBaseURL = "https://api.example.com"
static let defaultPageSize = 20

// ❌ 잘못된 예시
private let API_BASE_URL = "https://api.example.com"
static let DEFAULT_PAGE_SIZE = 20
```

#### 열거형 (PascalCase, case는 camelCase)
```swift
// ✅ 올바른 예시
enum NetworkError: Error {
    case noInternetConnection
    case serverError(String)
    case invalidResponse
}

// ❌ 잘못된 예시
enum NetworkError: Error {
    case NoInternetConnection
    case server_error(String)
}
```

### 들여쓰기 및 공백
- 들여쓰기: 4개의 스페이스 사용 (탭 금지)
- 함수 매개변수가 길 경우 줄바꿈:
```swift
// ✅ 올바른 예시
func fetchUserData(
    userId: String,
    includeDetails: Bool,
    completion: @escaping (Result<User, NetworkError>) -> Void
) {
    // 구현
}
```

### 타입 어노테이션
```swift
// ✅ 올바른 예시 - 명시적 타입 지정
let items: [CareItem] = []
var isLoading: Bool = false

// ✅ 타입 추론 가능한 경우
let userName = "홍길동"
```

### 옵셔널 처리
```swift
// ✅ Guard 문 사용 권장
guard let user = selectedUser else {
    return
}

// ✅ Nil 병합 연산자 활용
let userName = user?.name ?? "알 수 없음"

// ❌ 강제 언래핑 금지
let name = user!.name
```

## 파일 구조 및 모듈화

### 디렉토리 구조
```
Feature/
├── Home/
│   ├── Project.swift        # Tuist 프로젝트 정의 (Data, Domain, Presentation 타겟 포함)
│   ├── Data/Sources/        # Repository 구현, DTO
│   ├── Domain/Sources/      # UseCase, Entity, Repository 인터페이스
│   ├── Presentation/Sources/# View, Reducer
│   └── Sources/             # Aggregator
```

### 파일 네이밍
- 파일명은 포함된 주요 타입명과 일치
- 접미사로 역할 구분: `*Repository.swift`, `*UseCase.swift`, `*Reducer.swift`, `*View.swift`

```swift
// ✅ 올바른 예시
UserRepository.swift          // protocol UserRepository
DefaultUserRepository.swift   // struct DefaultUserRepository
UserUseCase.swift             // protocol UserUseCase
HomeReducer.swift             // @Reducer struct HomeReducer
HomeView.swift                // struct HomeView: View
```

## 아키텍처 패턴

### TCA (The Composable Architecture) Reducer
```swift
// ✅ 올바른 예시
@Reducer
struct HomeReducer {
    @ObservableState
    struct State: Equatable {
        var isLoading: Bool = false
        var items: [CareItem] = []
        var errorMessage: String?
    }

    enum Action {
        case onAppear
        case fetchItems
        case fetchItemsResponse(Result<[CareItem], Error>)
    }

    @Dependency(\.careItemClient) var careItemClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.fetchItems)

            case .fetchItems:
                state.isLoading = true
                return .run { send in
                    let result = await Result {
                        try await careItemClient.fetchItems()
                    }
                    await send(.fetchItemsResponse(result))
                }

            case .fetchItemsResponse(.success(let items)):
                state.isLoading = false
                state.items = items
                return .none

            case .fetchItemsResponse(.failure(let error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
            }
        }
    }
}
```

### SwiftUI View with Store
```swift
// ✅ 올바른 예시
struct HomeView: View {
    let store: StoreOf<HomeReducer>

    var body: some View {
        WithPerceptionTracking {
            List {
                ForEach(store.items) { item in
                    CareItemRow(item: item)
                }
            }
            .overlay {
                if store.isLoading {
                    ProgressView()
                }
            }
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}
```

### DI - TCA Dependency 사용
```swift
// ✅ 올바른 예시
struct CareItemClient {
    var fetchItems: @Sendable () async throws -> [CareItem]
    var fetchItem: @Sendable (String) async throws -> CareItem
}

extension CareItemClient: DependencyKey {
    static let liveValue = CareItemClient(
        fetchItems: {
            // 실제 네트워크 호출
        },
        fetchItem: { id in
            // 실제 네트워크 호출
        }
    )

    static let testValue = CareItemClient(
        fetchItems: { [] },
        fetchItem: { _ in .mock() }
    )
}

extension DependencyValues {
    var careItemClient: CareItemClient {
        get { self[CareItemClient.self] }
        set { self[CareItemClient.self] = newValue }
    }
}
```

## 네트워킹

### Moya TargetType 사용
```swift
// ✅ 올바른 예시
enum CareAPI: TargetType {
    case getItems
    case getItemDetail(id: String)

    var path: String {
        switch self {
        case .getItems:
            return "/items"
        case .getItemDetail(let id):
            return "/items/\(id)"
        }
    }
}
```

### async/await 에러 처리
```swift
// ✅ 올바른 예시
func fetchItems() async throws -> [CareItem] {
    do {
        let response = try await provider.request(.getItems)
        return try JSONDecoder().decode([CareItem].self, from: response.data)
    } catch {
        throw NetworkError.fetchFailed
    }
}
```

## 주석 및 문서화

### 함수 문서화
```swift
// ✅ 올바른 예시
/// 사용자의 케어 아이템 목록을 가져옵니다
/// - Parameter userId: 조회할 사용자 ID
/// - Returns: CareItem 배열
func fetchItems(userId: String) async throws -> [CareItem] {
    // 구현
}
```

### 코드 주석
```swift
// ✅ 올바른 예시 - 비즈니스 로직 설명
// 무료 사용자는 최대 5개의 아이템만 등록 가능
let maxItemsForFreeUser = 5

// ❌ 잘못된 예시 - 자명한 코드 설명
// 아이템 배열을 생성
let items: [CareItem] = []
```

## 테스트 가이드라인

### TCA Reducer 테스트
```swift
// ✅ 올바른 예시
@MainActor
func test_fetchItems_성공시_아이템목록반환() async {
    let store = TestStore(initialState: HomeReducer.State()) {
        HomeReducer()
    } withDependencies: {
        $0.careItemClient.fetchItems = { [CareItem.mock()] }
    }

    await store.send(.fetchItems) {
        $0.isLoading = true
    }

    await store.receive(.fetchItemsResponse(.success([CareItem.mock()]))) {
        $0.isLoading = false
        $0.items = [CareItem.mock()]
    }
}
```

## 금지 사항

1. **강제 언래핑**: `!` 연산자 사용 금지
2. **하드코딩된 문자열**: Localizable.strings 사용 필수
3. **레이어 간 부적절한 의존성**: Domain이 Presentation/Data에 의존 금지
4. **@ObservedObject 직접 사용**: TCA Store를 통해 상태 관리

## 권장 도구

- **의존성 관리**: Swift Package Manager (SPM)
- **프로젝트 관리**: Tuist
- **아키텍처**: The Composable Architecture (TCA)
- **네트워킹**: Moya + Alamofire
- **UI 프레임워크**: SwiftUI

이 가이드라인을 따라 일관성 있고 유지보수 가능한 코드를 작성해주세요.
