//
//  View+DismissKeyboard.swift
//  BasePresentation
//
//  Created by SimpleCare on 2/9/26.
//

import SwiftUI
import UIKit
import Combine

// MARK: - Keyboard Observer

/// Observable object that tracks keyboard visibility
public final class KeyboardObserver: ObservableObject {
    @Published public var isKeyboardVisible: Bool = false

    private var cancellables = Set<AnyCancellable>()

    public init() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.isKeyboardVisible = true
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.isKeyboardVisible = false
            }
            .store(in: &cancellables)
    }
}

// MARK: - Dismiss Keyboard Overlay Modifier

/// ViewModifier that shows a transparent overlay when keyboard is visible
/// Tapping the overlay dismisses the keyboard
public struct DismissKeyboardOverlayModifier: ViewModifier {
    @StateObject private var keyboardObserver = KeyboardObserver()

    public init() {}

    public func body(content: Content) -> some View {
        content
            .overlay {
                if keyboardObserver.isKeyboardVisible {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            dismissKeyboard()
                        }
                        .ignoresSafeArea(.keyboard)
                }
            }
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

// MARK: - View Extension

public extension View {
    /// Shows a transparent overlay when keyboard is visible
    /// Tapping the overlay dismisses the keyboard
    func dismissKeyboardOnTap() -> some View {
        modifier(DismissKeyboardOverlayModifier())
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
