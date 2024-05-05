import ArgumentParser
import Foundation
import OpenAPIRuntime
import OpenAPIURLSession
import Schema

@main
struct AppStoreAutomator: AsyncParsableCommand {

  static let configuration = CommandConfiguration(abstract: "Let's automate!")

  @Option(help: "Individual Key ID")
  var keyID: String

  @Option(help: "AppStoreConnectAPI Issuer ID")
  var issuerID: String

  @Option(help: "Path to the private key on your machine")
  var secretPath: String

  lazy var jwtStore = {
    JWTStore(keyID: keyID, issuerID: issuerID, secretPath: secretPath)
  }()

  mutating func run() async throws {
    let token = try jwtStore.read()
    let authMiddleware = AuthMiddleware(token: token)
    let client = Client(
      serverURL: try Servers.server1(),
      transport: URLSessionTransport(),
      middlewares: [authMiddleware])

    let appID = try await getAppId(using: client)
    var measurements = try await getMemoryMetrics(forAppWithID: appID, using: client)
    measurements.sort(by: { $0.version > $1.version })
    printMeasurements(measurements.filter({ $0.percentile == .p90 && $0.type == .peakMemory }))
  }

  private func getAppId(using client: Client) async throws -> String {
    let response = try await client.apps_hyphen_get_collection(
      Operations.apps_hyphen_get_collection.Input(
        query: Operations.apps_hyphen_get_collection.Input.Query(fields_lbrack_apps_rbrack_: [.name])))
    guard
      let scAppId = try response
        .ok
        .body
        .json
        .data
        .first(where: { $0.attributes?.name?.hasSuffix("(iAuditor)") == true })?.id
    else {
      throw CLIError.unableToGetAppID
    }

    return scAppId
  }

  private func getMemoryMetrics(forAppWithID appID: String, using client: Client) async throws -> [Measurement] {
    let response = try await client.apps_hyphen_perfPowerMetrics_hyphen_get_to_many_related(
      Operations.apps_hyphen_perfPowerMetrics_hyphen_get_to_many_related.Input(
        path: Operations.apps_hyphen_perfPowerMetrics_hyphen_get_to_many_related.Input.Path(id: appID),
      query: Operations.apps_hyphen_perfPowerMetrics_hyphen_get_to_many_related.Input.Query(
        filter_lbrack_deviceType_rbrack_: ["all_iphones"],
        filter_lbrack_metricType_rbrack_: [.MEMORY], 
        filter_lbrack_platform_rbrack_: [.IOS])))

    var result: [Measurement] = []
    switch response {
    case .ok(let okResponse):
      switch okResponse.body {
      case .application_vnd_period_apple_period_xcode_hyphen_metrics_plus_json(let xcodeMetrics):
        xcodeMetrics.productData?.forEach({ payload in
          payload.metricCategories?.forEach({ category in
            category.metrics?.forEach({ metric in
              metric.datasets?.forEach({ dataset in
                dataset.points?.forEach({ point in
                  let percentile: Measurement.Percentile = {
                    switch dataset.filterCriteria?.percentile {
                    case .some("percentile.fifty"):
                      return .p50
                    case .some("percentile.ninety"):
                      return .p90
                    default: return .p0
                    }
                  }()
                  let metricType = Measurement.MeasurementType(rawValue: metric.identifier ?? "") ?? .unknown

                  let measurement = Measurement(
                    type: metricType,
                    version: point.version ?? "--",
                    value: point.value ?? .nan,
                    unit: metric.unit?.displayName ?? "",
                    percentile: percentile)
                  result.append(measurement)
                })
              })
            })
          })
        })
      }
    default:
      throw CLIError.unrecogozedError
    }

    return result
  }

  private func printMeasurements(_ measurements: [Measurement]) {
    var message = "| VERSION | VALUE | TYPE | PERCENTILE |\n"
    message +=    "| ------- | ----- | ---- | ---------- |\n"
    measurements.forEach { measurement in
      message += "| \(measurement.version) | \(measurement.value) \(measurement.unit) | \(measurement.type) | \(measurement.percentile)\n"
    }

    print(message)
  }
}

enum CLIError: Error {

  case unableToGetAppID
  case unrecogozedError
}

private struct Measurement {
  let type: MeasurementType
  let version: String
  let value: Double
  let unit: String
  let percentile: Percentile

  enum Percentile: Equatable { case p0, p50, p90 }
  enum MeasurementType: String {
    case unknown, peakMemory, memoryAtSuspension
  }
}
