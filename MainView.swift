import SwiftUI

struct MainView: View {
  @State var albums = [String: [Album]]()
  @State var songs = [String: [Song]]()

  var body: some View {
    TabView {
      NavigationView {
        SongsList(songs: songs)
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
    .onAppear(perform: load)
    .accentColor(.purple)
  }

  func load() {
    log("loading songs")

    guard let url = URL(string: "http://192.168.2.147:4000/songs") else {
      log("Invalid URL")
      return
    }

    URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
      if let data = data {
        log("received \(data) for song data")
        do {
          let songs = try JSONDecoder().decode([String: Song].self, from: data)
          DispatchQueue.main.async {
            setData(songs: songs)
          }
        } catch {
          log("json error \(error.localizedDescription)")
        }
      } else {
        log("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
      }
    }.resume()
  }

  func setData(songs byID: [String: Song]) {
    var songs = [Song]()
    var albums = [String: [Song]]()

    for (_, song) in byID {
      songs.append(song)
      albums[song.album] = albums[song.album] != nil ? albums[song.album]! + [song] : [song]
    }

    self.albums = computeSections(els: albums.map { title, songs in Album(id: title, songs: songs) }, key: \.id)
    self.songs = computeSections(els: songs, key: \.title)
  }
}
