import SwiftUI

struct SlidePicker: View {
  @State var activeLetter: String?

  let letters: [String]
  let scroller: ScrollViewProxy

  func letterFromGesture(y: CGFloat) -> String {
    // 15 = height per letter
    let pos = Int(y / 15)
    return letters[max(min(pos, letters.count - 1), 0)]
  }

  var body: some View {
    HStack {
      Spacer()
      VStack(spacing: 0) {
        ForEach(letters, id: \.self) { char in
          Letter(letter: char)
        }

        MiniPlayerPadding(inPicker: true)
      }
      .frame(width: 15)
      .background(Color.clear)
      // https://stackoverflow.com/questions/61352171/swiftui-custom-button-does-not-recognize-touch-with-clear-background-and-button      .contentShape(Rectangle())
      .gesture(DragGesture().onChanged { value in
        let letter = letterFromGesture(y: value.location.y)

        if letter != activeLetter {
          activeLetter = letter
          scroller.scrollTo(letter, anchor: .top)
        }
      })
    }
  }
}

struct Letter: View {
  @State var isDragging = false

  let letter: String

  var body: some View {
    Text(letter)
      .font(.system(size: 11, weight: .medium, design: .rounded))
      .foregroundColor(.purple)
      .frame(height: 15)
  }
}
