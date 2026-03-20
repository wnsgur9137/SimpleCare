//
//  Source.swift
//  SettingsData
//
//  Created by JunHyeok Lee on 1/22/26.
//

import Foundation

// MARK: - Settings Data Layer
//
// Settings 모듈의 Data 레이어는 현재 최소 구성입니다.
//
// 이유:
// - 설정 데이터 영속화는 Base 매니저(ThemeManager, LocalizationManager,
//   NotificationManager, DataExportManager)가 UserDefaults로 직접 관리
// - SettingsData는 BaseData만 참조 가능하므로 BasePresentation 매니저 접근 불가
//
// 확장 시나리오:
// - 원격 설정 저장소 (Firebase Remote Config 등)
// - 설정 백업/복원 Repository 구현
// - 사용자 환경설정 캐시 레이어
