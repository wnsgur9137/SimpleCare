//
//  ExerciseDetailView.swift
//  ExercisePresentation
//
//  Created by SimpleCare on 2026-02-24.
//

import SwiftUI
import ComposableArchitecture
import ExerciseDomain
import BasePresentation

/// 운동 상세 화면
public struct ExerciseDetailView: View {
    @Bindable var store: StoreOf<ExerciseDetailFeature>
    @Environment(\.dismiss) private var dismiss

    public init(store: StoreOf<ExerciseDetailFeature>) {
        self.store = store
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection
                detailsSection
                if store.exercise.notes != nil || store.isEditing {
                    notesSection
                }
                deleteButton
            }
            .padding()
        }
        .navigationTitle(store.exercise.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if store.isEditing {
                    Button("common.done".localized) {
                        store.send(.saveChanges)
                    }
                } else {
                    Button("common.edit".localized) {
                        store.send(.editButtonTapped)
                    }
                }
            }
            if store.isEditing {
                ToolbarItem(placement: .topBarLeading) {
                    Button("common.cancel".localized) {
                        store.send(.cancelEdit)
                    }
                }
            }
        }
        .overlay {
            if store.viewState == .loading {
                loadingOverlay
            }
        }
        .alert("common.error".localized, isPresented: .constant(store.viewState.isError)) {
            Button("common.confirm".localized) { store.send(.dismissError) }
        } message: {
            if case .error(let message) = store.viewState {
                Text(message)
            }
        }
        .alert("exercise.detail.deleteConfirm.title".localized, isPresented: $store.showDeleteConfirmation) {
            Button("common.cancel".localized, role: .cancel) {
                store.send(.cancelDelete)
            }
            Button("common.delete".localized, role: .destructive) {
                store.send(.confirmDelete)
            }
        } message: {
            Text("exercise.detail.deleteConfirm.message".localized)
        }
        .onChange(of: store.viewState) { _, newState in
            if newState == .deleted {
                dismiss()
            }
        }
        .task {
            store.send(.onAppear)
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: store.exercise.exerciseType.category.icon)
                    .font(.title)
                    .foregroundStyle(categoryColor)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text(store.isEditing ? store.editingExerciseType.displayName : store.exercise.displayName)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(formattedDate)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("\(store.exercise.caloriesBurned)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(.scCalories)
                    Text("kcal")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(store.exercise.displayName), \(formattedDate), \(store.exercise.caloriesBurned) \("unit.kcal".localized)")
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
        }
    }

    // MARK: - Details Section

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("exercise.detail.info".localized)
                .font(.headline)

            HStack(spacing: 16) {
                ExerciseDetailCard(
                    label: "exercise.duration".localized,
                    value: store.isEditing
                        ? "\(store.editingDurationMinutes)"
                        : "\(store.exercise.durationMinutes)",
                    unit: "exercise.minutes".localized,
                    icon: "clock.fill",
                    color: .scSecondary
                )

                ExerciseDetailCard(
                    label: "exercise.intensity".localized,
                    value: store.isEditing
                        ? store.editingIntensity.displayName
                        : store.exercise.intensity.displayName,
                    unit: "",
                    icon: "flame.fill",
                    color: intensityColor
                )
            }

            if store.isEditing {
                editingControls
            }

            HStack(spacing: 16) {
                ExerciseDetailCard(
                    label: "exercise.category".localized,
                    value: store.exercise.exerciseType.category.displayName,
                    unit: "",
                    icon: store.exercise.exerciseType.category.icon,
                    color: categoryColor
                )

                ExerciseDetailCard(
                    label: "exercise.met".localized,
                    value: String(format: "%.1f", store.exercise.effectiveBaseMET),
                    unit: "MET",
                    icon: "bolt.fill",
                    color: .scWarning
                )
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
        }
    }

    // MARK: - Editing Controls

    private var editingControls: some View {
        VStack(spacing: 16) {
            // 카테고리 선택
            VStack(alignment: .leading, spacing: 8) {
                Text("exercise.category".localized)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Picker("exercise.category".localized, selection: $store.editingCategory) {
                    ForEach(ExerciseCategory.allCases, id: \.self) { cat in
                        Label(cat.displayName, systemImage: cat.icon).tag(cat)
                    }
                }
            }

            // 유형 선택 (선택된 카테고리 기준 필터)
            VStack(alignment: .leading, spacing: 8) {
                Text("exercise.type".localized)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Picker("exercise.type".localized, selection: $store.editingExerciseType) {
                    ForEach(
                        ExerciseType.allCases.filter { $0.category == store.editingCategory },
                        id: \.self
                    ) { type in
                        Text(type.displayName).tag(type)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("exercise.duration".localized)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Stepper(value: $store.editingDurationMinutes, in: 5...300, step: 5) {
                    Text("\(store.editingDurationMinutes) " + "exercise.minutes".localized)
                        .font(.body)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("exercise.intensity".localized)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Picker("exercise.intensity".localized, selection: $store.editingIntensity) {
                    ForEach(ExerciseIntensity.allCases, id: \.self) { intensity in
                        Text(intensity.displayName).tag(intensity)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - Notes Section

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("exercise.notes".localized)
                .font(.headline)

            if store.isEditing {
                TextField("exercise.notesPlaceholder".localized, text: $store.editingNotes, axis: .vertical)
                    .lineLimit(2...4)
                    .textFieldStyle(.roundedBorder)
            } else if let notes = store.exercise.notes, !notes.isEmpty {
                Text(notes)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
        }
    }

    // MARK: - Delete Button

    private var deleteButton: some View {
        Button(role: .destructive) {
            store.send(.deleteButtonTapped)
        } label: {
            HStack {
                Image(systemName: "trash")
                Text("exercise.detail.delete".localized)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.scError.opacity(0.1))
            }
        }
        .foregroundStyle(.scError)
    }

    // MARK: - Loading Overlay

    private var loadingOverlay: some View {
        ZStack {
            Color.scOverlay
                .ignoresSafeArea()

            ProgressView()
                .scaleEffect(1.5)
                .padding(32)
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.regularMaterial)
                }
        }
    }

    // MARK: - Helpers

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd (E) HH:mm"
        return formatter
    }()

    private var formattedDate: String {
        Self.dateFormatter.string(from: store.exercise.date)
    }

    private var categoryColor: Color {
        switch store.exercise.exerciseType.category {
        case .cardio: return .scError
        case .strength: return .scSecondary
        case .flexibility: return .scAccent
        case .sports: return .scSuccess
        case .other: return .scTextSecondary
        }
    }

    private var intensityColor: Color {
        let intensity = store.isEditing ? store.editingIntensity : store.exercise.intensity
        switch intensity {
        case .light: return .scIntensityLight
        case .moderate: return .scIntensityModerate
        case .vigorous: return .scIntensityVigorous
        }
    }
}

// MARK: - Exercise Detail Card

private struct ExerciseDetailCard: View {
    let label: String
    let value: String
    let unit: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)

            if !unit.isEmpty {
                Text(unit)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label), \(value) \(unit)")
    }
}

#Preview {
    NavigationStack {
        ExerciseDetailView(
            store: Store(
                initialState: ExerciseDetailFeature.State(
                    exercise: ExerciseRecord(
                        userProfileId: UUID(),
                        exerciseType: .running,
                        intensity: .moderate,
                        durationMinutes: 30,
                        userWeightKg: 70.0,
                        notes: "좋은 러닝이었다"
                    )
                )
            ) {
                ExerciseDetailFeature()
            }
        )
    }
}
