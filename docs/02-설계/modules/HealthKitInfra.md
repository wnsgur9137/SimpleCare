---
title: "HealthKitInfra 모듈"
aliases: ["HealthKitInfra"]
tags:
  - 설계
  - 설계/모듈
  - 설계/모듈/infrastructure
created: 2026-01-26
updated: 2026-03-11
status: active
---

# HealthKitInfra

**역할**: Apple HealthKit 연동

| 컴포넌트 | 파일 | 설명 |
|---------|------|------|
| Manager | `HealthKitManager.swift` | HealthKit 권한 요청 및 데이터 읽기/쓰기 |
| Type | `HealthKitDataType.swift` | HealthKit 데이터 타입 정의 (stepCount, activeEnergy, bodyMass) |
| **Models** | | |
| Model | `HealthKitWeightData.swift` | HealthKit 체중 데이터 |
| Model | `HealthKitStepData.swift` | HealthKit 걸음수 데이터 |
| Model | `HealthKitActivityData.swift` | HealthKit 활동 칼로리 데이터 |

**지원 데이터 타입**:
- `stepCount` — 일일 걸음수 (`HKQuantityType`)
- `activeEnergy` — 활동 칼로리 (kcal)
- `bodyMass` — 체중 (kg, 읽기+쓰기)

**주요 기능**:
- 권한 요청 (읽기: stepCount, activeEnergy, bodyMass / 쓰기: bodyMass만)
- 일일 걸음수/활동 칼로리 조회 (날짜 범위 기반)
- 체중 기록 조회 (기간별) + 최신 체중 조회
- 체중 저장 (HealthKit에 쓰기)
- 디바이스 HealthKit 지원 여부 확인

**에러 처리**: `notAvailable`, `authorizationDenied`, `queryFailed`

**연동**: HomeFeature(걸음수/활동 칼로리 표시), WeightFeature(체중 동기화)
