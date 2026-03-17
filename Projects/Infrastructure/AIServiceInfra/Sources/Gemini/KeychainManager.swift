//
//  KeychainManager.swift
//  AIServiceInfra
//
//  Created by SimpleCare on 3/17/26.
//

import Foundation
import Security

/// Keychain을 사용한 보안 키 저장 관리자
public enum KeychainManager {
    private static let service = "com.junhyeok.SimpleCare"

    /// Keychain에 값 저장
    public static func save(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }

        // 기존 항목 삭제 후 저장
        delete(key: key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    /// Keychain에서 값 읽기
    public static func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    /// Keychain에서 값 삭제
    @discardableResult
    public static func delete(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}

// MARK: - Keychain Keys

public extension KeychainManager {
    static let geminiAPIKeyIdentifier = "gemini_api_key"

    /// Gemini API 키를 Keychain에서 로드 (없으면 Info.plist에서 마이그레이션)
    static func loadGeminiAPIKey() -> String {
        // 1. Keychain에서 로드
        if let keychainKey = load(key: geminiAPIKeyIdentifier), !keychainKey.isEmpty {
            return keychainKey
        }

        // 2. Info.plist에서 마이그레이션
        if let plistKey = Bundle.main.infoDictionary?["GEMINI_API_KEY"] as? String,
           !plistKey.isEmpty, plistKey != "123" {
            _ = save(key: geminiAPIKeyIdentifier, value: plistKey)
            return plistKey
        }

        // 3. 환경변수에서 로드
        if let envKey = ProcessInfo.processInfo.environment["GEMINI_API_KEY"],
           !envKey.isEmpty {
            _ = save(key: geminiAPIKeyIdentifier, value: envKey)
            return envKey
        }

        return ""
    }
}
