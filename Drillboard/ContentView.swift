import SwiftUI

struct ContentView: View {
    @StateObject private var store = PlanStore()
    @State private var showingNewPlan = false
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            Group {
                if store.plans.isEmpty {
                    EmptyPlansView()
                } else {
                    planList
                }
            }
            .navigationTitle("Lesson Plans")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingNewPlan = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewPlan) {
                NewPlanSheet(store: store)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }

    private var planList: some View {
        List {
            ForEach(store.plans) { plan in
                NavigationLink(destination: PlanDetailView(plan: plan, store: store)) {
                    PlanRowView(plan: plan)
                }
            }
            .onDelete { offsets in
                store.delete(at: offsets)
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
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))

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
        VStack(spacing: 16) {
            Image(systemName: "list.clipboard")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)
            Text("No lesson plans yet")
                .font(.title3)
                .fontWeight(.semibold)
            Text("Tap + to create your first session plan.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
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
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}
