import Foundation
import SwiftUI

struct CoverCache {
  let cache = NSCache<NSString, UIImage>()

  func get(forKey: String) -> UIImage? {
    return cache.object(forKey: NSString(string: forKey))
  }

  func set(forKey: String, image: UIImage) {
    cache.setObject(image, forKey: NSString(string: forKey))
  }
}

private extension CoverCache {
  static let cache = CoverCache()
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
  @Published var image: UIImage?
  let url: String

  init(url: String) {
    self.url = url
    load()
  }

  func load() {
    let task = URLSession.shared.dataTask(with: URL(string: url)!,
                                          completionHandler: handleImage(data:response:error:))
    task.resume()
  }

  func handleImage(data: Data?, response: URLResponse?, error: Error?) {
    guard error == nil else {
      log("handle image: error: \(error!)")
      return
    }
    guard let data = data else {
      log("handle image: no data")
      return
    }

    DispatchQueue.main.async {
      guard let image = UIImage(data: data) else {
        return
      }
      self.image = image
    }
  }
}
