import MediaPlayer

class BackgroundControls {
  let player: Player

  init(player: Player) {
    self.player = player

    MPRemoteCommandCenter.shared().playCommand.addTarget { _ in
      self.player.play()
      return .success
    }

    MPRemoteCommandCenter.shared().pauseCommand.addTarget { _ in
      self.player.pause()
      return .success
    }

    MPRemoteCommandCenter.shared().nextTrackCommand.addTarget { _ in
      self.player.next()
      return .success
    }

    MPRemoteCommandCenter.shared().previousTrackCommand.addTarget { _ in
      self.player.prev()
      return .success
    }
  }

  func setSong(song: Song) {
    MPNowPlayingInfoCenter.default().nowPlayingInfo = [
      MPMediaItemPropertyTitle: song.title,
      MPMediaItemPropertyAlbumTitle: song.album,
      MPMediaItemPropertyArtist: song.artist,
      MPMediaItemPropertyPlaybackDuration: Float(song.duration)!,
      MPNowPlayingInfoPropertyPlaybackRate: 0,
    ]

    CoverImage.cache.get(album: song.album) { image in
      MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(
        boundsSize: image.size,
        requestHandler: { _ -> UIImage in image }
      )
    }
  }

  func didChangePlayerRate() {
    MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.elapsed ?? 0
    MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
  }

  func clear() {
    MPNowPlayingInfoCenter.default().nowPlayingInfo = [String: Any]()
  }
}
