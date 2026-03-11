---
title: "Settings 모듈"
aliases: ["Settings"]
tags:
  - 설계
  - 설계/모듈
  - 설계/모듈/feature
created: 2026-01-26
updated: 2026-03-11
status: active
---

# Settings

**역할**: 앱 설정 (모듈 골격 + 실제 UI는 Tab/Base 모듈에서 구현)

| 레이어 | 파일 | 설명 |
|--------|------|------|
| Domain | `Source.swift` | 플레이스홀더 |
| Data | `Source.swift` | 플레이스홀더 |
| Presentation | `Source.swift` | 플레이스홀더 |
| Aggregator | `Source.swift` | 플레이스홀더 |

> **Note**: Settings 모듈 자체는 골격 상태입니다.
> 설정 UI(`SettingsCoordinator`, `SettingsView`)는 Tab 모듈에, 실제 로직(ThemeManager, LocalizationManager, NotificationManager, DataExportManager)은 Base 모듈에 구현되어 있습니다.

**화면 구성** (Tab 모듈 `SettingsCoordinator` / Base 모듈 매니저):
- 테마 설정: system/light/dark 선택 (체크마크 표시)
- 언어 설정: system/한국어/English 선택 (체크마크 표시)
- 알림 설정: 권한 요청 버튼, 카테고리별 토글 + 시간 선택기
- 데이터 관리: 내보내기 형식 선택 시트 (JSON/CSV), 전체 삭제 + 확인 알림
- 앱 정보: 버전 표시, 건강 면책 조항
