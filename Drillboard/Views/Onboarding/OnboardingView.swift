import SwiftUI

/// First-launch onboarding pager. Presented as a full-screen cover over `ContentView`
/// while `hasCompletedOnboarding` is false; dismisses itself once the user finishes
/// via Get Started or Not now.
struct OnboardingView: View {
    @State private var viewModel = OnboardingViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(SubscriptionManager.self) private var subscriptionManager

    var body: some View {
        @Bindable var vm = viewModel

        VStack(spacing: 0) {
            TabView(selection: $vm.currentPage) {
                WelcomePageView(onGetStarted: goForward)
                    .tag(0)

                DisciplinePickerPageView(selection: $vm.selectedSport)
                    .tag(1)

                FeatureHighlightsPageView()
                    .tag(2)

                PaywallPageView(
                    subscriptionManager: subscriptionManager,
                    onNotNow: finish
                )
                .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.25), value: viewModel.currentPage)

            bottomBar
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .interactiveDismissDisabled(true)
    }

    // MARK: - Bottom navigation

    private var bottomBar: some View {
        HStack(spacing: 16) {
            backButton
                .frame(width: 90, alignment: .leading)

            Spacer()

            pageDots

            Spacer()

            forwardOrFinishButton
                .frame(width: 130, alignment: .trailing)
        }
        .frame(maxWidth: .infinity)
    }

    private var backButton: some View {
        Group {
            if viewModel.isFirstPage {
                Color.clear
                    .frame(width: 1, height: 1)
                    .accessibilityHidden(true)
            } else {
                Button {
                    viewModel.previousPage()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.subheadline.weight(.semibold))
                        Text("Back")
                            .font(.subheadline.weight(.medium))
                    }
                    .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Back to previous page")
            }
        }
    }

    private var pageDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<viewModel.totalPages, id: \.self) { index in
                Capsule()
                    .fill(dotFill(for: index))
                    .frame(width: index == viewModel.currentPage ? 22 : 8, height: 8)
                    .animation(.easeInOut(duration: 0.25), value: viewModel.currentPage)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Page \(viewModel.currentPage + 1) of \(viewModel.totalPages)")
    }

    private func dotFill(for index: Int) -> Color {
        index == viewModel.currentPage ? Color.drillboardOrange : Color.gray.opacity(0.28)
    }

    @ViewBuilder
    private var forwardOrFinishButton: some View {
        if viewModel.isLastPage {
            Button(action: finish) {
                Text("Get Started")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(Color.drillboardOrange, in: Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Get Started — finish onboarding")
        } else {
            Button(action: goForward) {
                HStack(spacing: 4) {
                    Text("Next")
                        .font(.subheadline.weight(.medium))
                    Image(systemName: "chevron.right")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(Color.drillboardOrange)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Next page")
        }
    }

    // MARK: - Actions

    private func goForward() {
        viewModel.nextPage()
    }

    private func finish() {
        viewModel.completeOnboarding()
        dismiss()
    }
}

// MARK: - Brand color

extension Color {
    /// The Drillboard brand orange used across onboarding — matches the app icon.
    static let drillboardOrange: Color = Color(hex: "FF6B1A") ?? .orange
}
