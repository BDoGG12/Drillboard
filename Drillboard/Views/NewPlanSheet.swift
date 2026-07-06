import SwiftUI

struct NewPlanSheet: View {
    /// Parent VM that owns the plans collection — receives the new plan via `addPlan`.
    let listViewModel: PlanListViewModel
    @Environment(\.dismiss) private var dismiss

    // UI-only form state — transient until the user taps Create.
    @State private var title = ""
    @State private var sport: SportDiscipline = .karate
    @State private var level: SkillLevel = .beginner
    @State private var duration: Int = 60
    @State private var focus = ""

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
                    .onAppear(perform: loadDefaultSport)

                    Picker("Student level", selection: $level) {
                        ForEach(SkillLevel.allCases, id: \.self) { l in
                            Text(l.rawValue).tag(l)
                        }
                    }

                }

                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Label("Duration", systemImage: "clock")
                                .foregroundStyle(.secondary)
                                .font(.subheadline.weight(.medium))
                            Spacer()
                            Text(duration.formattedAsDuration)
                                .font(.subheadline.weight(.semibold))
                                .monospacedDigit()
                        }
                        TimePickerView(totalMinutes: $duration)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Session length")
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
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        plan.title = trimmedTitle.isEmpty ? "Untitled Session" : trimmedTitle
        plan.sport = sport
        plan.level = level
        plan.durationMinutes = duration
        plan.focus = focus
        listViewModel.addPlan(plan)
        dismiss()
    }

    /// Pulls the discipline the user picked during onboarding (if any) so a fresh
    /// plan starts on their preferred sport. Runs once per sheet appearance.
    private func loadDefaultSport() {
        if let raw = UserDefaults.standard.string(forKey: OnboardingViewModel.defaultSportKey),
           let saved = SportDiscipline(rawValue: raw) {
            sport = saved
        }
    }
}
