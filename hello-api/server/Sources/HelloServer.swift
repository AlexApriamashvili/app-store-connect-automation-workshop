import OpenAPIRuntime
import OpenAPIVapor
import Vapor


struct HelloService: APIProtocol {
  
  func sayHello(_ input: Operations.sayHello.Input) async throws -> Operations.sayHello.Output {
    let username = input.query.name ?? "Username"
    return .ok(.init(body: .json(.init(message: "Hello, \(username)"))))
  }
}

@main struct HelloServer {
  
  static func main() async throws {
    let app = Application()
    let transport = VaporTransport(routesBuilder: app)
    let service = HelloService()

    try service.registerHandlers(on: transport, serverURL: URL(string: "/api")!)

    try await app.execute()
  }
}
