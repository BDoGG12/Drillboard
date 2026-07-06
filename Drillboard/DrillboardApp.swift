import SwiftUI

@main
struct DrillboardApp: App {
    @State private var subscriptionManager = SubscriptionManager()

    @AppStorage(OnboardingViewModel.hasCompletedOnboardingKey)
    private var hasCompletedOnboarding: Bool = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(subscriptionManager)
                .fullScreenCover(isPresented: .init(
                    get: { !hasCompletedOnboarding },
                    set: { hasCompletedOnboarding = !$0 }
                )) {
                    OnboardingView()
                        .environment(subscriptionManager)
                }
        }
    }
}
