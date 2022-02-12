import Networking

public struct GetVersion: Endpoint {
  public init() {}
  public var path: String { "/version" }

  public struct ResponseBody: Decodable {
    public let version: String
  }
}
