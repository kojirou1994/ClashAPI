import Networking
import ClashSupport
import AnyEncodable
import Foundation

public struct ClashProxyRes: Decodable {
  public let all: [String]?
  public let history: [History]
  public let now: String?
  public let type: ProxyType
  public struct History: Codable {
    public let time: String
    public let delay: Int
  }
  public enum ProxyType: String, Codable {
    case direct = "Direct"
    case reject = "Reject"
    case selector = "Selector"
    case shadowsocks = "Shadowsocks"
    case socks5 = "Socks5"
    case urlTest = "URLTest"
    case fallback = "Fallback"
    case vmess = "Vmess"
    case shadowsocksR = "ShadowsocksR"

    public var isRealProxy: Bool {
      switch self {
      case .shadowsocks, .shadowsocksR, .vmess, .socks5:
        return true
      default: return false
      }
    }
  }
}

public struct GetAllProxies: Endpoint {
  public init() {}

  public var path: String { "/proxies" }

  public struct ResponseBody: Decodable {
    public let proxies: [String: ClashProxyRes]
  }
}

public struct GetProxyInfo: ClashEndpoint {
  public init(name: String) {
    self.name = name
  }

  public let name: String

  public var path: String { "/proxies/\(name)" }

  public typealias ResponseBody = ClashProxyRes
}

public struct GetProxyDelay: ClashEndpoint {
  public init(name: String, timeout: Int, url: String) {
    self.name = name
    self.timeout = timeout
    self.url = url
  }

  public let name: String
  public let timeout: Int
  public let url: String

  public var path: String { "/proxies/\(name)/delay" }
  public var queryItems: [URLQueryItem] {
    [
      .init(name: "timeout", value: timeout.description),
      .init(name: "url", value: url)
    ]
  }

  public typealias ResponseBody = ClashProxyDelay
}
public struct ChangeSelection: ClashEndpoint {
  public init(newSelection: String, groupName: String) {
    self.newSelection = newSelection
    self.groupName = groupName
  }

  public let newSelection: String
  public let groupName: String

  public var path: String { "/proxies/\(groupName)" }
  public var method: HTTPMethod { .PUT }
  public var contentType: ContentType { .json }
  public var body: RequestBody {
    .init(name: newSelection)
  }
  public struct RequestBody: Encodable {
    let name: String
  }
}
