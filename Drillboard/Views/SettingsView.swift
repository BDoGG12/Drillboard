import SwiftUI
import StoreKit
import UIKit

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(\.requestReview) private var requestReview

    // UI-only state
    @State private var showingMailComposer = false
    @State private var showingMailUnavailableAlert = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    headerView
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                }

                Section("Feedback") {
                    feedbackRow
                    rateRow
                }

                Section("Legal") {
                    privacyRow
                    termsRow
                }

                Section("About") {
                    LabeledContent("Version", value: viewModel.version)
                    LabeledContent("AI", value: viewModel.aiInfo)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showingMailComposer) {
                MailComposer(
                    toRecipients: [viewModel.feedbackEmail],
                    subject: viewModel.feedbackSubject
                )
                .ignoresSafeArea()
            }
            .alert("Mail Not Set Up", isPresented: $showingMailUnavailableAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Mail is not set up on this device. Please configure the Mail app, or email \(viewModel.feedbackEmail) directly.")
            }
        }
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(spacing: 14) {
            appIconView
                .frame(width: 96, height: 96)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
                .accessibilityHidden(true)

            VStack(spacing: 4) {
                Text(viewModel.appName)
                    .font(.largeTitle.bold())
                Text(viewModel.tagline)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(viewModel.appName). \(viewModel.tagline)")
    }

    @ViewBuilder
    private var appIconView: some View {
        if let icon = Self.loadAppIcon() {
            Image(uiImage: icon)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            // Designed fallback when the bundled app icon can't be resolved.
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [.purple, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    Image(systemName: "list.clipboard")
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundStyle(.white)
                }
        }
    }

    /// Resolves the app's icon from the Info.plist's `CFBundleIcons` entries so the same
    /// icon shown on the home screen is also shown in-app. Returns nil if the bundle is
    /// missing the entries (e.g. simulator quirks); the View falls back to a designed tile.
    private static func loadAppIcon() -> UIImage? {
        guard
            let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
            let primary = icons["CFBundlePrimaryIcon"] as? [String: Any],
            let files = primary["CFBundleIconFiles"] as? [String],
            let last = files.last
        else { return nil }
        return UIImage(named: last)
    }

    // MARK: - Feedback rows

    private var feedbackRow: some View {
        Button {
            if viewModel.canSendMail {
                showingMailComposer = true
            } else {
                showingMailUnavailableAlert = true
            }
        } label: {
            settingRow(title: "Send Feedback", systemImage: "envelope")
        }
    }

    private var rateRow: some View {
        Button {
            requestReview()
        } label: {
            settingRow(title: "Rate Drillboard", systemImage: "star")
        }
    }

    // MARK: - Legal rows

    private var privacyRow: some View {
        Button {
            openURL(viewModel.privacyURL)
        } label: {
            settingRow(title: "Privacy Policy", systemImage: "hand.raised", showsExternalIndicator: true)
        }
    }

    private var termsRow: some View {
        Button {
            openURL(viewModel.termsURL)
        } label: {
            settingRow(title: "Terms of Use", systemImage: "doc.text", showsExternalIndicator: true)
        }
    }

    // MARK: - Row builder

    private func settingRow(title: String, systemImage: String, showsExternalIndicator: Bool = false) -> some View {
        HStack {
            Label(title, systemImage: systemImage)
                .foregroundStyle(.primary)
            Spacer()
            if showsExternalIndicator {
                Image(systemName: "arrow.up.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
        }
        .contentShape(Rectangle())
    }
}
