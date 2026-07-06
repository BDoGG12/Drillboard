import Foundation
import Observation

/// Drives the first-launch onboarding flow (`OnboardingView`). Owns the current
/// page, the sport the user picks, and the persistence hooks that mark onboarding
/// complete so it never shows again.
@Observable
@MainActor
final class OnboardingViewModel {
    // MARK: - Published state
    var currentPage: Int = 0
    var selectedSport: SportDiscipline = .karate

    // MARK: - Config
    let totalPages: Int = 4

    // MARK: - Storage keys
    static let hasCompletedOnboardingKey = "hasCompletedOnboarding"
    static let defaultSportKey = "drillboard_default_sport"

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let raw = defaults.string(forKey: Self.defaultSportKey),
           let saved = SportDiscipline(rawValue: raw) {
            selectedSport = saved
        }
    }

    // MARK: - Derived

    var isFirstPage: Bool { currentPage == 0 }
    var isLastPage: Bool { currentPage == totalPages - 1 }

    // MARK: - Navigation

    func nextPage() {
        guard currentPage < totalPages - 1 else { return }
        currentPage += 1
    }

    func previousPage() {
        guard currentPage > 0 else { return }
        currentPage -= 1
    }

    func goToPage(_ page: Int) {
        currentPage = max(0, min(totalPages - 1, page))
    }

    // MARK: - Completion

    /// Marks onboarding as complete and persists the user's discipline choice.
    /// The `OnboardingView`'s `.fullScreenCover` dismisses when this fires.
    func completeOnboarding() {
        defaults.set(true, forKey: Self.hasCompletedOnboardingKey)
        defaults.set(selectedSport.rawValue, forKey: Self.defaultSportKey)
    }

    // Workaround for Swift 6.2 / iOS 26.2 @Observable + @MainActor deinit bug.
    nonisolated deinit {}
}
