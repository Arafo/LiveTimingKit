import Logging
import SignalRClient

struct LiveTimingSignalRLogHandler: SignalRClient.LogHandler {
    private let logger: Logger

    init(logger: Logger) {
        self.logger = logger
    }

    func log(
        logLevel: SignalRClient.LogLevel,
        message: SignalRClient.LogMessage,
        file: String,
        function: String,
        line: UInt
    ) {
        logger.log(
            level: logLevel.loggingLevel,
            "\(message)",
            metadata: [
                "signalr_file": .string(file),
                "signalr_function": .string(function),
                "signalr_line": .string("\(line)")
            ],
            source: "signalr-client",
            file: file,
            function: function,
            line: line
        )
    }
}

private extension SignalRClient.LogLevel {
    var loggingLevel: Logger.Level {
        switch self {
        case .debug:
            return .debug
        case .information:
            return .info
        case .warning:
            return .warning
        case .error:
            return .error
        }
    }
}
