import SwiftUI

struct MiniPlayerButton: View {
  var size: CGFloat = 20
  let systemName: String
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Image(systemName: systemName)
        .font(.system(size: size))
        .frame(width: size, height: size)
        .padding(.top)
        .padding(.bottom)
        .padding(.leading, 5)
        .padding(.trailing, 5)
    }
  }
}

struct MiniPlayerButtonPrev: View {
  @EnvironmentObject var player: Player
  var body: some View {
    MiniPlayerButton(systemName: "backward.fill") { log("prev") }
  }
}

struct MiniPlayerButtonPlayPause: View {
  @EnvironmentObject var player: Player

  var size: CGFloat = 20

  var body: some View {
    MiniPlayerButton(size: size, systemName: player.isPlaying ? "pause.fill" : "play.fill") { player.toggle() }
  }
}

struct MiniPlayerButtonNext: View {
  @EnvironmentObject var player: Player
  var body: some View {
    MiniPlayerButton(systemName: "forward.fill") { player.next() }
  }
}
