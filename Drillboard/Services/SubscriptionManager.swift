import Foundation
import Observation

/// Gates Pro-only features. Currently a placeholder with `isPro` hardcoded to `true`
/// so the timer is reachable during development.
///
/// // TODO: Replace with RevenueCat integration
@Observable
@MainActor
final class SubscriptionManager {
    /// Whether the current user has an active Pro subscription.
    /// Hardcoded to `true` for development; flip to `false` to test the upgrade prompt.
    var isPro: Bool = true

    // MARK: - Purchase actions (DRIL-12 placeholders)

    /// Placeholder for annual subscription purchase. Wires up in DRIL-12 via RevenueCat.
    func purchaseAnnual() {
        // TODO: DRIL-12 — invoke RevenueCat annual product purchase flow.
    }

    /// Placeholder for monthly subscription purchase. Wires up in DRIL-12 via RevenueCat.
    func purchaseMonthly() {
        // TODO: DRIL-12 — invoke RevenueCat monthly product purchase flow.
    }

    /// Placeholder for restoring existing entitlements.
    func restorePurchases() {
        // TODO: DRIL-12 — call RevenueCat's restorePurchases and update isPro.
    }

    // Workaround for Swift 6.2 / iOS 26.2 @Observable + @MainActor deinit bug — see DrillboardTests.
    nonisolated deinit {}
}
