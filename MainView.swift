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
    .onAppear(perform: load)
    .accentColor(.purple)
    .overlay(MiniPlayer())
    .environmentObject(nowPlaying)
  }

  func load() {
    log("loading songs")

    URLSession.shared.dataTask(with: URLRequest(url: URL(string: "http://192.168.2.147:4000/songs")!)) { data, _, error in
      if let data = data {
        do {
          handleData(songs: try JSONDecoder().decode([String: Song].self, from: data))
        } catch {
          log("json error: \(error.localizedDescription)")
        }
      } else {
        log("no data returned: \(error?.localizedDescription ?? "Unknown error")")
      }
    }.resume()
  }

  func handleData(songs byID: [String: Song]) {
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

struct Blur: UIViewRepresentable {
  var style: UIBlurEffect.Style = .systemMaterial

  func makeUIView(context: Context) -> UIVisualEffectView {
    return UIVisualEffectView(effect: UIBlurEffect(style: style))
  }

  func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
    uiView.effect = UIBlurEffect(style: style)
  }
}
