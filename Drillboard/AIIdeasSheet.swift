import SwiftUI

struct AIIdeasSheet: View {
    @Binding var plan: LessonPlan
    @ObservedObject var store: PlanStore
    @Environment(\.dismiss) private var dismiss

    @State private var promptText = ""
    @State private var isLoading = false
    @State private var generatedIdeas = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var showingApplyMenu = false

    private var tags: [IdeaTag] { IdeaTag.tags(for: plan) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // Context pill
                    contextHeader

                    // Quick tags
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Quick prompts")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .tracking(0.5)

                        TagFlowLayout(tags: tags) { tag in
                            tagButton(tag)
                        }
                    }

                    Divider()

                    // Custom prompt
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Custom prompt")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .tracking(0.5)

                        TextEditor(text: $promptText)
                            .frame(minHeight: 80)
                            .padding(10)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .font(.body)
                            .overlay(alignment: .topLeading) {
                                if promptText.isEmpty {
                                    Text("Ask anything, e.g. \"Give me a fun game to teach timing for beginners\"")
                                        .font(.body)
                                        .foregroundStyle(.tertiary)
                                        .padding(.top, 18)
                                        .padding(.leading, 14)
                                        .allowsHitTesting(false)
                                }
                            }

                        Button {
                            Task { await generate() }
                        } label: {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .tint(.white)
                                        .scaleEffect(0.85)
                                } else {
                                    Image(systemName: "sparkles")
                                }
                                Text(isLoading ? "Generating..." : "Generate ideas")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.purple)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(isLoading || promptText.trimmingCharacters(in: .whitespaces).isEmpty)
                    }

                    // AI Output
                    if !generatedIdeas.isEmpty {
                        aiOutputCard
                    }
                }
                .padding()
            }
            .navigationTitle("AI Idea Generator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Subviews

    private var contextHeader: some View {
        HStack(spacing: 10) {
            Text(plan.sport.emoji)
                .font(.title2)
            VStack(alignment: .leading, spacing: 2) {
                Text(plan.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                Text("\(plan.sport.rawValue) · \(plan.level.rawValue) · \(plan.durationMinutes) min" + (plan.focus.isEmpty ? "" : " · \(plan.focus)"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func tagButton(_ tag: IdeaTag) -> some View {
        Button {
            promptText = tag.prompt
        } label: {
            Text(tag.label)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Color(.systemGray5))
                .foregroundStyle(.primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var aiOutputCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(.purple)
                Text("AI suggestions")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.purple)
                    .textCase(.uppercase)
                    .tracking(0.5)
                Spacer()
                Menu {
                    ForEach(plan.phases.indices, id: \.self) { i in
                        Button("Apply to \(plan.phases[i].name)") {
                            applyToPhase(index: i)
                        }
                    }
                    Button("Apply to General Notes") {
                        applyToNotes()
                    }
                } label: {
                    Label("Apply to...", systemImage: "square.and.arrow.down")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .tint(.purple)
            }

            Text(generatedIdeas)
                .font(.subheadline)
                .lineSpacing(4)

            Button {
                UIPasteboard.general.string = generatedIdeas
            } label: {
                Label("Copy all", systemImage: "doc.on.doc")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .tint(.secondary)
        }
        .padding(14)
        .background(Color.purple.opacity(0.07))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.purple.opacity(0.25), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Actions

    @MainActor
    private func generate() async {
        let prompt = promptText.trimmingCharacters(in: .whitespaces)
        guard !prompt.isEmpty else { return }
        isLoading = true
        generatedIdeas = ""
        do {
            generatedIdeas = try await AIService.shared.generateIdeas(plan: plan, userPrompt: prompt)
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
        isLoading = false
    }

    private func applyToPhase(index: Int) {
        guard index < plan.phases.count else { return }
        let separator = plan.phases[index].content.isEmpty ? "" : "\n\n--- AI Suggestions ---\n"
        plan.phases[index].content += separator + generatedIdeas
        store.update(plan)
    }

    private func applyToNotes() {
        let separator = plan.notes.isEmpty ? "" : "\n\n--- AI Suggestions ---\n"
        plan.notes += separator + generatedIdeas
        store.update(plan)
    }
}

// MARK: - Flow Layout for tags

struct TagFlowLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Identifiable {
    let tags: Data
    let content: (Data.Element) -> Content

    @State private var totalHeight: CGFloat = .zero

    var body: some View {
        GeometryReader { geo in
            self.generateContent(in: geo)
        }
        .frame(height: totalHeight)
    }

    private func generateContent(in geo: GeometryProxy) -> some View {
        var width: CGFloat = 0
        var height: CGFloat = 0
        var rows: [[Data.Element]] = [[]]

        for tag in tags {
            let tagWidth: CGFloat = 110
            if width + tagWidth > geo.size.width {
                rows.append([tag])
                width = tagWidth
                height += 36
            } else {
                rows[rows.count - 1].append(tag)
                width += tagWidth + 8
            }
        }

        return VStack(alignment: .leading, spacing: 8) {
            ForEach(rows.indices, id: \.self) { i in
                HStack(spacing: 8) {
                    ForEach(rows[i]) { tag in
                        content(tag)
                    }
                }
            }
        }
        .background(
            GeometryReader { geo in
                Color.clear.onAppear { totalHeight = geo.size.height }
            }
        )
    }
}
