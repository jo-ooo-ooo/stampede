import SwiftUI
import SwiftData

struct CardsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \StampCard.sortOrder) private var cards: [StampCard]
    @Query private var allEntries: [StampEntry]

    @State private var showAddForm = false
    @State private var showSettings = false
    @State private var cardToCheckIn: StampCard?
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                Theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        headerView

                        if cards.isEmpty {
                            emptyState
                        } else {
                            cardsList
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: StampCard.self) { card in
                CardDetailView(card: card)
            }
            .sheet(isPresented: $showAddForm) {
                CardFormView(nextSortOrder: cards.count)
            }
            .sheet(item: $cardToCheckIn) { card in
                CheckInSheet(card: card) { note in
                    stampCard(card, note: note)
                }
            }
            .sheet(isPresented: $showSettings) {
                NavigationStack {
                    VStack {
                        Spacer()
                        Text("Settings coming soon")
                            .font(.subheadline)
                            .foregroundStyle(Theme.text2)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .background(Theme.background)
                    .navigationTitle("Settings")
                    .navigationBarTitleDisplayMode(.inline)
                }
                .presentationDetents([.medium])
            }
        }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 10) {
                    Text("Stampede")
                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                        .foregroundStyle(Theme.text1)

                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 16))
                            .foregroundStyle(Theme.text2)
                    }
                }

                Text(Date().friendlyDateString)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.text2)
            }

            Spacer()

            Button { showAddForm = true } label: {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(Theme.text1)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
            }
            .padding(.top, 4)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 20)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 80)
            Image(systemName: "square.stack")
                .font(.system(size: 48))
                .foregroundStyle(Theme.text3)
            Text("No Cards Yet")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.text1)
            Text("Tap + to create your first stamp card.")
                .font(.system(size: 14))
                .foregroundStyle(Theme.text2)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Cards List

    private var cardsList: some View {
        VStack(spacing: 10) {
            ForEach(cards) { card in
                StampCardRow(
                    card: card,
                    weekStamps: weekStampsForCard(card),
                    onTapToday: { cardToCheckIn = card },
                    onTapCard: { navigationPath.append(card) }
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    // MARK: - Data Helpers

    private func weekStampsForCard(_ card: StampCard) -> [Date: Int] {
        let week = Date.currentWeekDays()
        guard let weekStart = week.first,
              let weekEnd = Calendar.current.date(byAdding: .day, value: 1, to: week.last!)
        else { return [:] }

        let entries = allEntries.filter {
            $0.stampCard?.id == card.id && $0.date >= weekStart && $0.date < weekEnd
        }

        var result: [Date: Int] = [:]
        for entry in entries {
            let day = entry.date.startOfDay
            result[day, default: 0] += 1
        }
        return result
    }

    private func stampCard(_ card: StampCard, note: String?) {
        let todayCount = weekStampsForCard(card)[Date().startOfDay] ?? 0
        if !card.allowsMultiple && todayCount > 0 { return }

        let entry = StampEntry(stampCard: card, date: Date().startOfDay, note: note)
        modelContext.insert(entry)
        try? modelContext.save()
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}
