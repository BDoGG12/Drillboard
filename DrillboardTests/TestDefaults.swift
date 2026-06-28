import Foundation

/// Helper for creating an isolated `UserDefaults` suite for tests.
///
/// All storage tests use the same suite name (`"DrillboardTests"`). `reset()` clears
/// the entire suite via `removePersistentDomain(forName:)` — the documented way to
/// wipe a UserDefaults suite without touching inherited system keys.
enum TestDefaults {
    static let suiteName = "DrillboardTests"

    static func make() -> UserDefaults {
        UserDefaults(suiteName: suiteName)!
    }

    /// Clears every key in the test suite. Call from `setUp` and `tearDown`.
    static func reset() {
        let defaults = make()
        defaults.removePersistentDomain(forName: suiteName)
        defaults.synchronize()
    }
}
