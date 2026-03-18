//
//  Error+UserMessage.swift
//  BaseDomain
//
//  Created by SimpleCare on 2026-03-18.
//

import Foundation

// MARK: - User-Friendly Error Message Extension

public extension Error {
    /// Returns a user-friendly localized error message.
    ///
    /// Maps common system errors and known app error types to localized strings,
    /// preventing raw technical error messages from being shown to users.
    var userMessage: String {
        // 1. Check for known app-specific error patterns by type name
        let typeName = String(describing: type(of: self))

        switch typeName {
        case "NutritionEstimationError":
            return mapNutritionEstimationError()
        case "HealthKitError":
            return mapHealthKitError()
        case "GeminiError":
            return mapGeminiError()
        case "MealRepositoryError":
            return "error.mealNotFound".localized
        case "WeightRepositoryError":
            return "error.weightNotFound".localized
        case "ProfileRepositoryError":
            return "error.profileNotFound".localized
        case "ExerciseRepositoryError":
            return "error.exerciseNotFound".localized
        default:
            break
        }

        // 2. Check for common system error types
        if let urlError = self as? URLError {
            return mapURLError(urlError)
        }

        if self is DecodingError {
            return "error.server".localized
        }

        if self is EncodingError {
            return "error.invalidInput".localized
        }

        // 3. Check for NSError domain-based mapping
        let nsError = self as NSError
        switch nsError.domain {
        case NSURLErrorDomain:
            return "error.network".localized
        case NSCocoaErrorDomain:
            return mapCocoaError(nsError)
        default:
            break
        }

        // 4. Fallback to generic error message
        return "error.unknown".localized
    }

    // MARK: - Private Mappers

    private func mapNutritionEstimationError() -> String {
        let description = localizedDescription
        if description.contains("응답을 받지 못") || description.contains("No response") {
            return "error.ai.noResponse".localized
        } else if description.contains("응답 형식") || description.contains("Invalid response") {
            return "error.ai.invalidFormat".localized
        } else if description.contains("파싱") || description.contains("parsing") {
            return "error.ai.parseFailed".localized(with: "")
        } else if description.contains("이미지") || description.contains("image") {
            return "error.ai.imageFailed".localized
        }
        return "error.aiAnalysis".localized
    }

    private func mapHealthKitError() -> String {
        let description = localizedDescription
        if description.contains("not available") || description.contains("사용할 수 없") {
            return "error.healthKit.notAvailable".localized
        } else if description.contains("denied") || description.contains("거부") {
            return "error.healthKit.denied".localized
        }
        return "error.healthKit.queryFailed".localized
    }

    private func mapGeminiError() -> String {
        let description = localizedDescription
        if description.contains("API key") || description.contains("api_key") {
            return "error.ai.invalidKey".localized
        } else if description.contains("rate") || description.contains("Rate") {
            return "error.ai.rateLimited".localized
        }
        return "error.aiAnalysis".localized
    }

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
