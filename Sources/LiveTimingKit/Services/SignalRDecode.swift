//import Foundation
//
///// Minimal, robust parser for the SignalR envelope.
///// We use JSONSerialization here to easily grab `M[i].M` (method) and `M[i].A[0]` (argument payload).
//enum SignalRDecode {
//    /// Known method keys we can try to infer from an already-unwrapped payload.
//    private static let knownMethods = [
//        "Heartbeat","TimingData","CarData","Position","WeatherData",
//        "TopThree","TimingStats","TimingAppData","TrackStatus","DriverList",
//        "RaceControlMessages","ExtrapolatedClock","SessionInfo","LapCount"
//    ]
//
//    /// Decode a raw websocket text frame into (method, payloadData).
//    /// - If the text is a full SignalR envelope (has "M"), returns one entry per message.
//    /// - If the text is already A[0] or already the inner R-object, it will unwrap "R" if present
//    ///   and try to infer a method from known keys; otherwise returns ("unknown", payload).
//    static func decode(_ raw: String) -> [(method: String, payloadData: Data)] {
//        guard let data = raw.data(using: .utf8) else { return [] }
//        // Try parse root object
//        guard let rootAny = try? JSONSerialization.jsonObject(with: data) else { return [] }
//
//        // Helper to produce Data from any JSON object
//        func dataFromJSON(_ obj: Any) -> Data? {
//            return (try? JSONSerialization.data(withJSONObject: obj, options: []))
//        }
//
//        var out: [(String, Data)] = []
//
//        // Case A: full SignalR envelope with "M"
//        if let root = rootAny as? [String: Any],
//           let msgs = root["M"] as? [[String: Any]] {
//            for msg in msgs {
//                guard let method = msg["M"] as? String else { continue }
//                // take A[0] if exists
//                if let args = msg["A"] as? [Any], let first = args.first {
//                    // if first is an object that contains "R", unwrap it
//                    if let firstDict = first as? [String: Any], let r = firstDict["R"] {
//                        if let payload = dataFromJSON(r) {
//                            out.append((method, payload)); continue
//                        }
//                    }
//                    // otherwise encode first as-is
//                    if let payload = dataFromJSON(first) {
//                        out.append((method, payload)); continue
//                    }
//                } else {
//                    // no args: emit an empty data payload so caller can log/handle it
//                    out.append((method, Data()))
//                }
//            }
//            return out
//        }
//
//        // Case B / C: the raw is already A[0] or already the content of R
//        if let root = rootAny as? [String: Any] {
//            // If root has "R", unwrap to its content
//            if let r = root["R"], let payload = dataFromJSON(r) {
//                // Try infer method from the unwrapped object keys
//                if let unwrapped = r as? [String: Any] {
//                    if let inferred = inferMethod(from: unwrapped) {
//                        out.append((inferred, payload))
//                    } else {
//                        out.append(("unknown", payload))
//                    }
//                } else {
//                    out.append(("unknown", payload))
//                }
//                return out
//            }
//
//            // If root does not have "R", maybe it's already the inner object: try to infer method
//            if let payload = dataFromJSON(root) {
//                if let inferred = inferMethod(from: root) {
//                    out.append((inferred, payload))
//                } else {
//                    out.append(("unknown", payload))
//                }
//                return out
//            }
//        }
//
//        // Fallback: unable to parse as JSON object (maybe array or primitive) — return raw bytes as unknown
//        if let payload = dataFromJSON(rootAny) {
//            out.append(("unknown", payload))
//        }
//
//        return out
//    }
//
//    private static func inferMethod(from dict: [String: Any]) -> String? {
//        for key in knownMethods {
//            if dict.keys.contains(key) { return key }
//        }
//        // also handle some variations (lowercase, etc.)
//        for key in dict.keys {
//            if knownMethods.contains(key) { return key }
//            if knownMethods.contains(key.capitalized) { return key.capitalized }
//        }
//        return nil
//    }
//}
