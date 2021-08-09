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
  api.log(msg: msg)
}

func log(_ msg: String, error: Error?) {
  log("\(msg): \(error?.localizedDescription ?? "Unknown error")")
}
