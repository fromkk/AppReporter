import APIClient
import ArgumentParser
import Compression
import Foundation
import SlackClient

struct Arguments: ParsableCommand {
  @Argument(help: "Key ID")
  var keyID: String

  @Argument(help: "Issuer ID")
  var issuerID: String

  @Argument(help: "Path for private key *.p8")
  var privateKey: String

  @Argument(help: "App ID")
  var appID: String

  @Argument(help: "Date(YYYY-MM-DD)")
  var date: String

  @Option(name: .shortAndLong, help: "Vendor Number")
  var vendorNumber: String?

  @Option(name: .shortAndLong, help: "TimeZone(ex. Asia/Tokyo)")
  var timeZone: String?

  @Option(name: .shortAndLong, help: "Locale(ex. ja_JP)")
  var locale: String?

  @Option(name: .shortAndLong, help: "Slack Webhook URL")
  var slackWebhookURL: String?
}

@main
struct Report {
  enum Errors: Error {
    case privateKeyNotFound
  }

  static func main() async throws {
    let arguments = Arguments.parseOrExit()
    let fileManager = FileManager.default
    guard fileManager.fileExists(atPath: arguments.privateKey) else {
      throw Errors.privateKeyNotFound
    }
    let privateKey = try String(contentsOfFile: arguments.privateKey.replacingOccurrences(of: "\r", with: "\n"))
    let configuration = APIConfiguration(
      issuerID: arguments.issuerID, keyID: arguments.keyID, privateKey: privateKey)

    let appClient = AppClient()
    let app = try await appClient.fetch(arguments.appID, configuration: configuration)

    var report: String = "*\(arguments.date) \(app.attributes.name) Report :memo: *\n\n"

    if let vendorNumber = arguments.vendorNumber {
      // インストール数
      var numberOfInstalls: Int = 0
      do {
        let client = SalesClient()
        let data = try await client.download(
          frequency: .DAILY,
          reportDate: arguments.date,
          reportSubType: .SUMMARY,
          reportType: .SALES,
          vendorNumber: vendorNumber,
          version: "1_0",
          configuration: configuration
        )

        guard
          let decodedData = gunzip(data: data),
          let tsv = String(data: decodedData, encoding: .utf8)
        else {
          print("gunzip failed")
          exit(1)
        }

        let tsvParser = TSVParser()
        let rows = tsvParser.parse(tsv)
        numberOfInstalls = rows.filter({ $0["Apple Identifier"] == arguments.appID }).count
      } catch {
        print("catch error \(error.localizedDescription)")
        exit(1)
      }
      report += ":tada: *Number of Installs:* \(numberOfInstalls)\n"
    }

    // カスタマーレビュー
    let customerReviewClient = CustomerReviewClient(configuration: configuration)
    let response = try await customerReviewClient.fetch(arguments.appID)

    var calendar = Calendar(identifier: .gregorian)
    let timeZone: TimeZone = arguments.timeZone.flatMap { TimeZone(identifier: $0) } ?? .current
    let locale: Locale = arguments.locale.map { Locale(identifier: $0) } ?? .current
    calendar.timeZone = timeZone
    calendar.locale = locale

    let dateFormatter = DateFormatter()
    dateFormatter.calendar = calendar
    dateFormatter.dateFormat = "yyyy-MM-dd"
    guard let startOfDay = dateFormatter.date(from: arguments.date) else {
      print("Invalid date \(arguments.date)")
      exit(1)
    }

    let endOfDay = startOfDay.addingTimeInterval(24 * 60 * 60)

    let customerReviews = response.data.filter {
      startOfDay <= $0.attributes.createdDate && $0.attributes.createdDate < endOfDay
    }
    if customerReviews.isEmpty {
      report += "*No customer reviews* :cry:"
    } else {
      let dateFormatStyle = Date.FormatStyle()
        .year()
        .month()
        .day()
        .hour()
        .minute()
        .locale(locale)

      report += ":speaker: *Customer reviews* \n"
      report += "=====================================\n"
      customerReviews.forEach {
        report += "*title:* \($0.attributes.title ?? "")\n"
        report += "*body:* \($0.attributes.body ?? "")\n"
        report += "*nickname:* \($0.attributes.reviewerNickname ?? "")\n"
        report += "*date* \($0.attributes.createdDate.formatted(dateFormatStyle))\n"
        report += "=====================================\n"
      }
    }

    guard let url = arguments.slackWebhookURL.flatMap(URL.init(string:)) else {
      print(report)
      return
    }

    let slackClient = SlackClient()
    try await slackClient.post(url, text: report)
    print("Done!")
    exit(0)
  }
}
