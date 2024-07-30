@preconcurrency import AVFoundation
import SwiftUI
import Mastodon

struct VideoPreviewView: View {
  init(url: URL?) {
    self.url = url
  }

  var url: URL?
  var frameDuration: TimeInterval = 1
  var frameAnimation: Animation? = .snappy
  @State var startDate: Date?
  @State var images: [Int: Image] = [:]
  @State var currentIndex: Int = 0

  var body: some View {
    ZStack {
      if let startDate, !images.isEmpty {
        TimelineView(.periodic(from: startDate, by: frameDuration)) { context in
          let secondsElapsed = context.date.timeIntervalSince(startDate)
          let framesElapsed = Int((secondsElapsed / frameDuration).rounded())

          ZStack {
            ForEach(images.map { $0 }, id: \.key) { (index, image) in
              let visible = (index == 0 || (index...index+1).contains(currentIndex))

              image
                .resizable()
                .scaledToFill()
                .id(index)
                .zIndex(Double(index))
                .transition(.opacity)
                .opacity(visible ? 1 : 0)
            }
          }
          .animation(frameAnimation, value: currentIndex)
          .onChange(of: framesElapsed) { _, _ in nextImage() }
        }
        .transition(.opacity)
      }
    }
    .animation(frameAnimation, value: startDate)
    .task(id: url) { await loadImages() }
  }

  @MainActor func loadImages() async {
    startDate = nil
    images = [:]
    currentIndex = 0
    guard let url else { return }
    let asset = AVAsset(url: url)
    guard let duration = try? await asset.load(.duration) else { return }
    let generator = AVAssetImageGenerator(asset: asset)
    generator.appliesPreferredTrackTransform = true
    let startFrame = min(3, duration.seconds)
    let frameStep = max(10, duration.seconds / 5)
    let frames = Array(stride(from: startFrame, to: duration.seconds, by: frameStep))
    let scale = CMTimeScale(NSEC_PER_SEC)
    let indexTime = frames
      .map { CMTime(seconds: $0, preferredTimescale: scale) }
      .filter { (.zero..<duration).contains($0) }
    for (index, time) in indexTime.enumerated() {
      if let cgImage = try? await generator.image(at: time).image {
        images[index] = Image(cgImage: cgImage)
        if startDate == nil {
          startDate = Date()
        }
      }
    }
  }

  func nextImage() {
    currentIndex += 1
    let lastIndex = images.keys.max() ?? 0
    if currentIndex > lastIndex {
      currentIndex = 0
    }
  }
}

private extension Image {
  init(cgImage: CGImage) {
#if os(iOS)
    self = Self(uiImage: UIImage(cgImage: cgImage))
#elseif os(macOS)
    self = Self(nsImage: NSImage(cgImage: cgImage, size: .zero))
#endif
  }
}

#Preview {
  let urlString: String = [Status].preview.first!.reblog!.mediaAttachments.first!.url
  return VideoPreviewView(url: URL(string: urlString))
    .aspectRatio(16/9, contentMode: .fit)
}
