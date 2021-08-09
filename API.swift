import Foundation
import UIKit

struct APIError: LocalizedError {
  let message: String

  var errorDescription: String? {
    return NSLocalizedString("API Error: \(message)", comment: message)
  }
}

struct API {
  typealias SongData = [String: Song]

  let endpoint = URL(string: "http://192.168.2.147:4000")!
  let logEndpoint = URL(string: "http://192.168.2.147:5000")!

  func url(_ path: String, log: Bool = false) -> URL {
    let path = path.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!

    if log {
      return logEndpoint.appendingPathComponent(path)
    } else {
      return endpoint.appendingPathComponent(path)
    }
  }

  func log(msg: String) {
    post(url: url("/", log: true), json: ["msg": msg])
  }

  func cover(album: String, then: @escaping (UIImage?, Error?) -> Void) {
    get(url: url("/songs")) { data, _, error in
      guard error == nil else {
        then(nil, error)
        return
      }

      guard let data = data else {
        then(nil, APIError(message: "no image data returned"))
        return
      }

      guard let image = UIImage(data: data) else {
        then(nil, APIError(message: "invalid image data"))
        return
      }

      then(image, nil)
    }
  }

  func songs(then: @escaping (SongData?, Error?) -> Void) {
    get(url: url("/songs")) { maybeData, _, error in
      guard error == nil else {
        then(nil, error)
        return
      }

      guard let data = maybeData else {
        then(nil, APIError(message: "no song data returned"))
        return
      }

      do {
        then(try JSONDecoder().decode(SongData.self, from: data), nil)
      } catch {
        then(nil, error)
      }
    }
  }

  func post(url: URL, json: Any) {
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    do {
      request.httpBody = try JSONSerialization.data(withJSONObject: json)
    } catch {
      Mu.log("serialize", error: error)
    }

    URLSession.shared.dataTask(with: request).resume()
  }

  func get(url: URL, action: @escaping (Data?, URLResponse?, Error?) -> Void) {
    URLSession.shared.dataTask(with: URLRequest(url: URL(string: "http://192.168.2.147:4000/songs")!),
                               completionHandler: action).resume()
  }
}

let api = API()
