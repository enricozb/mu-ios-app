import AVFoundation
import MediaPlayer
import SwiftUI

class Player: NSObject, ObservableObject {
  private let player = AVPlayer()
  private var backgroundControls: BackgroundControls?

  // uniquely-addressable values for a unique UnsafeMutableRawPointer
  // https://stackoverflow.com/a/32701309
  private var playerRateContext = "PLAYER_RATE_CONTEXT"
  private var playerItemStatusContext = "PLAYER_ITEM_STATUS_CONTEXT"

  @Published var song: Song?
  @Published var isPlaying: Bool = false

  // waitingToStart is true when a song is loading but has not played yet
  var waitingToStart: Bool = true

  // prev and next are the previous and upcoming songs in the queue
  @Published var prevs: Deque<Song> = []
  @Published var nexts: Deque<Song> = []

  var rate: Float { player.rate }
  var elapsed: Double? { player.currentItem?.currentTime().seconds }
  var duration: Float? { song != nil ? Float(song!.duration) : nil }
  var progress: Float? {
    if let duration = duration, let elapsed = elapsed {
      return Float(elapsed) / duration
    }
    return nil
  }

  override init() {
    super.init()
    backgroundControls = BackgroundControls(player: self)
    player.addObserver(self, forKeyPath: #keyPath(AVPlayer.rate), options: [.old, .new], context: &playerRateContext)
  }

  func playQueue<C>(songs: C) where C: Collection, C.Element == Song {
    prevs.removeAll()
    song = nil
    nexts = Deque(songs)
    next()
  }

  func next() {
    if let song = song { prevs.append(song) }
    if nexts.count > 0 {
      song = nexts.popFirst()
      start()
    }
  }

  func prev() {
    if let song = song { nexts.append(song) }
    if prevs.count > 0 {
      song = prevs.popLast()
      start()
    }
  }

  func start() {
    pause()

    if let song = song {
      waitingToStart = true

      let item = AVPlayerItem(asset: AVAsset(url: song.url()))
      registerListeners(item: item)
      player.replaceCurrentItem(with: item)
      backgroundControls!.setSong(song: song)
    }
  }

  func registerListeners(item: AVPlayerItem) {
    // playerStatusChanged
    item.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: &playerItemStatusContext)
    // didFinishPlaying
    NotificationCenter.default.addObserver(self, selector: #selector(Player.didFinishPlaying(_:)), name: .AVPlayerItemDidPlayToEndTime, object: item)
  }

  func pause() {
    player.pause()
    isPlaying = false
  }

  func play() {
    player.play()
    isPlaying = true
  }

  func toggle() {
    if isPlaying {
      player.pause()
    } else {
      player.play()
    }
  }

  func didChangePlayerItemStatus() {
    if player.status == .readyToPlay, waitingToStart {
      player.play()
      isPlaying = true
      waitingToStart = false
    }
  }

  func didChangePlayerRate() {
    isPlaying = player.rate != 0
    backgroundControls!.didChangePlayerRate()
  }

  @objc func didFinishPlaying(_ notification: NSNotification) {
    next()
  }

  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
    switch context {
    case &playerRateContext:
      didChangePlayerRate()
    case &playerItemStatusContext:
      didChangePlayerItemStatus()
    default:
      super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
  }
}
