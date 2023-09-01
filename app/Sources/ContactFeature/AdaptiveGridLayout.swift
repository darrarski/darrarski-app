import SwiftUI

/// Grid layout that presents elements adaptively to their size.
///
/// ```
/// +-------+----------+
/// |  AAA  |  BBBBBB  |
/// +-------+--+-------+
/// |  CCCCCC  |  DDD  |
/// +----------+-------+
/// |        EE        |
/// +------------------+
/// ```
///
public struct AdaptiveGridLayout: Layout {
  public struct Cache: Equatable {
    struct Element: Equatable {
      var size: CGSize
      var frame: CGRect
    }

    var elements: [Element]
    var size: CGSize
  }

  /// Creates an instance with optionally provided parameters
  ///
  /// - Parameters:
  ///   - spacing: Spacing between elements, where `width` defines horizonal and `height` vertical spacing. Defaults to `.zero` (no spacing between elements).
  ///   - fillWidth: Fill container horizontally by stretching out elements if needed. Defaults to `true`.
  public init(
    spacing: CGSize = .zero,
    fillWidth: Bool = true
  ) {
    self.spacing = spacing
    self.fillWidth = fillWidth
  }

  var spacing: CGSize
  var fillWidth: Bool

  public func makeCache(subviews: Subviews) -> Cache {
    makeCache(elementsSizes: subviews.map { $0.sizeThatFits(.unspecified) })
  }

  public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache)
  -> CGSize
  {
    let size = proposal.replacingUnspecifiedDimensions()
    layoutElements(for: size.width, cache: &cache)
    return cache.size
  }

  public func placeSubviews(
    in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache
  ) {
    subviewsPlacements(in: bounds, cache: cache).enumerated().forEach {
      subviews[$0].place(at: $1.at, anchor: $1.anchor, proposal: $1.proposal)
    }
  }

  // MARK: - Internals

  struct SubviewPlacement: Equatable {
    var at: CGPoint
    var anchor: UnitPoint
    var proposal: ProposedViewSize
  }

  func makeCache(elementsSizes: [CGSize]) -> Cache {
    Cache(
      elements: elementsSizes.map { size in
        Cache.Element(size: size, frame: .zero)
      },
      size: .zero
    )
  }

  func layoutElements(for width: CGFloat, cache: inout Cache) {
    guard !cache.elements.isEmpty else {
      cache.size = CGSize(width: width, height: .zero)
      return
    }
    var origin: CGPoint = .zero
    for index in cache.elements.indices {
      let spaceLeft = width - origin.x
      if index > cache.elements.startIndex,
         spaceLeft < cache.elements[index].size.width
      {
        origin.x = 0
        origin.y =
        cache.elements.enumerated()
          .filter { $0.offset < index }
          .map(\.element.frame.maxY)
          .max() ?? .zero
        origin.y += spacing.height
      }
      cache.elements[index].frame = CGRect(
        origin: origin,
        size: cache.elements[index].size
      )
      origin.x += cache.elements[index].frame.width + spacing.width
    }
    var rows: [CGFloat: [Int]] = [:]
    for index in cache.elements.indices {
      rows[cache.elements[index].frame.origin.y, default: []].append(index)
    }
    for rowIndices in rows.map(\.value) {
      let rowHeight = rowIndices.map { cache.elements[$0].frame.height }.max()!
      let extraWidthPerElement: CGFloat
      if fillWidth {
        let rowWidth = rowIndices.map { cache.elements[$0].frame.maxX }.max()!
        let rowWidthLeft = width - rowWidth
        extraWidthPerElement = rowWidthLeft / CGFloat(rowIndices.count)
      } else {
        extraWidthPerElement = 0
      }
      for (offset, index) in rowIndices.enumerated() {
        if extraWidthPerElement > 0 {
          cache.elements[index].frame.size.width += extraWidthPerElement
          cache.elements[index].frame.origin.x += extraWidthPerElement * CGFloat(offset)
        }
        cache.elements[index].frame.size.height = rowHeight
      }
    }
    cache.size = CGSize(
      width: width,
      height: cache.elements.map(\.frame.maxY).max() ?? .zero
    )
  }

  func subviewsPlacements(in bounds: CGRect, cache: Cache) -> [SubviewPlacement] {
    cache.elements.map { element in
      SubviewPlacement(
        at: CGPoint(
          x: element.frame.origin.x + bounds.minX,
          y: element.frame.origin.y + bounds.minY
        ),
        anchor: .topLeading,
        proposal: ProposedViewSize(element.frame.size)
      )
    }
  }
}
