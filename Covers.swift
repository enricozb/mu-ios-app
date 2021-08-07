import Foundation
import SwiftUI

class URLImageCache {
  let cache = NSCache<NSString, UIImage>()
  let mutex = DispatchQueue(label: "URLImageCache")

  var callbacks = [String: [(UIImage) -> Void]]()

  func get(url: String, callback: @escaping (UIImage) -> Void) {
    mutex.sync {
      if let image = cache.object(forKey: NSString(string: url)) {
        callback(image)
        return
      }

      if callbacks[url] != nil {
        callbacks[url] = callbacks[url]! + [callback]
        return
      }

      callbacks[url] = [callback]

      URLSession.shared.dataTask(
        with: URL(string: url)!,
        completionHandler: { data, _, error in
          guard error == nil else {
            log("handle image: error: \(error!)")
            return
          }
          guard let data = data else {
            log("handle image: no data")
            return
          }

          DispatchQueue.main.async {
            guard let image = UIImage(data: data) else { return }
            self.publish(url: url, image: image)
          }
        }

      ).resume()
    }
  }

  func publish(url: String, image: UIImage) {
    mutex.sync {
      cache.setObject(image, forKey: NSString(string: url))
      guard let urlCallbacks = callbacks[url] else { return }

      for callback in urlCallbacks {
        callback(image)
      }

      callbacks.removeValue(forKey: url)
    }
  }
}

struct Cover: View {
  @ObservedObject var image: URLImage
  static var defaultImage = UIImage()

  init(album: String) {
    let urlpart = album.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    image = URLImage(url: "http://192.168.2.147:4000/albums/\(urlpart)/cover")
  }

  var body: some View {
    Image(uiImage: image.image ?? Cover.defaultImage)
      .resizable()
      .scaledToFit()
  }
}

class URLImage: ObservableObject {
  static var cache = URLImageCache()

  @Published var image: UIImage?
  let url: String

  init(url: String) {
    self.url = url
    URLImage.cache.get(url: url) { image in
      self.image = image
    }
  }
}
