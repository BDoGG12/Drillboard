import SwiftUI

struct ContentView: View {
    @State private var viewModel = PlanListViewModel()

    // UI-only state
    @State private var showingNewPlan = false
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.plans.isEmpty {
                    EmptyPlansView()
                } else {
                    planList
                }
            }
            .navigationTitle("Lesson Plans")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingNewPlan = true
                    } label: {
                        Label("New Plan", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewPlan) {
                NewPlanSheet(listViewModel: viewModel)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }

    private var planList: some View {
        List {
            ForEach(viewModel.plans) { plan in
                NavigationLink {
                    PlanDetailView(plan: plan, store: viewModel.store)
                } label: {
                    PlanRowView(plan: plan)
                }
            }
            .onDelete { offsets in
                viewModel.deletePlans(at: offsets)
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - Plan Row

struct PlanRowView: View {
    let plan: LessonPlan

    var body: some View {
        HStack(spacing: 14) {
            Text(plan.sport.emoji)
                .font(.system(size: 32))
                .frame(width: 44, height: 44)
                .background(.gray.opacity(0.15), in: RoundedRectangle(cornerRadius: 10))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(plan.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(plan.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if !plan.focus.isEmpty {
                    Text("Focus: \(plan.focus)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }

            Spacer()

            LevelBadge(level: plan.level)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Empty State

struct EmptyPlansView: View {
    var body: some View {
        ContentUnavailableView(
            "No Lesson Plans Yet",
            systemImage: "list.clipboard",
            description: Text("Tap + to create your first session plan.")
        )
    }
}

// MARK: - Level Badge

struct LevelBadge: View {
    let level: SkillLevel

    var color: Color {
        switch level {
        case .beginner:     return .green
        case .intermediate: return .blue
        case .advanced:     return .red
        case .mixed:        return .purple
        }
    }

    var body: some View {
        Text(level.rawValue)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15), in: Capsule())
            .foregroundStyle(color)
    }
}
