import AVFoundation
import MediaPlayer
import SwiftUI

class NowPlaying: ObservableObject {
  private var player = AVPlayer()

  @Published var song: Song?

  @Published var isPlaying: Bool = false {
    didSet {
      if isPlaying {
        player.play()
      } else {
        player.pause()
      }
    }
  }

  init() {
    let commandCenter = MPRemoteCommandCenter.shared()
    commandCenter.playCommand.addTarget { [unowned self] _ in
      self.play()
      return .success
    }

    commandCenter.pauseCommand.addTarget { [unowned self] _ in
      self.pause()
      return .success
    }
  }

  func load(song: Song) {
    do {
      try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
      try AVAudioSession.sharedInstance().setActive(true)
    } catch {
      log("err: \(error)")
    }

    let urlpart = song.id.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    guard let url = URL(string: "http://192.168.2.147:4000/songs/\(urlpart)") else {
      log("bad url?")
      return
    }

    log("playing \(url)")

    player.replaceCurrentItem(with: AVPlayerItem(url: url))
    self.song = song
    setupMediaInfo()
    play()
  }

  func setupMediaInfo() {
    MPNowPlayingInfoCenter.default().nowPlayingInfo = [
      MPMediaItemPropertyTitle: song!.title,
      MPMediaItemPropertyAlbumTitle: song!.album,
      MPMediaItemPropertyArtist: song!.artist,
    ]

    let urlpart = song!.album.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!

    URLImage.cache.get(url: "http://192.168.2.147:4000/albums/\(urlpart)/cover") { image in
      MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(
        boundsSize: image.size,
        requestHandler: { _ -> UIImage in image }
      )
    }
  }

  func play() {
    isPlaying = true
  }

  func pause() {
    isPlaying = false
  }
}

struct NowPlayingPadding: View {
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

  var body: some View {
    if let song = nowPlaying.song {
      VStack(spacing: 0) {
        Spacer()
        Divider()
        HStack {
          SongRow(song: song)
          Spacer()
          MiniPlayerButtons()
        }
        .frame(height: MiniPlayer.Height)
        .padding(.leading, 10)
        .padding(.trailing, 10)
        .background(Blur(style: .systemChromeMaterial))
        Divider()
      }
      .padding(.bottom, 48)
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
    Button(action: { nowPlaying.isPlaying.toggle() }) {
      Image(systemName: nowPlaying.isPlaying ? "pause.fill" : "play.fill")
        .imageScale(.large)
        .padding(.top)
        .padding(.bottom)
        .padding(.leading, 5)
        .padding(.trailing, 5)
    }
    .frame(width: 20)
    Button(action: { log("next") }) {
      Image(systemName: "forward.fill")
        .imageScale(.large)
        .padding(.top)
        .padding(.bottom)
        .padding(.leading, 5)
        .padding(.trailing, 5)
    }
  }
}
