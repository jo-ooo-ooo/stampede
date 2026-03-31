import SwiftUI

struct DotInfo {
    let colorHex: String
    let isFilled: Bool
}

struct CalendarDayCell: View {
    let day: Int
    let isToday: Bool
    let isOtherMonth: Bool
    let dots: [DotInfo]

    var body: some View {
        VStack(spacing: 3) {
            Text("\(day)")
                .font(.system(size: 11, weight: isToday ? .heavy : .semibold))
                .foregroundStyle(isOtherMonth ? Color(hex: "#D0D0D4") : Theme.text1)

            dotGrid
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isOtherMonth ? Color.clear : Theme.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    isToday ? Theme.text1 :
                        (isOtherMonth ? Color.clear : Theme.border),
                    lineWidth: isToday ? 2 : 1
                )
        )
    }

    // 2×3 dot grid (3 columns × 2 rows)
    private var dotGrid: some View {
        let padded = dots + Array(repeating: DotInfo(colorHex: "", isFilled: false),
                                  count: max(0, 6 - dots.count))

        return VStack(spacing: 1.5) {
            ForEach(0..<2, id: \.self) { row in
                HStack(spacing: 1.5) {
                    ForEach(0..<3, id: \.self) { col in
                        let index = row * 3 + col
                        if index < padded.count {
                            Circle()
                                .fill(padded[index].isFilled
                                      ? Color(hex: padded[index].colorHex)
                                      : Theme.blank)
                                .frame(width: 5, height: 5)
                        }
                    }
                }
            }
        }
    }
}
