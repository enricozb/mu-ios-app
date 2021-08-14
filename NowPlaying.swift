import AVFoundation
import MediaPlayer
import SwiftUI

class NowPlaying: ObservableObject {
  private var player = AVPlayer()

  @Published var song: Song?
  @Published var queue = [Song]()

  @Published private(set) var isPlaying: Bool = false

  init() {
    MPRemoteCommandCenter.shared().playCommand.addTarget { _ in
      // setting this because the scrubber goes to 0 on pause for some reason
      let time = CMTimeGetSeconds(self.player.currentTime())
      MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = time
      log("setting time \(time)")

      self.play()

      MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = self.player.rate

      return .success
    }

    MPRemoteCommandCenter.shared().pauseCommand.addTarget { _ in
      self.pause()

      MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = self.player.rate
      // setting this because the scrubber goes to 0 on pause for some reason
      let time = CMTimeGetSeconds(self.player.currentTime())
      MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = time
      log("setting time \(time)")

      return .success
    }

    MPRemoteCommandCenter.shared().nextTrackCommand.addTarget { _ in
      self.next()
      return .success
    }

    // MPRemoteCommandCenter.shared().changePlaybackPositionCommand.addTarget { event in
    //   guard let event = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
    //   self.player.seek(to: CMTime(seconds: event.positionTime, preferredTimescale: CMTimeScale(1000))) { success in
    //     log("seek to: \(event.positionTime)")

    //     DispatchQueue.main.async {
    //       let time = CMTimeGetSeconds(self.player.currentTime())
    //       MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = time
    //       log("seek time to: \(time)")
    //     }

    //     if !success {
    //       log("change playback failed")
    //     }
    //   }

    //   return .success
    // }
  }

  func load(song: Song) {
    cleanupCurrentItem()

    do {
      try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
      try AVAudioSession.sharedInstance().setActive(true)
    } catch {
      log("AVAudioSession.sharedInstance: \(error)")
    }

    player.replaceCurrentItem(with: AVPlayerItem(url: api.url("/songs/\(song.id)")))

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(NowPlaying.didFinishPlaying(_:)),
      name: .AVPlayerItemDidPlayToEndTime,
      object: player.currentItem
    )

    self.song = song
    setupMediaInfo()
    play()
  }

  @objc func didFinishPlaying(_ notification: NSNotification) {
    next()
  }

  func setupMediaInfo() {
    MPNowPlayingInfoCenter.default().nowPlayingInfo = [
      MPMediaItemPropertyTitle: song!.title,
      MPMediaItemPropertyAlbumTitle: song!.album,
      MPMediaItemPropertyArtist: song!.artist,
      MPMediaItemPropertyPlaybackDuration: Float(song!.duration)!,
      MPNowPlayingInfoPropertyPlaybackRate: 1,
    ]

    CoverImage.cache.get(album: song!.album) { image in
      MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(
        boundsSize: image.size,
        requestHandler: { _ -> UIImage in image }
      )
    }
  }

  func clearMediaInfo() {
    MPNowPlayingInfoCenter.default().nowPlayingInfo = [String: Any]()
  }

  func cleanupCurrentItem() {
    NotificationCenter.default.removeObserver(
      self,
      name: .AVPlayerItemDidPlayToEndTime,
      object: player.currentItem
    )
  }

  func play() {
    player.play()
    isPlaying = true
  }

  func pause() {
    player.pause()
    isPlaying = false
  }

  func toggle() {
    if isPlaying {
      pause()
    } else {
      play()
    }
  }

  func next() {
    pause()
    cleanupCurrentItem()

    guard queue.count > 0 else {
      song = nil
      clearMediaInfo()
      return
    }

    load(song: queue.removeFirst())
  }

  func enqueue(songs: ArraySlice<Song>) {
    queue += songs
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
  @State private var showingSheet = false

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
      .onTapGesture {
        showingSheet.toggle()
      }.sheet(isPresented: $showingSheet) {
        NowPlayingDetail()
          .accentColor(.purple)
      }
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
