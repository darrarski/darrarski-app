import Mastodon
import SwiftUI

struct StatusHeaderView: View {
  struct State: Equatable {
    init(_ status: Status) {
      avatarURL = URL(string: status.account.avatar)
      displayName = status.account.displayName
      acct = status.account.acct
      date = status.createdAt
    }

    var avatarURL: URL?
    var displayName: String
    var acct: String
    var date: Date
  }

  var state: State
  @ScaledMetric var avatarSize = 32

  var body: some View {
    HStack(alignment: .top) {
      AsyncImage(url: state.avatarURL) { image in
        image
          .resizable()
          .scaledToFit()

      } placeholder: {
        Image(systemName: "person")
          .resizable()
          .scaledToFit()
          .padding(avatarSize / 10)
      }
      .background(Color.secondary)
      .clipShape(Circle())
      .aspectRatio(contentMode: .fit)
      .frame(width: avatarSize)

      VStack(alignment: .leading) {
        Text(state.displayName)
          .foregroundStyle(.primary)
          .font(.callout)

        HStack {
          Text(state.acct)
            .foregroundStyle(.secondary)
            .font(.caption)

          Spacer()

          Text(state.date.formatted())
            .foregroundStyle(.secondary)
            .font(.caption)
        }
      }
      .lineLimit(1)
    }
  }
}

#Preview {
  StatusHeaderView(state: StatusHeaderView.State(
    [Status].preview.first!
  ))
  .padding()
}
