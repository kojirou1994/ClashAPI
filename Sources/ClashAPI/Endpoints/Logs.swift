import Networking
import ClashSupport

public struct GetLogs: Endpoint {
  public init(level: ClashConfig.LogLevel) {
    self.level = level
  }

  public let level: ClashConfig.LogLevel

  public var path: String { "/logs" }

  public typealias ResponseBody = ClashLog

  public var queryItems: [URLQueryItem] {
    [.init(name: "level", value: level.rawValue)]
  }
}
