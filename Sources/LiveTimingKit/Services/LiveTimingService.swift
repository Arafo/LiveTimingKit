//import Vapor
//import AsyncHTTPClient
//
//public actor LiveTimingService: Sendable {
//    private let url: String
//    private let clientProtocol: Double = 2.1
//    private let connectionData: String = "%5B%7B%22Name%22%3A%22Streaming%22%7D%5D"
//
//    private let logger: Logger
//    private let http: HTTPClient
//    private let group: EventLoopGroup
//
//    private var ws: WebSocket?
//    private let aggregator = LiveTimingAggregator()
//    private let decoder = JSONDecoder()
//    private var reconnecting = false
//    private var backoffStep = 0
//    private let backoffStepsSec: [Double] = [1, 2, 5, 10, 20, 30]
//
//    public var snapshots: AsyncStream<LiveTimingState> { aggregator.stream() }
//    public var lastSnapshotData: Data? { aggregator.lastSnapshotData }
//
//    public init(
//        url: String = "https://livetiming.formula1.com/signalr",
//        logger: Logger = .init(label: "LiveTimingService"),
//        client: HTTPClient,
//        eventLoopGroup: EventLoopGroup
//    ) {
//        self.url = url
//        self.logger = logger
//        self.http = client
//        self.group = eventLoopGroup
//    }
//
//    public func connect() async throws {
//        let negotiate = try await self.negotiate()
//        try await self.connectWebSocket(with: negotiate)
//        try await self.sendInitialSubscribe()
//    }
//
//    public func disconnect() async {
//        try? await ws?.close(code: .normalClosure)
//        ws = nil
//    }
//
//    struct NegotiateData {
//        let connectionToken: String
//        let cookieHeader: String
//    }
//
//    private func negotiate() async throws -> NegotiateData {
//        let negotiateURL = "\(url)/negotiate?clientProtocol=\(clientProtocol)&connectionData=\(connectionData)"
//        logger.info("[SignalR] Negotiating \(negotiateURL)")
//
//        let response = try await http.get(url: negotiateURL).get()
//        let body = response.body.map { String(buffer: $0) } ?? ""
//        logger.debug("[SignalR] Negotiate body: \(body)")
//
//        let cookie = response.headers["Set-Cookie"]
//            .map { $0.split(separator: ";")[0] }
//            .joined(separator: "; ")
//
//        struct NegotiateResponse: Decodable { let ConnectionToken: String }
//        let data = try JSONDecoder().decode(NegotiateResponse.self, from: Data(body.utf8))
//
//        let token = data.ConnectionToken.signalRURLEncoded
//
//        return .init(connectionToken: token, cookieHeader: cookie)
//    }
//
//    private func connectWebSocket(with negotiate: NegotiateData) async throws {
//        let connectionData = "[{\"name\":\"Streaming\"}]"
//        let encoded = connectionData.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? connectionData
//        let wsURL = "wss://livetiming.formula1.com/signalr/connect?transport=webSockets&clientProtocol=\(clientProtocol)&connectionToken=\(negotiate.connectionToken)&connectionData=\(encoded)"
//
//        var headers = HTTPHeaders()
//        headers.add(name: "Host", value: "livetiming.formula1.com")
//        headers.add(name: "User-Agent", value: "SignalR.Client.NetStandard/2.4.3.0 (Unix 26.0.0)")
//        headers.add(name: "Accept", value: "*/*")
//        headers.add(name: "Origin", value: "https://livepersoninc.github.io")
//        headers.add(name: "Referer", value: "https://livetiming.formula1.com/")
//        headers.add(name: "Cookie", value: negotiate.cookieHeader)
//        
//        headers.add(name: "Accept-Language", value: "es-ES,en-US;q=0.7,en;q=0.3")
//        headers.add(name: "Accept-Encoding", value: "gzip, deflate, br, zstd")
//        headers.add(name: "Origin", value: "https://livetiming.formula1.com")
//        headers.add(name: "Sec-WebSocket-Extensions", value: "permessage-deflate")
//        headers.add(name: "Sec-GPC", value: "1")
//        headers.add(name: "Sec-Fetch-Dest", value: "empty")
//        headers.add(name: "Sec-Fetch-Mode", value: "websocket")
//        headers.add(name: "Sec-Fetch-Site", value: "cross-site")
//        headers.add(name: "Pragma", value: "no-cache")
//        headers.add(name: "Cache-Control", value: "no-cache")
//
//        let config = WebSocketClient.Configuration(maxFrameSize: Int(Int32.max) - 1)
//
//        try await WebSocket.connect(
//            to: wsURL,
//            headers: headers,
//            //proxy: "127.0.0.1",
//            //proxyPort: 9090,
//            configuration: config,
//            on: group
//        ) { [weak self] ws in
//            guard let self else { return }
//            self.ws = ws
//            self.backoffStep = 0
//            ws.pingInterval = .seconds(30)
//            self.logger.info("[SignalR] WebSocket connected")
//
//            ws.onText { [weak self] _, text in
//                self?.logger.info("[SignalR] Getting message \(text)")
//                self?.handleIncoming(text)
//            }
//            
//            ws.onPing { _, _ in
//                self.logger.info("[SignalR] Sending Ping")
//            }
//            
//            ws.onClose.whenComplete { [weak self] result in
//                guard let self else { return }
//                switch result {
//                case .success:
//                    self.logger.warning("[SignalR] WebSocket closed: \(String(describing: ws.closeCode))")
//                case .failure(let error):
//                    self.logger.error("[SignalR] WebSocket error: \(error.localizedDescription)")
//                }
//                Task { await self.scheduleReconnect() }
//            }
//        }.get()
//    }
//
//    private func sendInitialSubscribe() async throws {
//        // Subscribe to the main topics (you can extend later)
//        // Heartbeat will include these:
//        let msg = [
//            "H": "Streaming",
//            "M": "Subscribe",
//            "A": [[
//                "Heartbeat","CarData.z","Position.z",
//                "CarData","Position","ExtrapolatedClock","TopThree","TimingStats",
//                "TimingAppData","WeatherData","TrackStatus","DriverList","RaceControlMessages",
//                "SessionInfo","SessionData","LapCount","TimingData","ChampionshipPrediction",
//                "TeamRadio","TyreStintSeries","PitStopSeries"
//            ]],
//            "I": "0"
//        ] as [String: Any]
//
//        let data = try JSONSerialization.data(withJSONObject: msg)
//        guard let str = String(data: data, encoding: .utf8) else { return }
//        try await ws?.send(str)
//        logger.info("[SignalR] Subscribe sent")
//    }
//
//    private func handleIncoming(_ text: String) {
//        // Parse the envelope and decode each method payload
//        let items = SignalRDecode.decode(text)
//        for (method, payload) in items {
//            do {
//                switch method {
//                case "Heartbeat":
//                    let hb = try decoder.decode(Heartbeat.self, from: payload)
//                    aggregator.apply(.heartbeat(hb))
//
//                case "TimingData":
//                    let td = try decoder.decode(TimingData.self, from: payload)
//                    aggregator.apply(.timingData(td))
//
//                case "CarData":
//                    let cd = try decoder.decode(CarData.self, from: payload)
//                    aggregator.apply(.carData(cd))
//
//                case "Position":
//                    let pos = try decoder.decode(PositionData.self, from: payload)
//                    aggregator.apply(.position(pos))
//
//                case "WeatherData":
//                    let w = try decoder.decode(WeatherData.self, from: payload)
//                    aggregator.apply(.weather(w))
//
//                default:
//                    // Unknown or unhandled topic; keep raw name for now
//                    aggregator.apply(.raw(method))
//                }
//            } catch {
//                logger.error("[SignalR] Decode error for \(method): \(error.localizedDescription)")
//            }
//        }
//    }
//
//    private func scheduleReconnect() async {
//        guard !reconnecting else { return }
//        reconnecting = true
//        defer { reconnecting = false }
//
//        let delay = backoffStepsSec[min(backoffStep, backoffStepsSec.count - 1)]
//        backoffStep = min(backoffStep + 1, backoffStepsSec.count - 1)
//        logger.warning("[SignalR] Reconnecting in \(delay)s…")
//        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
//
//        do {
//            try await self.connect()
//        } catch {
//            logger.error("[SignalR] Reconnect failed: \(error.localizedDescription)")
//            // Try again with increased backoff
//            await scheduleReconnect()
//        }
//    }
//}
//
//fileprivate extension String {
//    var signalRURLEncoded: String {
//        self
//            .replacingOccurrences(of: "+", with: "%2B")
//            .replacingOccurrences(of: "/", with: "%2F")
//            .replacingOccurrences(of: "=", with: "%3D")
//    }
//}

public protocol LiveTimingService: Actor {
    var eventProcessor: LiveTimingEventProcessor { get async }
}
