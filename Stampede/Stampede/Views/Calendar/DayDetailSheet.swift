import SwiftUI

struct DayDetailSheet: View {
    let date: Date
    let entries: [StampEntry]

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                if entries.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "circle.dashed")
                            .font(.system(size: 40))
                            .foregroundStyle(Theme.text3)
                        Text("No stamps this day")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Theme.text2)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                                if let card = entry.stampCard {
                                    entryRow(card: card, entry: entry)

                                    if index < entries.count - 1 {
                                        Divider()
                                            .padding(.leading, 42)
                                    }
                                }
                            }
                        }
                        .background(Theme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Theme.border, lineWidth: 1.5)
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    }
                }
            }
            .navigationTitle(date.friendlyDateString)
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
    }

    @ViewBuilder
    private func entryRow(card: StampCard, entry: StampEntry) -> some View {
        HStack(spacing: 10) {
            Circle()
                .fill(Color(hex: card.color))
                .frame(width: 8, height: 8)

            Image(systemName: card.icon)
                .font(.system(size: 16))
                .foregroundStyle(Color(hex: card.color))
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(card.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.text1)

                if let note = entry.note, !note.isEmpty {
                    Text(note)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Theme.text2)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}
