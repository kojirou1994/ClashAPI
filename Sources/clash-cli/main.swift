import ArgumentParser
import ClashAPI
import Foundation

struct ClashCli: ParsableCommand {

  static var client: ClashAPIClient!

  @Option
  var server: String = "127.0.0.1"

  @Option
  var port: Int

  @Option
  var secret: String = ""

  @Flag
  var tls = false

  func validate() throws {
    Self.client = .init(auth: ClashAuth(server: server, port: port, secret: secret), tls: tls)
  }

  static var configuration: CommandConfiguration {
    .init(
      subcommands: [
        Version.self,
        Rule.self,
        Connection.self,
        Traffic.self,
        Kill.self,
        Proxy.self,
        Test.self,
        Select.self,
    ])
  }
}

extension ClashCli {

  struct Version: ParsableCommand {
    func run() throws {
      let version = try ClashCli.client.eventLoopFuture(GetVersion()).wait().body.get().version
      print(version)
    }
  }

  struct Rule: ParsableCommand {
    func run() throws {
      let rules = try ClashCli.client.eventLoopFuture(GetRules()).wait().body.get().rules
      rules.forEach { print($0) }
    }
  }

  struct Connection: ParsableCommand {
    func run() throws {
      let info = try ClashCli.client.eventLoopFuture(GetConnections()).wait().body.get()
      info.connections.forEach { print($0) }
      print("total down: \(ByteCountFormatter.string(fromByteCount: numericCast(info.downloadTotal), countStyle: .file))")
      print("total up: \(ByteCountFormatter.string(fromByteCount: numericCast(info.uploadTotal), countStyle: .file))")
    }
  }

  struct Traffic: ParsableCommand {
    func run() throws {
      let task = try ClashCli.client.streamSegmented(GetTraffic(), receiveCompletion: { completion in
        print("finished: \(completion)")
      }, receiveValue: { result in
        switch result {
        case .success(let traffic):
          print("Download: \(ByteCountFormatter.string(fromByteCount: numericCast(traffic.down), countStyle: .file))/s", "Upload: \(ByteCountFormatter.string(fromByteCount: numericCast(traffic.up), countStyle: .file))/s")
        case .failure(let error):
          print("Decode error: \(error)")
        }
      })
      try task.wait()
    }
  }

  struct Kill: ParsableCommand {

    @Argument(help: "connection's UUID or 'all'")
    var id: String

    func run() throws {
      let req: KillConnection
      if id == "all"{
        req = .all
      } else if let id = UUID(uuidString: id) {
        req = .id(id)
      } else {
        throw ValidationError("invalid UUID: \(id)")
      }
      let response = try ClashCli.client.eventLoopFutureRaw(req).wait()
      print("status:", response.response.status.code)
    }
  }

  struct Proxy: ParsableCommand {

    @Flag
    var all: Bool = false

    @Option
    var type: String?

    @Argument
    var name: String?

    func logProxy(_ p: GetProxyInfo.ResponseBody, name: String) {
      print("name:", name)
      print("type", p.type)
      if let now = p.now {
        print("now:", now)
      }
      if let all = p.all {
        print("all:", all)
      }
      if !p.history.isEmpty {
        print("history:")
        p.history.forEach { history in
          print("- \(history.time) \(history.delay)ms")
        }
      }
      print()
    }

    func run() throws {
      if let name = name {
        let res = try ClashCli.client.eventLoopFuture(GetProxyInfo(name: name)).wait().body.get()
        logProxy(res, name: name)
      } else {
        print("Get all proxies")
        let res = try ClashCli.client.eventLoopFuture(GetAllProxies()).wait().body.get()
        res.proxies.sorted(by: { l, r in
          if l.value.type == r.value.type {
            return l.key < r.key
          }
          return l.value.type.rawValue < r.value.type.rawValue
        }).forEach { proxy in
          guard all
                  || ([.selector, .fallback, .urlTest].contains(proxy.value.type))
                  || proxy.value.type.rawValue.caseInsensitiveCompare(type ?? "") == .orderedSame else {
            return
          }
          logProxy(proxy.value, name: proxy.key)
        }
      }

    }
  }

  struct Test: ParsableCommand {

    @Argument
    var name: String

    @Argument
    var timeout: Int

    @Argument
    var url: String

    func run() throws {
      let res = try ClashCli.client.eventLoopFuture(GetProxyDelay(name: name, timeout: timeout, url: url)).wait().body
      print(res)
    }
  }

  struct Select: ParsableCommand {

    @Argument
    var group: String

    @Argument
    var selection: String

    func run() throws {
      let response = try ClashCli.client.eventLoopFutureRaw(ChangeSelection(newSelection: selection, groupName: group)).wait()
      print("status:", response.response.status.code)
    }
  }
}

ClashCli.main()
