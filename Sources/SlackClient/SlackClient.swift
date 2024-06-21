import Foundation
import OSLog

public struct SlackClient: Sendable {
  public init() {}
  public func post(_ url: URL, text: String) async throws {
    #if DEBUG
      let logger = Logger(subsystem: "AppReporter", category: "SlackClient")
    #endif
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = try JSONSerialization.data(withJSONObject: [
      "text": text
    ])
    request.allHTTPHeaderFields = [
      "Content-Type": "application/json"
    ]
    let configuration = URLSessionConfiguration.default
    let session = URLSession(configuration: configuration)
    let (data, _) = try await session.data(for: request)
    #if DEBUG
      logger.info("data \(String(data: data, encoding: .utf8) ?? "nil")")
    #endif
  }
}
