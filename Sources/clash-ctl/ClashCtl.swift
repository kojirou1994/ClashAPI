import ArgumentParser
import ClashAPI
import Foundation

@main
struct ClashCtl: AsyncParsableCommand {

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
        Reload.self,
    ])
  }
}

extension ClashCtl {

  struct Version: AsyncParsableCommand {
    func run() async throws {
      let version = try await ClashCtl.client.response(GetVersion()).body.get().version
      print(version)
    }
  }

  struct Rule: AsyncParsableCommand {
    func run() async throws {
      let rules = try await ClashCtl.client.response(GetRules()).body.get().rules
      rules.forEach { print($0) }
    }
  }

  struct Connection: AsyncParsableCommand {
    func run() async throws {
      let info = try await ClashCtl.client.response(GetConnections()).body.get()
      info.connections.forEach { print($0) }
      print("total down: \(byteFormatter.string(fromByteCount: numericCast(info.downloadTotal)))")
      print("total up: \(byteFormatter.string(fromByteCount: numericCast(info.uploadTotal)))")
    }
  }

  struct Traffic: ParsableCommand {
    func run() throws {
      _ = try ClashCtl.client.streamSegmented(GetTraffic(), receiveCompletion: { completion in
        print("finished: \(completion)")
        Self.exit()
      }, receiveValue: { result in
        switch result {
        case .success(let traffic):
          print("Download: \(byteFormatter.string(fromByteCount: numericCast(traffic.down)))/s", "Upload: \(byteFormatter.string(fromByteCount: numericCast(traffic.up)))/s")
        case .failure(let error):
          print("Decode error: \(error)")
        }
      })

      dispatchMain()
    }
  }

  struct Kill: AsyncParsableCommand {

    @Argument(help: "connection's UUID or 'all'")
    var id: String

    func run() async throws {
      let req: KillConnection
      if id == "all"{
        req = .all
      } else if let id = UUID(uuidString: id) {
        req = .id(id)
      } else {
        throw ValidationError("invalid UUID: \(id)")
      }
      let response = try await ClashCtl.client.rawResponse(req)
      print("status:", response.response.status.code)
    }
  }

  struct Proxy: AsyncParsableCommand {

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

    func run() async throws {
      if let name = name {
        let res = try await ClashCtl.client.response(GetProxyInfo(name: name)).body.get()
        logProxy(res, name: name)
      } else {
        print("Get all proxies")
        let res = try await ClashCtl.client.response(GetAllProxies()).body.get()
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

  struct Test: AsyncParsableCommand {

    @Argument
    var name: String

    @Argument
    var timeout: Int

    @Argument
    var url: String

    func run() async throws {
      let res = try await ClashCtl.client.response(GetProxyDelay(name: name, timeout: timeout, url: url)).body
      print(res)
    }
  }

  struct Select: AsyncParsableCommand {

    @Argument
    var group: String

    @Argument
    var selection: String

    func run() async throws {
      let response = try await ClashCtl.client.rawResponse(ChangeSelection(newSelection: selection, groupName: group))
      print("status:", response.response.status.code)
    }
  }

  struct Reload: AsyncParsableCommand {

    @Argument
    var path: String

    func run() async throws {
      let endpoint = ReloadConfigs(force: false, body: .init(path: path))
      let response = try await ClashCtl.client.rawResponse(endpoint)
      try endpoint.validate(networking: ClashCtl.client, response: response)
    }
  }
}
