import AppIconCreator
import SwiftUI

public struct AppIconView: View {
  public enum Platform {
    case iOS
    case macOS
  }

  public init(_ platform: Platform) {
    self.platform = platform
  }

  var platform: Platform

  public var body: some View {
    GeometryReader { geometry in
      image(iconSize: geometry.size)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(background())
        .if(platform == .iOS) {
          $0.overlay(light(0.25, direction: .topLeading, .bottomTrailing))
            .overlay(light(0.1, direction: .top, .bottom))
            .overlay(light(0.1, direction: .leading, .trailing))
        }
        .if(platform == .macOS) {
          $0.overlay(light(0.15, direction: .top, .bottom))
            .overlay(light(0.15, direction: .leading, .trailing))
            .clipShape(borderShape(iconSize: geometry.size))
            .padding(geometry.size.width * 0.08)
            .shadow(
              color: Color.black.opacity(0.5),
              radius: geometry.size.width * 0.025,
              y: geometry.size.height * -0.01
            )
        }
    }
  }

  func image(iconSize size: CGSize) -> some View {
    Text("DR")
      .foregroundColor(Color.white)
      .font(.custom("Arial Rounded MT Bold", size: 1_000))
      .minimumScaleFactor(0.005)
      .lineLimit(1)
      .shadow(
        color: Color.black.opacity(0.5),
        radius: size.width * 0.025,
        y: size.height * -0.04
      )
      .padding(size.width * 0.1)
      .offset(y: size.width * -0.02)
  }

  @Environment(\.self) var environment

  @ViewBuilder
  func background() -> some View {
    Color(
      .sRGB,
      red: 0.035,
      green: 0.812,
      blue: 0.541
    )
  }

  func light(_ intensity: Double, direction start: UnitPoint, _ end: UnitPoint) -> some View {
    LinearGradient(
      gradient: Gradient(colors: [
        Color.white.opacity(intensity),
        Color.clear,
        Color.clear,
        Color.clear,
        Color.black.opacity(intensity),
      ]),
      startPoint: start,
      endPoint: end
    )
  }

  func borderShape(iconSize size: CGSize) -> some InsettableShape {
    RoundedRectangle(
      cornerRadius: size.width * 0.2,
      style: .continuous
    )
  }
}

#Preview("iOS") {
  IconPreviews(
    icon: AppIconView(.iOS),
    configs: .iOS
  )
}

#Preview("macOS") {
  IconPreviews(
    icon: AppIconView(.macOS),
    configs: .macOS,
    clip: false
  )
}
