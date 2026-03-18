//
//  SettingsCoordinator.swift
//  Settings
//
//  Created by JunHyeok Lee on 1/22/26.
//

import SwiftUI
import UIKit
import BasePresentation

// MARK: - SettingsCoordinator

public final class SettingsCoordinator: ObservableObject, Coordinator {
    private let userProfileId: UUID?

    public init(userProfileId: UUID? = nil) {
        self.userProfileId = userProfileId
    }

    @ViewBuilder
    public func start() -> some View {
        SettingsView(userProfileId: userProfileId)
    }
}

// MARK: - SettingsView

public struct SettingsView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var notificationManager = NotificationManager.shared
    @ObservedObject private var dataExportManager = DataExportManager.shared
    @State private var refreshID = UUID()
    @State private var mealRemindersExpanded = false
    @State private var showExportSheet = false
    @State private var showDeleteConfirmation = false
    @State private var exportFileURL: URL?
    @State private var showExportSuccess = false
    @State private var showDeleteSuccess = false
    @State private var errorMessage: String?

    private let userProfileId: UUID?

    public init(userProfileId: UUID? = nil) {
        self.userProfileId = userProfileId
    }

    public var body: some View {
        List {
            themeSection
            languageSection
            notificationSection
            if userProfileId != nil {
                dataManagementSection
            }
            appInfoSection
            disclaimerSection
        }
        .navigationTitle("settings.title".localized)
        .id(refreshID)
        .task {
            await notificationManager.checkAuthorizationStatus()
        }
        .sheet(isPresented: $showExportSheet) {
            if let userProfileId = userProfileId {
                ExportFormatSheet(
                    userProfileId: userProfileId,
                    onExportComplete: { url in
                        exportFileURL = url
                        showExportSheet = false
                        showExportSuccess = true
                    },
                    onError: { error in
                        errorMessage = error
                        showExportSheet = false
                    }
                )
            }
        }
        .sheet(item: $exportFileURL) { url in
            ShareSheet(activityItems: [url]) {
                // 공유 완료/취소 후 임시 파일 정리
                dataExportManager.cleanupExportFile(at: url)
                exportFileURL = nil
            }
        }
        .alert("settings.export.success".localized, isPresented: $showExportSuccess) {
            Button("common.ok".localized, role: .cancel) {}
        }
        .alert("settings.deleteAll.title".localized, isPresented: $showDeleteConfirmation) {
            Button("common.cancel".localized, role: .cancel) {}
            Button("common.delete".localized, role: .destructive) {
                Task {
                    await deleteAllData()
                }
            }
        } message: {
            Text("settings.deleteAll.warning".localized)
        }
        .alert("settings.deleteAll.success".localized, isPresented: $showDeleteSuccess) {
            Button("common.ok".localized, role: .cancel) {}
        }
        .alert("common.error".localized, isPresented: .init(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("common.ok".localized, role: .cancel) {}
        } message: {
            if let error = errorMessage {
                Text(error)
            }
        }
    }

    // MARK: - Data Management Section

    private var dataManagementSection: some View {
        Section("settings.dataManagement".localized) {
            // Export Data
            Button {
                showExportSheet = true
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(.blue)
                        .frame(width: 24)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("settings.export.title".localized)
                            .foregroundStyle(.primary)
                        Text("settings.export.description".localized)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if dataExportManager.isExporting {
                        ProgressView()
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .disabled(dataExportManager.isExporting)

            // Delete All Data
            Button {
                showDeleteConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                        .frame(width: 24)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("settings.deleteAll.title".localized)
                            .foregroundStyle(.red)
                        Text("settings.deleteAll.description".localized)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if dataExportManager.isDeleting {
                        ProgressView()
                    }
                }
            }
            .disabled(dataExportManager.isDeleting)
        }
    }

    private func deleteAllData() async {
        guard let userProfileId else { return }
        do {
            try await dataExportManager.deleteAllData(userProfileId: userProfileId)
            showDeleteSuccess = true
        } catch {
            errorMessage = error.userMessage
        }
    }

    // MARK: - Theme Section

    private var themeSection: some View {
        Section("settings.theme".localized) {
            ForEach(AppTheme.allCases) { theme in
                Button {
                    themeManager.setTheme(theme)
                } label: {
                    HStack {
                        Image(systemName: theme.icon)
                            .foregroundStyle(themeIconColor(for: theme))
                            .frame(width: 24)
                        Text(theme.displayName)
                            .foregroundStyle(.primary)
                        Spacer()
                        if themeManager.currentTheme == theme {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Language Section

    private var languageSection: some View {
        Section("settings.language".localized) {
            ForEach(AppLanguage.allCases) { language in
                Button {
                    localizationManager.setLanguage(language)
                    notificationManager.rescheduleAllNotifications()
                    refreshID = UUID()
                } label: {
                    HStack {
                        Text(language.displayName)
                            .foregroundStyle(.primary)
                        Spacer()
                        if localizationManager.currentLanguage == language {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Notification Section

    private var notificationSection: some View {
        Section("settings.notifications".localized) {
            if !notificationManager.isAuthorized {
                notificationPermissionButton
            }

            mealRemindersGroup
            exerciseReminderRow
            weightReminderRow
        }
    }

    private var notificationPermissionButton: some View {
        Button {
            Task {
                await notificationManager.requestAuthorization()
            }
        } label: {
            HStack {
                Image(systemName: "bell.badge")
                    .foregroundStyle(.orange)
                    .frame(width: 24)
                VStack(alignment: .leading, spacing: 2) {
                    Text("notification.enablePermission".localized)
                        .foregroundStyle(.primary)
                    Text("notification.permissionDescription".localized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var mealRemindersGroup: some View {
        DisclosureGroup(
            isExpanded: $mealRemindersExpanded,
            content: {
                NotificationToggleRow(category: .breakfast, manager: notificationManager)
                NotificationToggleRow(category: .lunch, manager: notificationManager)
                NotificationToggleRow(category: .dinner, manager: notificationManager)
            },
            label: {
                HStack {
                    Image(systemName: "fork.knife")
                        .foregroundStyle(.green)
                        .frame(width: 24)
                    Text("notification.meal".localized)
                }
            }
        )
    }

    private var exerciseReminderRow: some View {
        NotificationToggleRow(category: .exercise, manager: notificationManager)
    }

    private var weightReminderRow: some View {
        NotificationToggleRow(category: .weight, manager: notificationManager)
    }

    // MARK: - App Info Section

    private var appInfoSection: some View {
        Section("settings.appInfo".localized) {
            HStack {
                Text("settings.version".localized)
                Spacer()
                Text("1.0.0")
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Disclaimer Section

    private var disclaimerSection: some View {
        Section {
            Text("onboarding.disclaimer".localized)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Helpers

    private func themeIconColor(for theme: AppTheme) -> Color {
        switch theme {
        case .system:
            return .primary
        case .light:
            return .orange
        case .dark:
            return .indigo
        }
    }
}

// MARK: - NotificationToggleRow

// MARK: - Export Format Sheet

struct ExportFormatSheet: View {
    let userProfileId: UUID
    let onExportComplete: (URL) -> Void
    let onError: (String) -> Void

    @ObservedObject private var dataExportManager = DataExportManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFormat: ExportFormat = .json

    var body: some View {
        NavigationStack {
            List {
                Section("settings.export.format".localized) {
                    ForEach(ExportFormat.allCases) { format in
                        Button {
                            selectedFormat = format
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(format.displayName)
                                        .foregroundStyle(.primary)
                                    Text(".\(format.fileExtension)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if selectedFormat == format {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }

                Section {
                    Button {
                        Task {
                            await exportData()
                        }
                    } label: {
                        HStack {
                            Spacer()
                            if dataExportManager.isExporting {
                                ProgressView()
                                    .padding(.trailing, 8)
                            }
                            Text("settings.export.title".localized)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(dataExportManager.isExporting)
                }
            }
            .navigationTitle("settings.export.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.cancel".localized) {
                        dismiss()
                    }
                }
            }
        }
    }

    private func exportData() async {
        do {
            let url = try await dataExportManager.exportAllData(
                format: selectedFormat,
                userProfileId: userProfileId
            )
            onExportComplete(url)
        } catch {
            onError(error.userMessage)
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    var onComplete: (() -> Void)?

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        controller.completionWithItemsHandler = { _, _, _, _ in
            onComplete?()
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - URL Extension for Identifiable

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}

// MARK: - NotificationToggleRow

struct NotificationToggleRow: View {
    let category: NotificationCategory
    @ObservedObject var manager: NotificationManager

    private var isEnabled: Binding<Bool> {
        Binding(
            get: { manager.setting(for: category).isEnabled },
            set: { manager.updateSetting(for: category, isEnabled: $0) }
        )
    }

    private var selectedTime: Binding<Date> {
        Binding(
            get: { manager.setting(for: category).timeDate },
            set: { manager.updateTime(for: category, date: $0) }
        )
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                if category.group.categories.count == 1 {
                    Image(systemName: category.icon)
                        .foregroundStyle(iconColor)
                        .frame(width: 24)
                }
                Text(category.displayName)
                Spacer()
                Toggle("", isOn: isEnabled)
                    .labelsHidden()
            }

            if isEnabled.wrappedValue {
                HStack {
                    Text("notification.time".localized)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    DatePicker(
                        "",
                        selection: selectedTime,
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                }
                .padding(.leading, category.group.categories.count == 1 ? 32 : 0)
            }
        }
    }

    private var iconColor: Color {
        switch category {
        case .breakfast, .lunch, .dinner:
            return .green
        case .exercise:
            return .orange
        case .weight:
            return .blue
        }
    }
}
