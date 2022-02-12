import Networking

public struct GetRules: Endpoint {
  public init() {}
  
  public var path: String { "/rules" }

  public struct ResponseBody: Decodable {
    public let rules: [Rule]

    public struct Rule: Decodable {
      public let type: String
      public let payload: String
      public let proxy: String
    }
  }
}
