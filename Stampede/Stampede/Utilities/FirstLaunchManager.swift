import Foundation

final class FirstLaunchManager {
    static let shared = FirstLaunchManager()

    private let key = "firstLaunchDate"

    var firstLaunchDate: Date {
        if let stored = UserDefaults.standard.object(forKey: key) as? Date {
            return stored
        }
        let now = Date()
        UserDefaults.standard.set(now, forKey: key)
        return now
    }

    private init() {}
}
