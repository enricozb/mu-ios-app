import AVFoundation
import MediaPlayer
import SwiftUI

class Player: ObservableObject, AudioPlayerDelegate {
  private let player = AudioPlayer()
  private var background: BackgroundControls? = nil

  @Published var song: Song?
  @Published var isPlaying: Bool = false

  // prev and next are the previous and upcoming songs in the queue
  @Published var prevs: Deque<Song> = []
  @Published var nexts: Deque<Song> = []

  init() {
    background = BackgroundControls(player: self)
    player.delegate = self
  }

  func playQueue<C>(songs: C) where C: Collection, C.Element == Song {
    player.stop()
    prevs.removeAll()
    song = nil
    nexts = Deque(songs)
    next()
  }

  func next() {
    player.stop()
    if let song = song { prevs.append(song) }
    if nexts.count > 0 { song = nexts.popFirst() }
    play()
  }

  func prev() {
    player.stop()
    if let song = song { nexts.append(song) }
    if prevs.count > 0 { song = prevs.popLast() }
    play()
  }

  func play() {
    do {
      try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
      try AVAudioSession.sharedInstance().setActive(true)
    } catch {
      log("AVAudioSession.sharedInstance: \(error)")
    }

    if let song = song {
      player.play(url: api.url("/songs/\(song.id)"))
    }
  }

  func pause() { player.pause() }
  func resume() { player.resume() }

  func toggle() {
    if player.state == .paused { player.resume() }
    else if player.state == .playing { player.pause() }

    // publish changes to computed vars
    objectWillChange.send()
  }

  var elapsed: Double { player.progress }
  var duration: Double { player.duration }
  var rate: Float { player.rate }

  // ----- AudioPlayerDelegate methods -----

  // Tells the delegate that the player started playing
  func audioPlayerDidStartPlaying(player: AudioPlayer, with entryId: AudioEntryId) {
    // TODO(enricozb): update MPRemotePlayerInfo
    isPlaying = true
    background?.setSong(song: song!)
  }

  // Tells the delegate that the player finished buffering for an entry.
  // - note: May be called multiple times when seek is requested
  func audioPlayerDidFinishBuffering(player: AudioPlayer, with entryId: AudioEntryId) {}

  // Tells the delegate that the state has changed passing both the new state and previous.
  func audioPlayerStateChanged(player: AudioPlayer, with newState: AudioPlayerState, previous: AudioPlayerState) {
    isPlaying = newState == .playing
    background?.refreshState()
  }

  // Tells the delegate that an entry has finished
  func audioPlayerDidFinishPlaying(player: AudioPlayer,
                                   entryId: AudioEntryId,
                                   stopReason: AudioPlayerStopReason,
                                   progress: Double,
                                   duration: Double)
  {
    // TODO(enricozb): enqueue next song
    isPlaying = false
  }

  // Tells the delegate when an unexpected error occured.
  // - note: Probably a good time to recreate the player when this occurs
  func audioPlayerUnexpectedError(player: AudioPlayer, error: AudioPlayerError) {}

  // Tells the delegate when cancel occurs, usually due to a stop or play (new source)
  func audioPlayerDidCancel(player: AudioPlayer, queuedItems: [AudioEntryId]) {}

  // Tells the delegate when a metadata read occurred from the stream.
  func audioPlayerDidReadMetadata(player: AudioPlayer, metadata: [String: String]) {}
}

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
