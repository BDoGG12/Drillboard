import XCTest
@testable import Drillboard

@MainActor
final class SubscriptionManagerTests: XCTestCase {

    func testIsProDefaultsToTrueDuringDevelopment() {
        let manager = SubscriptionManager()
        XCTAssertTrue(
            manager.isPro,
            "The development placeholder hardcodes isPro = true so the timer is reachable."
        )
    }

    func testTogglingIsProUpdatesValue() {
        let manager = SubscriptionManager()

        manager.isPro = false
        XCTAssertFalse(manager.isPro)

        manager.isPro = true
        XCTAssertTrue(manager.isPro)
    }
}
