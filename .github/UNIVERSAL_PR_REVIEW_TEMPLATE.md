# PR 리뷰 템플릿

## 전체 평가 형식

```markdown
## 🎯 자동화된 코드 리뷰 - PR #{number}

**제목:** {PR 제목}
**변경사항:** {간략한 요약} ({additions}줄 추가, {deletions}줄 삭제)
**설정 기반 분석:** `.github/codereview-config.json` 규칙 적용

---

## 📊 코드 품질 지표 (설정 기반 분석)

### ✅ **코딩 컨벤션 준수도: {score}/10**
- **PascalCase**: 클래스/구조체 {상태} ({예시})
- **camelCase**: 변수/함수 {상태} ({예시})
- **Enum Cases**: {상태} ({예시})

### 🏗️ **아키텍처 준수도: {score}/10**
- **레이어 분리**: {상태} ({세부사항})
- **의존성 방향**: {상태} ({아키텍처_패턴})
- **패턴 일관성**: {상태} ({사용된_패턴들})

### 🎨 **디자인 시스템 구현도: {score}/10**
- **브랜딩 일관성**: {상태} ({색상_사용})
- **컴포넌트 라이브러리**: {상태} ({사용된_컴포넌트들})
- **스타일링 패턴**: {상태} ({스타일링_접근법})

### 🔧 **코드 구현 품질: {score}/10**

#### ✅ **우수한 점들**
1. **{카테고리}**
   ```swift
   // 좋은 구현 예시
   {코드_예시}
   ```

2. **{카테고리}**
   ```swift
   // 다른 예시
   {코드_예시}
   ```

#### ⚠️ **개선이 필요한 영역**

1. **{이슈 카테고리}** (설정 규칙: {규칙_이름})
   ```swift
   // {줄번호}줄: 문제점 설명
   {문제있는_코드}

   // 권장사항
   {권장_해결책}
   ```

### 💾 **메모리 관리: {score}/10**
- **순환 참조**: {상태} ({세부사항})
- **리소스 관리**: {상태} ({세부사항})

### 🧪 **테스트 고려사항: {score}/10**
- **테스트 커버리지**: {커버리지}% (목표: {목표}%)
- **테스트 품질**: {상태} ({세부사항})

---

## 🏆 **전체 평가: {전체_점수}/10**

### 🚀 **뛰어난 성과**
- {성과_1}
- {성과_2}
- {성과_3}

### 🎯 **권장 조치사항**

1. **높은 우선순위**
   ```swift
   // {설명}
   {코드_예시}
   ```

2. **중간 우선순위**
   ```swift
   // {설명}
   {코드_예시}
   ```

3. **향후 개선사항**
   - {개선사항_1}
   - {개선사항_2}

---

## 📈 **{프로젝트타입} 모범 사례 준수도: {준수도_점수}%**

**결론:** {결론_진술}
```

## 라인별 댓글 템플릿

### 1. 다국어화 필요 (범용)
```markdown
**다국어화 필요** 🌐

하드코딩된 문자열은 유지보수성을 해칩니다. 국제화를 위해 리소스 파일을 사용해주세요.

```swift
// 권장사항 (iOS)
case .home: return NSLocalizedString("tab.home.title", comment: "홈 탭 제목")
```
```

### 2. 아키텍처 위반 (범용)
```markdown
**아키텍처 레이어 위반** 🏗️

{레이어} 레이어에서 {대상} 레이어를 직접 참조하고 있습니다. 의존성 방향을 확인해주세요.

```swift
// 문제: Data 레이어가 Presentation을 import
import SomePresentation

// 권장사항: 인터페이스를 통한 의존성 역전
protocol SomeRepositoryInterface {
    // Domain 레이어에 인터페이스 정의
}
```
```

### 3. 메모리 관리 (범용)
```markdown
**메모리 관리 개선** 🔄

강한 참조로 인한 순환 참조 가능성이 있습니다. 약한 참조 사용을 권장합니다.

```swift
// 문제점
public var delegate: SomeDelegate?

// 권장사항
public weak var delegate: SomeDelegate?

// 클로저에서의 약한 참조
someService.performAction { [weak self] result in
    self?.handleResult(result)
}
```
```

### 4. 성능 최적화 (범용)
```markdown
**성능 최적화 권장** ⚡

{구체적인_이슈_설명}

```swift
// 현재 구현
{현재_코드}

// 최적화 방안
{최적화된_코드}
```

**예상 개선 효과:**
- 메모리 사용량: {메모리_개선율}
- 실행 시간: {성능_개선율}
```

### 5. 보안 이슈 (범용)
```markdown
**보안 취약점** 🔒

{보안_이슈_설명}

```swift
// 취약한 코드
{취약한_코드}

// 보안 개선
{보안_강화_코드}
```

**보안 가이드라인:**
- API 키는 환경 변수 또는 보안 저장소 사용
- 사용자 데이터는 암호화하여 저장
- 네트워크 통신은 HTTPS 사용
```

### 6. 테스트 커버리지 (범용)
```markdown
**테스트 커버리지 부족** 🧪

새로운 비즈니스 로직에 대한 테스트가 누락되었습니다.

```swift
// 테스트 대상
{프로덕션_코드}

// 권장 테스트
class {클래스명}Tests: XCTestCase {
    func test{함수명}_when{조건}_should{예상결과}() {
        // Given (준비)
        // When (실행)
        // Then (검증)
    }
}
```
```

## 플랫폼별 템플릿

### iOS/Swift 특화
```markdown
**SwiftUI/UIKit 모범 사례** 📱

{구체적인_iOS_가이드}

```swift
// iOS 권장사항
{iOS_특화_코드}
```
```

## 설정 변수 가이드

### 프로젝트별 커스터마이징
```bash
# .env 파일 예시
PROJECT_NAME="당신의프로젝트명"
PROJECT_TYPE="ios-swift"  # ios-swift, android-kotlin, flutter-dart, react-native
ARCHITECTURE="clean-architecture"  # clean-architecture, mvvm, viper, redux

# 리뷰 가중치 (총합 100%)
ARCHITECTURE_WEIGHT=30
CODE_QUALITY_WEIGHT=25
UI_WEIGHT=20
MAINTAINABILITY_WEIGHT=15
SECURITY_WEIGHT=10

# 기능 플래그
ENFORCE_LAYERS=true
DESIGN_CONSISTENCY=true
REQUIRE_LOCALIZATION=true
COVERAGE_THRESHOLD=70
```

### 패턴별 규칙
```json
{
  "ios-swift": {
    "금지패턴": ["forEach.*addSubview", "force_unwrap"],
    "권장패턴": ["weak_delegates", "individual_addsubview"]
  },
  "android-kotlin": {
    "금지패턴": ["!!_operator", "lateinit_abuse"],
    "권장패턴": ["sealed_classes", "coroutines"]
  },
  "flutter-dart": {
    "금지패턴": ["setState_abuse", "widget_rebuild"],
    "권장패턴": ["provider_pattern", "bloc_pattern"]
  }
}
```

## 사용 방법

1. **템플릿 파일들을** 프로젝트의 `.github` 디렉토리에 복사
2. **프로젝트별 변수로** `.env` 파일 생성
3. **필요에 맞게** `universal-codereview-config.json` 커스터마이징
4. **선택한 플랫폼으로** CI/CD 통합 설정
5. **리뷰 기준과 프로세스에 대해** 팀 교육

## 지원 플랫폼

- ✅ iOS (Swift/SwiftUI/UIKit)

## 통합 예시

### GitHub Actions
```yaml
- name: 범용 코드 리뷰
  uses: ./universal-code-review
  with:
    config-path: .github/universal-codereview-config.json
    platform: ${{ env.PROJECT_TYPE }}
```

### GitLab CI
```yaml
code_review:
  script:
    - universal-code-review --config .github/universal-codereview-config.json
```