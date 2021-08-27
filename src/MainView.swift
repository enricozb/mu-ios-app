import SwiftUI

struct MainView: View {
  @StateObject var nowPlaying = NowPlaying()

  @State var albums = [String: [Album]]()
  @State var songs = [String: [Song]]()

  var body: some View {
    TabView {
      NavigationView {
        SongsList(sections: songs)
          .navigationBarTitle("Songs")
      }
      .tabItem {
        Image(systemName: "music.note.list")
        Text("Songs")
      }

      NavigationView {
        AlbumsList(albums: albums)
          .navigationBarTitle("Albums")
      }
      .tabItem {
        Image(systemName: "square.stack")
        Text("Albums")
      }

      Text("Artists")
        .font(.system(size: 30, weight: .bold, design: .rounded))
        .tabItem {
          Image(systemName: "person.fill")
          Text("Artists")
        }
    }
    .overlay(GeometryReader { g in MiniPlayer(maxWidth: g.size.width, maxHeight: g.size.height) })
    .environmentObject(nowPlaying)
    .accentColor(.purple)
    .onAppear {
      api.songs { songs, error in
        log("got song data")

        if let error = error {
          log("api.songs", error: error)
        } else if let songs = songs {
          handleData(songs: songs)
        }
      }
    }
  }

  func handleData(songs byID: API.SongData) {
    var songs = [Song]()
    var albums = [String: [Song]]()

    for (_, song) in byID {
      songs.append(song)
      albums[song.album] = albums[song.album] != nil ? albums[song.album]! + [song] : [song]
    }

    self.albums = computeSections(els: albums.map { title, songs in Album(id: title, songs: songs.sorted(by: albumSongOrder)) }, key: \.id)
    self.songs = computeSections(els: songs, key: \.title)
  }
}
