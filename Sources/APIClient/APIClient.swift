//
// Copyright (c) 2018 PeaceTecLab Co., Ltd.
// All rights reserved.
//

import Foundation

#if DEBUG
  import OSLog
  let logger = Logger(subsystem: "AppReporter", category: "APIClient")
#endif

public enum APIHTTPMethod: String, Sendable {
  case get = "GET"
  case post = "POST"
  case put = "PUT"
  case delete = "DELETE"
  case PATCH = "PATCH"
}

public protocol APIRequest {
  associatedtype Response: Decodable
  associatedtype Params: Encodable
  var path: String { get }
  var method: APIHTTPMethod { get }
  var query: [String: String]? { get }
  var body: Params? { get }
  var customHeaders: [String: String]? { get }
}

extension APIRequest {
  func makeRequest(_ configuration: APIConfiguration) throws -> URLRequest {
    var urlComponents: URLComponents = .init(string: Constant.host)!
    urlComponents.path = path

    if let query {
      urlComponents.queryItems = query.map { .init(name: $0.key, value: $0.value) }
    }

    var urlRequest = URLRequest(url: urlComponents.url!)
    urlRequest.httpMethod = method.rawValue

    var header: [String: String] = ["Content-Type": "application/json"]
    let tokenGenerator = AccessTokenGenerator(configuration: configuration)
    header["Authorization"] = "Bearer \(try tokenGenerator.generate())"
    if let customHeaders {
      header.merge(customHeaders) { _, new in new }
    }
    urlRequest.allHTTPHeaderFields = header

    if method != .get, let body {
      urlRequest.httpBody = try? JSONEncoder().encode(body)
    }
    urlRequest.timeoutInterval = 30
    #if DEBUG
      logger.info(
        "customRequest URL: \(String(describing: urlRequest.url)) HEADER: \(String(describing: urlRequest.allHTTPHeaderFields)) BODY: \(String(describing: body))"
      )
    #endif
    return urlRequest
  }
}

public struct APIResponseError: Error, Decodable, Sendable {
  public init(propertyName: String? = nil, errorMessage: String) {
    self.propertyName = propertyName
    self.errorMessage = errorMessage
  }

  public let propertyName: String?
  public let errorMessage: String
}

extension APIResponseError: LocalizedError {
  public var errorDescription: String? { errorMessage }
}

public struct NoValueParams: Encodable, Sendable {}
public struct NoValueResult: Decodable, Sendable {}

public enum APIInfo: Sendable {
  public static var host: String = ""
}

public struct APIError: Error, Decodable, Sendable {
  public let id: String
  public let status: String
  public let code: String
  public let title: String?
  public let detail: String?
}

public struct APIErrors: Decodable, Sendable {
  public let errors: [APIError]
}

public enum APIClientError: Error, Sendable {
  case unknownError
}

public struct APIClient: Sendable {
  public func request<T: APIRequest>(_ request: T, apiConfiguration: APIConfiguration) async throws
    -> T.Response
  {
    let data = try await requestData(request, apiConfiguration: apiConfiguration)
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let result = try decoder.decode(T.Response.self, from: data)
    return result
  }

  public func requestData<T: APIRequest>(_ request: T, apiConfiguration: APIConfiguration)
    async throws -> Data
  {
    let configuration = URLSessionConfiguration.default
    let session = URLSession(configuration: configuration)
    let (data, response) = try await session.data(for: try request.makeRequest(apiConfiguration))
    #if DEBUG
      if let string = String(data: data, encoding: .utf8) {
        logger.info("APIClient.response \(string, privacy: .sensitive)")
      } else {
        logger.info("APIClient.response data \(data)")
      }
    #endif
    switch (response as! HTTPURLResponse).statusCode {
    case 200..<300:
      return data
    default:
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .iso8601
      let result = try decoder.decode(APIErrors.self, from: data)
      if let error = result.errors.first {
        throw error
      } else {
        throw APIClientError.unknownError
      }
    }
  }
}
