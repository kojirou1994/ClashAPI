import Foundation
import NIO
import NIOHTTP1
import Networking
import AsyncHTTPClient
import AsyncHTTPClientNetworking
import ClashAPI

struct ClashAPIClient: AsyncHTTPClientNetworking {

  let commonHTTPHeaders: HTTPHeaders
  let urlComponents: URLComponents
  let jsonDecoder: JSONDecoder = .init()
  let jsonEncoder: JSONEncoder = .init()
  let http: HTTPClient

  init(auth: ClashAuth, tls: Bool) {
    http = .init(eventLoopGroupProvider: .createNew)
    var urlComponents = URLComponents()
    urlComponents.scheme = tls ? "https" : "http"
    urlComponents.host = auth.server
    urlComponents.port = auth.port
    var commonHTTPHeaders = HTTPHeaders()
    commonHTTPHeaders.replaceOrAdd(name: "Authorization", value: "Bearer \(auth.secret)")
    self.urlComponents = urlComponents
    self.commonHTTPHeaders = commonHTTPHeaders
  }

}
