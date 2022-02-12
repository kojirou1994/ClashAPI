import Foundation

public struct ClashAuth {
  public var server: String
  public var port: Int
  public var secret: String
  
  public init(server: String, port: Int, secret: String) {
    self.server = server
    self.port = port
    self.secret = secret
  }
}
