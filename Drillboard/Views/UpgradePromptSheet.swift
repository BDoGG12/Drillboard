import SwiftUI

struct UpgradePromptSheet: View {
    @Environment(\.dismiss) private var dismiss

    private struct Benefit: Identifiable {
        let id = UUID()
        let systemImage: String
        let title: String
    }

    private let benefits: [Benefit] = [
        Benefit(systemImage: "timer",                 title: "Live phase countdown"),
        Benefit(systemImage: "bell.badge.fill",       title: "Automatic notifications"),
        Benefit(systemImage: "clock.arrow.circlepath", title: "Session history")
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 12)

            crownBadge
                .padding(.bottom, 20)

            Text("Unlock Live Session Timer")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Text("Guide your class through each phase automatically with countdown timers and phase notifications.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
                .padding(.horizontal, 28)

            benefitList
                .padding(.top, 28)
                .padding(.horizontal, 28)

            Spacer(minLength: 16)

            buttons
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
        }
        .background(Color(.systemBackground))
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Header badge

    private var crownBadge: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.orange, .yellow],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 88, height: 88)
                .shadow(color: .orange.opacity(0.35), radius: 12, y: 6)

            Image(systemName: "crown.fill")
                .font(.system(size: 38, weight: .semibold))
                .foregroundStyle(.white)
        }
        .accessibilityHidden(true)
    }

    // MARK: - Benefits

    private var benefitList: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(benefits) { benefit in
                HStack(spacing: 14) {
                    Image(systemName: benefit.systemImage)
                        .font(.title3)
                        .foregroundStyle(.orange)
                        .frame(width: 32, height: 32)
                        .background(.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
                        .accessibilityHidden(true)

                    Text(benefit.title)
                        .font(.body.weight(.medium))

                    Spacer()
                }
                .accessibilityElement(children: .combine)
            }
        }
    }

    // MARK: - Buttons

    private var buttons: some View {
        VStack(spacing: 12) {
            Button {
                // TODO: Replace with RevenueCat paywall presentation.
            } label: {
                Text("Upgrade to Pro")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [.orange, .pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: RoundedRectangle(cornerRadius: 14)
                    )
            }
            .accessibilityLabel("Upgrade to Pro")

            Button("Not now") { dismiss() }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
        }
    }
}
