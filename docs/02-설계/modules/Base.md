---
title: "Base 모듈"
aliases: ["Base"]
tags:
  - 설계
  - 설계/모듈
  - 설계/모듈/feature
created: 2026-01-26
updated: 2026-03-18
status: active
---

# Base

**역할**: 공통 UI 컴포넌트, 프로토콜, 유틸리티

| 레이어 | 파일 | 설명 |
|--------|------|------|
| **Domain** | | |
| Extension | `String+Localization.swift` | 다국어 문자열 확장 |
| Extension | `Error+UserMessage.swift` | 사용자 친화적 에러 메시지 매핑 (`UserFacingError` 프로토콜 + `Error.userMessage`) |
| **Presentation** | | |
| Protocol | `Coordinator.swift` | Coordinator 프로토콜, `SaveCompletable` 프로토콜 |
| Protocol | `DIContainer.swift` | DIContainer 프로토콜 |
| **Debug** | | |
| View | `DebugFloatingButton.swift` | 디버그 플로팅 버튼 |
| Modifier | `DebugOverlayModifier.swift` | 디버그 오버레이 |
| View | `DebugSettingsView.swift` | 디버그 설정 화면 |
| **Extensions** | | |
| Extension | `Color+SimpleCare.swift` | 앱 커스텀 색상 |
| Extension | `View+DismissKeyboard.swift` | 키보드 닫기 |
| Extension | `View+GlassCard.swift` | 글래스모피즘 카드 스타일 |
| **Localization** | | |
| Manager | `LocalizationManager.swift` | 런타임 언어 변경 관리 |
| **Theme** | | |
| Manager | `ThemeManager.swift` | 테마 관리 (system/light/dark) |
| **Notification** | | |
| View | `NotificationEnableBanner.swift` | 알림 활성화 유도 배너 |
| Manager | `NotificationManager.swift` | 로컬 알림 스케줄링 관리 |
| **Data** | | |
| Manager | `DataExportManager.swift` | JSON/CSV 데이터 내보내기 |

**하위 시스템별 기능**:
- **ThemeManager**: system/light/dark 전환, UserDefaults 영속화, 실시간 `ColorScheme` 반영
- **LocalizationManager**: system/한국어/영어 런타임 전환, 모듈별 Bundle 관리, 재시작 불필요
- **NotificationManager**: 5개 카테고리별 알림 (아침/점심/저녁 식사, 운동, 체중), 시간 설정, `UNUserNotificationCenter` 연동
- **DataExportManager**: JSON/CSV 내보내기 (CSV injection 방지), 전체 데이터 삭제
- **Color+SimpleCare**: Primary(teal) / Secondary(blue) / Accent(purple), 영양소별 색상, BMI 색상 매핑, 식사 타입별 색상(Breakfast/Lunch/Dinner/Snack), 운동 강도 색상(Light/Moderate), 오버레이 색상
- **View+GlassCard**: 글래스모피즘 카드/버튼/캡슐 스타일
- **Debug**: 디바이스 정보, 캐시/UserDefaults 초기화, 강제 크래시 (DEBUG 전용)
- **Error+UserMessage**: 5단계 에러 매핑 (UserFacingError → LocalizedError → System 타입 → NSError 도메인 → Fallback), 모든 인프라/리포지토리 에러가 `LocalizedError` 채택
- **SaveCompletable**: 저장 완료 콜백을 지원하는 Coordinator용 프로토콜, RecordSheet 제네릭 팩토리에서 활용
