//
//  View+DismissKeyboard.swift
//  BasePresentation
//
//  Created by SimpleCare on 2/9/26.
//

import SwiftUI
import UIKit

/// ViewModifier that dismisses keyboard when tapping outside of text fields
/// Uses simultaneousGesture to avoid conflicts with other tap gestures
public struct DismissKeyboardModifier: ViewModifier {
    public init() {}

    public func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .simultaneousGesture(
                TapGesture()
                    .onEnded { _ in
                        dismissKeyboard()
                    }
            )
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

public extension View {
    /// Dismiss keyboard when tapping anywhere on this view
    /// Uses simultaneousGesture to work alongside other tap gestures
    func dismissKeyboardOnTap() -> some View {
        modifier(DismissKeyboardModifier())
    }

    /// Hide keyboard programmatically
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
