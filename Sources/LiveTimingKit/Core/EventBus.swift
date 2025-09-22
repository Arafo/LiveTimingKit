import Foundation

public actor EventBus {
    public struct SubscriptionToken: Hashable, Sendable {
        fileprivate enum Target: Hashable {
            case topic(Topic)
            case all
        }

        fileprivate let id: UUID
        fileprivate let target: Target
    }

    private typealias TopicHandler = @Sendable (Any) async -> Void
    private typealias GlobalHandler = @Sendable (Topic, Any) async -> Void

    private var topicHandlers: [Topic: [UUID: TopicHandler]] = [:]
    private var globalHandlers: [UUID: GlobalHandler] = [:]

    public init() {}

    @discardableResult
    public func subscribe(to topic: Topic, handler: @escaping @Sendable (Any) async -> Void) -> SubscriptionToken {
        let id = UUID()
        var handlers = topicHandlers[topic] ?? [:]
        handlers[id] = handler
        topicHandlers[topic] = handlers
        return SubscriptionToken(id: id, target: .topic(topic))
    }

    @discardableResult
    public func subscribe<Payload>(to topic: Topic, as type: Payload.Type, handler: @escaping @Sendable (Payload) async -> Void) -> SubscriptionToken {
        subscribe(to: topic) { payload in
            guard let payload = payload as? Payload else { return }
            await handler(payload)
        }
    }

    @discardableResult
    public func subscribeToAll(_ handler: @escaping @Sendable (Topic, Any) async -> Void) -> SubscriptionToken {
        let id = UUID()
        globalHandlers[id] = handler
        return SubscriptionToken(id: id, target: .all)
    }

    public func unsubscribe(_ token: SubscriptionToken) {
        switch token.target {
        case .topic(let topic):
            topicHandlers[topic]?[token.id] = nil
            if topicHandlers[topic]?.isEmpty == true {
                topicHandlers[topic] = nil
            }
        case .all:
            globalHandlers[token.id] = nil
        }
    }

    public func publish(topic: Topic, payload: Any) async throws {
        let specificHandlers = topicHandlers[topic]?.values ?? []
        let globalHandlers = globalHandlers.values

        for handler in specificHandlers {
            await handler(payload)
        }

        for handler in globalHandlers {
            await handler(topic, payload)
        }
    }
}
