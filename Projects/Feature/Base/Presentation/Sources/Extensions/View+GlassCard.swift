//
//  View+GlassCard.swift
//  BasePresentation
//
//  Created by SimpleCare on 2/4/26.
//

import SwiftUI

// MARK: - Glass Card Modifier

/// Liquid Glass card modifier for consistent glass effect across the app
public struct GlassCard: ViewModifier {
    let cornerRadius: CGFloat
    let tint: Color?

    public init(cornerRadius: CGFloat = 16, tint: Color? = nil) {
        self.cornerRadius = cornerRadius
        self.tint = tint
    }

    public func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.clear)
                    .glassEffect(tint.map { .regular.tint($0) } ?? .regular, in: .rect(cornerRadius: cornerRadius))
            }
    }
}

// MARK: - Glass Button Modifier

/// Liquid Glass button modifier that ensures content visibility
public struct GlassButton: ViewModifier {
    let cornerRadius: CGFloat
    let tint: Color?
    let isInteractive: Bool

    public init(cornerRadius: CGFloat = 12, tint: Color? = nil, isInteractive: Bool = true) {
        self.cornerRadius = cornerRadius
        self.tint = tint
        self.isInteractive = isInteractive
    }

    public func body(content: Content) -> some View {
        content
            .background {
                let shape = RoundedRectangle(cornerRadius: cornerRadius).fill(.clear)
                if let tint {
                    if isInteractive {
                        shape.glassEffect(.regular.tint(tint).interactive(), in: .rect(cornerRadius: cornerRadius))
                    } else {
                        shape.glassEffect(.regular.tint(tint), in: .rect(cornerRadius: cornerRadius))
                    }
                } else {
                    if isInteractive {
                        shape.glassEffect(.regular.interactive(), in: .rect(cornerRadius: cornerRadius))
                    } else {
                        shape.glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
                    }
                }
            }
    }
}

// MARK: - Glass Capsule Modifier

/// Liquid Glass capsule modifier for pill-shaped buttons
public struct GlassCapsule: ViewModifier {
    let tint: Color?
    let isInteractive: Bool

    public init(tint: Color? = nil, isInteractive: Bool = true) {
        self.tint = tint
        self.isInteractive = isInteractive
    }

    public func body(content: Content) -> some View {
        content
            .background {
                let shape = Capsule().fill(.clear)
                if let tint {
                    if isInteractive {
                        shape.glassEffect(.regular.tint(tint).interactive(), in: .capsule)
                    } else {
                        shape.glassEffect(.regular.tint(tint), in: .capsule)
                    }
                } else {
                    if isInteractive {
                        shape.glassEffect(.regular.interactive(), in: .capsule)
                    } else {
                        shape.glassEffect(.regular, in: .capsule)
                    }
                }
            }
    }
}

// MARK: - View Extensions

public extension View {
    /// Apply a Liquid Glass card effect (background style - content always visible)
    func glassCard(tint: Color? = nil, cornerRadius: CGFloat = 16) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius, tint: tint))
    }

    /// Apply a Liquid Glass button effect (background style - content always visible)
    func glassButton(cornerRadius: CGFloat = 12, tint: Color? = nil, isInteractive: Bool = true) -> some View {
        modifier(GlassButton(cornerRadius: cornerRadius, tint: tint, isInteractive: isInteractive))
    }

    /// Apply a Liquid Glass capsule effect (background style - content always visible)
    func glassCapsule(tint: Color? = nil, isInteractive: Bool = true) -> some View {
        modifier(GlassCapsule(tint: tint, isInteractive: isInteractive))
    }
}
