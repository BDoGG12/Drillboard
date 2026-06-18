import SwiftUI

struct PlanDetailView: View {
    @State private var viewModel: PlanDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(SubscriptionManager.self) private var subscriptionManager

    // UI-only state
    @State private var showingAISheet = false
    @State private var showingDeleteAlert = false
    @State private var showingTimer = false
    @State private var showingUpgrade = false

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
                startSessionButton
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                    .listRowBackground(Color.clear)
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
        .fullScreenCover(isPresented: $showingTimer) {
            SessionTimerView(plan: viewModel.plan)
        }
        .sheet(isPresented: $showingUpgrade) {
            UpgradePromptSheet()
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

    // MARK: - Start Session

    private var startSessionButton: some View {
        Button {
            if subscriptionManager.isPro {
                showingTimer = true
            } else {
                showingUpgrade = true
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "play.fill")
                    .font(.headline)
                Text("Start Session")
                    .font(.headline)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(.orange, in: RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Start live session timer")
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

        // Duration
        HStack {
            Label("Duration", systemImage: "clock")
                .foregroundStyle(.secondary)
                .frame(width: 110, alignment: .leading)
            Spacer()
            Picker("", selection: $viewModel.plan.durationMinutes) {
                ForEach([30, 45, 60, 75, 90, 120], id: \.self) { d in
                    Text("\(d) min").tag(d)
                }
            }
            .labelsHidden()
        }

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

// MARK: - Phase Row

struct PhaseRowView: View {
    @Binding var phase: LessonPhase
    @State private var isExpanded = true

    var dotColor: Color {
        Color(hex: phase.colorHex) ?? .gray
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Circle()
                        .fill(dotColor)
                        .frame(width: 10, height: 10)
                        .accessibilityHidden(true)
                    Text(phase.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Spacer()
                    Text("\(phase.durationMinutes) min")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
            .padding(.vertical, 6)
            .accessibilityLabel("\(phase.name), \(phase.durationMinutes) minutes, \(isExpanded ? "expanded" : "collapsed")")

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
