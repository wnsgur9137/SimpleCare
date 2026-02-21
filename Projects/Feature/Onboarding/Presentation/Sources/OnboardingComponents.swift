//
//  OnboardingComponents.swift
//  OnboardingPresentation
//
//  Created by SimpleCare on 1/26/26.
//

import SwiftUI

// MARK: - StepHeader

struct StepHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.title)
                .fontWeight(.bold)
            Text(subtitle)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding(.bottom)
    }
}
