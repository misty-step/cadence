import Foundation

public struct Activity: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var name: String
    public var isRecurring: Bool = true

    public init(id: UUID = UUID(), name: String, isRecurring: Bool = true) {
        self.id = id
        self.name = name
        self.isRecurring = isRecurring
    }
}
