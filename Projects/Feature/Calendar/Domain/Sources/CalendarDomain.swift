//
//  CalendarDomain.swift
//  CalendarDomain
//
//  Created by JunHyeok Lee on 2/21/26.
//

import Foundation
import BaseDomain

// MARK: - CalendarDomain Bundle Registration

/// CalendarDomain 번들 자동 등록
private let _calendarDomainBundleRegistration: Void = {
    Bundle.module.registerForLocalization()
}()

/// CalendarDomain 번들 등록 보장
public func ensureCalendarDomainLocalizationRegistered() {
    _ = _calendarDomainBundleRegistration
}
