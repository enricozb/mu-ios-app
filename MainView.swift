import SwiftUI

struct MainView: View {
  @State var songs = [Song]()

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

      Text("Albums")
        .font(.system(size: 30, weight: .bold, design: .rounded))
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
  }

  func load() {
    NSLog("nugget: load")

    guard let url = URL(string: "http://192.168.2.147:4000/songs") else {
      NSLog("nugget: Invalid URL")
      return
    }

    URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
      if let data = data {
        NSLog("nugget: data -> \(data)")
        do {
          let songs = try JSONDecoder().decode([String: Song].self, from: data)
          DispatchQueue.main.async {
            for (_, song) in songs {
              self.songs.append(song)
            }
            self.songs.sort(by: { x, y in x.title < y.title })
          }
        } catch {
          NSLog("nugget: json error \(error.localizedDescription)")
        }
      }

      NSLog("nugget: Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
    }.resume()
  }
}
