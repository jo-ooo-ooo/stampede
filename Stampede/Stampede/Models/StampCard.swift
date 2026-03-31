import Foundation
import SwiftData

@Model
final class StampCard {
    var id: UUID
    var name: String
    var icon: String
    var color: String
    var sortOrder: Int
    var allowsMultiple: Bool
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \StampEntry.stampCard)
    var entries: [StampEntry]?

    init(name: String, icon: String, color: String, sortOrder: Int, allowsMultiple: Bool = false) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.color = color
        self.sortOrder = sortOrder
        self.allowsMultiple = allowsMultiple
        self.createdAt = Date()
        self.entries = nil
    }
}
