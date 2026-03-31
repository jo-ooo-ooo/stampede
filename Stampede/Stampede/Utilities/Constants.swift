import SwiftUI

// MARK: - Theme

enum Theme {
    static let background = Color(hex: "#F4F4F6")
    static let cardBackground = Color.white
    static let border = Color(hex: "#E6E6EA")
    static let text1 = Color(hex: "#1A1A1E")
    static let text2 = Color(hex: "#8A8A92")
    static let text3 = Color(hex: "#B0B0B8")
    static let blank = Color(hex: "#EDEDF0")
    static let doneCardBackground = Color(hex: "#FAFAFA")
}

// MARK: - App Constants

enum AppConstants {

    // MARK: - Icon Set

    struct IconCategory: Identifiable {
        let id = UUID()
        let name: String
        let icons: [String]
    }

    static let iconCategories: [IconCategory] = [
        IconCategory(name: "Fitness", icons: [
            "figure.run", "figure.walk", "dumbbell.fill", "figure.yoga",
            "bicycle", "figure.pool.swim", "sportscourt.fill", "heart.fill"
        ]),
        IconCategory(name: "Food & Drink", icons: [
            "fork.knife", "cup.and.saucer.fill", "waterbottle.fill",
            "carrot.fill", "leaf.fill", "wineglass"
        ]),
        IconCategory(name: "Learning & Work", icons: [
            "book.fill", "pencil.and.outline", "graduationcap.fill",
            "laptopcomputer", "brain.head.profile", "character.book.closed.fill",
            "doc.text.fill"
        ]),
        IconCategory(name: "Wellness", icons: [
            "bed.double.fill", "moon.fill", "sun.max.fill", "drop.fill",
            "figure.mind.and.body", "pills.fill", "cross.fill"
        ]),
        IconCategory(name: "Creative", icons: [
            "paintbrush.fill", "music.note", "camera.fill",
            "guitars.fill", "theatermasks.fill"
        ]),
        IconCategory(name: "Home & Life", icons: [
            "house.fill", "washer.fill", "sparkles", "cart.fill",
            "banknote.fill", "pawprint.fill"
        ]),
        IconCategory(name: "Social", icons: [
            "phone.fill", "bubble.left.fill", "person.2.fill",
            "envelope.fill", "hand.wave.fill"
        ]),
        IconCategory(name: "General", icons: [
            "star.fill", "checkmark.circle.fill", "flag.fill", "bolt.fill"
        ]),
    ]

    static let allIcons: [String] = iconCategories.flatMap(\.icons)

    // MARK: - Color Palette

    struct PaletteColor: Identifiable {
        let id = UUID()
        let name: String
        let hex: String
        let lightHex: String

        var color: Color { Color(hex: hex) }
        var lightColor: Color { Color(hex: lightHex) }
    }

    static let colorPalette: [PaletteColor] = [
        PaletteColor(name: "Red", hex: "#FF7B6B", lightHex: "#FFF0EE"),
        PaletteColor(name: "Blue", hex: "#6BA3FF", lightHex: "#EEF4FF"),
        PaletteColor(name: "Amber", hex: "#FFCA5C", lightHex: "#FFF8E8"),
        PaletteColor(name: "Purple", hex: "#B88AFF", lightHex: "#F4EEFF"),
        PaletteColor(name: "Teal", hex: "#5CE0B8", lightHex: "#ECFAF5"),
        PaletteColor(name: "Rose", hex: "#FF85AA", lightHex: "#FFF0F4"),
    ]

    static func lightColor(for hex: String) -> Color {
        let normalized = hex.uppercased()
        if let match = colorPalette.first(where: { $0.hex.uppercased() == normalized }) {
            return match.lightColor
        }
        return Color(hex: hex).opacity(0.12)
    }

    // MARK: - Validation

    static let maxCardNameLength = 30
    static let maxNoteLength = 200
}

// MARK: - Color Extension for Hex

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}
