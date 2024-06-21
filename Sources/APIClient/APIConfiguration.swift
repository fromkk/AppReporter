import Foundation

public struct APIConfiguration: Sendable {
  public let issuerID: String
  public let keyID: String
  public let privateKey: String

  public init(issuerID: String, keyID: String, privateKey: String) {
    self.issuerID = issuerID
    self.keyID = keyID
    self.privateKey = privateKey
  }
}
