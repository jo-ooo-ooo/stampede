import Foundation
import SwiftData

@Model
final class StampEntry {
    var id: UUID
    var stampCard: StampCard?
    var date: Date
    var note: String?
    var createdAt: Date

    init(stampCard: StampCard, date: Date, note: String? = nil) {
        self.id = UUID()
        self.stampCard = stampCard
        self.date = date.startOfDay
        self.note = note
        self.createdAt = Date()
    }
}
