import SwiftUI
import MessageUI

/// SwiftUI wrapper around `MFMailComposeViewController` for presenting in a sheet.
///
/// The mail composer's delegate calls back on the main thread when the user finishes,
/// at which point we close the enclosing SwiftUI sheet via `\.dismiss`.
struct MailComposer: UIViewControllerRepresentable {
    let toRecipients: [String]
    let subject: String

    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setToRecipients(toRecipients)
        vc.setSubject(subject)
        vc.mailComposeDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss)
    }

    final class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let dismiss: DismissAction

        init(dismiss: DismissAction) {
            self.dismiss = dismiss
        }

        nonisolated func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            Task { @MainActor in
                dismiss()
            }
        }
    }
}
