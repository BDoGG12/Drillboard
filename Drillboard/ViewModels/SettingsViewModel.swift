import Foundation
import Observation
import MessageUI

/// Drives `SettingsView`. Owns app-identity strings (version, AI line) plus the
/// destinations for the Feedback and Legal rows so URLs and addresses live in one place.
@Observable
@MainActor
final class SettingsViewModel {
    let appName: String = "Drillboard"
    let tagline: String = "AI-powered lesson planning for coaches"

    let version: String
    let aiInfo: String = "Powered by Drillboard servers"

    let feedbackEmail: String = "support@bdoappworkshop.com"
    let feedbackSubject: String = "Drillboard Feedback"

    let privacyURL: URL = URL(string: "https://bdoappworkshop.com/privacy")!
    let termsURL: URL = URL(string: "https://bdoappworkshop.com/terms")!

    init() {
        let short = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        version = short ?? "—"
    }

    /// True when the device is configured to send mail. Drives the View's choice
    /// between presenting the mail composer and showing an "unavailable" alert.
    var canSendMail: Bool {
        MFMailComposeViewController.canSendMail()
    }

    // Workaround for Swift 6.2 / iOS 26.2 @Observable + @MainActor deinit bug.
    nonisolated deinit {}
}
