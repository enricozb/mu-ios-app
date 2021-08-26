import SwiftUI

struct MiniPlayerPadding: View {
  @EnvironmentObject var nowPlaying: NowPlaying

  var body: some View {
    if let _ = nowPlaying.song {
      Section(header: Color(UIColor.systemBackground)
        .frame(width: .infinity, height: MiniPlayer.MinHeight).padding(0)) {
          EmptyView()
      }
      .listRowInsets(EdgeInsets())
    }
  }
}

struct MiniPlayerNarrowInfo: View {
  static let MinAlbumSize: Double = 50
  static let MaxAlbumSize: Double = 250

  let width: CGFloat
  let song: Song
  let lerp: Double

  var body: some View {
    HStack {
      Cover(album: song.album)
        .frame(width: albumSize, height: albumSize)
        .cornerRadius(albumCornerRadius)
      SongTitleAndAlbum(song: song)
        .opacity(nonCoverOpacity)

      Spacer()
      MiniPlayerButtons()
        .opacity(nonCoverOpacity)
    }
    .padding(.leading, leadingPadding)
    .padding(.trailing, trailingPadding)
  }

  // --- linearly interpolated values ---

  var albumSize: CGFloat { CGFloat(interp(start: MiniPlayerNarrowInfo.MinAlbumSize, end: MiniPlayerNarrowInfo.MaxAlbumSize, t: lerp)) }
  var albumCornerRadius: CGFloat { CGFloat(interp(start: 3, end: 5, t: lerp)) }
  var nonCoverOpacity: Double { 1 - 2 * lerp }
  var leadingPadding: CGFloat { CGFloat(interp(start: 10, end: Double(width - albumSize) / 2, t: lerp)) }
  var trailingPadding: CGFloat { CGFloat(interp(start: 10, end: -250, t: lerp)) }
}

struct MiniPlayer: View {
  static let MinHeight: CGFloat = 70

  let maxWidth: CGFloat
  let maxHeight: CGFloat

  @EnvironmentObject var nowPlaying: NowPlaying

  @State private var height: CGFloat = MiniPlayer.MinHeight
  @State private var maximized = false

  var body: some View {
    if let song = nowPlaying.song {
      VStack(spacing: 0) {
        Spacer()
        Divider()

        VStack {
          MiniPlayerNarrowInfo(width: maxWidth, song: song, lerp: lerp)

          // SongTitleAndAlbum(song: song, alignment: .center)
          //   .frame(maxHeight: 0)
          //   .fixedSize(horizontal: false, vertical: true)
          //   .scaleEffect(CGFloat(lerp))
          //   .opacity(0)
        }
        .frame(maxHeight: height)
        .background(Blur(style: .systemChromeMaterial))

        Divider()
      }
      .padding(.bottom, bottomPadding)
      .gesture(drag)
      .onTapGesture {
        withAnimation {
          self.height = maxHeight
          self.maximized = true
        }
      }
    } else {
      EmptyView()
    }
  }

  var bottomPadding: CGFloat { CGFloat(interp(start: 48, end: 0, t: Double(lerp))) }
  var snapHeight: CGFloat { maximized ? maxHeight : MiniPlayer.MinHeight }
  var lerp: Double { Double(min(maxHeight * 0.8, height - MiniPlayer.MinHeight) / (maxHeight * 0.8)) }

  var drag: some Gesture {
    DragGesture()
      .onChanged { drag in
        if maximized {
          self.height = maxHeight + min(-drag.translation.height, 0)
        } else {
          self.height = MiniPlayer.MinHeight + max(-drag.translation.height, 0)
        }
      }
      .onEnded { drag in
        if drag.translation.height < 0 {
          withAnimation {
            self.height = maxHeight
            self.maximized = true
          }
        } else {
          withAnimation {
            self.height = MiniPlayer.MinHeight
            self.maximized = false
          }
        }
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

struct SongTitleAndAlbum: View {
  let song: Song
  var alignment: HorizontalAlignment = .leading

  var body: some View {
    VStack(alignment: alignment) {
      Text(song.title)
        .lineLimit(1)
      Text("\(song.artist) · \(song.album)")
        .font(.caption)
        .foregroundColor(.gray)
        .lineLimit(1)
    }
  }
}

// linearly interpolates between start and end where t in [0, 1]
func interp(start: Double, end: Double, t: Double) -> Double {
  return start + t * (end - start)
}
