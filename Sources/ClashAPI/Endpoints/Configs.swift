import Networking
import ClashSupport
import AnyEncodable
import Foundation

public struct GetConfigs: Endpoint {
  public init() {}

  public var path: String { "/configs" }

  public typealias ResponseBody = ClashConfigsResponse
}

public struct PatchConfigs: Endpoint {
  public var path: String { "/configs" }
  public var method: HTTPMethod { .PATCH }
  public var contentType: ContentType { .json }

  public let body: AnyEncodable
}

public struct ReloadConfigs: ClashEndpoint {
  public init(force: Bool, body: RequestBody) {
    self.force = force
    self.body = body
  }

  public let force: Bool
  public let body: RequestBody

  public var path: String { "/configs" }
  public var method: HTTPMethod { .PUT }
  public var contentType: ContentType { .json }
  public var queryItems: [URLQueryItem] {
    [URLQueryItem.init(name: "force", value: force.description)]
  }

  public struct RequestBody: Encodable {
    public init(payload: String) {
      self.path = ""
      self.payload = payload
    }

    public init(path: String) {
      self.path = path
      self.payload = ""
    }

    public let path: String
    public let payload: String
  }
}

public struct ClashConfigsResponse: Decodable {
  public let allowLan: Bool?
  public let authentication: [ClashConfig.Authentication]?
  public let bindAddress: String?
  //        public let interfaceName: String?
  //        public let ipv6: Bool
  public let logLevel: ClashConfig.LogLevel?
  public let mixedPort: Int?
  public let mode: ClashConfig.Mode?
  public let port: Int?
  public let socksPort: Int?
  public let redirPort: Int?

  internal enum CodingKeys: String, CodingKey {
    case port
    case socksPort = "socks-port"
    case redirPort = "redir-port"
    case allowLan = "allow-lan"
    case mode
    case authentication
    case bindAddress = "bind-address"
    case logLevel = "log-level"
    case mixedPort = "mixed-port"
  }
}
