
import Foundation
import JWTKit

private struct Payload: JWTPayload {
  var sub: SubjectClaim
  var iat: IssuedAtClaim
  var exp: ExpirationClaim
  var aud: AudienceClaim
  var iss: IssuerClaim

  func verify(using signer: JWTSigner) throws {
    try self.exp.verifyNotExpired()
  }
}

final class JWTStore {

  private var lastRefreshedTime: Date = .distantPast
  private var cachedValue: String = ""

  private let keyID: String
  private let issuerID: String
  private let secretPath: String

  init(keyID: String, issuerID: String, secretPath: String) {
    self.keyID = keyID
    self.issuerID = issuerID
    self.secretPath = secretPath
  }

  func read() throws -> String {
    if hasTokenExpired() {
      cachedValue = try createJWT()
    }

    return cachedValue
  }

  private func hasTokenExpired() -> Bool {
    let timeNow = Date.now.timeIntervalSinceReferenceDate
    let lastRefreshed = lastRefreshedTime.timeIntervalSinceReferenceDate
    return timeNow - lastRefreshed >= Constant.expirationSeconds
  }

  private func createJWT() throws -> String {
    let privateKey = try String(contentsOfFile: secretPath)

    let keys = JWTSigners()
    let timeNow = Date()
    let expirationDate = timeNow.addingTimeInterval(Constant.expirationSeconds)
    let payload = Payload(
      sub: .init(value: Constant.subject),
      iat: .init(value: timeNow),
      exp: .init(value: expirationDate),
      aud: .init(value: Constant.audiences),
      iss: .init(value: issuerID))
    keys.use(.es256(key: try .private(pem: privateKey)))

    return try keys.sign(payload, typ: Constant.tokenType, kid: .init(string: keyID))
  }

  private enum Constant {
    static let expirationSeconds: TimeInterval = 1_200 // 20 minutes

    static let tokenType = "JWT"
    static let subject = "user"
    static let audiences = ["appstoreconnect-v1"]
  }
}
