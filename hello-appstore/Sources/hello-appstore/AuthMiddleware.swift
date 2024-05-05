import Foundation
import HTTPTypes
import OpenAPIRuntime

struct AuthMiddleware: ClientMiddleware {

  private let token: String

  init(token: String) { self.token = token }

  func intercept(
    _ request: HTTPTypes.HTTPRequest,
    body: OpenAPIRuntime.HTTPBody?,
    baseURL: URL,
    operationID: String,
    next: @Sendable (
      HTTPTypes.HTTPRequest,
      OpenAPIRuntime.HTTPBody?, URL)
    async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?))
  async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?)
  {
    var mutableRequest = request
    mutableRequest.headerFields[.authorization] = "Bearer \(token)"

    return try await next(mutableRequest, body, baseURL)
  }
}

