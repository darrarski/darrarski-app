import CustomDump
import SwiftUI
import XCTest
@testable import AppShared

final class AdaptiveGridLayoutTests: XCTestCase {
  func testEmpty() throws {
    let layout = AdaptiveGridLayout()
    let proposedSize = CGSize(width: 1337, height: 7331)
    let bounds = CGRect(origin: .zero, size: proposedSize)
    let subviewsSizes: [CGSize] = []
    var cache = layout.makeCache(elementsSizes: subviewsSizes)

    expectNoDifference(
      cache,
      AdaptiveGridLayout.Cache(
        elements: [],
        size: .zero
      )
    )

    layout.layoutElements(for: proposedSize.width, cache: &cache)

    expectNoDifference(
      cache,
      AdaptiveGridLayout.Cache(
        elements: [],
        size: CGSize(
          width: proposedSize.width,
          height: 0
        )
      )
    )

    let placements = layout.subviewsPlacements(in: bounds, cache: cache)

    expectNoDifference(placements, [])
  }

  func testBasicLayout() {
    let layout = AdaptiveGridLayout()
    let proposedSize = CGSize(width: 10, height: 0)
    let bounds = CGRect(origin: .zero, size: proposedSize)
    let subviewsSizes: [CGSize] = [
      CGSize(width: 2, height: 1),
      CGSize(width: 5, height: 1),
      CGSize(width: 3, height: 1),
      CGSize(width: 3, height: 2),
      CGSize(width: 7, height: 2),
      CGSize(width: 10, height: 3),
    ]
    var cache = layout.makeCache(elementsSizes: subviewsSizes)

    expectNoDifference(
      cache,
      AdaptiveGridLayout.Cache(
        elements: subviewsSizes.map { .init(size: $0, frame: .zero) },
        size: .zero
      )
    )

    layout.layoutElements(for: proposedSize.width, cache: &cache)

    expectNoDifference(
      cache.size,
      CGSize(
        width: proposedSize.width,
        height: 6
      ))

    let placements = layout.subviewsPlacements(in: bounds, cache: cache)

    expectNoDifference(
      placements,
      [
        .init(
          at: CGPoint(x: 0, y: 0),
          anchor: .topLeading,
          proposal: ProposedViewSize(subviewsSizes[0])
        ),
        .init(
          at: CGPoint(x: 2, y: 0),
          anchor: .topLeading,
          proposal: ProposedViewSize(subviewsSizes[1])
        ),
        .init(
          at: CGPoint(x: 7, y: 0),
          anchor: .topLeading,
          proposal: ProposedViewSize(subviewsSizes[2])
        ),
        .init(
          at: CGPoint(x: 0, y: 1),
          anchor: .topLeading,
          proposal: ProposedViewSize(subviewsSizes[3])
        ),
        .init(
          at: CGPoint(x: 3, y: 1),
          anchor: .topLeading,
          proposal: ProposedViewSize(subviewsSizes[4])
        ),
        .init(
          at: CGPoint(x: 0, y: 3),
          anchor: .topLeading,
          proposal: ProposedViewSize(subviewsSizes[5])
        ),
      ])
  }

  func testFillWidth() {
    let layout = AdaptiveGridLayout()
    let proposedSize = CGSize(width: 13, height: 0)
    let bounds = CGRect(origin: .zero, size: proposedSize)
    let subviewsSizes: [CGSize] = [
      CGSize(width: 2, height: 1),
      CGSize(width: 5, height: 1),
      CGSize(width: 3, height: 1),
      CGSize(width: 4, height: 2),
    ]
    var cache = layout.makeCache(elementsSizes: subviewsSizes)

    expectNoDifference(
      cache,
      AdaptiveGridLayout.Cache(
        elements: subviewsSizes.map { .init(size: $0, frame: .zero) },
        size: .zero
      )
    )

    layout.layoutElements(for: proposedSize.width, cache: &cache)

    expectNoDifference(
      cache.size,
      CGSize(
        width: proposedSize.width,
        height: 3
      ))

    let placements = layout.subviewsPlacements(in: bounds, cache: cache)

    expectNoDifference(
      placements,
      [
        .init(
          at: CGPoint(x: 0, y: 0),
          anchor: .topLeading,
          proposal: ProposedViewSize(
            CGSize(
              width: 3,
              height: subviewsSizes[0].height
            ))
        ),
        .init(
          at: CGPoint(x: 3, y: 0),
          anchor: .topLeading,
          proposal: ProposedViewSize(
            CGSize(
              width: 6,
              height: subviewsSizes[1].height
            ))
        ),
        .init(
          at: CGPoint(x: 9, y: 0),
          anchor: .topLeading,
          proposal: ProposedViewSize(
            CGSize(
              width: 4,
              height: subviewsSizes[2].height
            ))
        ),
        .init(
          at: CGPoint(x: 0, y: 1),
          anchor: .topLeading,
          proposal: ProposedViewSize(
            CGSize(
              width: 13,
              height: subviewsSizes[3].height
            ))
        ),
      ])
  }

  func testDontFillWidth() {
    let layout = AdaptiveGridLayout(fillWidth: false)
    let proposedSize = CGSize(width: 13, height: 0)
    let bounds = CGRect(origin: .zero, size: proposedSize)
    let subviewsSizes: [CGSize] = [
      CGSize(width: 2, height: 1),
      CGSize(width: 5, height: 1),
      CGSize(width: 3, height: 1),
      CGSize(width: 4, height: 2),
    ]
    var cache = layout.makeCache(elementsSizes: subviewsSizes)

    expectNoDifference(
      cache,
      AdaptiveGridLayout.Cache(
        elements: subviewsSizes.map { .init(size: $0, frame: .zero) },
        size: .zero
      )
    )

    layout.layoutElements(for: proposedSize.width, cache: &cache)

    expectNoDifference(
      cache.size,
      CGSize(
        width: proposedSize.width,
        height: 3
      ))

    let placements = layout.subviewsPlacements(in: bounds, cache: cache)

    expectNoDifference(
      placements,
      [
        .init(
          at: CGPoint(x: 0, y: 0),
          anchor: .topLeading,
          proposal: ProposedViewSize(subviewsSizes[0])
        ),
        .init(
          at: CGPoint(x: 2, y: 0),
          anchor: .topLeading,
          proposal: ProposedViewSize(subviewsSizes[1])
        ),
        .init(
          at: CGPoint(x: 7, y: 0),
          anchor: .topLeading,
          proposal: ProposedViewSize(subviewsSizes[2])
        ),
        .init(
          at: CGPoint(x: 0, y: 1),
          anchor: .topLeading,
          proposal: ProposedViewSize(subviewsSizes[3])
        ),
      ])
  }

  func testEqualHeightOfElementsInRow() {
    let layout = AdaptiveGridLayout()
    let proposedSize = CGSize(width: 10, height: 0)
    let bounds = CGRect(origin: .zero, size: proposedSize)
    let subviewsSizes: [CGSize] = [
      CGSize(width: 2, height: 2),
      CGSize(width: 5, height: 3),
      CGSize(width: 3, height: 1),
      CGSize(width: 3, height: 6),
      CGSize(width: 7, height: 4),
      CGSize(width: 10, height: 5),
    ]
    var cache = layout.makeCache(elementsSizes: subviewsSizes)

    expectNoDifference(
      cache,
      AdaptiveGridLayout.Cache(
        elements: subviewsSizes.map { .init(size: $0, frame: .zero) },
        size: .zero
      )
    )

    layout.layoutElements(for: proposedSize.width, cache: &cache)

    expectNoDifference(
      cache.size,
      CGSize(
        width: proposedSize.width,
        height: 14
      ))

    let placements = layout.subviewsPlacements(in: bounds, cache: cache)

    expectNoDifference(
      placements,
      [
        .init(
          at: CGPoint(x: 0, y: 0),
          anchor: .topLeading,
          proposal: ProposedViewSize(
            CGSize(
              width: subviewsSizes[0].width,
              height: 3
            ))
        ),
        .init(
          at: CGPoint(x: 2, y: 0),
          anchor: .topLeading,
          proposal: ProposedViewSize(
            CGSize(
              width: subviewsSizes[1].width,
              height: 3
            ))
        ),
        .init(
          at: CGPoint(x: 7, y: 0),
          anchor: .topLeading,
          proposal: ProposedViewSize(
            CGSize(
              width: subviewsSizes[2].width,
              height: 3
            ))
        ),
        .init(
          at: CGPoint(x: 0, y: 3),
          anchor: .topLeading,
          proposal: ProposedViewSize(
            CGSize(
              width: subviewsSizes[3].width,
              height: 6
            ))
        ),
        .init(
          at: CGPoint(x: 3, y: 3),
          anchor: .topLeading,
          proposal: ProposedViewSize(
            CGSize(
              width: subviewsSizes[4].width,
              height: 6
            ))
        ),
        .init(
          at: CGPoint(x: 0, y: 9),
          anchor: .topLeading,
          proposal: ProposedViewSize(
            CGSize(
              width: subviewsSizes[5].width,
              height: 5
            ))
        ),
      ])
  }
}
