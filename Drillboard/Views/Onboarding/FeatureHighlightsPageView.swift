import SwiftUI

struct FeatureHighlightsPageView: View {
    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 24)
                .padding(.top, 32)
                .padding(.bottom, 24)

            VStack(spacing: 14) {
                ForEach(OnboardingFeature.all) { feature in
                    FeatureCard(feature: feature)
                }
            }
            .padding(.horizontal, 20)

            Spacer(minLength: 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var header: some View {
        Text("Everything you need to coach better")
            .font(.system(size: 32, weight: .bold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - Feature model

private struct OnboardingFeature: Identifiable {
    let id = UUID()
    let systemImage: String
    let title: String
    let description: String

    static let all: [OnboardingFeature] = [
        OnboardingFeature(
            systemImage: "list.clipboard",
            title: "Structured Lesson Plans",
            description: "Build sessions with a 5-phase structure tailored to your sport."
        ),
        OnboardingFeature(
            systemImage: "timer",
            title: "Live Session Timer",
            description: "Guide your class through each phase with automatic countdown and notifications."
        ),
        OnboardingFeature(
            systemImage: "sparkles",
            title: "AI Drill Ideas (Pro)",
            description: "Get instant creative ideas tailored to your sport, level, and focus."
        )
    ]
}

// MARK: - Card

private struct FeatureCard: View {
    let feature: OnboardingFeature

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: feature.systemImage)
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(Color.drillboardOrange)
                .frame(width: 48, height: 48)
                .background(Color.drillboardOrange.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(feature.title)
                    .font(.headline)
                Text(feature.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color.gray.opacity(0.08), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}
