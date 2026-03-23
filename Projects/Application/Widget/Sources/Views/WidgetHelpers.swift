//
//  WidgetHelpers.swift
//  SimpleCareWidget
//

import SwiftUI

// MARK: - Progress Color

func progressColor(for progress: Double) -> Color {
    if progress < 0.8 {
        return .orange
    } else if progress <= 1.1 {
        return .green
    } else {
        return .red
    }
}

// MARK: - View Extension

extension View {
    @ViewBuilder
    func `if`<Content: View>(
        _ condition: Bool,
        transform: (Self) -> Content
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
