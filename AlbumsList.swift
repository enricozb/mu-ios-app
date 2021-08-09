import SwiftUI

struct Album: Hashable, Identifiable {
  let id: String
  let songs: [Song]
}

struct AlbumsList: View {
  let sections: [String: [Album]]

  init(albums: [String: [Album]]) {
    sections = albums

    UITableView.appearance().showsVerticalScrollIndicator = false
    UITableView.appearance().separatorStyle = .none
  }

  var body: some View {
    ScrollViewReader { proxy in
      ZStack {
        List {
          ForEach(sections.keys.sorted(), id: \.self) { char in
            Section(header: SectionHeader(char: char)) {
              ForEach(sections[char]!.chunked(by: 2), id: \.self) { albums in
                // https://stackoverflow.com/a/62598818/6101419
                AlbumsRow(albums: albums)
                  .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                  .padding(.bottom, 10)
                  .listRowInsets(EdgeInsets())
                  .background(Color(UIColor.systemBackground))
              }
            }
          }
          NowPlayingPadding()
        }

        SlidePicker(letters: sections.keys.sorted(), scroller: proxy)
      }
      .listStyle(PlainListStyle())
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
      ForEach(albums) { album in AlbumCover(album: album) }
    }
    .frame(maxWidth: .infinity)
    .padding(.leading, 15)
    .padding(.trailing, 15)
  }
}

struct AlbumCover: View {
  @State var selected = false
  let album: Album

  var body: some View {
    if album.songs.count == 0 {
      Text("").frame(width: 150)
    } else {
      VStack {
        NavigationLink(
          destination: AlbumDetail(album: album).navigationBarTitleDisplayMode(.inline),
          isActive: $selected
        ) { EmptyView() }
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
