import Foundation

public struct Links: Hashable, Sendable, Decodable {
  public let `self`: URL
  public let next: URL?
  public let related: URL?
}

public struct Paging: Hashable, Sendable, Decodable {
  public let total: Int
  public let limit: Int
}

public struct Meta: Hashable, Decodable, Sendable {
  public let paging: Paging
}

public struct CustomerReviewData: Hashable, Decodable, Sendable, Identifiable {
  public let type: String
  public let id: String
  public let attributes: CustomerReviewAttributes
  public let relationships: CustomerReviewRelationships
  public let links: Links
}

public struct CustomerReviewAttributes: Hashable, Decodable, Sendable {
  public let rating: Int
  public let title: String?
  public let body: String?
  public let reviewerNickname: String?
  public let createdDate: Date
  public let territory: String
}

public struct CustomerReviewRelationships: Hashable, Decodable, Sendable {
  public struct Response: Hashable, Decodable, Sendable {
    public let links: Links
  }
  public let response: Response
}

public struct CustomerReviewResponse: Hashable, Decodable, Sendable {
  public let data: [CustomerReviewData]
  public let links: Links
  public let meta: Meta
}

public struct CustomerReviewRequest: APIRequest {
  public let appID: String
  public init(appID: String) {
    self.appID = appID
    self.query = [
      "sort": "-createdDate"
    ]
  }

  public typealias Response = CustomerReviewResponse
  public typealias Params = NoValueParams
  public var path: String { "/v1/apps/\(appID)/customerReviews" }
  public var method: APIHTTPMethod = .get
  public var query: [String: String]?
  public var body: NoValueParams? = nil
  public var customHeaders: [String: String]? = nil
}

public struct CustomerReviewClient {
  public let configuration: APIConfiguration
  public init(configuration: APIConfiguration) {
    self.configuration = configuration
  }

  public func fetch(_ appID: String) async throws -> CustomerReviewResponse {
    let apiClient = APIClient()
    let request = CustomerReviewRequest(appID: appID)
    return try await apiClient.request(request, apiConfiguration: configuration)
  }
}
