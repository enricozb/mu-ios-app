import AVFoundation
import SwiftUI

// https://stackoverflow.com/a/58606176/6101419
extension View {
  func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
    clipShape(RoundedCorner(radius: radius, corners: corners))
  }
}

struct RoundedCorner: Shape {
  var radius: CGFloat = .infinity
  var corners: UIRectCorner = .allCorners

  func path(in rect: CGRect) -> Path {
    let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
    return Path(path.cgPath)
  }
}

// https://stackoverflow.com/a/38156873/6101419
extension Array {
  func chunked(by chunkSize: Int) -> [[Element]] {
    return stride(from: 0, to: count, by: chunkSize).map {
      Array(self[$0 ..< Swift.min($0 + chunkSize, self.count)])
    }
  }
}

// https://stackoverflow.com/a/60315146/6101419
struct Blur: UIViewRepresentable {
  var style: UIBlurEffect.Style = .systemMaterial

  func makeUIView(context: Context) -> UIVisualEffectView {
    return UIVisualEffectView(effect: UIBlurEffect(style: style))
  }

  func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
    uiView.effect = UIBlurEffect(style: style)
  }
}

// https://stackoverflow.com/a/48281081/6101419
extension AVPlayer {
  func progressObserver(action: @escaping ((Double) -> Void)) -> Any {
    return addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 1), queue: .main, using: { _ in
      if let item = self.currentItem {
        action(CMTimeGetSeconds(item.currentTime()))
      }
    })
  }
}

// https://stackoverflow.com/a/62044583
func clamped<T>(x: T, min: T, max: T) -> T where T: Comparable{
  if x < min { return min }
  if x > max { return max }
  return x
}
