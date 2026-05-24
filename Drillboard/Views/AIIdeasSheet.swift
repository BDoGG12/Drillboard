import SwiftUI

struct AIIdeasSheet: View {
    /// Parent VM for the plan being edited — used for context + apply actions.
    let planViewModel: PlanDetailViewModel

    /// Own VM for AI generation state.
    @State private var viewModel = AIIdeasViewModel()
    @Environment(\.dismiss) private var dismiss

    // UI-only state
    @State private var showingLibrary = false

    private var plan: LessonPlan { planViewModel.plan }
    private var tags: [IdeaTag] { IdeaTag.tags(for: plan) }

    var body: some View {
        @Bindable var vm = viewModel

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    contextHeader
                    categoryRow
                    surpriseButton
                    Divider()
                    quickPromptsSection
                    Divider()
                    customPromptSection(vm: $vm)
                    if !viewModel.generatedIdeas.isEmpty {
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
                IdeaLibraryView(viewModel: viewModel)
            }
            .alert("Error", isPresented: $vm.showingError) {
                Button("OK") {}
            } message: {
                Text(viewModel.errorMessage)
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
            Task {
                await viewModel.generate(
                    plan: plan,
                    prompt: category.prompt(for: plan),
                    categoryLabel: category.rawValue
                )
            }
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
        .disabled(viewModel.isLoading)
    }

    // MARK: - Surprise me

    private var surpriseButton: some View {
        Button {
            Task { await viewModel.generateSurprise(for: plan) }
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
        .disabled(viewModel.isLoading)
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
            viewModel.promptText = tag.prompt
        } label: {
            Text(tag.label)
                .font(.caption.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(.gray.opacity(0.15), in: Capsule())
                .foregroundStyle(.primary)
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isLoading)
    }

    // MARK: - Custom prompt

    @ViewBuilder
    private func customPromptSection(vm: Bindable<AIIdeasViewModel>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                sectionHeading("Custom prompt")
                Spacer()
                if !viewModel.promptHistory.isEmpty {
                    promptHistoryMenu
                }
            }

            TextEditor(text: vm.promptText)
                .frame(minHeight: 80)
                .padding(10)
                .background(.gray.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
                .font(.body)
                .overlay(alignment: .topLeading) {
                    if viewModel.promptText.isEmpty {
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
                ForEach(viewModel.promptHistory, id: \.self) { past in
                    Button {
                        viewModel.promptText = past
                    } label: {
                        Text(past)
                    }
                }
            }
            Section {
                Button(role: .destructive) {
                    viewModel.clearHistory()
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
            Task {
                await viewModel.generate(
                    plan: plan,
                    prompt: viewModel.promptText,
                    categoryLabel: nil
                )
            }
        } label: {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.85)
                } else {
                    Image(systemName: "sparkles")
                }
                Text(viewModel.isLoading ? "Generating..." : "Generate ideas")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(.purple, in: RoundedRectangle(cornerRadius: 12))
            .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isLoading || viewModel.promptText.trimmingCharacters(in: .whitespaces).isEmpty)
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

            Text(viewModel.generatedIdeas)
                .font(.subheadline)
                .lineSpacing(4)
                .textSelection(.enabled)

            Button {
                viewModel.copyOutputToPasteboard()
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
            viewModel.saveCurrent(for: plan)
        } label: {
            Image(systemName: viewModel.savedCurrent ? "bookmark.fill" : "bookmark")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.purple)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(viewModel.savedCurrent ? "Saved to library" : "Save to library")
        .disabled(viewModel.savedCurrent)
    }

    private var applyMenu: some View {
        Menu {
            ForEach(plan.phases.indices, id: \.self) { i in
                Button("Apply to \(plan.phases[i].name)") {
                    planViewModel.applyToPhase(index: i, text: viewModel.generatedIdeas)
                }
            }
            Button("Apply to General Notes") {
                planViewModel.applyToNotes(text: viewModel.generatedIdeas)
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
}

// MARK: - Native flow layout

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
