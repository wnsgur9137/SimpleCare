//
//  String+Localization.swift
//  BaseDomain
//
//  Created by SimpleCare on 2026-02-20.
//

import Foundation

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
        let userDefaultsKey = "SimpleCare.AppLanguage"

        if let savedLanguage = UserDefaults.standard.string(forKey: userDefaultsKey) {
            switch savedLanguage {
            case "system":
                return Locale.current.language.languageCode?.identifier ?? "ko"
            case "ko":
                return "ko"
            case "en":
                return "en"
            default:
                return Locale.current.language.languageCode?.identifier ?? "ko"
            }
        }
        return Locale.current.language.languageCode?.identifier ?? "ko"
    }
}

// MARK: - Bundle Extension for Easy Registration

public extension Bundle {
    /// 현재 Bundle을 로컬라이제이션 레지스트리에 등록
    func registerForLocalization() {
        LocalizationBundleRegistry.shared.register(self)
    }
}

// MARK: - Auto-registration for BaseDomain

private let _baseDomainBundleRegistration: Void = {
    if let bundle = Bundle(identifier: "com.junhyeok.SimpleCare.BaseDomain") {
        bundle.registerForLocalization()
    }
}()

/// Call this to ensure BaseDomain bundle is registered
public func ensureBaseDomainLocalizationRegistered() {
    _ = _baseDomainBundleRegistration
}
