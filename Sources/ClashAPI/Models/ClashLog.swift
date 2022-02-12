//public struct ClashLog: Identifiable, Equatable, Decodable {
//
//  static let dateFormatter: DateFormatter = {
//    let f = DateFormatter()
//    f.dateStyle = .medium
//    f.timeStyle = .medium
//    return f
//  }()
//
//  init(type: ClashConfig.LogLevel, payload: LogPayload, date: Date)
//  {
//    self.type = type
//    self.payload = payload
//    self.date = Self.dateFormatter.string(from: date)
//  }
//
//  let id: UUID = .init()
//  static var route: String { "logs" }
//  let type: ClashConfig.LogLevel
//  let payload: LogPayload  //String
//  let date: String
//
//  enum LogPayload: Equatable {
//    case info(LogInfoPayload)
//    case raw(String)
//
//    var asInfo: LogInfoPayload? {
//      switch self {
//      case .info(let v): return v
//      default: return nil
//      }
//    }
//
//    var asRaw: String? {
//      switch self {
//      case .raw(let v): return v
//      default: return nil
//      }
//    }
//  }
//
//  struct LogInfoPayload: Equatable {
//    let type: Substring
//    let host: Substring
//    let matched: Substring
//    let method: Substring
//    let policy: Substring
//
//    init?(full: String) {
//      let parts = full.split(separator: " ", maxSplits: 7)
//      guard parts.count == 8 else { return nil }
//      type = parts[0].dropFirst().dropLast()
//      host = parts[1]
//      matched = parts[3]
//      method = parts[5]
//      policy = parts[7]
//    }
//  }
//  private enum Keys: String, CodingKey {
//    case type
//    case payload
//  }
//  init(from decoder: Decoder) throws {
//    let container = try decoder.container(keyedBy: Keys.self)
//    type = try container.decode(ClashConfig.LogLevel.self, forKey: .type)
//    let payload = try container.decode(String.self, forKey: .payload)
//    switch type {
//    case .info:
//      guard let info = LogInfoPayload.init(full: payload) else { fallthrough }
//      self.payload = .info(info)
//    default: self.payload = .raw(payload)
//    }
//    date = Self.dateFormatter.string(from: .init())
//  }
//}
