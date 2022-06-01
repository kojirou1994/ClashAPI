import Networking
import Foundation

public struct KillConnection: ClashEndpoint {

  public static func id(_ id: UUID) -> Self { .init(id: id) }
  public static var all: Self { .init(id: nil) }

  private init(id: UUID?) {
    self.path = "/connections" + (id.map { "/\($0.uuidString)" } ?? "")
  }

  public let path: String
  public var method: HTTPMethod { .DELETE }
}

public struct GetConnections: Endpoint {

  public init() {}

  public var path: String { "/connections" }

  public struct ResponseBody: Decodable, Equatable {
    public let downloadTotal: Int
    public let uploadTotal: Int
    public let connections: [Connection]
  }
}

public struct Connection: Decodable, Identifiable, Equatable {
  public let id: UUID
  public let metadata: Metadata
  public let upload: Int
  public let download: Int
  public let start: String
  public let chains: [String]
  public let rule: String

  public struct Metadata: Decodable, Equatable {
    public let network: String
    public let type: String
    public let sourceIP: String
    public let destinationIP: String
    public let sourcePort: String
    public let destinationPort: String
    public let host: String
  }
}
