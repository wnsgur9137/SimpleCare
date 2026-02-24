//
//  String+Localization.swift
//  BaseDomain
//
//  Created by SimpleCare on 2026-02-20.
//

import Foundation

// MARK: - Localization Constants

/// 다국어 관련 공유 상수
public enum LocalizationConstants {
    /// UserDefaults에 저장되는 언어 설정 키
    public static let userDefaultsKey = "SimpleCare.AppLanguage"

    /// 기본 폴백 언어 코드
    public static let defaultLanguageCode = "ko"

    /// 지원 언어 코드
    public enum LanguageCode {
        public static let system = "system"
        public static let korean = "ko"
        public static let english = "en"
    }

    /// 저장된 언어 설정에 따른 실제 언어 코드 반환
    public static func resolveLanguageCode(from savedLanguage: String?) -> String {
        guard let savedLanguage = savedLanguage else {
            return systemLanguageCode
        }

        switch savedLanguage {
        case LanguageCode.system:
            return systemLanguageCode
        case LanguageCode.korean:
            return LanguageCode.korean
        case LanguageCode.english:
            return LanguageCode.english
        default:
            return systemLanguageCode
        }
    }

    /// 시스템 언어 코드 (폴백 포함)
    public static var systemLanguageCode: String {
        Locale.current.language.languageCode?.identifier ?? defaultLanguageCode
    }
}

// MARK: - Localization Bundle Registry

/// 모듈별 Bundle을 등록하고 관리하는 클래스
public final class LocalizationBundleRegistry: @unchecked Sendable {
    public static let shared = LocalizationBundleRegistry()

    private var bundles: [Bundle] = []
    private let lock = NSLock()

    private init() {
        // 기본적으로 main bundle 등록
        bundles.append(Bundle.main)
    }

    /// 모듈의 Bundle 등록
    public func register(_ bundle: Bundle) {
        lock.lock()
        defer { lock.unlock() }
        if !bundles.contains(bundle) {
            bundles.insert(bundle, at: 0) // 모듈 번들을 우선 탐색
        }
    }

    /// 등록된 모든 Bundle 반환
    public func allBundles() -> [Bundle] {
        lock.lock()
        defer { lock.unlock() }
        return bundles
    }
}

// MARK: - String Extension for Localization

public extension String {
    /// Returns localized string searching through registered module bundles
    var localized: String {
        // BaseDomain 번들이 등록되었는지 확인
        ensureBaseDomainLocalizationRegistered()

        let languageCode = Self.resolveCurrentLanguageCode()

        // 등록된 모든 번들에서 탐색
        for bundle in LocalizationBundleRegistry.shared.allBundles() {
            if let path = bundle.path(forResource: languageCode, ofType: "lproj"),
               let localizedBundle = Bundle(path: path) {
                let result = localizedBundle.localizedString(forKey: self, value: nil, table: nil)
                if result != self {
                    return result
                }
            }

            // lproj 없이 직접 시도
            let result = bundle.localizedString(forKey: self, value: nil, table: nil)
            if result != self {
                return result
            }
        }

        // 찾지 못하면 키 자체 반환
        return self
    }

    /// Returns localized string with format arguments
    func localized(with arguments: CVarArg...) -> String {
        String(format: self.localized, arguments: arguments)
    }

    /// Resolves the current language code from UserDefaults
    private static func resolveCurrentLanguageCode() -> String {
        let savedLanguage = UserDefaults.standard.string(forKey: LocalizationConstants.userDefaultsKey)
        return LocalizationConstants.resolveLanguageCode(from: savedLanguage)
    }
}

// MARK: - Bundle Extension for Easy Registration

public extension Bundle {
    /// 현재 Bundle을 로컬라이제이션 레지스트리에 등록
    func registerForLocalization() {
        LocalizationBundleRegistry.shared.register(self)
    }
}

// MARK: - BaseDomain Bundle Helper

/// BaseDomain 번들을 찾기 위한 마커 클래스
private final class BaseDomainBundleMarker {}

/// BaseDomain 번들 반환
public var baseDomainBundle: Bundle {
    Bundle(for: BaseDomainBundleMarker.self)
}

// MARK: - Auto-registration for BaseDomain

private let _baseDomainBundleRegistration: Void = {
    baseDomainBundle.registerForLocalization()
}()

/// Call this to ensure BaseDomain bundle is registered
public func ensureBaseDomainLocalizationRegistered() {
    _ = _baseDomainBundleRegistration
}
