import SwiftUI

class NowPlaying: ObservableObject {
  @Published var song: Song?

  var isPlaying: Bool {
    return song != nil
  }

  func play(song: Song) {
    self.song = song
  }
}

struct NowPlayingPadding: View {
  @EnvironmentObject var nowPlaying: NowPlaying

  var body: some View {
    if nowPlaying.isPlaying {
      Section(header: Color(UIColor.systemBackground)
        .frame(width: .infinity, height: 49).padding(0)) {
          EmptyView()
      }
      .listRowInsets(EdgeInsets())
    }
  }
}

struct MiniPlayer: View {
  @EnvironmentObject var nowPlaying: NowPlaying

  var body: some View {
    if nowPlaying.isPlaying {
      VStack(spacing: 0) {
        Spacer()
        Divider()
        Text("playing something...")
          .frame(maxWidth: .infinity)
          .frame(height: 50)
          .background(Blur(style: .systemChromeMaterial))
        Divider()
      }
      .padding(.bottom, 48)
    } else {
      EmptyView()
    }
  }
}
