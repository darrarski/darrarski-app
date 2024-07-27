import SwiftUI

public struct FlowLayout: Layout {
  public struct Cache: Equatable {
    var frames: [CGRect]
  }

  public init(spacing: CGFloat = 0) {
    self.spacing = spacing
  }

  var spacing: CGFloat

  public func makeCache(subviews: Subviews) -> Cache {
    Cache(frames: subviews.map {
      let dimensions = $0.dimensions(in: .unspecified)
      return CGRect(
        origin: .zero,
        size: CGSize(
          width: dimensions.width,
          height: dimensions.height
        )
      )
    })
  }

  public func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout Cache
  ) -> CGSize {
    let proposedSize = proposal.replacingUnspecifiedDimensions()
    var rowHeight = CGFloat.zero
    var origin = CGPoint.zero
    for (index, _) in subviews.enumerated() {
      if proposedSize.width > .zero, cache.frames[index].width > proposedSize.width {
        cache.frames[index].size.width = proposedSize.width
      }
      let isFirst = index == subviews.startIndex
      let nextRow = !isFirst && (origin.x + cache.frames[index].width) > proposedSize.width
      if nextRow {
        origin.x = .zero
        origin.y += rowHeight + spacing
        rowHeight = cache.frames[index].height
        cache.frames[index].origin = origin
        origin.x = cache.frames[index].maxX + spacing
      } else {
        cache.frames[index].origin = origin
        origin.x = cache.frames[index].maxX + spacing
        rowHeight = max(rowHeight, cache.frames[index].height)
      }
    }
    return CGSize(
      width: cache.frames.map(\.maxX).max() ?? .zero,
      height: cache.frames.map(\.maxY).max() ?? .zero
    )
  }

  public func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout Cache
  ) {
    for (index, subview) in subviews.enumerated() {
      subview.place(
        at: cache.frames[index].origin
          .applying(.init(
            translationX: bounds.minX,
            y: bounds.minY
          )),
        anchor: .topLeading,
        proposal: ProposedViewSize(
          cache.frames[index].size
        )
      )
    }
  }
}

#Preview {
  FlowLayout(spacing: 10) {
    let tags = [
      "Swift",
      "Objective-C",
      "UIKit",
      "Swift Composable Architecture",
      "SwiftUI",
      "CoreData",
      "AVFoundation",
    ]
    ForEach(tags, id: \.self) { tag in
      Text(tag)
        .padding()
        .border(.red)
    }
  }
  .border(.red)
  .padding()
  .frame(width: 300)
}
