public protocol LiveTimingService: Actor {
    var eventProcessor: LiveTimingEventProcessor { get async }
}
