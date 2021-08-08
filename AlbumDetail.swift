import SwiftUI

struct AlbumDetail: View {
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
      List(album.songs.sorted(by: albumSongOrder)) { song in
        AlbumSongRow(song: song)
      }
    }
  }
}

struct AlbumSongRow: View {
  let song: Song

  var body: some View {
    HStack {
      Text(song.track ?? "?")
        .foregroundColor(.gray)
        .frame(width: 30)
      Text(song.title)
        .lineLimit(1)
    }
  }
}

func albumSongOrder(song1: Song, song2: Song) -> Bool {
  switch (song1.track, song2.track) {
  case let (.some(p1), .some(p2)): return p1 < p2
  case (.some(_), nil): return true
  case (nil, .some(_)): return false
  case (nil, nil): return song1.title < song2.title
  }
}
