//
//  Error+UserMessage.swift
//  BaseDomain
//
//  Created by SimpleCare on 2026-03-18.
//

import Foundation

// MARK: - UserFacingError Protocol

/// Protocol for errors that provide user-friendly messages.
/// Adopt this protocol in error types to provide localized messages
/// without relying on fragile string matching.
public protocol UserFacingError: Error {
    var userMessage: String { get }
}

// MARK: - User-Friendly Error Message Extension

public extension Error {
    /// Returns a user-friendly localized error message.
    ///
    /// Priority:
    /// 1. UserFacingError protocol conformance (type-safe)
    /// 2. LocalizedError with custom errorDescription (type-safe)
    /// 3. System error type mapping (URLError, DecodingError, etc.)
    /// 4. NSError domain-based mapping
    /// 5. Fallback to generic error message
    var userMessage: String {
        // 1. Check for UserFacingError protocol conformance
        if let userFacing = self as? UserFacingError {
            return userFacing.userMessage
        }

        // 2. Check for LocalizedError with custom errorDescription
        // All app error types (NutritionEstimationError, HealthKitError,
        // GeminiError, *RepositoryError) adopt LocalizedError and provide
        // user-friendly errorDescription via NSLocalizedString/.localized.
        if let localized = self as? LocalizedError,
           let description = localized.errorDescription {
            return description
        }

        // 3. Check for common system error types
        if let urlError = self as? URLError {
            return mapURLError(urlError)
        }

        if self is DecodingError {
            return "error.server".localized
        }

        if self is EncodingError {
            return "error.invalidInput".localized
        }

        // 4. Check for NSError domain-based mapping
        let nsError = self as NSError
        switch nsError.domain {
        case NSURLErrorDomain:
            return "error.network".localized
        case NSCocoaErrorDomain:
            return mapCocoaError(nsError)
        default:
            break
        }

        // 5. Fallback to generic error message
        return "error.unknown".localized
    }

    // MARK: - Private Mappers

    private func mapURLError(_ error: URLError) -> String {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return "error.network".localized
        case .timedOut:
            return "error.network.timeout".localized
        case .cannotFindHost, .cannotConnectToHost:
            return "error.server".localized
        default:
            return "error.network".localized
        }
    }

    private func mapCocoaError(_ error: NSError) -> String {
        switch error.code {
        case NSFileWriteOutOfSpaceError:
            return "error.storage.full".localized
        case NSFileReadNoSuchFileError, NSFileNoSuchFileError:
            return "error.loadFailure".localized
        default:
            if error.code >= 1550 && error.code <= 1599 {
                // Core Data / SwiftData error range
                return "error.saveFailure".localized
            }
            return "error.unknown".localized
        }
    }
}
