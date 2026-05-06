import SwiftUI

struct PlanDetailView: View {
    @State private var plan: LessonPlan
    @ObservedObject var store: PlanStore
    @Environment(\.dismiss) private var dismiss

    @State private var showingAISheet = false
    @State private var showingDeleteAlert = false

    init(plan: LessonPlan, store: PlanStore) {
        _plan = State(initialValue: plan)
        self.store = store
    }

    var body: some View {
        List {
            // Header section
            Section {
                metaFields
            }

            // Phases
            Section("Lesson Structure") {
                ForEach($plan.phases) { $phase in
                    PhaseRowView(phase: $phase)
                }
            }

            // Notes
            Section("General Notes") {
                TextEditor(text: $plan.notes)
                    .frame(minHeight: 80)
                    .font(.body)
            }

            // Danger zone
            Section {
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Label("Delete Plan", systemImage: "trash")
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(plan.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAISheet = true
                } label: {
                    Label("AI Ideas", systemImage: "sparkles")
                }
                .tint(.purple)
            }
        }
        .onChange(of: plan) { _, newValue in
            store.update(newValue)
        }
        .sheet(isPresented: $showingAISheet) {
            AIIdeasSheet(plan: $plan, store: store)
        }
        .alert("Delete Plan?", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                store.delete(plan)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }

    private var metaFields: some View {
        Group {
            // Title
            HStack {
                Label("Title", systemImage: "pencil")
                    .foregroundStyle(.secondary)
                    .frame(width: 110, alignment: .leading)
                TextField("Session title", text: $plan.title)
                    .multilineTextAlignment(.trailing)
            }

            // Sport
            HStack {
                Label("Discipline", systemImage: "figure.martial.arts")
                    .foregroundStyle(.secondary)
                    .frame(width: 110, alignment: .leading)
                Spacer()
                Picker("", selection: $plan.sport) {
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
                Picker("", selection: $plan.level) {
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
                Picker("", selection: $plan.durationMinutes) {
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
                TextField("e.g. roundhouse kick", text: $plan.focus)
                    .multilineTextAlignment(.trailing)
            }
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
                    Text(phase.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
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
