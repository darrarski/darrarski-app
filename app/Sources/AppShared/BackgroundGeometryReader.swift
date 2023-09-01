import SwiftUI

/// A container view with a `GeometryReader` added to background. Defines its
/// content as a function of provided `Geometry` value.
public struct BackgroundGeometryReader<Geometry: Codable, Content: View>: View {
  /// Create container
  /// - Parameters:
  ///   - compute: Converts provided `GeometryProxy` to a codable `Geometry` value.
  ///   - content: Returns content view with provided `Geometry` value.
  public init(
    geometry compute: @escaping (GeometryProxy) -> Geometry,
    @ViewBuilder content: @escaping (Geometry?) -> Content
  ) {
    self.compute = compute
    self.content = content
  }

  var content: (Geometry?) -> Content
  var compute: (GeometryProxy) -> Geometry
  @State var geometry: Geometry?

  public var body: some View {
    content(geometry).background {
      GeometryReader { geometryProxy in
        Color.clear.preference(
          key: BackgroundGeometryPreferenceKey.self,
          value: try? JSONEncoder().encode(compute(geometryProxy))
        ).onPreferenceChange(BackgroundGeometryPreferenceKey.self) { data in
          DispatchQueue.main.async {
            self.geometry = try? data.map { try JSONDecoder().decode(Geometry.self, from: $0) }
          }
        }
      }
    }
  }
}

struct BackgroundGeometryPreferenceKey: PreferenceKey {
  static var defaultValue: Data? = nil

  static func reduce(value: inout Data?, nextValue: () -> Data?) {
    value = nextValue()
  }
}
