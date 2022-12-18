import Foundation
import NIO
import NIOHTTP1
import Networking

public struct ClashAPIClient: URLSessionNetworking {

  public let commonHTTPHeaders: HTTPHeaders
  public let urlComponents: URLComponents
  public let jsonDecoder: JSONDecoder = .init()
  public let jsonEncoder: JSONEncoder = .init()
  public let session: URLSession
  public var autoResume: Bool { true }
  let delegate: URLSessionTaskIndependentDelegate

  public init(auth: ClashAuth, tls: Bool) {
    delegate = URLSessionTaskIndependentDelegate()
    session = .init(configuration: .ephemeral, delegate: delegate, delegateQueue: nil)
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

extension ClashAPIClient: StreamNetworking {

  class StreamHandler: NSObject, URLSessionDataDelegate {
    internal init(receiveCompletion: @escaping (Result<Void, Error>) -> Void, receiveValue: @escaping (Data) -> Void) {
      self.receiveCompletion = receiveCompletion
      self.receiveValue = receiveValue
    }

    let receiveCompletion: (Result<Void, Error>) -> Void
    let receiveValue: (Data) -> Void

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
      if let error = error {
        receiveCompletion(.failure(error))
      } else {
        receiveCompletion(.success(()))
      }
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
      data.split(separator: UInt8(ascii: "\n")).forEach { line in
        receiveValue(line)
      }
    }
  }

  public func stream<E>(_ endpoint: E, receiveCompletion: @escaping (Result<Void, Error>) -> Void, receiveValue: @escaping (Data) -> Void) throws -> Task where E : Endpoint {
    var request = try request(endpoint)
    request.timeoutInterval = .greatestFiniteMagnitude
    let task = session.dataTask(with: request)
    delegate.delegates[task] = StreamHandler(receiveCompletion: receiveCompletion, receiveValue: receiveValue)
    if autoResume {
      task.resume()
    }
    return task
  }
}

public final class URLSessionTaskIndependentDelegate: NSObject {
  var delegates: [URLSessionTask: NSObject] = .init()
}

extension URLSessionTaskIndependentDelegate: URLSessionDelegate {

}

extension URLSessionTaskIndependentDelegate: URLSessionTaskDelegate {
  public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    (delegates[task] as? URLSessionTaskDelegate)?.urlSession?(session, task: task, didCompleteWithError: error)
    delegates[task] = nil
  }
}

extension URLSessionTaskIndependentDelegate: URLSessionDataDelegate {
  public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    (delegates[dataTask] as? URLSessionDataDelegate)?.urlSession?(session, dataTask: dataTask, didReceive: data)
  }
}
