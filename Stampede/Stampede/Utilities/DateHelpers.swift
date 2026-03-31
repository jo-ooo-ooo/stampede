import Foundation

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    /// Returns Monday–Sunday of the week containing this date.
    static func currentWeekDays(containing date: Date = Date()) -> [Date] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: date)
        // weekday: 1=Sun, 2=Mon, ..., 7=Sat
        let weekday = cal.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7 // Mon=0 … Sun=6
        let monday = cal.date(byAdding: .day, value: -daysFromMonday, to: today)!
        return (0..<7).map { cal.date(byAdding: .day, value: $0, to: monday)! }
    }

    /// Short weekday symbol for this date: "M", "T", "W", etc.
    var shortWeekdayLetter: String {
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: self) // 1=Sun … 7=Sat
        let letters = ["S", "M", "T", "W", "T", "F", "S"]
        return letters[weekday - 1]
    }

    /// Formatted as "Tuesday, March 31"
    var friendlyDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: self)
    }
}
