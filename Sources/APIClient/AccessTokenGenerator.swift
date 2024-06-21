import CryptoKit
import Foundation

enum Algorithm: String {
  case es256 = "ES256"
}

enum TokenType: String {
  case jwt
}

struct AccessTokenGenerator: Sendable {
  let configuration: APIConfiguration

  func generate() throws -> String {
    let header: [String: String] = [
      "alg": Algorithm.es256.rawValue,
      "kid": configuration.keyID,
      "typ": TokenType.jwt.rawValue,
    ]

    let payload: [String: Any] = [
      "iss": configuration.issuerID,
      "iat": Int(Date().timeIntervalSince1970),
      "exp": Int(Date().timeIntervalSince1970 + (20 * 60)),
      "aud": Constant.audience,
    ]

    let privateKey = try P256.Signing.PrivateKey(pemRepresentation: configuration.privateKey)

    let headerJson = try! JSONSerialization.data(withJSONObject: header)
    let payloadJson = try! JSONSerialization.data(withJSONObject: payload)

    let input: String =
      "\(headerJson.base64urlEncodedString()).\(payloadJson.base64urlEncodedString())"

    let data = input.data(using: .utf8)!
    let signature = try privateKey.signature(for: data)

    let raw = signature.rawRepresentation
    let signedJWT = "\(input).\(raw.base64urlEncodedString())"

    return signedJWT
  }
}
