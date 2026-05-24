import SwiftUI

struct AIIdeasSheet: View {
    @Binding var plan: LessonPlan
    @ObservedObject var store: PlanStore
    @Environment(\.dismiss) private var dismiss

    @State private var library = IdeaLibrary.shared

    @State private var promptText = ""
    @State private var isLoading = false

    // Output state for the currently displayed AI suggestion.
    @State private var generatedIdeas = ""
    @State private var generatedTitle = ""
    @State private var generatedPrompt = ""
    @State private var generatedCategory: String?
    @State private var savedCurrent = false

    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var showingLibrary = false

    private var tags: [IdeaTag] { IdeaTag.tags(for: plan) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    contextHeader
                    categoryRow
                    surpriseButton
                    Divider()
                    quickPromptsSection
                    Divider()
                    customPromptSection
                    if !generatedIdeas.isEmpty {
                        aiOutputCard
                    }
                }
                .padding()
            }
            .navigationTitle("AI Idea Generator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingLibrary = true
                    } label: {
                        Label("Library", systemImage: "books.vertical")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showingLibrary) {
                IdeaLibraryView()
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Context header

    private var contextHeader: some View {
        HStack(spacing: 10) {
            Text(plan.sport.emoji)
                .font(.title2)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(plan.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                Text("\(plan.sport.rawValue) · \(plan.level.rawValue) · \(plan.durationMinutes) min" + (plan.focus.isEmpty ? "" : " · \(plan.focus)"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.gray.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
        .accessibilityElement(children: .combine)
    }

    // MARK: - Category row

    private var categoryRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeading("Browse by category")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(IdeaCategory.allCases) { category in
                        categoryButton(category)
                    }
                }
                .padding(.horizontal, 2)
            }
            .scrollClipDisabled()
        }
    }

    private func categoryButton(_ category: IdeaCategory) -> some View {
        Button {
            Task { await generate(prompt: category.prompt(for: plan), categoryLabel: category.rawValue) }
        } label: {
            VStack(spacing: 6) {
                Image(systemName: category.systemIcon)
                    .font(.title3)
                Text(category.rawValue)
                    .font(.caption2.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(width: 86, height: 70)
            .background(.purple.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
            .foregroundStyle(.purple)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Generate \(category.rawValue) ideas")
        .disabled(isLoading)
    }

    // MARK: - Surprise Me

    private var surpriseButton: some View {
        Button {
            Task { await generate(prompt: AIService.surprisePrompt(for: plan), categoryLabel: "Surprise") }
        } label: {
            HStack {
                Image(systemName: "wand.and.stars")
                    .font(.title3)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Surprise me")
                        .font(.headline)
                    Text("Auto-design a full creative session")
                        .font(.caption)
                        .opacity(0.85)
                }
                Spacer()
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(colors: [.purple, .pink],
                               startPoint: .leading,
                               endPoint: .trailing),
                in: RoundedRectangle(cornerRadius: 14)
            )
            .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
        .accessibilityLabel("Surprise me — generate a full creative session")
    }

    // MARK: - Quick prompts

    private var quickPromptsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeading("Quick prompts")
            FlowLayout(spacing: 8) {
                ForEach(tags) { tag in
                    tagButton(tag)
                }
            }
        }
    }

    private func tagButton(_ tag: IdeaTag) -> some View {
        Button {
            promptText = tag.prompt
        } label: {
            Text(tag.label)
                .font(.caption.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(.gray.opacity(0.15), in: Capsule())
                .foregroundStyle(.primary)
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }

    // MARK: - Custom prompt

    private var customPromptSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                sectionHeading("Custom prompt")
                Spacer()
                if !library.promptHistory.isEmpty {
                    promptHistoryMenu
                }
            }

            TextEditor(text: $promptText)
                .frame(minHeight: 80)
                .padding(10)
                .background(.gray.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
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

            generateButton
        }
    }

    private var promptHistoryMenu: some View {
        Menu {
            Section("Recent prompts") {
                ForEach(library.promptHistory, id: \.self) { past in
                    Button {
                        promptText = past
                    } label: {
                        Text(past)
                    }
                }
            }
            Section {
                Button(role: .destructive) {
                    library.clearHistory()
                } label: {
                    Label("Clear History", systemImage: "trash")
                }
            }
        } label: {
            Label("History", systemImage: "clock.arrow.circlepath")
                .font(.caption.weight(.semibold))
        }
        .accessibilityLabel("Recent prompts")
    }

    private var generateButton: some View {
        Button {
            Task { await generate(prompt: promptText, categoryLabel: nil) }
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
            .background(.purple, in: RoundedRectangle(cornerRadius: 12))
            .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
        .disabled(isLoading || promptText.trimmingCharacters(in: .whitespaces).isEmpty)
    }

    // MARK: - Output

    private var aiOutputCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(.purple)
                Text("AI suggestions")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.purple)
                    .textCase(.uppercase)
                    .tracking(0.5)
                Spacer()
                bookmarkButton
                applyMenu
            }

            Text(generatedIdeas)
                .font(.subheadline)
                .lineSpacing(4)
                .textSelection(.enabled)

            Button {
                UIPasteboard.general.string = generatedIdeas
            } label: {
                Label("Copy all", systemImage: "doc.on.doc")
                    .font(.caption.weight(.medium))
            }
            .tint(.secondary)
        }
        .padding(14)
        .background(.purple.opacity(0.07), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.purple.opacity(0.25), lineWidth: 1)
        )
    }

    private var bookmarkButton: some View {
        Button {
            saveCurrent()
        } label: {
            Image(systemName: savedCurrent ? "bookmark.fill" : "bookmark")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.purple)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(savedCurrent ? "Saved to library" : "Save to library")
        .disabled(savedCurrent)
    }

    private var applyMenu: some View {
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
                .font(.caption.weight(.semibold))
        }
        .tint(.purple)
    }

    // MARK: - Layout helpers

    private func sectionHeading(_ title: String) -> some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .tracking(0.5)
    }

    // MARK: - Actions

    private func generate(prompt rawPrompt: String, categoryLabel: String?) async {
        let prompt = rawPrompt.trimmingCharacters(in: .whitespaces)
        guard !prompt.isEmpty else { return }
        isLoading = true
        generatedIdeas = ""
        generatedTitle = ""
        generatedPrompt = prompt
        generatedCategory = categoryLabel
        savedCurrent = false

        // Only record user-typed prompts in history (not auto-built category/surprise ones).
        if categoryLabel == nil {
            library.recordPrompt(prompt)
        }

        do {
            let response = try await AIService.shared.generateIdeas(plan: plan, userPrompt: prompt)
            generatedIdeas = response
            generatedTitle = response.extractedIdeaTitle(fallback: categoryLabel ?? "AI Idea")
            savedCurrent = library.contains(content: response)
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
        isLoading = false
    }

    private func saveCurrent() {
        guard !generatedIdeas.isEmpty, !savedCurrent else { return }
        let idea = SavedIdea(
            title: generatedTitle.isEmpty ? "AI Idea" : generatedTitle,
            content: generatedIdeas,
            sport: plan.sport,
            level: plan.level,
            category: generatedCategory,
            promptUsed: generatedPrompt
        )
        library.save(idea)
        withAnimation { savedCurrent = true }
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

// MARK: - Native flow layout (replaces the old GeometryReader-based TagFlowLayout)

/// Wraps its children onto multiple rows, respecting each child's intrinsic size.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        return arrange(subviews: subviews, maxWidth: maxWidth).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(subviews: subviews, maxWidth: bounds.width)
        for (index, point) in result.offsets.enumerated() {
            let size = subviews[index].sizeThatFits(.unspecified)
            subviews[index].place(
                at: CGPoint(x: bounds.minX + point.x, y: bounds.minY + point.y),
                proposal: ProposedViewSize(size)
            )
        }
    }

    private func arrange(subviews: Subviews, maxWidth: CGFloat) -> (offsets: [CGPoint], size: CGSize) {
        var offsets: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            offsets.append(CGPoint(x: currentX, y: currentY))
            currentX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
            totalWidth = max(totalWidth, currentX - spacing)
        }
        return (offsets, CGSize(width: totalWidth, height: currentY + rowHeight))
    }
}
