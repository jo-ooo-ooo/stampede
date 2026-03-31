import SwiftUI
import SwiftData

struct CalendarView: View {
    @Query(sort: \StampCard.sortOrder) private var cards: [StampCard]
    @Query private var allEntries: [StampEntry]

    @State private var displayedMonth = Date()
    @State private var selectedDay: IdentifiableDate?

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 3), count: 7)
    private let weekdayLabels = ["M", "T", "W", "T", "F", "S", "S"]

    private var firstLaunchDate: Date {
        FirstLaunchManager.shared.firstLaunchDate
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    monthHeader
                    weekdayHeader
                    calendarGrid
                }
                .padding(.horizontal, 20)
            }
        }
        .sheet(item: $selectedDay) { item in
            DayDetailSheet(date: item.date, entries: entriesForDay(item.date))
        }
    }

    // MARK: - Month Header

    private var monthHeader: some View {
        HStack {
            Text(displayedMonth.formatted(.dateTime.month(.wide).year()))
                .font(.system(size: 30, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.text1)

            Spacer()

            HStack(spacing: 8) {
                Button { moveMonth(by: -1) } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(canGoBack ? Theme.text2 : Theme.text3)
                        .frame(width: 36, height: 36)
                        .background(Theme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Theme.border, lineWidth: 1.5)
                        )
                }
                .disabled(!canGoBack)

                Button { moveMonth(by: 1) } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(canGoForward ? Theme.text2 : Theme.text3)
                        .frame(width: 36, height: 36)
                        .background(Theme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Theme.border, lineWidth: 1.5)
                        )
                }
                .disabled(!canGoForward)
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 20)
    }

    // MARK: - Weekday Header

    private var weekdayHeader: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach(weekdayLabels, id: \.self) { label in
                Text(label)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Theme.text3)
                    .textCase(.uppercase)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.bottom, 6)
    }

    // MARK: - Calendar Grid

    private var calendarGrid: some View {
        let days = daysInMonth()
        return LazyVGrid(columns: columns, spacing: 3) {
            ForEach(Array(days.enumerated()), id: \.offset) { _, date in
                if let date {
                    let day = calendar.component(.day, from: date)
                    let isToday = calendar.isDateInToday(date)
                    let isOtherMonth = !calendar.isDate(date, equalTo: displayedMonth, toGranularity: .month)
                    let dots = dotsForDay(date)

                    CalendarDayCell(
                        day: day,
                        isToday: isToday,
                        isOtherMonth: isOtherMonth,
                        dots: dots
                    )
                    .onTapGesture {
                        selectedDay = IdentifiableDate(date: date)
                    }
                } else {
                    Color.clear
                        .aspectRatio(0.85, contentMode: .fit)
                }
            }
        }
        .padding(.bottom, 20)
    }

    // MARK: - Navigation Logic

    private var canGoBack: Bool {
        let firstMonth = calendar.dateInterval(of: .month, for: firstLaunchDate)?.start ?? firstLaunchDate
        let displayedStart = calendar.dateInterval(of: .month, for: displayedMonth)?.start ?? displayedMonth
        return displayedStart > firstMonth
    }

    private var canGoForward: Bool {
        let currentMonthStart = calendar.dateInterval(of: .month, for: Date())?.start ?? Date()
        let displayedStart = calendar.dateInterval(of: .month, for: displayedMonth)?.start ?? displayedMonth
        return displayedStart < currentMonthStart
    }

    private func moveMonth(by value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: displayedMonth) {
            displayedMonth = newDate
        }
    }

    // MARK: - Data Helpers

    private func daysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth) else {
            return []
        }

        let firstDay = monthInterval.start
        let weekday = calendar.component(.weekday, from: firstDay)
        // Adjust for Monday-start: Mon=0, Tue=1, ..., Sun=6
        let leadingPadding = (weekday + 5) % 7

        var days: [Date?] = Array(repeating: nil, count: leadingPadding)

        let daysCount = calendar.range(of: .day, in: .month, for: displayedMonth)?.count ?? 30
        for day in 0..<daysCount {
            if let date = calendar.date(byAdding: .day, value: day, to: firstDay) {
                days.append(date)
            }
        }

        return days
    }

    private func entriesForDay(_ date: Date) -> [StampEntry] {
        let dayStart = calendar.startOfDay(for: date)
        guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else { return [] }
        return allEntries.filter { $0.date >= dayStart && $0.date < dayEnd }
    }

    private func dotsForDay(_ date: Date) -> [DotInfo] {
        let dayEntries = entriesForDay(date)
        let stampedCardIds = Set(dayEntries.compactMap { $0.stampCard?.id })

        return cards.prefix(6).map { card in
            DotInfo(
                colorHex: card.color,
                isFilled: stampedCardIds.contains(card.id)
            )
        }
    }
}

/// Wrapper to make Date work with .sheet(item:)
struct IdentifiableDate: Identifiable {
    let id = UUID()
    let date: Date
}
