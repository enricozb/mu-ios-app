import SwiftUI

struct NowPlayingDetail: View {
  @EnvironmentObject var nowPlaying: NowPlaying

  var body: some View {
    VStack(alignment: .leading) {
      Text("Now Playing").font(.title).fontWeight(.bold)
      LargePlayer(song: nowPlaying.song!)
      Text("Up Next")
        .font(.title)
        .fontWeight(.bold)
        .padding(.top)
      Queue()
    }
    .frame(
      minWidth: 0,
      maxWidth: .infinity,
      minHeight: 0,
      maxHeight: .infinity,
      alignment: .topLeading
    )
    .padding([.top, .leading, .trailing])
  }
}

struct Queue: View {
  @EnvironmentObject var nowPlaying: NowPlaying

  var body: some View {
    List(nowPlaying.queue) { song in
      SongRow(song: song)
    }
  }
}

struct LargePlayer: View {
  let song: Song

  var body: some View {
    HStack(alignment: .top, spacing: 10) {
      Cover(album: song.album)
        .frame(width: 150, height: 150)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(7)
        .overlay(
          RoundedRectangle(cornerRadius: 7)
            .stroke(Color(UIColor.lightGray), lineWidth: 0.3)
        )

      VStack(alignment: .leading) {
        Text(song.title)
          .font(.headline)
          .lineLimit(2)
        Button(action: {}) {
          Text(song.artist)
            .font(.subheadline)
        }
        Button(action: {}) {
          Text(song.album)
            .font(.subheadline)
        }

        Spacer()

        // playback / download buttons
        HStack {
          MiniPlayerButtons()
        }
        .frame(maxWidth: .infinity)

        ProgressView(value: 0.5)
      }
      .frame(height: 150)
      Spacer()
    }
  }
}
