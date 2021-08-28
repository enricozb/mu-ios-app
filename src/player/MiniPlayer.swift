import SwiftUI

struct MiniPlayerPadding: View {
  @EnvironmentObject var player: Player

  var body: some View {
    if let _ = player.song {
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
  static let MaxAlbumSize: Double = 300

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
      MiniPlayerButtonPlayPause().opacity(nonCoverOpacity)
      MiniPlayerButtonNext().opacity(nonCoverOpacity)
    }
    .padding(.leading, leadingPadding)
    .padding(.trailing, trailingPadding)
  }

  // --- interpolated values ---

  var albumSize: CGFloat { CGFloat(interp(start: MiniPlayerNarrowInfo.MinAlbumSize, end: MiniPlayerNarrowInfo.MaxAlbumSize, t: lerp)) }
  var albumCornerRadius: CGFloat { CGFloat(interp(start: 3, end: 5, t: lerp)) }
  var nonCoverOpacity: Double { 1 - 2 * lerp }
  var leadingPadding: CGFloat { CGFloat(interp(start: 10, end: Double(width - albumSize) / 2, t: lerp)) }
  var trailingPadding: CGFloat { CGFloat(interp(start: 10, end: -250, t: lerp)) }
}

struct MiniPlayerWideInfo: View {
  @EnvironmentObject var player: Player

  let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
  @State private var progress: Float = 0.01
  @State private var elapsed: String = ""
  @State private var remaining: String = ""

  let width: CGFloat
  let song: Song
  let lerp: Double

  var body: some View {
    VStack {
      // TODO(enricozb): hydrate these values
      ProgressView(value: progress).onReceive(timer) { _ in
        progress = player.progress ?? 0.01
        if let duration = player.duration, let elapsed = player.elapsed {
          self.elapsed = formatTime(time: Float(elapsed))
          self.remaining = "-" + formatTime(time: Float(elapsed) - duration)
        } else {
          self.elapsed = ""
          self.remaining = ""
        }
      }
      HStack {
        Text(elapsed).font(Font.caption.monospacedDigit())
        Spacer()
        Text(remaining).font(Font.caption.monospacedDigit())
      }
      .padding(.bottom, 10)

      SongTitleAndAlbum(song: song, alignment: .center)

      HStack(spacing: 50) {
        MiniPlayerButtonPrev()
        MiniPlayerButtonPlayPause(size: 32)
        MiniPlayerButtonNext()
      }
      .frame(maxWidth: .infinity)

      VolumeSlider().frame(height: 40)
    }
    .padding(.top, 20)
    // TODO(enricozb): this -500 fixes weird alignment when the miniplayer is minimized, but not sure what the /right/ value is
    .padding(.bottom, CGFloat(interp(start: -500, end: 10, t: lerp)))
    .padding(.leading, progressPadding)
    .padding(.trailing, progressPadding)
    .opacity(2 * lerp - 1)
  }

  var progressPadding: CGFloat { (width - CGFloat(MiniPlayerNarrowInfo.MaxAlbumSize)) / 2 }
}

struct MiniPlayer: View {
  static let MinHeight: CGFloat = 70

  let song: Song
  let maxWidth: CGFloat
  let maxHeight: CGFloat

  // maximized represents whether or not the miniplayer view is maximized
  @State private var maximized = false

  // drag represents the current drag of a gesture in number of pixels. Positive numbers represent dragging downward
  @State private var drag: CGFloat? = nil

  var body: some View {
    VStack(spacing: 0) {
      Spacer()
      Divider()

      VStack(spacing: 0) {
        MiniPlayerNarrowInfo(width: maxWidth, song: song, lerp: lerp)
        MiniPlayerWideInfo(width: maxWidth, song: song, lerp: lerp)
      }
      .frame(maxHeight: height)
      .background(Blur(style: .systemChromeMaterial))
      .mask(Rectangle().frame(height: height, alignment: .bottom))

      Divider()
    }
    .padding(.bottom, bottomPadding)
    .gesture(tapDragGesture)
  }

  var snapHeight: CGFloat { maximized ? maxHeight : MiniPlayer.MinHeight }
  var height: CGFloat { clamped(x: snapHeight - (drag ?? 0), min: MiniPlayer.MinHeight, max: maxHeight) }
  var lerp: Double { Double((height - MiniPlayer.MinHeight) / (maxHeight - MiniPlayer.MinHeight)) }

  var tapDragGesture: some Gesture {
    return SimultaneousGesture(
      DragGesture()
        .onChanged { gesture in self.drag = gesture.translation.height }
        .onEnded { gesture in withAnimation {
          self.maximized = gesture.translation.height < 0
          self.drag = nil
        }},

      TapGesture(count: 1)
        .onEnded { _ in withAnimation {
          self.maximized = true
        }}
    )
  }

  // --- interpolated values ---

  var bottomPadding: CGFloat { CGFloat(interp(start: 48, end: 0, t: Double(lerp))) }
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
