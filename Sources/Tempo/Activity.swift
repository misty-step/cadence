import Foundation

struct Activity: Identifiable, Codable, Equatable, Sendable {
    var id = UUID()
    var name: String
    var isRecurring: Bool = true
}
