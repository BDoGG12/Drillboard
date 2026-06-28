import XCTest
@testable import Drillboard

@MainActor
final class SettingsViewModelTests: XCTestCase {

    // MARK: - Initialization

    func testSettingsViewModelInitializesWithExpectedFields() {
        let vm = SettingsViewModel()

        XCTAssertEqual(vm.appName, "Drillboard")
        XCTAssertEqual(vm.tagline, "AI-powered lesson planning for coaches")
        XCTAssertEqual(vm.aiInfo, "Powered by Drillboard servers")
        XCTAssertEqual(vm.feedbackEmail, "support@bdoappworkshop.com")
        XCTAssertEqual(vm.feedbackSubject, "Drillboard Feedback")
        XCTAssertEqual(vm.privacyURL.absoluteString, "https://bdoappworkshop.com/privacy")
        XCTAssertEqual(vm.termsURL.absoluteString, "https://bdoappworkshop.com/terms")
    }

    func testVersionIsReadFromBundleAndNonEmpty() {
        let vm = SettingsViewModel()
        XCTAssertFalse(vm.version.isEmpty)
    }

    // MARK: - DRIL-7 sanity (no apiKey property remains)

    /// `SettingsViewModel` had an `apiKey` field before DRIL-7 stripped it. Mirror reflection
    /// asserts the surface no longer exposes that property — if it ever returns, this fails.
    func testSettingsViewModelHasNoApiKeyProperty() {
        let mirror = Mirror(reflecting: SettingsViewModel())
        let propertyNames = mirror.children.compactMap(\.label)
        XCTAssertFalse(
            propertyNames.contains("apiKey"),
            "SettingsViewModel exposes an `apiKey` property — DRIL-7 removed this; do not re-add."
        )
    }

    /// Belt-and-suspenders for DRIL-7: no code path touches the legacy
    /// `drillboard_api_key` UserDefaults key after instantiation.
    func testSettingsViewModelLeavesLegacyApiKeyUserDefaultsUntouched() {
        let defaults = TestDefaults.make()
        TestDefaults.reset()

        _ = SettingsViewModel()

        XCTAssertNil(defaults.string(forKey: "drillboard_api_key"))
        TestDefaults.reset()
    }
}
