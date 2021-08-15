import SwiftUI

struct AlbumDetail: View {
  @EnvironmentObject var nowPlaying: NowPlaying

  let album: Album

  var body: some View {
    VStack {
      HStack(alignment: .top, spacing: 10) {
        Cover(album: album.id)
          .frame(width: 150, height: 150)
          .background(Color(UIColor.systemGray6))
          .cornerRadius(7)
          .overlay(
            RoundedRectangle(cornerRadius: 7)
              .stroke(Color(UIColor.lightGray), lineWidth: 0.3)
          )
        VStack(alignment: .leading) {
          // album info
          Text(album.id)
            .font(.headline)
            .lineLimit(2)
          Button(action: {}) {
            Text(album.songs[0].artist)
              .font(.subheadline)
          }
          if let year = album.songs[0].year {
            Text(year)
              .foregroundColor(.gray)
              .font(.subheadline)
          }
          Spacer()
          // playback / download buttons
          HStack {
            Button(action: {}) {
              Image(systemName: "shuffle")
            }
          }
        }
        .frame(height: 150)
        Spacer()
      }
      .padding(10)
      List {
        ForEach(album.songs.indices) { i in
          Button(action: {
            nowPlaying.load(song: album.songs[i])
            nowPlaying.enqueue(songs: album.songs[(i + 1)...])
          }) {
            AlbumSongRow(song: album.songs[i])
          }
        }
        MiniPlayerPadding()
      }
    }
  }
}

struct AlbumSongRow: View {
  let song: Song

  var body: some View {
    HStack {
      Text(parseTrack(track: song.track))
        .foregroundColor(.gray)
        .frame(width: 35)
      Text(song.title)
        .lineLimit(1)
    }
  }
}

func parseTrack(track: String?) -> String {
  guard track != nil else { return "?" }
  guard let trackInt = Int(track!) else { return track! }
  return String(trackInt)
}

func albumSongOrder(song1: Song, song2: Song) -> Bool {
  switch (Int(song1.track ?? ""), Int(song2.track ?? "")) {
  case (nil, nil): return song1.title < song2.title
  case (_, nil): return true
  case (nil, _): return false
  case let (.some(track1), .some(track2)): return track1 < track2
  }
}
