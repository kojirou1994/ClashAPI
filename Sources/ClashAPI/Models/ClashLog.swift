import ClashSupport

public struct ClashLog: Equatable, Decodable {

  public let level: ClashConfig.LogLevel

  public let payload: LogPayload

  public enum LogPayload: Equatable {
    case info(LogInfoPayload)
    case dns(src: String, dst: String)
    case raw(String)

    public var asInfo: LogInfoPayload? {
      switch self {
      case .info(let v): return v
      default: return nil
      }
    }

    public var asRaw: String? {
      switch self {
      case .raw(let v): return v
      default: return nil
      }
    }
  }

  public struct LogInfoPayload: Equatable {
    public let type: Substring
    public let host: Substring
    public let matched: Substring
    public let method: Substring
    public let policy: Substring

    init?(full: String) {
      let parts = full.split(separator: " ", maxSplits: 7)
      guard parts.count == 8 else { return nil }
      type = parts[0].dropFirst().dropLast()
      host = parts[1]
      matched = parts[3]
      method = parts[5]
      policy = parts[7]
    }
  }

  private enum Keys: String, CodingKey {
    case type
    case payload
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: Keys.self)
    level = try container.decode(ClashConfig.LogLevel.self, forKey: .type)
    let payload = try container.decode(String.self, forKey: .payload)
    switch level {
    case .info:
      if let info = LogInfoPayload(full: payload) {
        self.payload = .info(info)
        return
      }
    case .debug:
      /*
       formats:
       [DNS] www.google-analytics.com --> 220.181.174.33
       */
      let parts = payload.split(separator: " ")
      if parts.count > 3 {
        if parts[0] == "[DNS]",
           parts[2] == "-->" {
          self.payload = .dns(src: String(parts[1]), dst: String(parts[3]))
          return
        }
      }
    default: break
    }
    self.payload = .raw(payload)
  }
}
