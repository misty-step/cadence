import Foundation

public struct Activity: Identifiable, Codable, Equatable, Sendable {
    public let id = UUID()
    public var name: String
    public var isRecurring: Bool = true

    public init(name: String, isRecurring: Bool = true) {
        self.name = name
        self.isRecurring = isRecurring
    }
}
