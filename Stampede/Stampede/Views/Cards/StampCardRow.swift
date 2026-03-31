import SwiftUI

struct StampCardRow: View {
    let card: StampCard
    let weekStamps: [Date: Int]
    let onTapToday: () -> Void
    let onTapCard: () -> Void

    private let calendar = Calendar.current
    private let today = Calendar.current.startOfDay(for: Date())

    private var cardColor: Color { Color(hex: card.color) }
    private var lightColor: Color { AppConstants.lightColor(for: card.color) }
    private var todayCount: Int { weekStamps[today] ?? 0 }
    private var isDoneToday: Bool { !card.allowsMultiple && todayCount > 0 }
    private var weekDays: [Date] { Date.currentWeekDays() }

    var body: some View {
        VStack(spacing: 0) {
            // Top row: icon + name → tap navigates to detail
            Button(action: onTapCard) {
                HStack(spacing: 12) {
                    Image(systemName: card.icon)
                        .font(.system(size: 22))
                    Text(card.name)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                    Spacer()
                }
                .foregroundStyle(isDoneToday ? Theme.text3 : Theme.text1)
            }
            .buttonStyle(.plain)

            // Stamp strip
            HStack(spacing: 0) {
                ForEach(weekDays, id: \.self) { day in
                    stampSlot(day: day)
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 14)
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .background(isDoneToday ? Theme.doneCardBackground : Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Theme.border, lineWidth: 1.5)
        )
    }

    // MARK: - Stamp Slot

    @ViewBuilder
    private func stampSlot(day: Date) -> some View {
        let isToday = calendar.isDateInToday(day)
        let count = weekStamps[day] ?? 0
        let isFuture = day > today

        VStack(spacing: 4) {
            if isToday {
                Text("today")
                    .font(.system(size: 8, weight: .heavy))
                    .foregroundStyle(Theme.text1)
                    .textCase(.uppercase)
            } else {
                Text(day.shortWeekdayLetter)
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundStyle(Theme.text3)
                    .textCase(.uppercase)
            }

            if isToday {
                todayCircle(count: count)
            } else {
                pastOrFutureCircle(count: count, isFuture: isFuture)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Today Circle

    @ViewBuilder
    private func todayCircle(count: Int) -> some View {
        Button {
            if !isDoneToday {
                onTapToday()
            }
        } label: {
            ZStack {
                if count > 0 {
                    Circle()
                        .fill(cardColor)
                        .frame(width: 32, height: 32)
                        .shadow(color: .black.opacity(0.12), radius: 3, y: 2)

                    if card.allowsMultiple {
                        Text("\(count)")
                            .font(.system(size: 13, weight: .heavy))
                            .foregroundStyle(.white)
                    } else {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .heavy))
                            .foregroundStyle(.white)
                    }
                } else {
                    Circle()
                        .stroke(style: StrokeStyle(lineWidth: 2.5, dash: [4, 3]))
                        .foregroundStyle(cardColor)
                        .frame(width: 32, height: 32)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Past / Future Circle

    @ViewBuilder
    private func pastOrFutureCircle(count: Int, isFuture: Bool) -> some View {
        ZStack {
            if count > 0 && !isFuture {
                Circle()
                    .fill(lightColor)
                    .frame(width: 26, height: 26)

                if card.allowsMultiple && count > 1 {
                    Text("\(count)")
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundStyle(cardColor)
                } else {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundStyle(cardColor)
                }
            } else {
                Circle()
                    .fill(Theme.blank)
                    .frame(width: 26, height: 26)
            }
        }
    }
}
