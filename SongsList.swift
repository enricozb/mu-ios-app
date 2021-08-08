import SwiftUI

struct Song: Codable, Identifiable, Hashable {
  var id: String
  var album: String
  var artist: String
  var duration: String
  var title: String
  var year: String?
  var track: String?
}

struct SongsList: View {
  @EnvironmentObject var nowPlaying: NowPlaying

  let sections: [String: [Song]]

  var body: some View {
    ScrollViewReader { proxy in
      ZStack {
        List {
          ForEach(sections.keys.sorted(), id: \.self) { char in
            Section(header: SectionHeader(char: char)) {
              ForEach(sections[char]!.sorted(by: { $0.title < $1.title }), id: \.self) { song in
                Button(action: { nowPlaying.play(song: song) }) {
                  SongRow(song: song)
                }
              }
            }
            .id(char)
          }
          NowPlayingPadding()
        }
        .listStyle(PlainListStyle())

        // right-hand side selector
        HStack {
          Spacer()
          VStack(spacing: 2) {
            ForEach(sections.keys.sorted(), id: \.self) { char in
              Button(action: {
                withAnimation {
                  proxy.scrollTo(char, anchor: .top)
                }
              }, label: {
                Text(char)
                  .font(.system(size: 11, weight: .medium, design: .rounded))
              })
            }
          }
        }
      }
    }
  }
}

struct SongRow: View {
  let song: Song

  var body: some View {
    HStack {
      Cover(album: song.album)
        .frame(width: 50, height: 50)
        .cornerRadius(3)
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
}

struct SectionHeader: View {
  let char: String

  var body: some View {
    HStack {
      Text(char)
        .padding(.leading, 5)
        .foregroundColor(.purple)
      Spacer()
    }
    .padding(5)
    .background(Color(UIColor.systemGray6))
    .listRowInsets(EdgeInsets())
  }
}
