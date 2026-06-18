import SwiftUI

struct SessionTimerView: View {
    let plan: LessonPlan
    @State private var viewModel: SessionTimerViewModel

    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase

    init(plan: LessonPlan) {
        self.plan = plan
        _viewModel = State(wrappedValue: SessionTimerViewModel(plan: plan))
    }

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            if viewModel.isComplete {
                SessionCompleteView(
                    plan: plan,
                    totalSeconds: viewModel.totalSecondsElapsed
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else {
                timerScreen
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: viewModel.isComplete)
        .onAppear { viewModel.start() }
        .onDisappear { viewModel.cancel() }
        .onChange(of: scenePhase) { _, newPhase in
            viewModel.handleScenePhase(newPhase)
        }
    }

    // MARK: - Timer screen

    private var timerScreen: some View {
        VStack(spacing: 0) {
            topBar
            phaseDotsRow
                .padding(.top, 12)

            Spacer(minLength: 12)

            VStack(spacing: 18) {
                Text(viewModel.currentPhase?.name ?? "Session")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                countdownRing
                    .frame(width: 280, height: 280)
                    .padding(.vertical, 8)
            }

            Spacer(minLength: 12)

            controlsRow
                .padding(.horizontal, 24)

            Spacer(minLength: 12)

            overallProgressBar
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
        }
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            Button {
                viewModel.cancel()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 36, height: 36)
                    .background(.gray.opacity(0.12), in: Circle())
            }
            .accessibilityLabel("End session")

            Spacer()

            Text(plan.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Spacer()

            Button {
                viewModel.restart()
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 36, height: 36)
                    .background(.gray.opacity(0.12), in: Circle())
            }
            .accessibilityLabel("Restart session")
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    // MARK: - Phase dots

    private var phaseDotsRow: some View {
        HStack(spacing: 8) {
            ForEach(Array(plan.phases.enumerated()), id: \.element.id) { index, phase in
                phaseDot(phase: phase, index: index)
            }
        }
        .padding(.horizontal, 20)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Phase \(viewModel.currentPhaseIndex + 1) of \(plan.phases.count)")
    }

    @ViewBuilder
    private func phaseDot(phase: LessonPhase, index: Int) -> some View {
        let color = Color(hex: phase.colorHex) ?? .gray
        let isCurrent = index == viewModel.currentPhaseIndex
        let isCompleted = index < viewModel.currentPhaseIndex

        Capsule()
            .fill(dotFill(color: color, isCurrent: isCurrent, isCompleted: isCompleted))
            .overlay {
                Capsule()
                    .stroke(color.opacity(isCurrent ? 1 : 0.4), lineWidth: isCurrent ? 2 : 1)
            }
            .frame(height: 8)
            .frame(maxWidth: .infinity)
            .scaleEffect(y: isCurrent ? 1.4 : 1, anchor: .center)
            .animation(.easeInOut(duration: 0.25), value: viewModel.currentPhaseIndex)
    }

    private func dotFill(color: Color, isCurrent: Bool, isCompleted: Bool) -> Color {
        if isCompleted { return color }
        if isCurrent { return color.opacity(0.45) }
        return color.opacity(0.08)
    }

    // MARK: - Countdown ring

    private var countdownRing: some View {
        ZStack {
            Circle()
                .stroke(.gray.opacity(0.15), lineWidth: 18)

            Circle()
                .trim(from: 0, to: 1 - viewModel.currentPhaseProgress)
                .stroke(currentPhaseColor, style: StrokeStyle(lineWidth: 18, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.95), value: viewModel.secondsRemaining)

            VStack(spacing: 4) {
                Text(timeString(from: viewModel.secondsRemaining))
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                Text(viewModel.isPaused ? "Paused" : "Remaining")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(timeString(from: viewModel.secondsRemaining)) remaining in \(viewModel.currentPhase?.name ?? "session")")
    }

    private var currentPhaseColor: Color {
        guard let phase = viewModel.currentPhase else { return .gray }
        return Color(hex: phase.colorHex) ?? .accentColor
    }

    // MARK: - Controls

    private var controlsRow: some View {
        HStack(spacing: 24) {
            controlButton(
                systemImage: "backward.fill",
                label: "Previous phase",
                size: 56
            ) { viewModel.goBack() }

            Button {
                if viewModel.isPaused { viewModel.resume() } else { viewModel.pause() }
            } label: {
                Image(systemName: viewModel.isPaused ? "play.fill" : "pause.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 76, height: 76)
                    .background(currentPhaseColor, in: Circle())
            }
            .accessibilityLabel(viewModel.isPaused ? "Resume" : "Pause")

            controlButton(
                systemImage: "forward.fill",
                label: "Next phase",
                size: 56
            ) { viewModel.skipToNext() }
        }
    }

    private func controlButton(systemImage: String, label: String, size: CGFloat, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)
                .frame(width: size, height: size)
                .background(.gray.opacity(0.12), in: Circle())
        }
        .accessibilityLabel(label)
    }

    // MARK: - Overall progress

    private var overallProgressBar: some View {
        VStack(spacing: 6) {
            HStack {
                Text("Overall")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                Spacer()
                Text("\(timeString(from: viewModel.totalSecondsElapsed)) / \(timeString(from: viewModel.totalSessionSeconds))")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            ProgressView(value: viewModel.overallProgress)
                .progressViewStyle(.linear)
                .tint(currentPhaseColor)
        }
    }

    // MARK: - Time formatting

    private func timeString(from seconds: Int) -> String {
        let safe = max(0, seconds)
        let m = safe / 60
        let s = safe % 60
        return String(format: "%02d:%02d", m, s)
    }
}
