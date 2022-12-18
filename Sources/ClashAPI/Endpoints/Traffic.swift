import Networking

public struct GetTraffics: Endpoint {
  public init() {}
  
  public var path: String { "/traffic" }

  public typealias ResponseBody = ClashTraffic
}
