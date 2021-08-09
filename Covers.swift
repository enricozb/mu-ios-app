import Foundation
import SwiftUI

struct Cover: View {
  @ObservedObject var image: CoverImage
  static var defaultImage = UIImage()

  init(album: String) {
    image = CoverImage(album: album)
  }

  var body: some View {
    Image(uiImage: image.image ?? Cover.defaultImage)
      .resizable()
      .scaledToFit()
  }
}

class CoverImage: ObservableObject {
  static var cache = CoverImageCache()

  @Published var image: UIImage?

  init(album: String) {
    CoverImage.cache.get(album: album) { image in
      self.image = image
    }
  }
}

class CoverImageCache {
  let cache = NSCache<NSString, UIImage>()
  let mutex = DispatchQueue(label: "CoverImageCache")

  var callbacks = [String: [(UIImage) -> Void]]()

  func get(album: String, callback: @escaping (UIImage) -> Void) {
    mutex.sync {
      if let image = cache.object(forKey: NSString(string: album)) {
        callback(image)
        return
      }

      if callbacks[album] != nil {
        callbacks[album] = callbacks[album]! + [callback]
        return
      }

      callbacks[album] = [callback]

      load(album: album)
    }
  }

  func load(album: String) {
    api.cover(album: album) { image, error in
      if let error = error {
        log("api.cover", error: error)
        return
      }

      DispatchQueue.main.async {
        self.publish(album: album, image: image!)
      }
    }
  }

  func publish(album: String, image: UIImage) {
    mutex.sync {
      cache.setObject(image, forKey: NSString(string: album))
      guard let albumCallbacks = callbacks[album] else { return }

      for callback in albumCallbacks {
        callback(image)
      }

      callbacks.removeValue(forKey: album)
    }
  }
}
