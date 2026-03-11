---
title: "Weight 모듈"
aliases: ["Weight"]
tags:
  - 설계
  - 설계/모듈
  - 설계/모듈/feature
created: 2026-01-26
updated: 2026-03-11
status: active
---

# Weight

**역할**: 체중 기록 및 목표 관리

| 레이어 | 파일 | 설명 |
|--------|------|------|
| **Domain** | | |
| Entity | `WeightRecord.swift` | 체중 기록 |
| UseCase | `WeightUseCases.swift` | 체중 CRUD + BMR/TDEE/추세 계산 |
| **Data** | | |
| Repository | `WeightRepository.swift` | 체중 레포지토리 구현 |
| **Presentation** | | |
| Coordinator | `WeightCoordinator.swift` | 체중 화면 네비게이션 |
| Reducer | `WeightFeature.swift` | 체중 기록 TCA Reducer |
| View | `WeightView.swift` | 체중 기록/차트 UI |
| **Aggregator** | | |
| DIContainer | `WeightDIContainer.swift` | 의존성 조립 |

**BMR 계산 (Mifflin-St Jeor)**:
```
남성: BMR = 10×체중(kg) + 6.25×키(cm) - 5×나이 + 5
여성: BMR = 10×체중(kg) + 6.25×키(cm) - 5×나이 - 161
```

**TDEE 계산**:
```
TDEE = BMR × 활동계수
- 좌식: 1.2  |  가벼운 활동: 1.375  |  보통 활동: 1.55
- 활발한 활동: 1.725  |  매우 활발: 1.9
```
