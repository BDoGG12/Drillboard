import SwiftUI

struct NewPlanSheet: View {
    @ObservedObject var store: PlanStore
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var sport: SportDiscipline = .karate
    @State private var level: SkillLevel = .beginner
    @State private var duration: Int = 60
    @State private var focus = ""

    private let durations = [30, 45, 60, 75, 90, 120]

    var body: some View {
        NavigationStack {
            Form {
                Section("Session details") {
                    TextField("Session title", text: $title)

                    Picker("Sport / Discipline", selection: $sport) {
                        ForEach(SportDiscipline.allCases, id: \.self) { s in
                            Label(s.rawValue, systemImage: "sportscourt").tag(s)
                        }
                    }

                    Picker("Student level", selection: $level) {
                        ForEach(SkillLevel.allCases, id: \.self) { l in
                            Text(l.rawValue).tag(l)
                        }
                    }

                    Picker("Duration", selection: $duration) {
                        ForEach(durations, id: \.self) { d in
                            Text("\(d) min").tag(d)
                        }
                    }
                }

                Section("Focus area (optional)") {
                    TextField("e.g. roundhouse kick, takedown defense", text: $focus)
                }
            }
            .navigationTitle("New Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { createAndDismiss() }
                        .fontWeight(.semibold)
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func createAndDismiss() {
        var plan = LessonPlan()
        plan.title = title.trimmingCharacters(in: .whitespaces).isEmpty ? "Untitled Session" : title
        plan.sport = sport
        plan.level = level
        plan.durationMinutes = duration
        plan.focus = focus
        store.add(plan)
        dismiss()
    }
}
