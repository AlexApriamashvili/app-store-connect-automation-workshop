import ArgumentParser
import Foundation


@main
struct HelloCLI: ParsableCommand {

  static let configuration = CommandConfiguration(
    abstract: "Let me know your name and I will say hello to you!")

  @Option(name: .customLong("my-name-is"), help: "Let me know your name")
  var username: String

  mutating func run() {
    print("Hello, \(username)!")
  }
}
