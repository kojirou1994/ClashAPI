import NIOHTTP1
import Networking

struct ClashErrorMessage: Decodable {
  let message: String
}

public enum ClashAPIError: Error, CustomStringConvertible {
  case message(HTTPResponseStatus, String)

  public var description: String {
    switch self {
      case let .message(status, message):
  return "Error message from clash api: \"\(message)\", status: \(status)"
    }
  }
}

public protocol ClashEndpoint: Endpoint { }

extension ClashEndpoint {

  public func validate<N: Networking>(networking: N, response: N.RawResponse) throws {
    switch response.response.status {
    case .ok...(.noContent): return
    default: throw ClashAPIError.message(response.response.status, try (networking.decode(contentType: .json, body: response.body) as ClashErrorMessage).message)
    }
  }
}
