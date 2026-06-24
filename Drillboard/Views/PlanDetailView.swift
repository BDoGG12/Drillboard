import SwiftUI

struct PlanDetailView: View {
    @State private var viewModel: PlanDetailViewModel
    @Environment(\.dismiss) private var dismiss

    // UI-only state
    @State private var showingAISheet = false
    @State private var showingDeleteAlert = false

    init(plan: LessonPlan, store: PlanStore) {
        _viewModel = State(wrappedValue: PlanDetailViewModel(plan: plan, store: store))
    }

    var body: some View {
        @Bindable var vm = viewModel

        List {
            Section {
                MetaFieldsSection(viewModel: viewModel)
            }

            Section("Lesson Structure") {
                ForEach($vm.plan.phases) { $phase in
                    PhaseRowView(phase: $phase)
                }
            }

            Section("General Notes") {
                TextEditor(text: $vm.plan.notes)
                    .frame(minHeight: 80)
                    .font(.body)
            }

            Section {
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Label("Delete Plan", systemImage: "trash")
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(vm.plan.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            // TODO: DRIL-5 — re-enable once Vercel proxy is live.
            // ToolbarItem(placement: .topBarTrailing) {
            //     Button {
            //         showingAISheet = true
            //     } label: {
            //         Label("AI Ideas", systemImage: "sparkles")
            //     }
            //     .tint(.purple)
            // }
        }
        .sheet(isPresented: $showingAISheet) {
            AIIdeasSheet(planViewModel: viewModel)
        }
        .alert("Delete Plan?", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                viewModel.delete()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }
}

// MARK: - Meta Fields

private struct MetaFieldsSection: View {
    @Bindable var viewModel: PlanDetailViewModel

    var body: some View {
        // Title
        HStack {
            Label("Title", systemImage: "pencil")
                .foregroundStyle(.secondary)
                .frame(width: 110, alignment: .leading)
            TextField("Session title", text: $viewModel.plan.title)
                .multilineTextAlignment(.trailing)
        }

        // Sport
        HStack {
            Label("Discipline", systemImage: "figure.martial.arts")
                .foregroundStyle(.secondary)
                .frame(width: 110, alignment: .leading)
            Spacer()
            Picker("", selection: $viewModel.plan.sport) {
                ForEach(SportDiscipline.allCases, id: \.self) { s in
                    Text("\(s.emoji) \(s.rawValue)").tag(s)
                }
            }
            .labelsHidden()
        }

        // Level
        HStack {
            Label("Level", systemImage: "chart.bar")
                .foregroundStyle(.secondary)
                .frame(width: 110, alignment: .leading)
            Spacer()
            Picker("", selection: $viewModel.plan.level) {
                ForEach(SkillLevel.allCases, id: \.self) { l in
                    Text(l.rawValue).tag(l)
                }
            }
            .labelsHidden()
        }

        // Duration — tap the value to edit via the wheel picker sheet
        DurationRow(
            label: "Duration",
            systemImage: "clock",
            totalMinutes: $viewModel.plan.durationMinutes,
            sheetTitle: "Session Duration"
        )

        // Focus
        HStack {
            Label("Focus", systemImage: "target")
                .foregroundStyle(.secondary)
                .frame(width: 110, alignment: .leading)
            TextField("e.g. roundhouse kick", text: $viewModel.plan.focus)
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - Duration Row (reusable inside metaFields)

private struct DurationRow: View {
    let label: String
    let systemImage: String
    @Binding var totalMinutes: Int
    let sheetTitle: String

    @State private var showingPicker = false

    var body: some View {
        HStack {
            Label(label, systemImage: systemImage)
                .foregroundStyle(.secondary)
                .frame(width: 110, alignment: .leading)
            Spacer()
            Button {
                showingPicker = true
            } label: {
                HStack(spacing: 4) {
                    Text(totalMinutes.formattedAsDuration)
                        .monospacedDigit()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .foregroundStyle(.primary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(label) \(totalMinutes.formattedAsDuration). Tap to change.")
        }
        .sheet(isPresented: $showingPicker) {
            DurationPickerSheet(totalMinutes: $totalMinutes, title: sheetTitle)
        }
    }
}

// MARK: - Phase Row

struct PhaseRowView: View {
    @Binding var phase: LessonPhase
    @State private var isExpanded = true
    @State private var showingDurationPicker = false

    var dotColor: Color {
        Color(hex: phase.colorHex) ?? .gray
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(dotColor)
                            .frame(width: 10, height: 10)
                            .accessibilityHidden(true)
                        Text(phase.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(phase.name), \(isExpanded ? "expanded" : "collapsed")")

                Spacer()

                Button {
                    showingDurationPicker = true
                } label: {
                    Text(phase.durationMinutes.formattedAsDuration)
                        .font(.caption.weight(.semibold))
                        .monospacedDigit()
                        .foregroundStyle(dotColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(dotColor.opacity(0.15), in: Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(phase.name) duration \(phase.durationMinutes.formattedAsDuration). Tap to change.")

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityHidden(true)
            }
            .padding(.vertical, 6)

            if isExpanded {
                TextEditor(text: $phase.content)
                    .font(.subheadline)
                    .frame(minHeight: 70)
                    .overlay(alignment: .topLeading) {
                        if phase.content.isEmpty {
                            Text(phase.placeholder)
                                .font(.subheadline)
                                .foregroundStyle(.tertiary)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                                .allowsHitTesting(false)
                        }
                    }
            }
        }
        .sheet(isPresented: $showingDurationPicker) {
            DurationPickerSheet(totalMinutes: $phase.durationMinutes, title: phase.name)
        }
    }
}

// MARK: - Color Extension

extension Color {
    init?(hex: String) {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if h.hasPrefix("#") { h = String(h.dropFirst()) }
        guard h.count == 6, let val = UInt64(h, radix: 16) else { return nil }
        self.init(
            red:   Double((val >> 16) & 0xFF) / 255,
            green: Double((val >> 8)  & 0xFF) / 255,
            blue:  Double( val        & 0xFF) / 255
        )
    }
}
