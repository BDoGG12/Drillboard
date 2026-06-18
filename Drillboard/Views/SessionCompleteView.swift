import SwiftUI

struct SessionCompleteView: View {
    let plan: LessonPlan
    let totalSeconds: Int

    @Environment(\.dismiss) private var dismiss

    @State private var checkmarkScale: CGFloat = 0
    @State private var checkmarkOpacity: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 20)

            checkmark
                .padding(.bottom, 12)

            Text("Session Complete!")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
                .padding(.bottom, 24)

            phaseSummaryList
                .padding(.horizontal, 24)

            Spacer(minLength: 12)

            totalRow
                .padding(.horizontal, 24)
                .padding(.bottom, 24)

            doneButton
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
        }
        .background(Color(.systemBackground))
        .onAppear(perform: animateCheckmark)
    }

    // MARK: - Checkmark

    private var checkmark: some View {
        ZStack {
            Circle()
                .fill(.green.opacity(0.12))
                .frame(width: 140, height: 140)

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 100, weight: .semibold))
                .foregroundStyle(.green)
                .scaleEffect(checkmarkScale)
                .opacity(checkmarkOpacity)
        }
        .accessibilityHidden(true)
    }

    private func animateCheckmark() {
        withAnimation(.spring(response: 0.55, dampingFraction: 0.62)) {
            checkmarkScale = 1.0
        }
        withAnimation(.easeIn(duration: 0.25)) {
            checkmarkOpacity = 1.0
        }
    }

    // MARK: - Phase summary

    private var phaseSummaryList: some View {
        VStack(spacing: 10) {
            ForEach(plan.phases) { phase in
                phaseRow(phase)
            }
        }
    }

    private func phaseRow(_ phase: LessonPhase) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .font(.title3)
                .accessibilityHidden(true)

            Text(phase.name)
                .font(.body.weight(.medium))

            Spacer()

            Text("\(phase.durationMinutes) min")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(.gray.opacity(0.10), in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Total row

    private var totalRow: some View {
        HStack {
            Text("Total")
                .font(.headline)
            Spacer()
            Text(formattedTotal)
                .font(.title3.bold())
                .monospacedDigit()
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(.gray.opacity(0.10), in: RoundedRectangle(cornerRadius: 14))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Total session duration \(formattedTotal)")
    }

    private var formattedTotal: String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        if minutes >= 60 {
            let hours = minutes / 60
            let remainder = minutes % 60
            return String(format: "%d:%02d:%02d", hours, remainder, seconds)
        }
        return String(format: "%d:%02d", minutes, seconds)
    }

    // MARK: - Done

    private var doneButton: some View {
        Button {
            dismiss()
        } label: {
            Text("Done")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(.green, in: RoundedRectangle(cornerRadius: 14))
        }
        .accessibilityLabel("Done — close session")
    }
}
