import Foundation

func computeSections(els: [String]) -> [String: [String]] {
  computeSections(els: els, key: { s in s })
}

func computeSections<E>(els: [E], key: (E) -> String) -> [String: [E]] {
  var sections = [String: [E]]()

  for el in els {
    var char = "#"
    if let first = key(el).first, first.isLetter {
      char = first.uppercased()
    }

    sections[char] = sections[char] != nil ? sections[char]! + [el] : [el]
  }

  for char in sections.keys {
    sections[char]!.sort { key($0).uppercased() < key($1).uppercased() }
  }

  return sections
}

func log(_ msg: String) {
  api.log(msg: msg)
}

func log(_ msg: String, error: Error?) {
  log("\(msg): \(error?.localizedDescription ?? "Unknown error")")
}

// linearly interpolates between start and end where t in [0, 1]
func interp(start: Double, end: Double, t: Double) -> Double {
  return start + t * (end - start)
}
