import NIOHTTP1
import Networking

struct ClashErrorMessage: Decodable {
  let message: String
}

public enum ClashAPIError: Error {
  case noOKStatus(HTTPResponseStatus)
  case message(String)
}

public protocol ClashEndpoint: Endpoint { }

extension ClashEndpoint {

  public func validate<N: Networking>(networking: N, response: N.RawResponse) throws {
    switch response.response.status {
    case .ok...(.noContent): return
    default: throw ClashAPIError.message(try (networking.decode(contentType: .json, body: response.body) as ClashErrorMessage).message)
    }
  }
}
