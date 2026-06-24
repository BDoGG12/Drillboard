import SwiftUI

/// Two-column wheel picker styled after the iOS Clock-app timer.
///
/// Externally, the caller passes a `Binding<Int>` of total minutes — the view splits
/// that into hours and minutes internally and writes back whenever either wheel changes.
/// Works equally well inline in a `Form` row or inside a sheet (see `DurationPickerSheet`).
struct TimePickerView: View {
    @Binding var totalMinutes: Int

    @State private var hours: Int
    @State private var minutes: Int

    private static let maxHours = 5
    private static let maxMinutes = 59

    init(totalMinutes: Binding<Int>) {
        self._totalMinutes = totalMinutes
        let clamped = max(0, min(Self.maxHours * 60 + Self.maxMinutes, totalMinutes.wrappedValue))
        _hours = State(initialValue: clamped / 60)
        _minutes = State(initialValue: clamped % 60)
    }

    var body: some View {
        HStack(spacing: 0) {
            wheelColumn(
                title: "hrs",
                selection: $hours,
                range: 0...Self.maxHours,
                accessibilityLabel: "Hours"
            )
            wheelColumn(
                title: "min",
                selection: $minutes,
                range: 0...Self.maxMinutes,
                accessibilityLabel: "Minutes"
            )
        }
        .frame(height: 160)
        .onChange(of: hours) { _, _ in syncTotal() }
        .onChange(of: minutes) { _, _ in syncTotal() }
    }

    private func wheelColumn(
        title: String,
        selection: Binding<Int>,
        range: ClosedRange<Int>,
        accessibilityLabel: String
    ) -> some View {
        VStack(spacing: 4) {
            Picker(accessibilityLabel, selection: selection) {
                ForEach(range, id: \.self) { value in
                    Text("\(value)")
                        .monospacedDigit()
                        .tag(value)
                }
            }
            .pickerStyle(.wheel)
            .labelsHidden()
            .frame(maxWidth: .infinity)
            .accessibilityLabel(accessibilityLabel)

            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)
                .accessibilityHidden(true)
        }
    }

    private func syncTotal() {
        totalMinutes = hours * 60 + minutes
    }
}

// MARK: - Sheet wrapper

/// Convenience sheet that hosts `TimePickerView` with a title bar and Done button.
/// Useful for per-row duration editing where the picker doesn't belong inline.
struct DurationPickerSheet: View {
    @Binding var totalMinutes: Int
    let title: String

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text(totalMinutes.formattedAsDuration)
                    .font(.title.bold())
                    .monospacedDigit()
                    .padding(.top, 20)

                TimePickerView(totalMinutes: $totalMinutes)
                    .padding(.horizontal)

                Spacer()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Formatting

extension Int {
    /// Formats `self` (interpreted as a count of minutes) as a human-readable duration.
    ///
    /// Examples:
    /// - `60` → `"1 hr"`
    /// - `75` → `"1 hr 15 min"`
    /// - `45` → `"45 min"`
    /// - `120` → `"2 hrs"`
    /// - `0` → `"0 min"`
    var formattedAsDuration: String {
        let total = Swift.max(0, self)
        let hours = total / 60
        let minutes = total % 60

        switch (hours, minutes) {
        case (0, _):
            return "\(minutes) min"
        case (_, 0):
            return hours == 1 ? "1 hr" : "\(hours) hrs"
        default:
            let hourLabel = hours == 1 ? "1 hr" : "\(hours) hrs"
            return "\(hourLabel) \(minutes) min"
        }
    }
}
