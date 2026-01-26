# SimpleCare 개발 환경 설정

## 목차
1. [요구 사항](#요구-사항)
2. [설치](#설치)
3. [프로젝트 생성](#프로젝트-생성)
4. [API Key 설정](#api-key-설정)
5. [빌드 및 실행](#빌드-및-실행)
6. [문제 해결](#문제-해결)

---

## 요구 사항

### 필수 소프트웨어

| 소프트웨어 | 버전 | 설명 |
|-----------|------|------|
| macOS | 15.0+ | Sequoia |
| Xcode | 16.0+ | Swift 6.0 지원 |
| Tuist | 4.x | 프로젝트 생성 |
| mise | 최신 | 버전 관리 (선택) |

### 설치 확인
```bash
# Xcode 버전 확인
xcodebuild -version

# Tuist 버전 확인
tuist version

# mise 버전 확인 (선택)
mise --version
```

---

## 설치

### 1. Tuist 설치

**Homebrew 사용**:
```bash
brew install tuist
```

**mise 사용**:
```bash
mise install tuist
```

### 2. 저장소 클론
```bash
git clone https://github.com/wnsgur9137/SimpleCare.git
cd SimpleCare
```

### 3. mise 설정 (선택)
```bash
# .mise.toml 기반 자동 설정
mise install
mise trust
```

---

## 프로젝트 생성

### Tuist 명령어

```bash
# 의존성 설치 및 프로젝트 생성
tuist install
tuist generate

# 또는 Makefile 사용
make generate
```

### 생성 결과
- `SimpleCare.xcworkspace` 생성
- 모든 Feature/Infrastructure 모듈 프로젝트 생성
- SPM 패키지 연결

### 프로젝트 열기
```bash
open SimpleCare.xcworkspace
```

---

## API Key 설정

### OpenAI API Key

1. [OpenAI Platform](https://platform.openai.com/)에서 API Key 발급

2. XCConfig 파일 생성
```bash
# Debug 설정
echo 'OPENAI_API_KEY = sk-your-api-key-here' >> XCConfig/Debug.xcconfig

# Release 설정 (CI/CD용)
echo 'OPENAI_API_KEY = $(OPENAI_API_KEY)' >> XCConfig/Release.xcconfig
```

3. `.gitignore` 확인
```
# XCConfig 파일 중 민감 정보 포함된 파일
XCConfig/Debug.xcconfig
```

### 환경 변수로 설정 (CI/CD)
```bash
export OPENAI_API_KEY=sk-your-api-key-here
```

---

## 빌드 및 실행

### Xcode에서 빌드

1. `SimpleCare.xcworkspace` 열기
2. Scheme 선택: `Application`
3. 시뮬레이터/기기 선택
4. `Cmd + R` 실행

### 커맨드라인 빌드

```bash
# 전체 빌드
make build

# 또는 직접 실행
xcodebuild build \
  -workspace SimpleCare.xcworkspace \
  -scheme Application \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

### 특정 모듈만 빌드
```bash
# Meal 모듈만 빌드
xcodebuild build \
  -workspace SimpleCare.xcworkspace \
  -scheme Meal \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

---

## Makefile 명령어

```bash
# 프로젝트 생성
make generate

# 빌드
make build

# 클린
make clean

# 전체 초기화
make reset

# 의존성 그래프 생성
make graph

# SwiftLint 실행
make lint

# SwiftFormat 실행
make format
```

---

## 문제 해결

### 1. Tuist 생성 실패

**증상**: `tuist generate` 실패

**해결**:
```bash
# Tuist 캐시 정리
tuist clean

# Xcode 프로세스 종료
killall Xcode

# DerivedData 삭제
rm -rf ~/Library/Developer/Xcode/DerivedData

# 재생성
tuist generate
```

### 2. PIF Transfer Session 오류

**증상**:
```
Could not compute dependency graph: MsgHandlingError... PIF transfer session
```

**해결**:
```bash
killall Xcode
tuist clean
rm -rf ~/Library/Developer/Xcode/DerivedData
tuist generate
```

### 3. Swift 헤더 빌드 오류

**증상**:
```
MealData-Swift.h not found
```

**해결**:
이미 `Project+Templates.swift`에 설정되어 있음:
```swift
"SWIFT_INSTALL_OBJC_HEADER": "NO"
```

### 4. API Key 오류

**증상**: AI 기능 동작 안함

**확인**:
```swift
// AppDelegate 또는 디버그 코드에서 확인
print(Bundle.main.infoDictionary?["OpenAIAPIKey"] as? String ?? "Not found")
```

**해결**:
- `XCConfig/Debug.xcconfig` 파일 확인
- API Key 형식 확인 (sk- 로 시작)
- OpenAI 계정 크레딧 확인

### 5. SwiftData 마이그레이션 오류

**증상**: 앱 시작 시 크래시

**해결**:
```bash
# 시뮬레이터 데이터 삭제
xcrun simctl erase all

# 또는 앱 삭제 후 재설치
```

### 6. 의존성 충돌

**증상**: SPM 패키지 버전 충돌

**해결**:
```bash
# 패키지 캐시 삭제
rm -rf ~/Library/Caches/org.swift.swiftpm
rm -rf .build

# Tuist 캐시 삭제
tuist clean

# 재설치
tuist install
tuist generate
```

---

## 디렉토리 구조

```
SimpleCare/
├── .git/                    # Git 저장소
├── .github/                 # GitHub 설정 (PR 템플릿 등)
├── .swiftformat             # SwiftFormat 설정
├── .swiftlint.yml           # SwiftLint 설정
├── Makefile                 # 빌드 스크립트
├── Workspace.swift          # Tuist 워크스페이스 정의
├── Tuist/
│   ├── Config.swift         # Tuist 설정
│   ├── Package.swift        # SPM 의존성
│   └── ProjectDescriptionHelpers/
│       ├── Dependencies/    # 의존성 정의
│       └── Templates/       # 프로젝트 템플릿
├── XCConfig/
│   ├── Debug.xcconfig       # 디버그 빌드 설정
│   └── Release.xcconfig     # 릴리즈 빌드 설정
├── Projects/
│   ├── Application/         # 앱 타겟
│   ├── Feature/             # Feature 모듈
│   ├── Infrastructure/      # Infrastructure 모듈
│   ├── LibraryManager/      # 외부 라이브러리 래퍼
│   └── InjectionManager/    # DI 관리
├── docs/                    # 문서
└── graphs/                  # 의존성 그래프
```

---

## IDE 설정

### Xcode 권장 설정

1. **Editor**
   - Show Line Numbers: ON
   - Show Invisibles: ON

2. **Text Editing**
   - Automatically trim trailing whitespace: ON
   - Including whitespace-only lines: ON

3. **Source Control**
   - Enable Source Control: ON

### SwiftLint/SwiftFormat

프로젝트 루트의 설정 파일 사용:
- `.swiftlint.yml`
- `.swiftformat`

빌드 시 자동 실행됨 (Build Phase 설정)

---

## 추가 도구

### 의존성 그래프 생성
```bash
tuist graph --format png --output-path graphs/
```

### 모듈 의존성 시각화
```bash
tuist graph --targets Application --format png
```

---

## 참고 링크

- [Tuist 공식 문서](https://docs.tuist.io)
- [SwiftLint 규칙](https://realm.github.io/SwiftLint/rule-directory.html)
- [SwiftFormat 옵션](https://github.com/nicklockwood/SwiftFormat)
- [OpenAI API 문서](https://platform.openai.com/docs)
