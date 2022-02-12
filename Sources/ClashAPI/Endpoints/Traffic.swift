import Networking

public struct GetTraffic: Endpoint {
  public init() {}
  
  public var path: String { "/traffic" }

  public typealias ResponseBody = ClashTraffic
}
