import SwiftUI

struct MiniPlayerPadding: View {
  @EnvironmentObject var nowPlaying: NowPlaying

  var body: some View {
    if let _ = nowPlaying.song {
      Section(header: Color(UIColor.systemBackground)
        .frame(width: .infinity, height: MiniPlayer.Height).padding(0)) {
          EmptyView()
      }
      .listRowInsets(EdgeInsets())
    }
  }
}

struct MiniPlayer: View {
  static let Height: CGFloat = 70

  @EnvironmentObject var nowPlaying: NowPlaying
  @State private var showingSheet = false
  @State private var height: CGFloat = MiniPlayer.Height
  @State private var lerp: CGFloat = 0

  @State private var albumScale: CGFloat = 1

  var drag: some Gesture {
    DragGesture()
      .onChanged { drag in
        self.height = MiniPlayer.Height + max(drag.startLocation.y - drag.location.y, 0)
        self.lerp = min(450, self.height - MiniPlayer.Height) / 450

        self.albumScale = 1 + 4 * self.lerp
      }
      .onEnded { drag in
        if (drag.startLocation.y - drag.location.y) > 0 {
          withAnimation {
            self.height = 700
            self.lerp = min(450, self.height - MiniPlayer.Height) / 450

            self.albumScale = 1 + 4 * self.lerp
          }
        } else {
          withAnimation {
            self.height = MiniPlayer.Height
            self.lerp = 0

            self.albumScale = 1
          }
        }
      }
  }

  var body: some View {
    if let song = nowPlaying.song {
      VStack(spacing: 0) {
        Spacer()
        Divider()
        HStack {
          HStack {
            Cover(album: song.album)
              .frame(width: 50 * self.albumScale, height: 50 * self.albumScale)
              .cornerRadius(3)
            VStack(alignment: .leading) {
              Text(song.title)
                .lineLimit(1)
              HStack {
                Text("\(song.artist) · \(song.album)")
                  .font(.caption)
                  .foregroundColor(.gray)
                  .lineLimit(1)
              }
            }
            .opacity(Double(1 - self.lerp))
          }
          Spacer()
          MiniPlayerButtons()
            .opacity(Double(1 - self.lerp))
        }
        .frame(height: height)
        .padding(.leading, 10)
        .padding(.trailing, 60 + self.albumScale * -50)
        .background(Blur(style: .systemChromeMaterial))
        Divider()
      }
      .padding(.bottom, 48)
      .gesture(drag)
    } else {
      EmptyView()
    }
  }
}

struct MiniPlayerButtons: View {
  @EnvironmentObject var nowPlaying: NowPlaying

  var body: some View {
    Button(action: { log("prev") }) {
      Image(systemName: "backward.fill")
        .imageScale(.large)
        .padding(.top)
        .padding(.bottom)
        .padding(.leading, 5)
        .padding(.trailing, 5)
    }
    Button(action: { nowPlaying.toggle() }) {
      Image(systemName: nowPlaying.isPlaying ? "pause.fill" : "play.fill")
        .imageScale(.large)
        .padding(.top)
        .padding(.bottom)
        .padding(.leading, 5)
        .padding(.trailing, 5)
    }
    .frame(width: 20)
    Button(action: { nowPlaying.next() }) {
      Image(systemName: "forward.fill")
        .imageScale(.large)
        .padding(.top)
        .padding(.bottom)
        .padding(.leading, 5)
        .padding(.trailing, 5)
    }
  }
}
