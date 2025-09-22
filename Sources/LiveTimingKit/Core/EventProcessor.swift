import Foundation

public protocol EventProcessor: Sendable {
    func process(_ event: RawEvent) async throws
}
