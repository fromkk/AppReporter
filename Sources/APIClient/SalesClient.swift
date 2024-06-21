import Foundation

public enum SalesFrequency: String, Sendable {
  case DAILY
  case WEEKLY
  case MONTHLY
  case YEARLY
}

public enum SalesReportSubType: String, Sendable {
  case SUMMARY
  case DETAILED
  case SUMMARY_INSTALL_TYPE
  case SUMMARY_TERRITORY
  case SUMMARY_CHANNEL
}

public enum SalesReportType: String, Sendable {
  case SALES
  case PRE_ORDER
  case NEWSSTAND
  case SUBSCRIPTION
  case SUBSCRIPTION_EVENT
  case SUBSCRIBER
  case SUBSCRIPTION_OFFER_CODE_REDEMPTION
  case INSTALLS
  case FIRST_ANNUAL
}

struct SalesAPIRequest: APIRequest {
  init(
    frequency: SalesFrequency,
    reportDate: String,
    reportSubType: SalesReportSubType,
    reportType: SalesReportType,
    vendorNumber: String,
    version: String
  ) {
    query = [
      "filter[frequency]": frequency.rawValue,
      "filter[reportDate]": reportDate,
      "filter[reportSubType]": reportSubType.rawValue,
      "filter[reportType]": reportType.rawValue,
      "filter[vendorNumber]": vendorNumber,
      "filter[version]": version,
    ]
  }

  typealias Response = NoValueResult
  typealias Params = NoValueParams

  let path: String = "/v1/salesReports"
  let method: APIHTTPMethod = .get
  var query: [String: String]?
  var body: NoValueParams? = nil
  var customHeaders: [String: String]? = nil
}

public struct SalesClient: Sendable {
  public init() {}
  public func download(
    frequency: SalesFrequency,
    reportDate: String,
    reportSubType: SalesReportSubType,
    reportType: SalesReportType,
    vendorNumber: String,
    version: String,
    configuration: APIConfiguration
  ) async throws -> Data {
    let apiClient = APIClient()
    let request = SalesAPIRequest(
      frequency: frequency,
      reportDate: reportDate,
      reportSubType: reportSubType,
      reportType: reportType,
      vendorNumber: vendorNumber,
      version: version
    )
    return try await apiClient.requestData(
      request,
      apiConfiguration: configuration
    )
  }
}
