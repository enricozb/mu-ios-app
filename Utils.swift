import Foundation

func computeSections(els: [String]) -> [String: [String]] {
  computeSections(els: els, key: { s in s })
}

func computeSections<E>(els: [E], key: (E) -> String) -> [String: [E]] {
  var buckets = [String: [E]]()

  for el in els {
    var char = "#"
    if let first = key(el).first, first.isLetter {
      char = first.uppercased()
    }

    buckets[char] = buckets[char] != nil ? buckets[char]! + [el] : [el]
  }

  return buckets
}

func log(_ msg: String) {
  var request = URLRequest(url: URL(string: "http://192.168.2.147:5000/")!)
  request.httpMethod = "POST"
  request.setValue("application/json", forHTTPHeaderField: "Content-Type")

  do {
    request.httpBody = try JSONSerialization.data(withJSONObject: ["msg": msg])
  } catch {
    print(error.localizedDescription)
  }

  URLSession.shared.dataTask(with: request).resume()
}
