---
title: "Tab 모듈"
aliases: ["Tab"]
tags:
  - 설계
  - 설계/모듈
  - 설계/모듈/feature
created: 2026-01-26
updated: 2026-03-11
status: active
---

# Tab

**역할**: 메인 탭 네비게이션 관리

| 레이어 | 파일 | 설명 |
|--------|------|------|
| Aggregator | `Tab.swift` | 모듈 진입점 |
| Coordinator | `TabCoordinator.swift` | 탭 네비게이션 및 자식 Coordinator 관리 |
| DIContainer | `TabDIContainer.swift` | 모든 Feature DIContainer 생성 |
| View | `MainTabView.swift` | 메인 탭 뷰 (5개 탭) |

**탭 구성**:
```swift
public enum AppTab: Hashable {
    case home       // 홈
    case meal       // 식단
    case exercise   // 운동
    case progress   // 체중
    case calendar   // 캘린더
}
```

**Sheet 화면**: Settings, Profile, MealDetail, ExerciseDetail
