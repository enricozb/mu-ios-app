import SwiftUI

struct Song: Codable, Identifiable {
  var id: String
  var album: String
  var artist: String
  var duration: String
  var title: String
  var year: String?
  var track: String?
}

struct SongsList: View {
  var songs: [Song]

  var body: some View {
    List(songs) { song in
      SongRow(song: song)
    }
  }
}

struct SongRow: View {
  let song: Song

  var body: some View {
    VStack(alignment: .leading) {
      Text(song.title)
        .lineLimit(1)
      HStack {
        Text("\(song.artist) · \(song.album)")
          .font(.caption)
          .foregroundColor(.gray)
          .lineLimit(1)
      }
    }
  }
}
