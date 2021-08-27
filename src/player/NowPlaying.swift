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
      self.play()
      return .success
    }

    MPRemoteCommandCenter.shared().pauseCommand.addTarget { _ in
      self.pause()
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
      MPNowPlayingInfoPropertyPlaybackRate: 0,
    ]

    CoverImage.cache.get(album: song!.album) { image in
      MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(
        boundsSize: image.size,
        requestHandler: { _ -> UIImage in image }
      )
    }
  }

  func setMPRemoteTimeAndRate() {
    MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(player.currentTime())
    MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
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
    setMPRemoteTimeAndRate()
    isPlaying = true
  }

  func pause() {
    player.pause()
    setMPRemoteTimeAndRate()
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
