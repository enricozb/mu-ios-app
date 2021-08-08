import SwiftUI

struct Album: Hashable, Identifiable {
  let id: String
  let songs: [Song]
}

struct AlbumsList: View {
  let albums: [Album]
  let sections: [String: [Album]]

  init(albums: [Album]) {
    self.albums = albums
    sections = computeSections(els: albums, key: \.id)
    UITableView.appearance().showsVerticalScrollIndicator = false

    UITableView.appearance().separatorStyle = .none
  }

  var body: some View {
    List {
      ForEach(sections.keys.sorted(), id: \.self) { char in
        Section(header: SectionHeader(char: char)) {
          ForEach(
            sections[char]!
              .sorted(by: { $0.id < $1.id })
              .chunked(by: 2), id: \.self
          ) { albums in
            // https://stackoverflow.com/a/62598818/6101419
            VStack {
              AlbumsRow(albums: albums)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .listRowInsets(EdgeInsets())
            .background(Color(UIColor.systemBackground))
          }
        }
      }
    }
  }
}

struct AlbumsRow: View {
  let albums: [Album]

  init(albums: [Album]) {
    if albums.count % 2 == 0 {
      self.albums = albums
    } else {
      self.albums = albums + [Album(id: "", songs: [Song]())]
    }
  }

  var body: some View {
    HStack(alignment: .center, spacing: 40) {
      ForEach(albums) { album in AlbumView(album: album) }
    }
    .frame(maxWidth: .infinity)
    .padding(10)
  }
}

struct AlbumView: View {
  @State var selected = false
  let album: Album

  var body: some View {
    if album.songs.count == 0 {
      Text("").frame(width: 150)
    } else {
      VStack {
        NavigationLink(destination: Text(album.id), isActive: $selected) { EmptyView() }
          .disabled(!selected)
          .hidden()

        Cover(album: album.id)
          .frame(width: 150, height: 150)
          .background(Color(UIColor.systemGray6))
          .cornerRadius(7)
          .overlay(
            RoundedRectangle(cornerRadius: 7)
              .stroke(Color(UIColor.lightGray), lineWidth: 0.3)
          )

        Text(album.id)
          .frame(width: 150, alignment: .leading)
          .font(.caption)
          .lineLimit(1)
        Text(album.songs.count > 0 ? album.songs[0].artist : "???")
          .frame(width: 150, alignment: .leading)
          .font(.caption)
          .lineLimit(1)
          .foregroundColor(.gray)
      }
      .onTapGesture {
        self.selected = true
        log("touched: \(album.id)")
      }
    }
  }
}
