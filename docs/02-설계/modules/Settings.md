---
title: "Settings 모듈"
aliases: ["Settings"]
tags:
  - 설계
  - 설계/모듈
  - 설계/모듈/feature
created: 2026-01-26
updated: 2026-03-18
status: active
---

# Settings

**역할**: 앱 설정 (테마, 언어, 알림, 데이터 관리)

| 레이어 | 파일 | 설명 |
|--------|------|------|
| **Domain** | `Source.swift` | 최소 구성 (아키텍처 설명 주석) — 핵심 타입이 BaseDomain/BasePresentation에 위치 |
| **Data** | `Source.swift` | 최소 구성 (아키텍처 설명 주석) — 영속화 로직이 Base 매니저에 위임 |
| **Presentation** | | |
| Protocol | `Source.swift` | `SettingsCoordinatorDependency` — 의존성 주입 프로토콜 |
| Coordinator | `Source.swift` | `SettingsCoordinator` — DI 기반 화면 진입점 |
| View | `Source.swift` | `SettingsView`, `ExportFormatSheet`, `ShareSheet`, `NotificationToggleRow` |
| **Aggregator** | | |
| DIContainer | `SettingsDIContainer.swift` | Base 매니저(Theme/Localization/Notification/DataExport)를 주입 |
| Re-export | `Source.swift` | `@_exported import` (Domain, Data, Presentation) |

**의존성 주입 패턴**:
```
TabDIContainer.makeSettingsDIContainer()
  → SettingsDIContainer (conforms to SettingsCoordinatorDependency)
    → SettingsCoordinator(dependencies:)
      → SettingsView(themeManager:, localizationManager:, notificationManager:, dataExportManager:)
```

> **Domain/Data 최소 구성 사유**: Settings의 핵심 타입(`AppTheme`, `AppLanguage`, `NotificationCategory` 등)과 영속화 로직은 BasePresentation에 정의된 싱글톤 매니저가 관리합니다. SettingsDomain은 BaseDomain만 참조 가능하므로, 프로토콜/타입 정의에 제약이 있어 Presentation 레이어에서 의존성 역전을 구현합니다.

**화면 구성**:
- 테마 설정: system/light/dark 선택 (체크마크 표시)
- 언어 설정: system/한국어/English 선택 (체크마크 표시)
- 알림 설정: 권한 요청 버튼, 카테고리별 토글 + 시간 선택기
- 데이터 관리: 내보내기 형식 선택 시트 (JSON/CSV), 전체 삭제 + 확인 알림
- 앱 정보: 버전 표시, 건강 면책 조항
