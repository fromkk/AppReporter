import Foundation

public struct App: Hashable, Decodable, Sendable, Identifiable {
  public struct Attributes: Hashable, Decodable, Sendable {
    public let name: String
    public let bundleId: String
    public let sku: String
    public let primaryLocale: String
    public let isOrEverWasMadeForKids: Bool
    public let subscriptionStatusUrl: URL?
    public let subscriptionStatusUrlVersion: String?
    public let subscriptionStatusUrlForSandbox: URL?
    public let subscriptionStatusUrlVersionForSandbox: String?
    public let contentRightsDeclaration: String
  }

  public let type: String
  public let id: String
  public let attributes: Attributes
  public let links: Links
  // TODO: add relationships
}

public struct AppResponse: Hashable, Decodable, Sendable {
  public let data: App
  public let links: Links
}

public struct AppRequest: APIRequest {
  public typealias Response = AppResponse
  public typealias Params = NoValueParams
  public let appID: String
  public init(appID: String) {
    self.appID = appID
  }

  public var path: String {
    "/v1/apps/\(appID)"
  }
  public var method: APIHTTPMethod = .get
  public var query: [String: String]? = nil
  public var body: NoValueParams? = nil
  public var customHeaders: [String: String]? = nil
}

public struct AppClient: Sendable {
  public init() {}
  public func fetch(_ appID: String, configuration: APIConfiguration) async throws -> App {
    let request = AppRequest(appID: appID)
    let client = APIClient()
    return try await client.request(request, apiConfiguration: configuration).data
  }
}
