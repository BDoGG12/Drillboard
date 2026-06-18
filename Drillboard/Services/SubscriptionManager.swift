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
}
