import Foundation
import Mastodon

extension Array<Status> {
  /// Source: [@darrarski@mastodon.social statuses](https://mastodon.social/api/v1/accounts/108131495937150285/statuses)
  static let preview: [Status] = {
    let url = Bundle.module.url(forResource: "statuses_preview", withExtension: "json")!
    let data = try! Data(contentsOf: url)
    let decoder = JSONDecoder.mastodon
    return try! decoder.decode([Status].self, from: data)
  }()
}
