import ArgumentParser
import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

@main
struct HelloCLI: AsyncParsableCommand {

  static let configuration = CommandConfiguration(
    abstract: "Let me know your name and I will say hello to you!")

  @Option(name: .customLong("my-name-is"), help: "Let me know your name")
  var username: String

  mutating func run() async throws {
    let client = Client(
      serverURL: URL(string: "http://127.0.0.1:8080/api")!,
      transport: URLSessionTransport())
    let response = try await client.sayHello(
      Operations.sayHello.Input(
        query: Operations.sayHello.Input.Query(name: username)))

    let greeting = try response.ok.body.json.message
    print(greeting)
  }
}
