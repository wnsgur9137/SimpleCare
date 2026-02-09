//
//  View+GlassCard.swift
//  BasePresentation
//
//  Created by SimpleCare on 2/4/26.
//

import SwiftUI

/// Liquid Glass card modifier for consistent glass effect across the app
public struct GlassCard: ViewModifier {
    let cornerRadius: CGFloat
    let tint: Color?

    public init(cornerRadius: CGFloat = 16, tint: Color? = nil) {
        self.cornerRadius = cornerRadius
        self.tint = tint
    }

    public func body(content: Content) -> some View {
        if let tint {
            content
                .glassEffect(.regular.tint(tint), in: .rect(cornerRadius: cornerRadius))
        } else {
            content
                .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
        }
    }
}

public extension View {
    /// Apply a Liquid Glass card effect
    func glassCard(cornerRadius: CGFloat = 16) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius))
    }

    /// Apply a Liquid Glass card effect with a tint color
    func glassCard(tint: Color, cornerRadius: CGFloat = 16) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius, tint: tint))
    }
}
