import SwiftUI

struct DisciplinePickerPageView: View {
    @Binding var selection: SportDiscipline

    private let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 12)
    ]

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 24)
                .padding(.top, 32)
                .padding(.bottom, 20)

            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(SportDiscipline.allCases, id: \.self) { sport in
                        DisciplineCard(sport: sport, isSelected: sport == selection) {
                            selection = sport
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("What's your discipline?")
                .font(.system(size: 32, weight: .bold))
            Text("We'll personalise Drillboard for you.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Card

private struct DisciplineCard: View {
    let sport: SportDiscipline
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(sport.emoji)
                    .font(.system(size: 40))
                    .accessibilityHidden(true)
                Text(sport.rawValue)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 108)
            .background(cardFill, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(borderColor, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
        .accessibilityLabel(sport.rawValue)
        .accessibilityAddTraits(isSelected ? [.isSelected, .isButton] : .isButton)
    }

    private var cardFill: Color {
        isSelected ? Color.drillboardOrange.opacity(0.15) : Color.gray.opacity(0.08)
    }

    private var borderColor: Color {
        isSelected ? Color.drillboardOrange : Color.gray.opacity(0.25)
    }
}
