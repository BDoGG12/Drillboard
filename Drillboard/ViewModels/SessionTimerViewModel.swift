import Foundation
import Observation
import Combine
import SwiftUI
import UserNotifications
#if canImport(UIKit)
import UIKit
#endif

/// Drives a future `SessionTimerView`. Owns countdown state, pause/skip logic, and the
/// side effects (haptics + local notifications) that fire on every phase transition.
///
/// **Background behavior.** iOS suspends app code within ~30s of backgrounding, so a
/// foreground `Timer` cannot keep counting while the app is away. We schedule one
/// `UNNotificationRequest` per upcoming phase transition at `start()` so transitions
/// announce themselves even while suspended. When the View reports `.active` via
/// `scenePhase`, we catch the visible state up to wall-clock time.
@Observable
@MainActor
final class SessionTimerViewModel {
    // MARK: - Published state
    var currentPhaseIndex: Int = 0
    var secondsRemaining: Int = 0
    var isPaused: Bool = false
    var isComplete: Bool = false
    var totalSecondsElapsed: Int = 0

    // MARK: - Inputs
    let plan: LessonPlan

    // MARK: - Private state
    private var timerCancellable: AnyCancellable?
    private var backgroundedAt: Date?

    #if canImport(UIKit)
    private let haptic = UIImpactFeedbackGenerator(style: .medium)
    #endif

    private let notificationCenter = UNUserNotificationCenter.current()
    private let notificationIdentifierPrefix = "drillboard.phase-transition."

    // MARK: - Init

    init(plan: LessonPlan) {
        self.plan = plan
        if let first = plan.phases.first {
            self.secondsRemaining = first.durationMinutes * 60
        }
    }

    // MARK: - Derived

    var currentPhase: LessonPhase? {
        guard plan.phases.indices.contains(currentPhaseIndex) else { return nil }
        return plan.phases[currentPhaseIndex]
    }

    var totalSessionSeconds: Int {
        plan.phases.reduce(0) { $0 + $1.durationMinutes * 60 }
    }

    var overallProgress: Double {
        let total = totalSessionSeconds
        guard total > 0 else { return 0 }
        return min(1, Double(totalSecondsElapsed) / Double(total))
    }

    var currentPhaseProgress: Double {
        guard let phase = currentPhase else { return 1 }
        let total = phase.durationMinutes * 60
        guard total > 0 else { return 1 }
        let elapsed = total - secondsRemaining
        return min(1, max(0, Double(elapsed) / Double(total)))
    }

    // MARK: - Lifecycle

    func start() {
        guard !plan.phases.isEmpty else {
            isComplete = true
            return
        }
        currentPhaseIndex = 0
        secondsRemaining = plan.phases[0].durationMinutes * 60
        totalSecondsElapsed = 0
        isPaused = false
        isComplete = false

        #if canImport(UIKit)
        haptic.prepare()
        #endif

        Task { await requestNotificationPermission() }
        scheduleAllUpcomingTransitionNotifications()
        startTicking()
    }

    func pause() {
        guard !isPaused, !isComplete else { return }
        isPaused = true
        stopTicking()
        clearScheduledNotifications()
    }

    func resume() {
        guard isPaused, !isComplete else { return }
        isPaused = false
        scheduleAllUpcomingTransitionNotifications()
        startTicking()
    }

    func skipToNext() {
        guard !isComplete else { return }
        let leftover = secondsRemaining
        totalSecondsElapsed += leftover
        secondsRemaining = 0
        advancePhaseIfNeeded()
    }

    func goBack() {
        guard !isComplete else { return }
        let currentDuration = (currentPhase?.durationMinutes ?? 0) * 60
        if secondsRemaining == currentDuration, currentPhaseIndex > 0 {
            // At the start of the phase — rewind to previous phase.
            let previousIndex = currentPhaseIndex - 1
            let previousDuration = plan.phases[previousIndex].durationMinutes * 60
            totalSecondsElapsed = max(0, totalSecondsElapsed - previousDuration)
            currentPhaseIndex = previousIndex
            secondsRemaining = previousDuration
            firePhaseTransitionEffects()
        } else {
            // Mid-phase: rewind to the start of this phase.
            let consumedThisPhase = currentDuration - secondsRemaining
            totalSecondsElapsed = max(0, totalSecondsElapsed - consumedThisPhase)
            secondsRemaining = currentDuration
        }
        if !isPaused { scheduleAllUpcomingTransitionNotifications() }
    }

    func restart() {
        clearScheduledNotifications()
        stopTicking()
        start()
    }

    /// Called by the View when `scenePhase` changes. Catches visible state up to
    /// wall-clock time when the app returns from background.
    func handleScenePhase(_ phase: ScenePhase) {
        switch phase {
        case .background, .inactive:
            if backgroundedAt == nil, !isPaused, !isComplete {
                backgroundedAt = Date()
                stopTicking()
            }
        case .active:
            guard let backgroundedAt, !isPaused, !isComplete else {
                self.backgroundedAt = nil
                if !isPaused, !isComplete { startTicking() }
                return
            }
            let secondsAway = Int(Date().timeIntervalSince(backgroundedAt).rounded())
            self.backgroundedAt = nil
            catchUp(by: secondsAway)
            if !isComplete { startTicking() }
        @unknown default:
            break
        }
    }

    func cancel() {
        stopTicking()
        clearScheduledNotifications()
    }

    deinit {
        let ids = (0..<plan.phases.count).map { notificationIdentifierPrefix + String($0) }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }

    // MARK: - Ticking

    private func startTicking() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    private func stopTicking() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    private func tick() {
        guard !isPaused, !isComplete else { return }
        if secondsRemaining > 0 {
            secondsRemaining -= 1
            totalSecondsElapsed += 1
        }
        if secondsRemaining == 0 {
            advancePhaseIfNeeded()
        }
    }

    private func advancePhaseIfNeeded() {
        while secondsRemaining == 0 {
            let nextIndex = currentPhaseIndex + 1
            if nextIndex >= plan.phases.count {
                isComplete = true
                stopTicking()
                clearScheduledNotifications()
                firePhaseTransitionEffects()
                return
            }
            currentPhaseIndex = nextIndex
            secondsRemaining = plan.phases[nextIndex].durationMinutes * 60
            firePhaseTransitionEffects()
        }
    }

    private func firePhaseTransitionEffects() {
        #if canImport(UIKit)
        haptic.impactOccurred()
        haptic.prepare()
        #endif
    }

    private func catchUp(by secondsAway: Int) {
        var remaining = secondsAway
        while remaining > 0, !isComplete {
            if remaining >= secondsRemaining {
                remaining -= secondsRemaining
                totalSecondsElapsed += secondsRemaining
                secondsRemaining = 0
                advancePhaseIfNeeded()
            } else {
                secondsRemaining -= remaining
                totalSecondsElapsed += remaining
                remaining = 0
            }
        }
    }

    // MARK: - Notifications

    private func requestNotificationPermission() async {
        _ = try? await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
    }

    private func scheduleAllUpcomingTransitionNotifications() {
        clearScheduledNotifications()
        guard !isComplete else { return }

        var offset = TimeInterval(secondsRemaining)
        for nextIndex in (currentPhaseIndex + 1)..<plan.phases.count {
            let phase = plan.phases[nextIndex]

            let content = UNMutableNotificationContent()
            content.title = "Time for \(phase.name)!"
            content.body = "Drillboard session — phase \(nextIndex + 1) of \(plan.phases.count)."
            content.sound = .default

            guard offset > 0 else { continue }
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: offset, repeats: false)
            let request = UNNotificationRequest(
                identifier: notificationIdentifierPrefix + String(nextIndex),
                content: content,
                trigger: trigger
            )
            notificationCenter.add(request)

            offset += TimeInterval(phase.durationMinutes * 60)
        }
    }

    private func clearScheduledNotifications() {
        let ids = (0..<plan.phases.count).map { notificationIdentifierPrefix + String($0) }
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ids)
    }
}
