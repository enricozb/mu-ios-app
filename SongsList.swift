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
  var sections = [String: [Song]]()

  init(songs: [Song]) {
    for song in songs {
      var char = "#"
      if let first = song.title.first, first.isLetter {
        char = first.uppercased()
      }

      sections[char] = sections[char] != nil ? sections[char]! + [song] : [song]
    }

    UITableView.appearance().showsVerticalScrollIndicator = false
  }

  var body: some View {
    ScrollViewReader { proxy in
      ZStack {
        List {
          ForEach(sections.keys.sorted(), id: \.self) { char in
            Section(header: Text(char)) {
              ForEach(sections[char]!, id: \.self) { song in
                SongRow(song: song)
              }
            }
            .id(char)
          }
        }.listStyle(InsetGroupedListStyle())

        // right - hand side selector
        HStack {
          Spacer()
          VStack {
            ForEach(sections.keys.sorted(), id: \.self) { char in
              Button(action: {
                withAnimation {
                  proxy.scrollTo(char, anchor: .top)
                }
              }, label: { Text(char).font(.system(size: 10, weight: .bold, design: .rounded)) })
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
