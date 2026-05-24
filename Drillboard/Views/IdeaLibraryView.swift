import SwiftUI

struct IdeaLibraryView: View {
    /// The same `AIIdeasViewModel` instance used by the parent sheet — so saves and
    /// deletes from either screen stay in sync without a second VM.
    let viewModel: AIIdeasViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.savedIdeas.isEmpty {
                    ContentUnavailableView(
                        "No Saved Ideas Yet",
                        systemImage: "bookmark",
                        description: Text("Bookmark any AI suggestion to keep it here for later.")
                    )
                } else {
                    List {
                        ForEach(viewModel.savedIdeas) { idea in
                            NavigationLink(value: idea) {
                                IdeaLibraryRow(idea: idea)
                            }
                        }
                        .onDelete { offsets in
                            viewModel.removeIdeas(at: offsets)
                        }
                    }
                }
            }
            .navigationTitle("Idea Library")
            .navigationDestination(for: SavedIdea.self) { idea in
                IdeaDetailView(idea: idea)
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Row

private struct IdeaLibraryRow: View {
    let idea: SavedIdea

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 10) {
                Text(idea.sport.emoji)
                    .font(.title3)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(idea.title)
                        .font(.headline)
                        .lineLimit(1)
                    Text("\(idea.sport.rawValue) · \(idea.level.rawValue)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if let category = idea.category {
                    Text(category)
                        .font(.caption2.weight(.medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(.purple.opacity(0.15), in: Capsule())
                        .foregroundStyle(.purple)
                }
            }
            Text(idea.content)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Detail

private struct IdeaDetailView: View {
    let idea: SavedIdea

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(idea.title)
                        .font(.title2.bold())
                    HStack(spacing: 12) {
                        Label(idea.sport.rawValue, systemImage: "sportscourt")
                        Label(idea.level.rawValue, systemImage: "chart.bar")
                        Text(idea.savedAt, style: .date)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                Text(idea.content)
                    .font(.body)
                    .textSelection(.enabled)

                if !idea.promptUsed.isEmpty {
                    Divider()
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Prompt used")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .tracking(0.5)
                        Text(idea.promptUsed)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("Saved Idea")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: "\(idea.title)\n\n\(idea.content)")
            }
        }
    }
}
