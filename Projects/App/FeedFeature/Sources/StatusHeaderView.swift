import AppShared
import Kingfisher
import Mastodon
import SwiftUI

struct StatusHeaderView: View {
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
  @ScaledMetric var avatarSize = 32

  var body: some View {
    HStack(alignment: .top) {
      KFImage(avatarURL)
        .placeholder {
          Image(systemName: "person")
            .resizable()
            .scaledToFit()
            .padding(avatarSize / 10)
        }
        .resizable()
        .scaledToFit()
        .background(Color.secondary)
        .clipShape(Circle())
        .aspectRatio(contentMode: .fit)
        .frame(width: avatarSize)

      VStack(alignment: .leading) {
        Text(displayName)
          .foregroundStyle(.primary)
          .font(.callout)

        HStack {
          Text(acct)
            .foregroundStyle(.secondary)
            .font(.caption)

          Spacer()

          Text(date.formatted())
            .foregroundStyle(.secondary)
            .font(.caption)
        }
      }
      .lineLimit(1)
    }
  }
}

#Preview {
  StatusHeaderView([Status].preview.first!)
    .padding()
    .tint(.appTint)
}
